---
title: Uzun Consulting Documentation Pattern (UCDP)
version: 1.0
last_reviewed: 2026-04-24
author: Mustafa Uzun
---

# Uzun Consulting Documentation Pattern (UCDP)

Ein strukturiertes Muster für die Projektdokumentation von Software-
Vorhaben, die mit KI-Assistenten (Claude Code, ChatGPT, Cursor,
Cline o. Ä.) gebaut, gepflegt und weiterentwickelt werden.

Das Pattern ist aus der Praxis entstanden — aus mehreren parallel
laufenden Projekten bei Uzun Consulting und Aviation Trade Services,
die mit Claude Code agentisch gebaut werden. Ziel des Patterns ist,
dass ein KI-Assistent zu Beginn jeder Session den Projektstand
selbständig versteht, während der Arbeit konsistent pflegt und Drift
zwischen Konzept, Code und Dokumentation sichtbar macht — ohne dass
der Projektbetreuer das in jeder Session neu erklärt.

## 1. Philosophie

Drei Leitprinzipien durchziehen das ganze System.

**Erstens: Ziel und Ist werden getrennt dokumentiert.** Jedes Thema
(Architektur, Datenmodell, Deployment) hat zwei Abschnitte — was wir
bauen wollen, und was tatsächlich gebaut ist. Die Differenz ist kein
Fehler, sondern ein sichtbar gemachtes Delta, das verwaltet wird.

**Zweitens: Der Code ist Single Source of Truth für die Implementierung,
die Dokumentation für die Absicht.** Wenn Doku und Code sich
widersprechen, entscheidet nie der Code stillschweigend und nie die
Doku ohne Prüfung — der Widerspruch wird explizit benannt und
aufgelöst (entweder als Doku-Korrektur oder als Delta).

**Drittens: Entscheidungen werden dauerhaft festgehalten, nicht nur
Zustände.** Architektur-Entscheidungen bekommen einen eigenen Eintrag
(ADR), der begründet, *warum* etwas so ist — unabhängig vom aktuellen
Zustand, der sich ändern kann.

Der Zweck dahinter ist operativ: KI-Assistenten haben kein
Projektgedächtnis zwischen Sessions. Das Pattern ersetzt dieses
Gedächtnis durch eine strukturierte, redundanzarme, versionierte
Dokumentation, die jede neue Session in wenigen Minuten aufgreifen
kann.

## 2. Ordnerstruktur

Pro Projekt liegt im Repo ein `docs/`-Ordner mit folgender Struktur:

```
projekt-repo/
├── AGENTS.md            (oder CLAUDE.md — Session-Disziplin)
├── docs/
│   ├── README.md        (Meta: Leseroutine, Konventionen)
│   ├── 00-handover-YYYY-MM-DD.md  (optional: historische Übergaben)
│   ├── 01-concept.md    (ZIEL: Produktvision, Zielgruppe, Scope)
│   ├── 02-architecture.md
│   ├── 03-datamodel.md
│   ├── 04-deployment.md
│   ├── 05-status.md     (Delta-Register — lebendes Dokument)
│   ├── 06-decisions.md  (ADRs — unveränderlich)
│   ├── 07-*.md          (projektspezifische Zusatzthemen, optional)
│   └── _source/         (historische Originaldokumente, nie editieren)
└── src/                 (oder app/, bzw. der Code-Pfad)
```

Die Nummerierung 01–06 ist fix. Zusätzliche Topic-Dateien (07 und
aufwärts) sind projektspezifisch erlaubt, wenn ein Thema
produktdefinierend ist und in 02–04 nicht gut untergebracht werden
kann — zum Beispiel eine Datei `07-ai-evaluation.md` in einem Projekt,
dessen Kern eine KI-Bewertungslogik ist.

Der Unterordner `_source/` enthält die ursprünglichen Konzept-
Dokumente (Word-Dokumente, PDFs, exportierte Google Docs), aus denen
die 01–07-Dateien inhaltlich gespeist wurden. Diese Originale werden
**niemals editiert** — sie sind Zeitstempel des ursprünglichen
Denkens. Wenn sie nicht mehr aktuell sind, gilt die gepflegte 01–07-
Doku, nicht das Original.

## 3. Topic-Dateien: Innerer Aufbau

Die Dateien `02-architecture.md`, `03-datamodel.md`,
`04-deployment.md` sowie optionale 07+-Dateien folgen alle demselben
dreigeteilten Aufbau:

