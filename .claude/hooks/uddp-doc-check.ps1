# UDDP Doku-Pflicht-Check (Stop)
# Blockt Session-Ende EINMAL, wenn Code geaendert wurde, aber unter docs/ nichts aktualisiert ist.
# No-op ausserhalb von UDDP; respektiert stop_hook_active (kein Endlos-Loop). Escape: $env:UDDP_NODOC=1. Fail-open.
#
# v1.5: Klassifikation kommt aus uddp-lib.ps1 (eine Liste statt zwei divergierender).
#       Nur Aenderungen unter docs/ quittieren die Doku-Pflicht - in v1.4 genuegte
#       jede beliebige .md irgendwo im Repo.
$ErrorActionPreference = 'Stop'
try {
  $raw = [Console]::In.ReadToEnd()
  $in  = if ($raw) { $raw | ConvertFrom-Json } else { $null }
} catch { exit 0 }

if ($in -and $in.stop_hook_active -eq $true) { exit 0 }   # bereits einmal genudged -> durchlassen
if ($env:UDDP_NODOC -eq '1' -or $env:UCDP_NODOC -eq '1') { exit 0 }   # UCDP_*: Altname vor 1.6, bleibt gueltig

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir -and $in) { $projectDir = [string]$in.cwd }
if (-not $projectDir) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $projectDir 'docs\05-status.md'))) { exit 0 }

try { . (Join-Path $PSScriptRoot 'uddp-lib.ps1') } catch { exit 0 }
try { $cfg = Get-UddpConfig -ProjectDir $projectDir } catch { exit 0 }

try { $porc = & git -C $projectDir status --porcelain 2>$null } catch { exit 0 }
if (-not $porc) { exit 0 }

$codeFiles   = @()
$docsTouched = $false
foreach ($line in @($porc)) {
  if ($line.Length -lt 4) { continue }
  $p = $line.Substring(3).Trim()
  if ($p -match '->') { $p = ($p -split '->')[-1].Trim() }   # Rename: Zielpfad zaehlt
  $p = $p.Trim('"')
  $rel = ConvertTo-UddpRelPath -Path $p -ProjectDir $projectDir
  if (Test-UddpDoc  -RelPath $rel -Config $cfg) { $docsTouched = $true; continue }
  if (Test-UddpCode -RelPath $rel -Config $cfg) { $codeFiles += $rel }
}

if ($codeFiles.Count -gt 0 -and -not $docsTouched) {
  $sample = (@($codeFiles) | Select-Object -First 6) -join ', '
  $reason = "UDDP Doku-Pflicht: In dieser Session wurde Code geaendert ($($codeFiles.Count) Datei(en): $sample), aber unter docs/ nichts aktualisiert. " +
            "NUR Aenderungen unter docs/ quittieren die Doku-Pflicht - eine README oder Notiz ausserhalb docs/ genuegt nicht. " +
            "Vor Session-Ende gemaess CLAUDE.md nachziehen: betroffene Topic-Datei (## Ist) bzw. docs/05-status.md " +
            "(Delta eintragen / erledigtes Delta mit Strikethrough+Datum markieren), last_reviewed bumpen, und bei bewussten " +
            "Entscheidungen einen ADR in docs/06-decisions.md. Wenn hier BEWUSST keine Doku noetig ist (z.B. reiner Versuch/Verworfenes), " +
            "sag das kurz explizit. Zaehlt eine Dateiart in diesem Projekt zu Unrecht als Code (oder fehlt eine), regelt das " +
            ".claude/uddp.config.json. Ausnahme dauerhaft via  `$env:UDDP_NODOC=1 ."
  $o = @{ decision = 'block'; reason = $reason }
  $o | ConvertTo-Json -Depth 6 -Compress
  exit 0
}
exit 0
