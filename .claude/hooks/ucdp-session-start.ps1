# UCDP SessionStart-Briefing
# Injiziert aktuellen Projektstand + Leseroutine. Feuert bei startup/resume/clear/compact.
# No-op ausserhalb von UCDP-Projekten (kein docs/05-status.md). Fail-open.
$ErrorActionPreference = 'Stop'
try {
  $raw = [Console]::In.ReadToEnd()
  $in  = if ($raw) { $raw | ConvertFrom-Json } else { $null }
} catch { $in = $null }

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir -and $in) { $projectDir = [string]$in.cwd }
if (-not $projectDir) { exit 0 }

$source = if ($in) { [string]$in.source } else { '' }
$sid    = if ($in) { [string]$in.session_id } else { '' }

$status = Join-Path $projectDir 'docs\05-status.md'
if (-not (Test-Path -LiteralPath $status)) {
  # Kein UCDP-Projekt an dieser Stelle. ABER: liegt eines DARUNTER, ist die Session
  # eine Ebene zu hoch gestartet (v1.5). Folge: Doku-Hooks sind ein No-op und die
  # Grenzwaechter-Wurzel rutscht auf den Elternordner - die Grenze ist faktisch weg.
  # Das laut sagen statt still auszusteigen.
  $found = @()
  try {
    $queue = @($projectDir); $depth = 0; $scanned = 0
    while ($queue.Count -gt 0 -and $depth -lt 2 -and $scanned -lt 200 -and $found.Count -lt 8) {
      $next = @()
      foreach ($d in $queue) {
        foreach ($sub in (Get-ChildItem -LiteralPath $d -Directory -ErrorAction SilentlyContinue)) {
          if ($scanned -ge 200) { break }
          $scanned++
          if ($sub.Name -match '^(\.|node_modules$|dist$|build$|out$|target$|vendor$)') { continue }
          if (Test-Path -LiteralPath (Join-Path $sub.FullName 'docs\05-status.md')) {
            $found += $sub.FullName
          } else {
            $next += $sub.FullName
          }
        }
      }
      $queue = $next; $depth++
    }
  } catch {}
  if ($found.Count -eq 0) { exit 0 }

  if ($sid) {
    $wFlag = Join-Path ([System.IO.Path]::GetTempPath()) ("ucdp-warn-$sid-$source.flag")
    if (Test-Path -LiteralPath $wFlag) { exit 0 }
    try { New-Item -ItemType File -Path $wFlag -Force -ErrorAction Stop | Out-Null } catch {}
  }
  $w  = @()
  $w += "=== UCDP-WARNUNG: Session im FALSCHEN Ordner gestartet. ==="
  $w += "Aktuell: $projectDir  - hier liegt kein docs/05-status.md."
  $w += "UCDP-Projekt(e) unterhalb dieses Ordners:"
  foreach ($f in $found) { $w += "  - $f" }
  $w += ""
  $w += "Folgen in diesem Zustand:"
  $w += "  - Doku-Nudge und Doku-Ende-Check sind ein No-op: die Doku-Pflicht wird NICHT geprueft."
  $w += "  - Das Stand-Briefing (last_reviewed, Deltas, Commits) fehlt."
  $w += "  - Der Grenzwaechter nimmt DIESEN Ordner als erlaubte Schreib-Wurzel - der Schutz vor"
  $w += "    Schreibzugriffen in Nachbarprojekte ist damit praktisch aufgehoben."
  $w += ""
  $w += "Richtig: Session beenden und claude IM Projektordner neu starten."
  $w += "Solange das nicht passiert ist: keine Schreibzugriffe ueber Projektgrenzen hinweg, und die"
  $w += "Leseroutine aus der CLAUDE.md des Zielprojekts von Hand ausfuehren."
  $out = @{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = ($w -join "`n") } }
  $out | ConvertTo-Json -Depth 6 -Compress
  exit 0
}

$proj = Split-Path $projectDir -Leaf

