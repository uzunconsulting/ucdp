# UCDP PostToolUse-Nudge (Write|Edit)
# Einmal pro Session: sanfte Doku-Erinnerung nach der ersten Code-Aenderung.
# No-op ausserhalb von UCDP, bei Nicht-Code-Dateien und bei docs/-Dateien. Fail-open.
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

$ext = ([System.IO.Path]::GetExtension($fp)).ToLower()
$codeExts = '.ts','.tsx','.js','.jsx','.mjs','.cjs','.mts','.cts','.py','.sql','.css','.scss','.vue','.svelte','.go','.rs','.rb','.php','.java','.sh','.ps1','.prisma','.astro','.json','.yaml','.yml','.toml','.html'
if ($codeExts -notcontains $ext) { exit 0 }
if (($fp -replace '/','\') -match '(?i)\\docs\\') { exit 0 }

$sid = [string]$in.session_id
if (-not $sid) { $sid = 'nosid' }
$flag = Join-Path ([System.IO.Path]::GetTempPath()) ("ucdp-nudge-$sid.flag")
if (Test-Path -LiteralPath $flag) { exit 0 }
try { New-Item -ItemType File -Path $flag -Force -ErrorAction Stop | Out-Null } catch {}

$msg = "UCDP-Erinnerung (einmal pro Session): Du hast Code geaendert. Nach dieser Arbeitseinheit die Doku nachziehen - " +
       "docs/05-status.md (Delta eintragen bzw. erledigtes Delta mit Strikethrough+Datum markieren), last_reviewed bumpen, " +
       "ADR in docs/06-decisions.md bei bewussten Entscheidungen. Der Session-Ende-Check blockiert, wenn Code geaendert wurde, docs/ aber unberuehrt bleibt."
$o = @{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $msg } }
$o | ConvertTo-Json -Depth 6 -Compress
exit 0
