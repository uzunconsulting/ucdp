# UCDP Ueberschreibschutz (PreToolUse: Write | NotebookEdit | Bash)  - neu in v1.5
#
# Blockt das Ueberschreiben einer bestehenden Datei, die NICHT aus Git wiederherstellbar ist
# (kein Repo, oder Datei ungetrackt). Getrackte Dateien duerfen ueberschrieben werden - die
# holt  git checkout  zurueck.
#
# Warum das noetig ist, obwohl Claude Code schon das Ueberschreiben ungelesener Dateien
# verweigert: die Harness prueft KENNTNIS, nicht WIEDERHERSTELLBARKEIT. Lesen-dann-
# Ueberschreiben ist erlaubt und vernichtet ungetrackte Arbeit genauso - und der Bash-Pfad
# (>, Set-Content, cp, mv) wird ueberhaupt nicht geprueft.
#
# Write/NotebookEdit: harte Sperre.  Bash: best-effort (Umleitung >, Set-Content/Out-File,
# cp/mv/Copy-Item/Move-Item). Ein per Shell zusammengebauter Pfad wird nicht erkannt.
#
# Escape: $env:UCDP_ALLOW_OVERWRITE=1 vor dem Start von claude. Fail-open bei jedem Fehler.
$ErrorActionPreference = 'Stop'
try {
  $raw = [Console]::In.ReadToEnd()
  if (-not $raw) { exit 0 }
  $in = $raw | ConvertFrom-Json
} catch { exit 0 }

if ($env:UCDP_ALLOW_OVERWRITE -eq '1') { exit 0 }

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) { $projectDir = [string]$in.cwd }
if (-not $projectDir) { exit 0 }

try { . (Join-Path $PSScriptRoot 'ucdp-lib.ps1') } catch { exit 0 }
try { $cfg = Get-UcdpConfig -ProjectDir $projectDir } catch { $cfg = $null }

function Norm([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { return $null }
  try {
    $p = $p.Trim().Trim('"').Trim("'")
    if (Get-Command ConvertFrom-UcdpPosixPath -ErrorAction SilentlyContinue) { $p = ConvertFrom-UcdpPosixPath $p }
    if (-not [System.IO.Path]::IsPathRooted($p)) { $p = Join-Path $projectDir $p }
    return [System.IO.Path]::GetFullPath($p).TrimEnd('\')
  } catch { return $null }
}

function Deny([string]$path, [string]$why) {
  $reason = @"
UCDP-Ueberschreibschutz: Diese Datei existiert bereits und ist NICHT aus Git wiederherstellbar.
  Ziel  : $path
  Grund : $why

Ein Ueberschreiben waere endgueltig - es gibt keinen  git checkout , der das zurueckholt.

Waehle bewusst einen Weg:
  1. Datei erst LESEN (Read) und gezielt per Edit aendern statt sie komplett zu ersetzen.
  2. Bestand sichern:  git add <datei> && git commit  - danach ist Ueberschreiben gefahrlos.
  3. Inhalt ist wirklich wertlos: Datei explizit loeschen, dann neu schreiben.
Bewusste Ausnahme fuer die ganze Session:  `$env:UCDP_ALLOW_OVERWRITE=1  vor dem Start von claude.
"@
  (@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } } | ConvertTo-Json -Depth 6 -Compress)
  exit 0
}

# --- Zielpfade je nach Werkzeug einsammeln ---------------------------------
$tool    = [string]$in.tool_name
$targets = @()

if ($tool -eq 'Write') {
  $fp = [string]$in.tool_input.file_path
  if ($fp) { $targets += $fp }
}
elseif ($tool -eq 'NotebookEdit') {
  $fp = [string]$in.tool_input.notebook_path
  if ($fp) { $targets += $fp }
}
elseif ($tool -eq 'Bash') {
  $cmd = [string]$in.tool_input.command
  if ($cmd) {
    # Umleitung "> ziel" (nicht ">>", das haengt an und vernichtet nichts)
    foreach ($m in [regex]::Matches($cmd, '(?<![>\d])>(?!>)\s*("[^"]+"|''[^'']+''|[^\s;&|>]+)')) { $targets += $m.Groups[1].Value }
    # PowerShell-Cmdlets mit explizitem Pfad-Parameter
    foreach ($m in [regex]::Matches($cmd, '(?i)\b(?:Set-Content|Out-File|Copy-Item|Move-Item)\b[^;&|]*?\s-(?:Path|LiteralPath|FilePath|Destination)\s+("[^"]+"|''[^'']+''|[^\s;&|]+)')) { $targets += $m.Groups[1].Value }
    # cp/mv: letztes Argument ist das Ziel
    foreach ($m in [regex]::Matches($cmd, '(?im)(?:^|[\s;&|])(?:cp|mv)\s+(?:-[^\s]+\s+)*[^\s;&|]+\s+("[^"]+"|''[^'']+''|[^\s;&|]+)')) { $targets += $m.Groups[1].Value }
  }
}

if ($targets.Count -eq 0) { exit 0 }

# --- Pruefung ---------------------------------------------------------------
foreach ($t in $targets) {
  $abs = Norm $t
  if (-not $abs) { continue }

  # Nur bestehende, nicht-leere Dateien koennen etwas verlieren.
  if (-not (Test-Path -LiteralPath $abs -PathType Leaf)) { continue }
  try { if ((Get-Item -LiteralPath $abs).Length -eq 0) { continue } } catch { continue }

  # Ausserhalb des Projekts ist der Grenzwaechter zustaendig; Temp ist Wegwerf-Bereich.
  $rootFwd = ($projectDir -replace '\\','/').TrimEnd('/') + '/'
  $absFwd  = ($abs -replace '\\','/')
  if (-not $absFwd.StartsWith($rootFwd, [System.StringComparison]::OrdinalIgnoreCase)) { continue }

  # Build-Artefakte, Lockfiles, Werkzeug-Interna: kein schuetzenswerter Inhalt.
  $rel = ConvertTo-UcdpRelPath -Path $abs -ProjectDir $projectDir
  if ($cfg -and (Test-UcdpExcluded -RelPath $rel -Config $cfg)) { continue }

  # Wiederherstellbar aus Git?
  $inRepo = $false
  try {
    $null = & git -C $projectDir rev-parse --git-dir 2>$null
    $inRepo = ($LASTEXITCODE -eq 0)
  } catch { $inRepo = $false }

  if (-not $inRepo) {
    Deny $abs "Der Ordner steht nicht unter Versionskontrolle (kein Git-Repo)."
  }

  $tracked = $false
  try {
    $null = & git -C $projectDir ls-files --error-unmatch -- $rel 2>$null
    $tracked = ($LASTEXITCODE -eq 0)
  } catch { $tracked = $false }

  if (-not $tracked) {
    Deny $abs "Die Datei ist in Git ungetrackt - kein Commit, kein Stash, keine Kopie im Objektspeicher."
  }
}
exit 0