```markdown
---
project: <projektname>
last_reviewed: YYYY-MM-DD
last_reviewed_by: <name>
source: docs/_source/<originaldokument>    # optional
---

# 02 · Architektur

## Ziel

<Was die Architektur erreichen soll. Stammt aus dem Konzept in
_source/, ist stabil, ändert sich selten. Beschreibt den Sollzustand.>

## Ist

<Was im Code tatsächlich existiert. Verifiziert gegen konkrete
Dateien und Zeilennummern. Ändert sich, wenn der Code sich ändert.>

## Offene Deltas (→ 05-status.md)

<Liste der bekannten Abweichungen zwischen Ziel und Ist, mit ID-
Verweisen ins Delta-Register. Keine ausführliche Beschreibung hier —
die lebt in 05-status.md.>
```

Die Datei `01-concept.md` hat nur einen `## Ziel`-Abschnitt — sie
beschreibt die stabile Produktvision. Sie enthält keine Ist- oder
Delta-Sektion, weil es hier kein Ist gibt (nur Vision).

Die Datei `05-status.md` ist tabellarisch aufgebaut (siehe unten).

Die Datei `06-decisions.md` ist eine Sammlung von ADRs (siehe unten).

## 4. Frontmatter-Konvention

Jede Datei in `docs/` beginnt mit einem YAML-Frontmatter-Block:

```yaml
---
project: ats-dashboard
last_reviewed: 2026-04-20
last_reviewed_by: Mustafa Uzun
source: docs/_source/ATS_Dashboard_Agent_Concept.docx
---
```

- **project**: Eindeutiger Projektname (wichtig in Monorepo- oder
  Multi-Repo-Setups, wo mehrere Projekte dieselben Konventionen
  teilen).
- **last_reviewed**: Datum der letzten inhaltlichen Durchsicht oder
  Lesebestätigung. Wird bei jedem Commit, der die Datei berührt,
  mindestens auf das Commit-Datum gebumpt.
- **last_reviewed_by**: Person, die die Datei zuletzt durchgegangen
  ist.
- **source** (optional): Pfad zum Originaldokument in `_source/`,
  falls die Datei aus einem historischen Konzept destilliert wurde.

## 5. Das Delta-Register (`05-status.md`)

Das Delta-Register ist das Herzstück des operativen Betriebs. Jede
bekannte Abweichung zwischen Ziel und Ist bekommt eine ID und einen
Eintrag in einer Tabelle:

```markdown
| ID      | Bereich                | Soll                        | Ist                         | Offene Arbeit                | Priorität | ADR       |
|---------|------------------------|-----------------------------|-----------------------------|------------------------------|-----------|-----------|
| DSH-001 | architecture/intake    | Stündlicher Pull            | Tägliches Cron um 06:00 UTC | Cron-Intervall erhöhen       | P2        | —         |
| DSH-002 | datamodel/rls          | RLS-Policy mit Parent-Check | Nur is_public-Check         | Policy-Präzisierung in 03    | P1        | ADR-0006  |
```

**ID-Konvention**: Projektspezifisches Präfix plus fortlaufende
Nummer. Beispiele: `DSH-` (Dashboard), `WEB-` (Website), `PT-`
(Prüfungstrainer). Die Präfixe werden pro Projekt einmal festgelegt
und nie geändert. Vorteil: Wenn jemand „Delta 5" sagt, ist unklar,
welches Projekt gemeint ist — „DSH-005" und „WEB-005" sind
unverwechselbar.

**Prioritäten**:

- **P1** — Diese Woche. Wichtig für das aktive Geschäft.
- **P2** — Dieses Quartal. Wichtig, aber nicht akut.
- **P3** — Nice-to-have. Blockiert nichts.

Bewusst keine P0-Kategorie. P0 wäre „Produktion kaputt, sofort fixen"
— solche Fälle gehören in Incident-Management, nicht ins Delta-
Register. Wenn es doch einmal einen Incident gibt, wird er separat
behandelt und Nachgelagertes als P1-Delta erfasst.

**Abschluss von Deltas**: Erledigte Einträge werden nicht gelöscht,
sondern mit Strikethrough und Datum markiert:

```markdown
| ~~DSH-011~~ | ~~outbound/email~~ | ~~Resend verdrahten~~ | ~~erledigt 2026-04-20~~ | — | ~~P1~~ | ADR-0014 |
```

So bleibt die Historie sichtbar, was wann warum geschlossen wurde.

**Bereichs-Notation**: Kurze Kennung aus der Topic-Datei plus
Sub-Aspekt, z. B. `architecture/intake`, `datamodel/rls`,
`deployment/cron`. Erleichtert das Filtern und Gruppieren, wenn das
Register wächst.

