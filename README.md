# UDDP — Uzun Digital Documentation Pattern

Dies ist ein **GitHub-Repository-Template** für AI-assisted-
Software-Projekte. Es liefert eine fertig strukturierte Doku-
Skelett-Ablage, die der UDDP-Konvention folgt.

Die Konvention selbst — Philosophie, Struktur, Disziplin — ist
in [`PATTERN.md`](./PATTERN.md) beschrieben.

Ein vollständig ausgefülltes Beispielprojekt liegt unter
[`examples/newsletter-tool/`](./examples/newsletter-tool/).

## Erste Schritte

1. **Template anziehen.** Klick oben rechts auf „Use this
   template" → „Create a new repository". Wähle einen Namen für
   dein neues Projekt.
2. **Pattern-Reste entfernen.** Was mitkopiert wird, aber zum
   Pattern gehört und nicht zu deinem Projekt:

   ```bash
   rm -rf examples/ PATTERN.md PATTERN-LIZENZ.md
   git add -A && git commit -m "chore: UDDP-Vorlagenreste entfernt"
   ```

   `PATTERN.md` kannst du behalten, wenn du die Konvention im Repo
   nachschlagen willst — dann bleibt auch `PATTERN-LIZENZ.md`
   liegen, sie gehört dazu.
3. **Lizenz festlegen.** Dieses Repo liefert **absichtlich keine**
   `LICENSE` im Wurzelverzeichnis: eine Datei mit diesem Namen
   würde GitHub als Lizenz *deines* Projekts anzeigen. Entscheide
   bewusst:

   - **Proprietär / privat** → gar keine `LICENSE`. Fertig.
   - **Open Source** → deine Lizenz anlegen (MIT, Apache-2.0, …).
     Auf GitHub: *Add file → Create new file → `LICENSE` →
     „Choose a license template"*.

   `PATTERN-LIZENZ.md` betrifft nur das Pattern, nie deinen Code.
4. **Frontmatter befüllen.** In jeder Datei unter `docs/` und in
   `CLAUDE.md` steht oben ein YAML-Block mit Platzhaltern
   (`<projektname>`, `<n>`, `<YYYY-MM-DD>`). Trage deine echten
   Werte ein.
5. **Erste Inhalte schreiben.** Die `## Ziel`-Sektion in
   `01-concept.md` zuerst, dann iterativ die übrigen Topic-
   Dateien (siehe `PATTERN.md` Abschnitt 8 für die empfohlene
   Phasenreihenfolge).
6. **`CLAUDE.md` an dein Projekt anpassen.** Die Vorlage enthält
   Platzhalter für Projektname, Tech-Stack und projekt-
   spezifische Regeln.
7. **Optionales aktivieren oder löschen.** Nichts davon ist
   Voraussetzung für den Rest:

   ```bash
   git config core.hooksPath .githooks   # Git-Hooks scharfschalten (pro Klon)
   ```

   - `.claude/` — Enforcement-Hooks für Claude Code. Andere
     Harness? Ordner löschen, folgenlos.
   - `.githooks/` — Secret-Schutz beim Commit, Doku-Warnung bei
     Commit und Push. Muss pro Klon aktiviert werden (siehe oben).
   - `CHANGELOG.md` — Gerüst. Kein Release nach außen? Löschen.
   - `.claude/uddp.config.example.json` — nach
     `.claude/uddp.config.json` kopieren, wenn in deinem Projekt
     eine besondere Dateiart die tragende ist (z. B. `.tf` oder
     eine Regel-`.json`).

## Was dieses Repo enthält

```
.
├── README.md                ← diese Datei (im Folgeprojekt löschen
│                              und durch eine projektspezifische
│                              ersetzen)
├── PATTERN.md               ← die UDDP-Konvention im Detail
├── PATTERN-LIZENZ.md        ← CC-BY-4.0, gilt für das PATTERN,
│                              nicht für dein Projekt. Bewusst ohne
│                              "LICENSE" im Namen — GitHub würde sie
│                              sonst als Lizenz deines Repos anzeigen
├── CHANGELOG.md             ← optionales Gerüst („was wurde wann
│                              geändert"); Abgrenzung zu docs/ im Kopf
├── CLAUDE.md                ← Session-Disziplin (Quelle, projektspezifisch)
├── AGENTS.md                ← Pointer auf CLAUDE.md (Tool-Konvention)
├── .gitignore               ← Standard für Web-Projekte + .claude-Lokaldateien
├── .gitattributes           ← erzwingt LF für .githooks/ (sonst „bad interpreter")
├── .claude/                 ← optionale Enforcement-Hooks (Claude Code):
│   ├── settings.json          erzwingt die Session-Disziplin maschinell
│   ├── hooks/                 (siehe PATTERN.md §11); löschbar, falls ungenutzt
│   └── uddp.config.example.json  projektspezifische Code-Klassifikation
├── .githooks/               ← optionale Git-Hooks (werkzeugunabhängig):
│   ├── pre-commit             blockt Secrets/.env, warnt bei fehlender Doku
│   └── pre-push               warnt bei Code-Push ohne docs/
├── docs/                    ← Skelett der Projektdokumentation
│   ├── README.md
│   ├── 01-concept.md
│   ├── 02-architecture.md
│   ├── 03-datamodel.md
│   ├── 04-deployment.md
│   ├── 05-status.md
│   ├── 06-decisions.md
│   └── _source/             ← historische Originaldokumente
└── examples/
    └── newsletter-tool/     ← vollständig ausgefülltes Demo
```

