# UCDP Projektordner-Grenzwaechter (PreToolUse) - portabel, kein hartkodierter Pfad.
# Erlaubt Schreiben NUR im eigenen Projektordner (+ Temp + ~/.claude + optionalem
# Workspace-Umbrella). Alles andere -> deny.
# Write/Edit/NotebookEdit: harte Sperre. Bash: heuristisch (cd/Set-Location/pushd + git -C in
# fremde Pfade, nur wenn zugleich eine Schreib-/Commit-Absicht erkennbar ist). Reads bleiben erlaubt.
#
# Workspace-Umbrella: Liegt in einem Vorfahren-Ordner eine Datei ".ucdp-workspace", gilt dieser
# Dach-Ordner als gemeinsamer Schreib-Bereich (z.B. mehrere zusammengehoerige Repos unter einem
# Hauptordner). Alle Unterprojekte darunter werden gegenseitig beschreibbar; alles ausserhalb bleibt
# blockiert. Marker beim Dach-Ordner ablegen - NICHT bei einem Wurzelordner wie C:\Projekte (das
# wuerde den Schutz global aushebeln).
#
# Escape: $env:UCDP_UNLOCK=1 vor dem Start von claude. Fail-open bei jedem Fehler.
$ErrorActionPreference = 'Stop'
try {
  $raw = [Console]::In.ReadToEnd()
  if (-not $raw) { exit 0 }
  $in = $raw | ConvertFrom-Json
} catch { exit 0 }

if ($env:UCDP_UNLOCK -eq '1') { exit 0 }

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) { $projectDir = [string]$in.cwd }
if (-not $projectDir) { exit 0 }

# Optional: gemeinsame Bibliothek fuer die Uebersetzung von Git-Bash-Pfaden
# (/c/... -> C:\...). Fehlt sie, arbeitet der Hook wie bisher weiter.
try { . (Join-Path $PSScriptRoot 'ucdp-lib.ps1') } catch {}

function Norm([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { return $null }
  try {
    if (Get-Command ConvertFrom-UcdpPosixPath -ErrorAction SilentlyContinue) { $p = ConvertFrom-UcdpPosixPath $p }
    if (-not [System.IO.Path]::IsPathRooted($p)) { $p = Join-Path $projectDir $p }
    return [System.IO.Path]::GetFullPath($p).TrimEnd('\')
  } catch { return $null }
}
function IsUnder([string]$path, [string]$root) {
  if (-not $path -or -not $root) { return $false }
  $r = $root.TrimEnd('\') + '\'
  $pp = $path.TrimEnd('\') + '\'
  return $pp.StartsWith($r, [System.StringComparison]::OrdinalIgnoreCase)
}

# Erlaubte Schreib-Wurzeln: eigenes Projekt + Temp + ~/.claude
$allow = @()
$allow += (Norm $projectDir)
$allow += (Norm ([System.IO.Path]::GetTempPath()))
if ($env:TEMP) { $allow += (Norm $env:TEMP) }
if ($env:TMP)  { $allow += (Norm $env:TMP) }
$prof = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($HOME) { $HOME } else { $null }
if ($prof) { $allow += (Norm (Join-Path $prof '.claude')) }

# Optionaler Workspace-Umbrella: naechsten .ucdp-workspace-Marker aufwaerts suchen.
$cur = Norm $projectDir
$depth = 0
while ($cur -and $depth -lt 8) {
  if (Test-Path -LiteralPath (Join-Path $cur '.ucdp-workspace')) { $allow += $cur; break }
  $parent = [System.IO.Path]::GetDirectoryName($cur)
  if (-not $parent -or $parent -eq $cur) { break }
  $cur = $parent; $depth++
}

$allow = $allow | Where-Object { $_ } | Select-Object -Unique

function IsOffending([string]$n) {
  if (-not $n) { return $false }
  foreach ($a in $allow) { if (IsUnder $n $a) { return $false } }
  return $true
}

function Deny([string]$path) {
  $reason = @"
UCDP-Grenzwaechter: Schreiben AUSSERHALB des eigenen Projektordners wurde blockiert.
  Ziel : $path
  Aktiv: $projectDir

Regel: Diese Session schreibt nur im eigenen Projektordner (plus Temp/Memory bzw. einem per
.ucdp-workspace markierten Umbrella). Arbeite nicht in einem fremden Projekt.
Ist ein Nachbarprojekt betroffen: erzeuge einen Handoff-Prompt (Uebergabe + konkretes To-do) fuer dessen
EIGENE Claude-Code-Session, statt selbst dort zu schreiben.
Bewusste Ausnahme: Session mit  `$env:UCDP_UNLOCK=1  neu starten.
"@
  (@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } } | ConvertTo-Json -Depth 6 -Compress)
  exit 0
}

$tool = [string]$in.tool_name
$targets = @()

if ($tool -in @('Write','Edit','NotebookEdit')) {
  $fp = [string]$in.tool_input.file_path
  if (-not $fp) { $fp = [string]$in.tool_input.notebook_path }
  if ($fp) { $targets += $fp }
}
elseif ($tool -eq 'Bash') {
  $cmd = [string]$in.tool_input.command
  if ($cmd) {
    $hasWrite = $cmd -match '(?i)(Set-Content|Out-File|Add-Content|New-Item|Remove-Item|Move-Item|Copy-Item|Rename-Item|(^|[\s;&|])(rm|mv|cp|ni)\s|git\s+.*\b(commit|push|add|reset|clean|checkout|switch|restore|init)\b)'
    if ($hasWrite) {
      foreach ($m in [regex]::Matches($cmd, '(?i)(?:Set-Location|pushd|cd)\s+([^\s;&|]+)')) { $targets += $m.Groups[1].Value.Trim('"''') }
      foreach ($m in [regex]::Matches($cmd, '(?i)git\s+-C\s+([^\s;&|]+)')) { $targets += $m.Groups[1].Value.Trim('"''') }
    }
  }
}

if ($targets.Count -eq 0) { exit 0 }
foreach ($t in $targets) {
  $n = Norm $t                      # GetFullPath normalisiert / zu \ selbst
  if (IsOffending $n) { Deny $n }
}
exit 0
