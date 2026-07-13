# UCDP Doku-Pflicht-Check (Stop)
# Blockt Session-Ende EINMAL, wenn Code geaendert wurde, aber unter docs/ nichts aktualisiert ist.
# No-op ausserhalb von UCDP; respektiert stop_hook_active (kein Endlos-Loop). Escape: $env:UCDP_NODOC=1. Fail-open.
$ErrorActionPreference = 'Stop'
try {
  $raw = [Console]::In.ReadToEnd()
  $in  = if ($raw) { $raw | ConvertFrom-Json } else { $null }
} catch { exit 0 }

if ($in -and $in.stop_hook_active -eq $true) { exit 0 }   # bereits einmal genudged -> durchlassen
if ($env:UCDP_NODOC -eq '1') { exit 0 }

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir -and $in) { $projectDir = [string]$in.cwd }
if (-not $projectDir) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $projectDir 'docs\05-status.md'))) { exit 0 }

try { $porc = & git -C $projectDir status --porcelain 2>$null } catch { exit 0 }
if (-not $porc) { exit 0 }

$codeExts = '.ts','.tsx','.js','.jsx','.mjs','.cjs','.mts','.cts','.py','.sql','.css','.scss','.vue','.svelte','.go','.rs','.rb','.php','.java','.sh','.ps1','.prisma','.astro'
$codeFiles = @()
$docsTouched = $false
foreach ($line in @($porc)) {
  if ($line.Length -lt 4) { continue }
  $p = $line.Substring(3).Trim()
  if ($p -match '->') { $p = ($p -split '->')[-1].Trim() }
  $p = $p.Trim('"')
  $pl = $p -replace '\\','/'
  if ($pl -match '(?i)(^|/)docs/') { $docsTouched = $true; continue }
  if ($pl -match '(?i)\.md$')      { $docsTouched = $true; continue }
  if ($pl -match '(?i)(^|/)(node_modules|\.next|dist|build|out)/') { continue }
  $ext = ([System.IO.Path]::GetExtension($pl)).ToLower()
  if ($codeExts -contains $ext) { $codeFiles += $pl }
}

if ($codeFiles.Count -gt 0 -and -not $docsTouched) {
  $sample = (@($codeFiles) | Select-Object -First 6) -join ', '
  $reason = "UCDP Doku-Pflicht: In dieser Session wurde Code geaendert ($($codeFiles.Count) Datei(en): $sample), aber unter docs/ nichts aktualisiert. " +
            "Vor Session-Ende gemaess CLAUDE.md nachziehen: betroffene Topic-Datei (## Ist) bzw. docs/05-status.md " +
            "(Delta eintragen / erledigtes Delta mit Strikethrough+Datum markieren), last_reviewed bumpen, und bei bewussten " +
            "Entscheidungen einen ADR in docs/06-decisions.md. Wenn hier BEWUSST keine Doku noetig ist (z.B. reiner Versuch/Verworfenes), " +
            "sag das kurz explizit. Ausnahme dauerhaft via  `$env:UCDP_NODOC=1 ."
  $o = @{ decision = 'block'; reason = $reason }
  $o | ConvertTo-Json -Depth 6 -Compress
  exit 0
}
exit 0