## 6. ADRs (`06-decisions.md`)

ADR steht für **Architecture Decision Record** — ein Format, das
ursprünglich 2011 von Michael Nygard (Software-Architekt) geprägt
wurde. UCDP übernimmt dieses Format unverändert, fügt aber eine
feste Nummerierung und Cross-Repo-Verweise hinzu.

Jedes ADR folgt dem Schema:

```markdown
## ADR-0006 · RLS-Defense-in-Depth bei öffentlichen Dateien

**Status:** Akzeptiert (2026-04-18)

### Kontext

<Warum diese Entscheidung jetzt getroffen wird. Welches Problem
liegt vor, welche Alternativen standen zur Wahl.>

### Entscheidung

<Was konkret entschieden wurde. Ein Satz, oder wenige.>

### Konsequenzen

<Was folgt daraus. Positive und negative Auswirkungen, offene
Folgefragen, Querverweise auf andere ADRs oder Deltas.>

### Verweise

- Implementierung: `supabase/migrations/0010_file_attachments.sql`
- Verwandtes ADR im anderen Repo: ats-website/ADR-0006
- Betroffenes Delta: DSH-002
```

**Wichtige Regeln für ADRs**:

Einmal committet, werden ADRs **nicht mehr editiert**. Wenn sich eine
Entscheidung ändert, schreibt man ein neues ADR, das das alte ersetzt,
mit einer Zeile wie `supersedes: ADR-0003`. Das alte bleibt stehen.
So bleibt die Entscheidungshistorie nachvollziehbar — jemand, der in
18 Monaten fragt „warum haben wir das damals so gemacht", bekommt
eine Antwort, statt einer redigierten Gegenwartsversion.

ADRs sollten nicht inflationär verwendet werden. Eine Mini-
Entscheidung gehört nicht in ein ADR, sondern wahlweise als
Konsequenz-Bullet eines bestehenden ADR oder als Delta. Die
Faustregel: Ein ADR lohnt sich, wenn die Entscheidung später
jemanden verwirren oder einen Commit in Frage stellen könnte.

## 7. `AGENTS.md` / `CLAUDE.md` — Session-Disziplin

Das ist die Datei, die dem KI-Assistenten am Anfang jeder Session
sagt, wie er mit der Dokumentation umgehen soll. Der Name hängt vom
Tool ab — Claude Code liest `CLAUDE.md`, andere Tools lesen
`AGENTS.md`, manche lesen beide. Inhaltlich identisch.

Typische Struktur der Datei:

```markdown
# <Projektname>

## Projekt in 5 Zeilen
<Extrem kurze Projekt-Charakterisierung: Was ist das, für wen, Stack,
Live-Status.>

## Session-Start — Leseroutine
Vor der ersten inhaltlichen Aktion in dieser Reihenfolge lesen:
1. docs/README.md
2. docs/05-status.md (aktuelle Deltas)
3. docs/01-concept.md (Ziel verinnerlichen)
4. Topic-Datei passend zum Session-Thema
5. docs/06-decisions.md bei Relevanz

## Doku-Struktur
<Kurzindex der 01–07-Dateien, Verweis auf _source/, Hinweis
auf Delta-Register.>

## Update-Pflicht bei jeder Code-Änderung
Kein Commit ohne Doku-Bewertung. Vor jedem Commit prüfen:
- Neues Feature / Architektur-Änderung → ## Ist der betroffenen
  Topic-Datei aktualisieren, last_reviewed bumpen.
- Bewusste Strategie-Entscheidung → ADR in 06.
- Schema-Änderung → 03-datamodel.md aktualisieren.
- Deployment-Änderung → 04-deployment.md aktualisieren.
- Reiner Refactor → nur last_reviewed bumpen.

## Session-Typen
- **Doku-Session**: Doku IST die Arbeit. Code unberührt.
- **Code-Session**: Code wird geändert, Doku wird mitgepflegt.
- **Delta-Arbeit**: Umsetzung eines konkreten Delta-Eintrags aus
  05-status. Abschluss = Strikethrough im Register.
- **Read-only**: Nur Nachschlagen, keine Änderungen.

## Commit-Disziplin
- Explizites Staging (nie `git add .` ohne Prüfung)
- Commit-Messages in der Projektsprache, imperativ
- Secrets niemals in Commits (nur Variablennamen in 04-deployment)
- Pro Commit ein logisch abgeschlossener Schritt

## Cross-Projekt-Regeln (falls relevant)
<Wenn mehrere Projekte sich eine Datenbank oder Schnittstelle
teilen: klare Regeln, welches Repo die Single Source of Truth für
was ist, und was bei Schnittstellen-Änderungen in beiden Repos zu
tun ist.>

## Wenn Doku und Code widersprechen
1. Widerspruch explizit benennen, nicht still auflösen.
2. Entscheiden: Doku falsch (korrigieren) oder Code vom Ziel
   abgewichen (Delta in 05-status anlegen, Fix-Plan).
```