# Dedup pro Session+Source: verhindert doppeltes Briefing, falls globale UND Repo-Hooks aktiv sind.
# Source im Schluessel -> Re-Briefing bei compact/resume bleibt erhalten.
if ($sid) {
  $ssFlag = Join-Path ([System.IO.Path]::GetTempPath()) ("ucdp-ss-$sid-$source.flag")
  if (Test-Path -LiteralPath $ssFlag) { exit 0 }
  try { New-Item -ItemType File -Path $ssFlag -Force -ErrorAction Stop | Out-Null } catch {}
}

# --- last_reviewed aus Frontmatter ---
$lastReviewed = $null
try {
  foreach ($l in (Get-Content -LiteralPath $status -TotalCount 12)) {
    if ($l -match '^\s*last_reviewed\s*:\s*(.+?)\s*$') { $lastReviewed = $Matches[1].Trim(); break }
  }
} catch {}
$today = (Get-Date).ToString('yyyy-MM-dd')
$staleNote = ''
if ($lastReviewed -and $lastReviewed -ne $today) {
  $staleNote = "  <-- heute ist $today; pruefe, ob der Stand noch aktuell ist"
}

# --- git-Schnappschuss ---
function GitCmd { param([string[]]$a) try { (& git -C $projectDir @a 2>$null) } catch { $null } }
$branch = (GitCmd @('rev-parse','--abbrev-ref','HEAD')) | Select-Object -First 1
$porc   = GitCmd @('status','--porcelain')
$dirty  = if ($porc) { @($porc).Count } else { 0 }
$unpushed = (GitCmd @('rev-list','--count','@{u}..HEAD')) | Select-Object -First 1
if (-not $unpushed) { $unpushed = 'n/a' }
$log = GitCmd @('log','--oneline','-5')
$logText = if ($log) { ($log -join "`n") } else { '(kein git-log verfuegbar)' }

$header = if ($source -in @('compact','resume')) {
  "UCDP-Kontext NEU VERANKERN ($source) - lange/fortgesetzte Session: hol dir den AKTUELLEN Stand erneut, bevor du weiterarbeitest."
} else {
  "UCDP-Session gestartet."
}

$lines = @()
$lines += "=== $header ==="
$lines += "Projekt: $proj   ($projectDir)"
$lines += "git: Branch $branch | uncommittet $dirty Datei(en) | ungepusht $unpushed Commit(s)"
if ($lastReviewed) { $lines += "docs/05-status.md last_reviewed: $lastReviewed$staleNote" }
$lines += ""
$lines += "PFLICHT vor der ersten inhaltlichen Aktion - Leseroutine (siehe CLAUDE.md/AGENTS.md):"
$lines += "  1) docs/README.md   2) docs/05-status.md (offene Deltas)   3) docs/01-concept.md"
$lines += "  4) passende Topic-Datei (02-architecture / 03-datamodel / 04-deployment / ...)"
$lines += "  5) docs/06-decisions.md bei Architektur-/Strategiefragen   6) docs/08-agent-runs.md bei agentischen Runs"
$lines += ""
$lines += "Letzte 5 Commits:"
$lines += $logText
$lines += ""
$lines += "GRENZE: Diese Session arbeitet AUSSCHLIESSLICH in '$proj'. Kein Schreiben in andere Projektordner"
$lines += "  unter C:\Projekte. Ist ein Nachbarprojekt mitbetroffen, liefere einen Handoff-Prompt (Uebergabe + To-do),"
$lines += "  den Mustafa in dessen eigener Claude-Code-Session einfuegt - arbeite NICHT selbst dort."
$lines += "DOKU-PFLICHT: Jede Code-Aenderung wird in docs/ nachgezogen (05-status.md Delta, last_reviewed bumpen,"
$lines += "  ADR bei Entscheidungen). Andernfalls blockiert der Session-Ende-Check."
$lines += ""
$lines += "Gib Mustafa zuerst eine 5-Zeilen-Zusammenfassung (Ziel des Projekts, aktueller Stand, offene P1-Deltas aus"
$lines += "05-status.md, was zuletzt passiert ist, Vorschlag fuer heute) und warte dann auf seine konkrete Aufgabe."

$ctx = ($lines -join "`n")
$out = @{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $ctx } }
$out | ConvertTo-Json -Depth 6 -Compress
exit 0
