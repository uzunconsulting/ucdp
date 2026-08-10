# UDDP Hook-Bibliothek (gemeinsam genutzt, ab v1.5)
#
# Zweck: Die Klassifikation "was ist Code, was ist Doku, was ist Rauschen" existiert
# GENAU EINMAL. In v1.4 lag sie doppelt (uddp-doc-check.ps1 und uddp-postedit-nudge.ps1)
# und war bereits auseinandergelaufen: der Nudge kannte .json, der Ende-Check nicht.
#
# Projektspezifische Anpassung ueber die optionale, committete Datei
# .claude/uddp.config.json (siehe uddp.config.example.json). Kein Eintrag noetig,
# solange die Defaults passen.
#
# Alle Funktionen sind fail-open: bei kaputter Config gelten die Defaults.

# --- Defaults ---------------------------------------------------------------

$script:UddpCodeExts = @(
  # Web / JS / TS
  '.ts','.tsx','.js','.jsx','.mjs','.cjs','.mts','.cts','.vue','.svelte','.astro','.html'
  # Backend / Systemsprachen
  '.py','.rb','.php','.java','.kt','.kts','.scala','.clj','.go','.rs','.swift','.dart'
  '.ex','.exs','.lua','.zig','.c','.cc','.cpp','.h','.hpp','.cs','.m','.mm','.r','.pl'
  # Shell / Automatisierung
  '.sh','.bash','.zsh','.ps1','.psm1','.bat','.cmd'
  # Daten / Schema / Vertraege
  '.sql','.prisma','.graphql','.gql','.proto','.sol'
  # Styles
  '.css','.scss','.sass','.less'
  # Konfiguration-als-Code (v1.5): steuert in vielen Projekten das Produktverhalten
  '.json','.jsonc','.yml','.yaml','.toml','.ini','.xml','.tf','.tfvars','.hcl','.bicep'
  '.gradle','.cmake','.csproj','.fsproj','.vbproj','.sln'
)

# Dateien ohne Endung, die trotzdem Code sind (Vergleich auf den Dateinamen)
$script:UddpCodeNames = @(
  'Dockerfile','Containerfile','Makefile','CMakeLists.txt','Jenkinsfile','Vagrantfile'
  'Procfile','Justfile','Rakefile','Gemfile','Brewfile','Caddyfile'
)

# Rauschen: aendert sich staendig, hat keinen Doku-Bedarf. Wildcard-Muster (* und ?),
# geprueft gegen den projekt-relativen Pfad mit Forward-Slashes, case-insensitiv.
$script:UddpExcludeGlobs = @(
  # Build- und Abhaengigkeits-Ordner
  '*node_modules/*','*/.next/*','.next/*','*/dist/*','dist/*','*/build/*','build/*'
  '*/out/*','out/*','*/coverage/*','coverage/*','*/target/*','target/*','*/vendor/*'
  '.git/*','*/.venv/*','.venv/*','*/__pycache__/*'
  # Lockfiles: aendern sich bei jedem Install, dokumentieren nichts
  '*package-lock.json','*pnpm-lock.yaml','*yarn.lock','*bun.lockb','*composer.lock'
  '*Cargo.lock','*poetry.lock','*Gemfile.lock','*go.sum','*.lock'
  # Generiertes / Minifiziertes
  '*.min.js','*.min.css','*.generated.*','*.g.dart','*_pb2.py','*.pb.go','*.designer.cs'
  # Werkzeug-Interna (nicht das Projekt)
  '.claude/settings.local.json','.claude/launch.json','.claude/*.local.json'
  '.vscode/*','.idea/*'
  # Fluechtiges: Logs, Caches, OS-Muell. Nie dokumentationspflichtig, nie schuetzenswert.
  '*.log','*.tmp','*.cache','*.DS_Store','*Thumbs.db'
)

# Was als "Doku nachgezogen" zaehlt. Bewusst NUR docs/ (v1.5):
# in v1.4 quittierte jede beliebige .md irgendwo im Repo die Doku-Pflicht.
$script:UddpDocGlobs = @('docs/*','*/docs/*')

# --- Config-Laden -----------------------------------------------------------

