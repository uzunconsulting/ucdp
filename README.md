# UCDP — Uzun Consulting Documentation Pattern

Dies ist ein **GitHub-Repository-Template** für AI-assisted-
Software-Projekte. Es liefert eine fertig strukturierte Doku-
Skelett-Ablage, die der UCDP-Konvention folgt.

Die Konvention selbst — Philosophie, Struktur, Disziplin — ist
in [`PATTERN.md`](./PATTERN.md) beschrieben.

Ein vollständig ausgefülltes Beispielprojekt liegt unter
[`examples/newsletter-tool/`](./examples/newsletter-tool/).

## Erste Schritte

1. **Template anziehen.** Klick oben rechts auf „Use this
   template" → „Create a new repository". Wähle einen Namen für
   dein neues Projekt.
2. **`examples/`-Ordner löschen.** Das Demo wird beim
   Template-Klick mitkopiert; im neuen Projekt brauchst du es
   nicht.

   ```bash
   rm -rf examples/
   git add -A && git commit -m "chore: remove ucdp examples"
   ```
3. **Frontmatter befüllen.** In jeder Datei unter `docs/` und in
   `CLAUDE.md` steht oben ein YAML-Block mit Platzhaltern
   (`<projektname>`, `<n>`, `<YYYY-MM-DD>`). Trage deine echten
   Werte ein.
4. **Erste Inhalte schreiben.** Die `## Ziel`-Sektion in
   `01-concept.md` zuerst, dann iterativ die übrigen Topic-
   Dateien (siehe `PATTERN.md` Abschnitt 8 für die empfohlene
   Phasenreihenfolge).
5. **`CLAUDE.md` an dein Projekt anpassen.** Die Vorlage enthält
   Platzhalter für Projektname, Tech-Stack und projekt-
   spezifische Regeln.

## Was dieses Repo enthält

```
.
├── README.md                ← diese Datei (im Folgeprojekt löschen
│                              und durch eine projektspezifische
│                              ersetzen)
├── PATTERN.md               ← die UCDP-Konvention im Detail
├── LICENSE                  ← CC-BY-4.0
├── CLAUDE.md                ← Skelett für Session-Disziplin
├── .gitignore               ← Standard für Web-Projekte
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

## Was dieses Repo nicht enthält

- Keinen Quellcode, keine Build-Konfiguration, keine
  Programmiersprachen-Wahl. UCDP ist eine **Doku-Konvention**,
  kein Tech-Stack-Boilerplate.
- Keine Init-Skripte. Die Ordnerstruktur ist bereits angelegt;
  ein zusätzliches Skript wäre redundant.

## Lizenz

CC-BY-4.0 — frei nutzbar mit Quellenangabe. Siehe `LICENSE`.

## Pattern-Versionierung

Aktuelle UCDP-Version: **1.1** (siehe `PATTERN.md` Frontmatter).

Änderungen am Pattern selbst werden in `PATTERN.md` dokumentiert.
Projekte, die auf einer älteren Version aufgesetzt wurden,
bleiben gültig — eine Pattern-Version-Migration ist nicht
verpflichtend, aber bei größeren Änderungen empfohlen.
