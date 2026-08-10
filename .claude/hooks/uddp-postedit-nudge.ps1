# UDDP PostToolUse-Nudge (Write|Edit)
# Einmal pro Session: sanfte Doku-Erinnerung nach der ersten Code-Aenderung.
# No-op ausserhalb von UDDP, bei Nicht-Code-Dateien und bei docs/-Dateien. Fail-open.
#
# v1.5: teilt die Code-Klassifikation mit uddp-doc-check.ps1 ueber uddp-lib.ps1.
#       Vorher hatte jeder Hook seine eigene Endungsliste - mit dem Ergebnis, dass
#       eine .json-Aenderung genudged, aber am Session-Ende nicht geprueft wurde.
$ErrorActionPreference = 'Stop'
try {
  $raw = [Console]::In.ReadToEnd()
  $in  = if ($raw) { $raw | ConvertFrom-Json } else { $null }
} catch { exit 0 }
if (-not $in) { exit 0 }

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) { $projectDir = [string]$in.cwd }
if (-not $projectDir) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $projectDir 'docs\05-status.md'))) { exit 0 }

$fp = [string]$in.tool_input.file_path
if (-not $fp) { $fp = [string]$in.tool_input.notebook_path }
if (-not $fp) { exit 0 }

try { . (Join-Path $PSScriptRoot 'uddp-lib.ps1') } catch { exit 0 }
try { $cfg = Get-UddpConfig -ProjectDir $projectDir } catch { exit 0 }

$rel = ConvertTo-UddpRelPath -Path $fp -ProjectDir $projectDir
if (-not (Test-UddpCode -RelPath $rel -Config $cfg)) { exit 0 }

$sid = [string]$in.session_id
if (-not $sid) { $sid = 'nosid' }
$tmp     = [System.IO.Path]::GetTempPath()
$flag    = Join-Path $tmp ("uddp-nudge-$sid.flag")
$flagOld = Join-Path $tmp ("ucdp-nudge-$sid.flag")   # Hook-Satz vor 1.6 parallel aktiv
if ((Test-Path -LiteralPath $flag) -or (Test-Path -LiteralPath $flagOld)) { exit 0 }
try { New-Item -ItemType File -Path $flag -Force -ErrorAction Stop | Out-Null } catch {}

$msg = "UDDP-Erinnerung (einmal pro Session): Du hast Code geaendert. Nach dieser Arbeitseinheit die Doku nachziehen - " +
       "docs/05-status.md (Delta eintragen bzw. erledigtes Delta mit Strikethrough+Datum markieren), last_reviewed bumpen, " +
       "ADR in docs/06-decisions.md bei bewussten Entscheidungen. Der Session-Ende-Check blockiert, wenn Code geaendert wurde, docs/ aber unberuehrt bleibt."
$o = @{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $msg } }
$o | ConvertTo-Json -Depth 6 -Compress
exit 0