Diese Datei ist das operative Rückgrat des Patterns. Ohne sie liest
der KI-Assistent die Doku nicht proaktiv. Mit ihr wird die
Doku-Disziplin automatisch Teil jeder Session.

## 8. Setup-Phasen für ein neues Projekt

Wenn UCDP in einem bestehenden Projekt eingeführt wird, empfiehlt
sich ein vierphasiges Vorgehen. Phase A und B passieren typischerweise
in einer Konzept-Session mit einem Chat-Assistenten (z. B. Claude im
Chat), Phase C und D in einer Arbeits-Session mit dem Coding-Agenten
(z. B. Claude Code lokal im Terminal).

**Phase A — Bestandsaufnahme.** Welche Konzept-Dokumente existieren
schon? Was ist der Ist-Zustand im Code? Gibt es bereits eine
CLAUDE.md oder AGENTS.md? Alles bestehende Material in `_source/`
verschieben, damit die neue Struktur auf grüner Wiese beginnen kann.
Wichtig: Verschiebung per `git mv`, nicht per Explorer, damit die
Git-Historie erhalten bleibt.

**Phase B — Struktur festlegen.** Skelett-Dateien für 01–06 (und bei
Bedarf 07+) anlegen, jeweils nur mit Frontmatter und leeren
`## Ziel` / `## Ist` / `## Offene Deltas`-Überschriften. Ein
gemeinsamer Commit `docs: Skelett-Struktur für UCDP`.

**Phase C — Befüllen.** Pro Topic-Datei ein Zyklus: Plan vorstellen,
Review, Schreiben, Review, nächste Datei. Die Arbeit läuft am besten
mit einem Coding-Agenten, der direkten Filesystem-Zugriff hat und
Code gegen Konzept abgleichen kann. Gefundene Abweichungen wandern
als Delta-Einträge in 05-status. Gefundene Architektur-Entscheidungen
(bewusst oder historisch) wandern als ADR in 06.

**Phase D — Disziplin verankern.** AGENTS.md/CLAUDE.md mit der
Session-Disziplin füllen. Ab jetzt wird bei jeder neuen Session die
Leseroutine automatisch aufgerufen, und bei jedem Commit die
Update-Pflicht geprüft.

Erfahrungswert aus der Praxis: Ein mittelgroßes Next.js-Projekt
(~5000 Codezeilen, eine Supabase-Datenbank, Vercel-Deployment) braucht
etwa 4–6 Stunden fokussierte Arbeit für Phase A bis D, verteilt auf
eine bis zwei Sessions. Größere Projekte proportional mehr.

## 9. Cross-Projekt-Regeln (optional)

Wenn mehrere Projekte sich Ressourcen teilen — etwa eine gemeinsame
Datenbank, gemeinsame Deployment-Infrastruktur oder Schnittstellen —
dann braucht das Pattern eine klare Single-Source-of-Truth-Regel pro
geteiltem Thema.

Beispiel aus der Praxis: Ein ATS-Dashboard und eine ATS-Website
teilen eine Supabase-Datenbank. Das Datenmodell wird in beiden Repos
dokumentiert, aber als SoT gilt das Dashboard-`03-datamodel.md`. Die
Website-`03-datamodel.md` dokumentiert nur eigene Reads, Views und
Policies und verweist für das Schema-Gesamtbild auf das Dashboard.

Die Regel dazu in beiden AGENTS.md:

> Schnittstellen-Änderung zwischen den Projekten (gemeinsames Schema,
> Webhook-Verträge, API-Calls) = 02-architecture.md in **beiden**
> Repos aktualisieren. Schema-Änderung = 03-datamodel.md im SoT-Repo
> aktualisieren, im anderen Repo Verweis-Update falls nötig.

Das verhindert, dass sich die beiden Repos auseinander entwickeln und
Claude Code in einer Website-Session nicht weiß, was im Dashboard
gerade passiert ist.

## 10. Geheimnisse und Secrets

Das Pattern hat eine harte Regel: **Secrets niemals in der Doku.**
Keine API-Keys, keine Webhook-Secrets, keine Connection-Strings mit
Passwort. In `04-deployment.md` stehen nur Variablennamen (z. B.
`RESEND_API_KEY`, `SHOPIFY_WEBHOOK_SECRET`), die tatsächlichen Werte
leben in `.env.local` (gitignored), bei Vercel, in Supabase Vault oder
in einem Password-Manager.

