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
| `ucdp-session-start.ps1` | `SessionStart` (auch `compact`/`resume`) | Injiziert Stand-Briefing (Projekt, `last_reviewed` inkl. Stale-Warnung, Branch, uncommittet/ungepusht, letzte 5 Commits) und erzwingt die Leseroutine. Feuert auch nach Kontext-Kompaktierung → Re-Anchoring in langen Sessions. Warnt, wenn die Session **oberhalb** eines UCDP-Projekts gestartet wurde. Dedup pro Session+Source. |
| `ucdp-guard.ps1` | `PreToolUse` (Write/Edit/NotebookEdit + Bash) | Blockt Schreibzugriffe **außerhalb des eigenen Projektordners** (erlaubt sind nur Projekt + Temp + `~/.claude`). Zwingt zu Handoff-Prompts statt Selbst-Editieren im Nachbarprojekt. |
| `ucdp-overwrite-guard.ps1` | `PreToolUse` (Write/NotebookEdit + Bash) | Blockt das Überschreiben bestehender Dateien, die **nicht aus Git wiederherstellbar** sind (ungetrackt oder gar kein Repo). Getrackte Dateien bleiben frei. |
| `ucdp-postedit-nudge.ps1` | `PostToolUse` (Write/Edit) | Einmal pro Session ein sanfter Doku-Hinweis nach der ersten Code-Änderung. |
| `ucdp-doc-check.ps1` | `Stop` | Blockt das Session-Ende **einmal**, wenn Code geändert wurde, aber unter `docs/` nichts aktualisiert ist. |
| `ucdp-lib.ps1` | — | Keine Hook-Datei: gemeinsame Klassifikation (Code / Doku / Rauschen) für Nudge, Ende-Check und Überschreibschutz. |

## Sicherheit / Grenzen

- **Hart & lückenlos** ist die Sperre auf `Write/Edit/NotebookEdit` — so
  editiert eine KI-Session real Dateien.
- **Best-effort** ist der `Bash`-Zweig: er greift bei `cd`/`Set-Location`/
  `pushd` bzw. `git -C` in fremde Pfade in Verbindung mit einer Schreib-/
  Commit-Absicht. Reine Lesezugriffe auf Nachbarprojekte bleiben erlaubt.
- Der Überschreibschutz erkennt auf dem Bash-Pfad die üblichen Formen
  (`> ziel`, `Set-Content`/`Out-File`, `cp`/`mv`), aber keinen im Skript
  zusammengesetzten Pfad. `>>` (anhängen) wird nicht geblockt — es
  vernichtet nichts.

## Überschreibschutz — warum zusätzlich zur Harness

Claude Code verweigert bereits das Überschreiben einer Datei, die in dieser
Session nicht gelesen wurde. Das prüft **Kenntnis**. Der Hook prüft
**Wiederherstellbarkeit** — eine andere Frage, mit drei offenen Fällen:

1. **Lesen, dann überschreiben** ist erlaubt und für ungetrackte Arbeit
   genauso endgültig.
2. **Der Shell-Pfad** (`>`, `Set-Content`, `cp`, `mv`) läuft an der
   Write-Prüfung vorbei.
3. **Andere Werkzeuge** — zweiter Assistent, Skript, Headless-Run — kennen
   die Regel nicht.

Der Hook lässt durch, was Git zurückholen kann, und blockt, was niemand
zurückholen kann. In einem Ordner **ohne** Git ist damit jedes Überschreiben
gesperrt — beabsichtigt, das ist der teuerste Zustand eines Projekts. Nicht
geprüft werden 0-Byte-Dateien, Build-Ordner, Lockfiles und alles außerhalb
des Projektordners.

## Projektspezifische Konfiguration

`ucdp.config.example.json` nach `.claude/ucdp.config.json` kopieren, wenn in
diesem Projekt eine besondere Dateiart die tragende ist (`.tf`, eine
Regel-`.json`, ein Zustandsautomat) oder etwas zu Unrecht als Code zählt. Die
Datei gehört **ins Repo** — sie beschreibt das Projekt, nicht die Maschine.
Ohne sie gelten die Defaults aus `ucdp-lib.ps1`; bei kaputtem JSON ebenfalls.

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
$env:UCDP_UNLOCK          = "1"   # Grenzwächter aus (bewusste Cross-Projekt-Session)
$env:UCDP_ALLOW_OVERWRITE = "1"   # Überschreibschutz aus
$env:UCDP_NODOC           = "1"   # Doku-Ende-Check aus
```

## Adoption in einem bestehenden Repo

1. Diesen Ordner `.claude/hooks/` und die `.claude/settings.json` ins Ziel-Repo
   kopieren (bei bestehender `settings.json`: den `hooks`-Block einmergen).
   `ucdp-lib.ps1` nicht vergessen — ohne sie steigen drei Hooks fail-open aus
   und tun schlicht nichts.
2. Voraussetzung: **PowerShell 7 (`pwsh`)** auf dem Rechner. Die Skripte
   setzen die ExecutionPolicy prozess-lokal auf `Bypass`, laufen also auch bei
   `RemoteSigned`.
3. Beim ersten Öffnen der Session fragt Claude Code, ob die Repo-Hooks
   vertraut werden sollen — bestätigen. Danach greifen sie automatisch.

> Läuft parallel eine **globale** UCDP-Hook-Installation (`~/.claude`), sorgt
> die Session-Dedup dafür, dass das Start-Briefing nicht doppelt erscheint.

## Die Session muss im Projektordner starten

Wird `claude` eine Ebene **oberhalb** des Projekts gestartet, wird bei
repo-lokaler Installation `.claude/settings.json` gar nicht geladen — es
feuert kein einziger Hook, und keiner kann davor warnen. Bei globaler
Installation feuern sie, finden aber kein `docs/05-status.md`: die Doku-Hooks
sind ein No-op, und der Grenzwächter nimmt den Elternordner als erlaubte
Schreib-Wurzel. Für diesen zweiten Fall warnt das Start-Briefing seit v1.5
ausdrücklich, statt still auszusteigen.

Die Regel bleibt: **eine Session pro Projektordner, gestartet im
Projektordner.**

## Verhältnis zu `.githooks/`

Diese Hooks greifen während einer Session. Der optionale Satz unter
[`../../.githooks/`](../../.githooks/) greift beim **Commit** und beim
**Push** — werkzeugunabhängig und auch dann, wenn gar keine Claude-Code-Session
läuft. Beide Sätze sind unabhängig voneinander nutzbar.