function Get-UddpConfig {
  param([string]$ProjectDir)
  $cfg = [ordered]@{
    CodeExts     = @($script:UddpCodeExts)
    CodeNames    = @($script:UddpCodeNames)
    ExcludeGlobs = @($script:UddpExcludeGlobs)
    DocGlobs     = @($script:UddpDocGlobs)
  }
  if (-not $ProjectDir) { return $cfg }
  $path = Join-Path $ProjectDir '.claude\uddp.config.json'
  if (-not (Test-Path -LiteralPath $path)) {
    # Altname vor Pattern-Version 1.6 (Umbenennung UCDP -> UDDP): bleibt unbefristet gueltig.
    $path = Join-Path $ProjectDir '.claude\ucdp.config.json'
  }
  if (-not (Test-Path -LiteralPath $path)) { return $cfg }
  try {
    $j = (Get-Content -LiteralPath $path -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
  } catch { return $cfg }   # kaputte Config -> Defaults, niemals blockieren

  function Norm-Ext([string]$e) {
    if ([string]::IsNullOrWhiteSpace($e)) { return $null }
    $e = $e.Trim().ToLower()
    if (-not $e.StartsWith('.')) { $e = '.' + $e }
    return $e
  }
  if ($j.codeExtsAdd)    { foreach ($e in @($j.codeExtsAdd))    { $n = Norm-Ext $e; if ($n) { $cfg.CodeExts += $n } } }
  if ($j.codeExtsRemove) { foreach ($e in @($j.codeExtsRemove)) { $n = Norm-Ext $e; if ($n) { $cfg.CodeExts = @($cfg.CodeExts | Where-Object { $_ -ne $n }) } } }
  if ($j.codeNamesAdd)   { foreach ($n in @($j.codeNamesAdd))   { if ($n) { $cfg.CodeNames += [string]$n } } }
  if ($j.excludeAdd)     { foreach ($g in @($j.excludeAdd))     { if ($g) { $cfg.ExcludeGlobs += ([string]$g -replace '\\','/' -replace '\*\*/','*') } } }
  if ($j.docPathsAdd)    { foreach ($g in @($j.docPathsAdd))    { if ($g) { $cfg.DocGlobs += ([string]$g -replace '\\','/' -replace '\*\*/','*') } } }
  $cfg.CodeExts = @($cfg.CodeExts | Select-Object -Unique)
  return $cfg
}

# --- Klassifikation ---------------------------------------------------------

function ConvertFrom-UddpPosixPath {
  # Git Bash / MSYS liefern unter Windows Pfade wie /c/Projekte/foo oder
  # /cygdrive/c/Projekte/foo. [System.IO.Path]::GetFullPath() macht daraus
  # C:\c\Projekte\foo - ein Pfad, der aussieht, als laege er in einem fremden
  # Projekt. Ohne diese Uebersetzung blockt der Grenzwaechter den EIGENEN Ordner.
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
  $p = $Path
  if ($p -match '^/cygdrive/([a-zA-Z])(/.*)?$') { return ($Matches[1].ToUpper() + ':' + (($Matches[2] -replace '/','\'))) }
  if ($p -match '^/([a-zA-Z])(/.*)?$')          { return ($Matches[1].ToUpper() + ':' + (($Matches[2] -replace '/','\'))) }
  return $p
}

function ConvertTo-UddpRelPath {
  param([string]$Path, [string]$ProjectDir)
  if (-not $Path) { return $null }
  $p = $Path -replace '\\','/'
  if ($ProjectDir) {
    $root = ($ProjectDir -replace '\\','/').TrimEnd('/') + '/'
    if ($p.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
      $p = $p.Substring($root.Length)
    }
  }
  # NICHT TrimStart('./') verwenden: das nimmt eine Zeichen-MENGE und frisst den
  # fuehrenden Punkt von .claude/, .github/, .gitignore weg. Nur das Praefix "./".
  if ($p.StartsWith('./')) { $p = $p.Substring(2) }
  return $p
}

function Test-UddpGlob {
  param([string]$RelPath, [string[]]$Globs)
  if (-not $RelPath) { return $false }
  foreach ($g in @($Globs)) {
    if (-not $g) { continue }
    if ($RelPath -like $g) { return $true }
  }
  return $false
}

function Test-UddpDoc {
  param([string]$RelPath, $Config)
  return (Test-UddpGlob -RelPath $RelPath -Globs $Config.DocGlobs)
}

function Test-UddpExcluded {
  param([string]$RelPath, $Config)
  return (Test-UddpGlob -RelPath $RelPath -Globs $Config.ExcludeGlobs)
}

function Test-UddpCode {
  param([string]$RelPath, $Config)
  if (-not $RelPath) { return $false }
  if (Test-UddpDoc      -RelPath $RelPath -Config $Config) { return $false }
  if (Test-UddpExcluded -RelPath $RelPath -Config $Config) { return $false }
  $leaf = $RelPath.Split('/')[-1]
  if ($Config.CodeNames -contains $leaf) { return $true }
  $ext = ([System.IO.Path]::GetExtension($leaf)).ToLower()
  if (-not $ext) { return $false }
  return ($Config.CodeExts -contains $ext)
}
