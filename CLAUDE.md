# <projektname>

> Diese Datei ist das operative Rückgrat für KI-Assistenten
> (Claude Code, ChatGPT, Cursor o. Ä.). Sie beschreibt, wie der
> Assistent in jeder Session mit der Doku umgeht. Ersetze die
> Platzhalter `<…>` durch deine Projektwerte; die Sektions-
> struktur sollte erhalten bleiben.

## Projekt in 5 Zeilen

<Kurze Charakterisierung in 3–6 Sätzen: Was ist das Projekt? Für
wen? Welcher Tech-Stack? Live-Status? Nachbarprojekte, falls
relevant?>

## Session-Start — Leseroutine

Vor der ersten inhaltlichen Aktion in jeder Session in dieser
Reihenfolge lesen:

1. `docs/README.md` — Doku-Konventionen
2. `docs/05-status.md` — aktuelle Deltas, was offen ist
3. `docs/01-concept.md` — Ziel verinnerlichen (Soll-Vision)
4. Topic-Datei passend zum Session-Thema:
    - Architektur-Frage → `docs/02-architecture.md`
    - Schema-/DB-Frage → `docs/03-datamodel.md`
    - Deployment-/Infrastruktur-Frage → `docs/04-deployment.md`
5. `docs/06-decisions.md` — bei Architektur- oder Strategie­
   fragen, um nicht versehentlich entgegen einer bestehenden
   Entscheidung zu arbeiten

Der Code unter `<code-pfade>` ist Single Source of Truth für die
Implementierung. Bei Widerspruch zwischen Code und Doku siehe
Sektion „Wenn Doku und Code widersprechen" am Ende.

## Doku-Struktur

```
docs/
├── README.md                Doku-Konventionen, Frontmatter,
│                            ID-Präfixe, Prioritäten
├── 01-concept.md            Produktvision, Scope, Erfolgskriterien
├── 02-architecture.md       Tech-Stack, Komponenten, Schnittstellen
├── 03-datamodel.md          Tabellen, Schema, Migrationen
├── 04-deployment.md         Hosting, Cron, Env-Vars, Setup-Checkliste
├── 05-status.md             Delta-Register Soll ↔ Ist (lebt)
├── 06-decisions.md          ADRs, einmal geschrieben unverändert
└── _source/                 historische Originaldokumente, nie editieren
```

ID-Präfix für Deltas in diesem Projekt: **`<PRÄFIX>`** (z. B.
`<PRÄFIX>-001`).

## Update-Pflicht bei jeder Code-Änderung

Kein Commit ohne Doku-Bewertung. Vor jedem Commit prüfen:

- **Neues Feature / Architektur-Änderung** → `## Ist` der
  betroffenen Topic-Datei aktualisieren, `last_reviewed` bumpen.
- **Bewusste Strategie- oder Designentscheidung** → ADR in
  `06-decisions.md`. Mini-Entscheidungen können auch als
  Konsequenz-Bullet eines bestehenden ADR oder als Delta-
  Eintrag erfasst werden.
- **Schema-Änderung** → `03-datamodel.md` aktualisieren,
  Migrationsdatei mit fortlaufender Nummer anlegen.
- **Deployment-Änderung** (Env-Var, Cron, Domain) →
  `04-deployment.md` aktualisieren.
- **Reiner Refactor** → nur `last_reviewed` bumpen, keine
  inhaltliche Doku-Änderung nötig.
- **Delta erledigt** → Eintrag in `05-status.md` mit Strikethrough
  und Datum markieren, nicht löschen.

## Session-Typen

- **Doku-Session**: Doku IST die Arbeit. Code unberührt.
- **Code-Session**: Code wird geändert, Doku wird mitgepflegt.
  Standardfall.
- **Delta-Arbeit**: Umsetzung eines konkreten Delta-Eintrags aus
  `05-status.md`. Abschluss = Strikethrough im Register.
- **Read-only**: Nur Nachschlagen, keine Änderungen.

## Commit-Disziplin

- Explizites Staging — niemals `git add .` ohne vorherigen
  `git status`-Check.
- Commit-Messages in der Projektsprache, imperativ, knapp.
- Pro Commit ein logisch abgeschlossener Schritt. Keine
  Sammelcommits über mehrere Themen.
- **Secrets niemals in Commits** — nur Variablennamen in
  `04-deployment.md`, niemals Werte. Vor jedem Commit
  `git diff` prüfen.

## Cross-Projekt-Regeln

<Diese Sektion entfernen, falls nicht relevant. Andernfalls hier
beschreiben, welche anderen Projekte mit diesem in Verbindung
stehen, was die Schnittstellen-Verträge sind, und welche Doku-
Updates bei Schnittstellen-Änderungen in beiden Repos nötig
sind. Beispiel:>

> Schnittstellen-Änderung zwischen <projekt-a> und <projekt-b>
> (gemeinsames Schema, Webhook-Verträge, API-Calls) =
> `02-architecture.md` in **beiden** Repos aktualisieren.
> Schema-Änderung = `03-datamodel.md` im SoT-Repo
> aktualisieren, im anderen Repo Verweis-Update falls nötig.

## Wenn Doku und Code widersprechen

1. Widerspruch **explizit benennen**, nicht still auflösen.
2. Entscheiden:
    - **Doku falsch** (Code ist korrekt) → Doku korrigieren,
      `last_reviewed` bumpen, Commit-Message macht den Fix
      explizit.
    - **Code vom Ziel abgewichen** (Doku beschreibt korrekte
      Absicht) → Delta in `05-status.md` anlegen mit Plan zur
      Auflösung. Niemals stillschweigend die Doku an einen
      vom Ziel abgewichenen Code anpassen.
3. Wenn unklar, welche Seite richtig ist → ADR schreiben, in
   dem die neue Entscheidung getroffen und begründet wird.

## Projekt-spezifische Hinweise

<Optional. Hier kommen Hinweise rein, die nur für dieses Projekt
gelten — z. B. Compliance-Anforderungen (GoBD, HIPAA, …),
Append-only-Tabellen, besondere Test-Verfahren, Deployment-
Eigenheiten. Wenn nichts Besonderes gilt, diese Sektion
entfernen.>
