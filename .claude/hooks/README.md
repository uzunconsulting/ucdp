# UCDP Enforcement-Hooks (optional)

Diese Hooks erzwingen die UCDP-Session-Disziplin **maschinell** — nicht als
Bitte in `CLAUDE.md`, die eine KI-Session vergessen oder auslegen kann,
sondern als deterministische Kommandos, die Claude Code (die Harness) an
festen Lebenszyklus-Punkten ausführt. Verdrahtet sind sie in
[`../settings.json`](../settings.json).

Alles ist **fail-open** (jeder unerwartete Fehler → durchlassen, nie den
Workflow brechen) und **self-detecting**: ohne `docs/05-status.md` sind
SessionStart, Nudge und Doc-Check ein No-op. Die Skripte sind **portabel**
(kein hartkodierter Pfad, kein fester Projekt-Wurzelordner) — sie lösen sich
über `$env:CLAUDE_PROJECT_DIR` relativ zum jeweiligen Repo auf.

| Skript | Event | Wirkung |
|---|---|---|
| `ucdp-session-start.ps1` | `SessionStart` (auch `compact`/`resume`) | Injiziert Stand-Briefing (Projekt, `last_reviewed` inkl. Stale-Warnung, Branch, uncommittet/ungepusht, letzte 5 Commits) und erzwingt die Leseroutine. Feuert auch nach Kontext-Kompaktierung → Re-Anchoring in langen Sessions. Dedup pro Session+Source. |
| `ucdp-guard.ps1` | `PreToolUse` (Write/Edit/NotebookEdit + Bash) | Blockt Schreibzugriffe **außerhalb des eigenen Projektordners** (erlaubt sind nur Projekt + Temp + `~/.claude`). Zwingt zu Handoff-Prompts statt Selbst-Editieren im Nachbarprojekt. |
| `ucdp-postedit-nudge.ps1` | `PostToolUse` (Write/Edit) | Einmal pro Session ein sanfter Doku-Hinweis nach der ersten Code-Änderung. |
| `ucdp-doc-check.ps1` | `Stop` | Blockt das Session-Ende **einmal**, wenn Code geändert wurde, aber unter `docs/` nichts aktualisiert ist. |

## Sicherheit / Grenzen

- **Hart & lückenlos** ist die Sperre auf `Write/Edit/NotebookEdit` — so
  editiert eine KI-Session real Dateien.
- **Best-effort** ist der `Bash`-Zweig: er greift bei `cd`/`Set-Location`/
  `pushd` bzw. `git -C` in fremde Pfade in Verbindung mit einer Schreib-/
  Commit-Absicht. Reine Lesezugriffe auf Nachbarprojekte bleiben erlaubt.

## Workspace-Umbrella (`.ucdp-workspace`)

Gehören mehrere Repos zusammen und sollen sich gegenseitig beschreiben dürfen
(z. B. mehrere Sub-Repos unter einem gemeinsamen Hauptordner), lege im Dach-
Ordner eine leere Datei **`.ucdp-workspace`** ab. Der Grenzwächter sucht sie
vom Projektordner aufwärts; wird sie gefunden, gilt der gesamte Dach-Ordner als
ein zusammenhängender Schreib-Bereich — alle Unterprojekte darunter sind
gegenseitig beschreibbar, alles außerhalb bleibt blockiert. Funktioniert egal,
ob die Session im Umbrella oder in einem Sub-Repo startet.

> Den Marker beim **Dach-Ordner** ablegen, nicht bei einem Wurzelordner wie
> `C:\Projekte` — dort würde er den Schutz für alle Projekte aushebeln.

## Escape-Schalter (bewusste Ausnahmen)

Im Terminal **vor** dem Start von `claude` setzen:

```powershell
$env:UCDP_UNLOCK = "1"   # Grenzwächter aus (bewusste Cross-Projekt-Session)
$env:UCDP_NODOC  = "1"   # Doku-Ende-Check aus
```

## Adoption in einem bestehenden Repo

1. Diesen Ordner `.claude/hooks/` und die `.claude/settings.json` ins Ziel-Repo
   kopieren (bei bestehender `settings.json`: den `hooks`-Block einmergen).
2. Voraussetzung: **PowerShell 7 (`pwsh`)** auf dem Rechner. Die Skripte
   setzen die ExecutionPolicy prozess-lokal auf `Bypass`, laufen also auch bei
   `RemoteSigned`.
3. Beim ersten Öffnen der Session fragt Claude Code, ob die Repo-Hooks
   vertraut werden sollen — bestätigen. Danach greifen sie automatisch.

> Läuft parallel eine **globale** UCDP-Hook-Installation (`~/.claude`), sorgt
> die Session-Dedup dafür, dass das Start-Briefing nicht doppelt erscheint.