`docs/08-agent-runs.md` (Register autonomer Agent-Runs, `PATTERN.md`
§10) wird **nicht** mitgeliefert — sie lohnt sich nur für agentisch
gebaute Projekte. Aufbau und Spaltenschema stehen in §10; die Datei
wird bei Bedarf von Hand angelegt.

## Was dieses Repo nicht enthält

- Keinen Quellcode, keine Build-Konfiguration, keine
  Programmiersprachen-Wahl. UDDP ist eine **Doku-Konvention**,
  kein Tech-Stack-Boilerplate.
- Keine Init-Skripte. Die Ordnerstruktur ist bereits angelegt;
  ein zusätzliches Skript wäre redundant.

## Lizenz

Das **Pattern** steht unter CC-BY-4.0 — frei nutzbar mit
Quellenangabe, siehe [`PATTERN-LIZENZ.md`](./PATTERN-LIZENZ.md).

Für **dein Projekt** gilt sie nicht. Dein Code gehört dir und
trägt die Lizenz, die du dafür wählst — oder gar keine. Deshalb
liegt hier absichtlich keine Datei namens `LICENSE`: GitHub würde
sie als Lizenz deines Repos erkennen und CC-BY auf deine
Geschäftslogik legen.

## Pattern-Versionierung

Aktuelle UDDP-Version: **1.6** (siehe `PATTERN.md` Frontmatter).

v1.6 ist die **Umbenennung** UCDP → UDDP nach der Umfirmierung auf
Uzun Digital. Inhaltlich identisch mit 1.5 — keine neue Regel,
keine Änderung an `docs/`. Hook-Dateien heißen jetzt `uddp-*.ps1`,
die Escapes `UDDP_*`, der Umbrella-Marker `.uddp-workspace`.
**Alle alten Namen bleiben unbefristet gültig**, damit Projekte
einzeln und in beliebiger Reihenfolge migrieren können
(`PATTERN.md` §11, „Namenswechsel und Rückwärtskompatibilität").

v1.5 härtete zuvor die Enforcement-Schicht aus 1.4, angestoßen
durch Befunde aus Folgeprojekten:

- **Überschreibschutz** — bestehende, nicht aus Git
  wiederherstellbare Dateien lassen sich nicht mehr überschreiben.
- **Eine Code-Klassifikation statt zweier**, jetzt inklusive
  Konfiguration-als-Daten (`.json`, `.yml`, `.tf` …), ohne
  Lockfile-Rauschen, projektspezifisch erweiterbar.
- **Doku-Pflicht präzisiert** — nur `docs/` quittiert sie; vorher
  genügte jede beliebige `.md`.
- **Warnung**, wenn die Session eine Ebene zu hoch gestartet wurde.
- **Optionale Git-Hooks** (`.githooks/`) für den Commit-Moment.
- **Lizenz-, `.gitignore`- und `CHANGELOG`-Korrekturen** (siehe oben).

Was ein bestehendes Projekt nachziehen sollte und was optional ist,
steht in `PATTERN.md` §15 unter „Migration von v1.x auf 1.6" — nach
Dringlichkeit sortiert und unabhängig davon, von welcher Version
aus migriert wird. Die `docs/`-Struktur ist unverändert.

v1.4 hatte zuvor die **Enforcement-Hooks** eingeführt
(`.claude/hooks/` + `.claude/settings.json`, `PATTERN.md` §11);
Projekte ohne Hook-fähige Harness löschen `.claude/` folgenlos.
v1.3 die optionale Datei `08-agent-runs.md` für agentisch gebaute
Projekte.

Änderungen am Pattern selbst werden in `PATTERN.md` dokumentiert.
Projekte, die auf einer älteren Version aufgesetzt wurden,
bleiben gültig — eine Pattern-Version-Migration ist nicht
verpflichtend, aber bei größeren Änderungen empfohlen.