Diese Regel scheint offensichtlich, wird aber in der Praxis oft
verletzt, weil „nur eben kurz zur Doku dazupacken" praktisch ist. Es
lohnt sich, diese Regel in AGENTS.md explizit zu formulieren und vor
jedem Commit zu prüfen.

## 11. Was UCDP bewusst *nicht* ist

Das Pattern ist keine vollständige Software-Engineering-Methode. Es
ersetzt weder Code-Reviews, noch Tests, noch Issue-Tracker, noch
Projektmanagement-Tools. Es deckt explizit nur die **Projekt-
Dokumentation** ab und sorgt dafür, dass diese mit einem KI-
Assistenten zusammen produktiv gepflegt werden kann.

Es ist auch nicht für jedes Projekt sinnvoll. Für ein Wochenend-
Skript oder ein rein persönliches Tool ist der Overhead zu groß. Die
Investition lohnt sich ab dem Punkt, an dem ein Projekt länger als
einen Monat lebt, mehrere Code-Sessions über Zeit verteilt stattfinden
und ein KI-Assistent den Kontext nicht in einer einzigen Sitzung im
Kopf behalten kann.

## 12. Anhang: Minimal-Starter-Templates

Für den Schnellstart in einem neuen Projekt hier die drei
wichtigsten Templates zum Kopieren.

### `docs/README.md`

```markdown
---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <name>
---

# Projektdokumentation

Diese Dokumentation folgt dem Uzun Consulting Documentation Pattern
(UCDP). Siehe UCDP-Referenz für die vollständige Beschreibung.

## Dateien
- `01-concept.md` — Produktvision (Ziel)
- `02-architecture.md` — System-Architektur (Ziel/Ist/Deltas)
- `03-datamodel.md` — Datenmodell (Ziel/Ist/Deltas)
- `04-deployment.md` — Infrastruktur und Deployment (Ziel/Ist/Deltas)
- `05-status.md` — Delta-Register (lebendes Dokument)
- `06-decisions.md` — ADRs (unveränderlich)
- `_source/` — Historische Originaldokumente (nicht editieren)

## Konventionen
- Prioritäten: P1 (diese Woche) / P2 (dieses Quartal) / P3 (nice-to-have)
- Delta-IDs: <PRÄFIX>-NNN, fortlaufend
- ADRs: fortlaufend nummeriert, einmal geschrieben nicht mehr editiert
- Secrets: niemals in die Doku, nur Variablennamen
```

### `docs/05-status.md`

```markdown
---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <name>
---

# Status — offene Deltas Ziel ↔ Ist

| ID | Bereich | Soll | Ist | Offene Arbeit | Priorität | ADR |
|----|---------|------|-----|---------------|-----------|-----|
|    |         |      |     |               |           |     |

## Konventionen
- Priorität: P1 (diese Woche) / P2 (dieses Quartal) / P3 (nice-to-have)
- ID: <PRÄFIX>-NNN, fortlaufend
- Bereich: Dateiname aus 02–04 plus Sub-Aspekt
- Abschluss: Strikethrough mit Datum, nicht löschen
```

### `docs/06-decisions.md`

```markdown
---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <name>
---

# Architectural Decision Records

ADRs werden chronologisch nummeriert. Einmal geschrieben werden sie
nicht mehr editiert. Bei Widerruf: neues ADR mit `supersedes:`-Verweis.

---

## ADR-0001 · <Titel der Entscheidung>

**Status:** Akzeptiert (<YYYY-MM-DD>)

### Kontext
<Problemlage und Alternativen>

### Entscheidung
<Was gewählt wurde>

### Konsequenzen
<Positive und negative Folgen>

### Verweise
- <Code-Pfade, verwandte ADRs, betroffene Deltas>
```

## 13. Abschluss

UCDP ist kein abgeschlossenes System, sondern ein in der Praxis
entstandenes und sich weiterentwickelndes Muster. Wenn du es in
eigenen Projekten einsetzt und merkst, dass etwas fehlt oder
verbessert werden kann, ist das Teil der erwarteten Dynamik.

Das Wichtigste ist der Kern: **Ziel und Ist getrennt führen, Deltas
sichtbar machen, Entscheidungen dauerhaft festhalten, dem KI-
Assistenten das nötige Rüstzeug an die Hand geben**. Der Rest ist
Geschmacksfrage und projektabhängig.

Viel Erfolg beim Einsatz.
