---
title: Uzun Digital Documentation Pattern (UDDP)
version: 1.6
last_reviewed: 2026-08-10
author: Mustafa Uzun
---

# Uzun Digital Documentation Pattern (UDDP)

Ein strukturiertes Muster für die Projektdokumentation von
Software-Vorhaben, die mit KI-Assistenten (Claude Code, ChatGPT,
Cursor, Cline o. Ä.) gebaut, gepflegt und weiterentwickelt
werden.

Das Pattern ist aus der Praxis entstanden — aus mehreren parallel
laufenden Projekten bei Uzun Digital, die agentisch mit KI-
Assistenten gebaut werden. Ziel des Patterns ist, dass ein KI-
Assistent zu Beginn jeder Session den Projektstand selbständig
versteht, während der Arbeit konsistent pflegt und Drift zwischen
Konzept, Code und Dokumentation sichtbar macht — ohne dass der
Projektbetreuer das in jeder Session neu erklärt.

> **Herkunft des Namens.** Bis einschließlich Version 1.5 hieß
> dieses Pattern **UCDP** — *Uzun Consulting Documentation
> Pattern*. Mit der Umfirmierung auf Uzun Digital heißt es ab
> **1.6 UDDP**. Es ist dasselbe Pattern: gleiche Struktur, gleiche
> Regeln, gleiche `docs/`-Ablage. Projekte, die auf einer
> UCDP-Version aufgesetzt wurden, bleiben unverändert gültig, und
> alle maschinenlesbaren Altnamen (`.ucdp-workspace`, `UCDP_*`,
> `ucdp.config.json`) werden von den 1.6-Hooks unbefristet
> weiterhin akzeptiert — siehe Abschnitt 11.

## 1. Philosophie

Drei Leitprinzipien durchziehen das ganze System.

**Erstens: Ziel und Ist werden getrennt dokumentiert.** Jedes Thema
(Architektur, Datenmodell, Deployment) hat zwei Abschnitte — was
wir bauen wollen, und was tatsächlich gebaut ist. Die Differenz
ist kein Fehler, sondern ein sichtbar gemachtes Delta, das
verwaltet wird.

**Zweitens: Der Code ist Single Source of Truth für die
Implementierung, die Dokumentation für die Absicht.** Wenn Doku
und Code sich widersprechen, entscheidet nie der Code
stillschweigend und nie die Doku ohne Prüfung — der Widerspruch
wird explizit benannt und aufgelöst (entweder als Doku-Korrektur
oder als Delta).

**Drittens: Entscheidungen werden dauerhaft festgehalten, nicht
nur Zustände.** Architektur-Entscheidungen bekommen einen eigenen
Eintrag (ADR), der begründet, *warum* etwas so ist — unabhängig
vom aktuellen Zustand, der sich ändern kann.

Der Zweck dahinter ist operativ: KI-Assistenten haben kein
Projektgedächtnis zwischen Sessions. Das Pattern ersetzt dieses
Gedächtnis durch eine strukturierte, redundanzarme, versionierte
Dokumentation, die jede neue Session in wenigen Minuten aufgreifen
kann.

## 2. Ordnerstruktur

Pro Projekt liegt im Repo ein `docs/`-Ordner mit folgender
Struktur:

```
projekt-repo/
├── README.md            (Projekt-README — kein UDDP-Inhalt)
├── CLAUDE.md            (Session-Disziplin, Quelle)
├── AGENTS.md            (Pointer auf CLAUDE.md, optional)
├── docs/
│   ├── README.md        (Doku-Konventionen-Index)
│   ├── 00-handover-YYYY-MM-DD.md  (optional, historisch)
│   ├── 01-concept.md    (ZIEL: Produktvision, Zielgruppe, Scope)
│   ├── 02-architecture.md
│   ├── 03-datamodel.md
│   ├── 04-deployment.md
│   ├── 05-status.md     (Delta-Register — lebendes Dokument)
│   ├── 06-decisions.md  (ADRs — unveränderlich)
│   ├── 07-*.md          (projektspezifische Zusatzthemen, optional)
│   ├── 08-agent-runs.md (Register autonomer Agent-Runs — optional)
│   └── _source/         (historische Originaldokumente, nie editieren)
└── src/                 (oder app/, der Code-Pfad)
```

Die Nummerierung 01–06 sowie 08 sind pattern-reserviert; ihre
Bedeutung ist in dieser Spezifikation festgelegt. Projekt-
spezifische Topic-Dateien nutzen 07 oder Nummern ab 09, wenn
ein Thema produktdefinierend ist und in 02–04 nicht gut
untergebracht werden kann — zum Beispiel `07-glossary.md` für
Projekte mit viel Fachsprache, oder `07-ai-evaluation.md` in
einem Projekt, dessen Kern eine KI-Bewertungslogik ist.

Die Datei `08-agent-runs.md` ist optional und nur dann sinnvoll,
wenn das Projekt agentisch gebaut wird — siehe Abschnitt 10.

Der Unterordner `_source/` enthält die ursprünglichen Konzept-
Dokumente (Word-Dokumente, PDFs, exportierte Google Docs), aus
denen die 01–07-Dateien inhaltlich gespeist wurden. Diese
Originale werden **niemals editiert** — sie sind Zeitstempel des
ursprünglichen Denkens. Wenn sie nicht mehr aktuell sind, gilt
die gepflegte 01–07-Doku, nicht das Original.

### Verhältnis zur Root-README

Die `README.md` im Repo-Root und die `docs/README.md` haben
unterschiedliche Aufgaben:

- **Root-`README.md`**: erklärt, was das Projekt macht, wie
  man es installiert, betreibt, dazu beiträgt — das, was ein
  Entwickler oder Anwender beim ersten Repo-Besuch sehen will.
- **`docs/README.md`**: erklärt die Doku-Konventionen — wie die
  Dateien in `docs/` zu lesen sind, was ID-Präfixe bedeuten,
  welche Prioritäten gelten. Sie ist primär für KI-Assistenten
  und Mitwirkende relevant, nicht für den Anwender.

Beide sollen kurz sein. Inhalte werden nicht doppelt geführt;
die Root-README verweist bei Bedarf auf `docs/`.

### Verhältnis zu `CHANGELOG.md`

`CHANGELOG.md` und `docs/` beantworten verschiedene Fragen und
ersetzen einander nicht:

- **`CHANGELOG.md`** — *was wurde wann geändert*. Chronologisch,
  nach außen gerichtet, wächst am Ende, wird nie umgeschrieben.
- **`docs/02`–`04`** — *was ist es und wie funktioniert es heute*.
  Zustandsbeschreibend; der `## Ist`-Abschnitt wird überschrieben,
  nicht fortgeschrieben.
- **`docs/05-status.md`** — die Brücke: *was fehlt noch*. Offene
  Arbeit mit IDs.
- **`docs/06-decisions.md`** — *warum es so ist*. Begründungen,
  die einen CHANGELOG-Eintrag überdauern.

Die Verwechslung, die in der Praxis am häufigsten vorkommt: ein
CHANGELOG-Eintrag wird geschrieben und der `## Ist`-Abschnitt
bleibt stehen wie er war. Danach beschreibt die Doku einen Stand,
den es nicht mehr gibt — das Anti-Pattern „Veraltete
`## Ist`-Sektionen" aus Abschnitt 13. Ein CHANGELOG-Eintrag
ersetzt **nie** einen Delta-Eintrag oder ein ADR.

`CHANGELOG.md` ist optional. Projekte ohne Releases nach außen
kommen mit `git log` und `05-status.md` aus. Das Template liefert
ein Gerüst mit; wer es nicht braucht, löscht es.

## 3. Topic-Dateien: Innerer Aufbau

Die Dateien `02-architecture.md`, `03-datamodel.md`,
`04-deployment.md` sowie optionale 07+-Dateien folgen alle
demselben dreigeteilten Aufbau:

```
---
project: <projektname>
last_reviewed: YYYY-MM-DD
last_reviewed_by: <n>
source: docs/_source/<originaldokument>    # optional
---

# 02 · Architektur

## Ziel

<Was die Architektur erreichen soll. Stammt aus dem Konzept in
_source/, ist stabil, ändert sich selten. Beschreibt den
Sollzustand.>

## Ist

<Was im Code tatsächlich existiert. Verifiziert gegen konkrete
Dateien und Zeilennummern. Ändert sich, wenn der Code sich
ändert.>

## Offene Deltas (→ 05-status.md)

<Liste der bekannten Abweichungen zwischen Ziel und Ist, mit ID-
Verweisen ins Delta-Register. Keine ausführliche Beschreibung
hier — die lebt in 05-status.md.>
```

Die Datei `01-concept.md` hat nur einen `## Ziel`-Abschnitt — sie
beschreibt die stabile Produktvision. Sie enthält keine Ist- oder
Delta-Sektion, weil es hier kein Ist gibt (nur Vision).

Die Datei `05-status.md` ist tabellarisch aufgebaut (siehe unten).

Die Datei `06-decisions.md` ist eine Sammlung von ADRs (siehe
unten).

## 4. Frontmatter-Konvention

Jede Datei in `docs/` beginnt mit einem YAML-Frontmatter-Block:

```
---
project: <projektname>
last_reviewed: YYYY-MM-DD
last_reviewed_by: <n>
source: docs/_source/<originaldokument>    # optional
---
```

- **project**: Eindeutiger Projektname (wichtig in Monorepo- oder
  Multi-Repo-Setups, wo mehrere Projekte dieselben Konventionen
  teilen).
- **last_reviewed**: Datum der letzten inhaltlichen Durchsicht
  oder Lesebestätigung. Wird bei jedem Commit, der die Datei
  berührt, mindestens auf das Commit-Datum gebumpt.
- **last_reviewed_by**: Person, die die Datei zuletzt
  durchgegangen ist.
- **source** (optional): Pfad zum Originaldokument in `_source/`,
  falls die Datei aus einem historischen Konzept destilliert
  wurde.

## 5. Das Delta-Register (`05-status.md`)

Das Delta-Register ist das Herzstück des operativen Betriebs.
Jede bekannte Abweichung zwischen Ziel und Ist bekommt eine ID
und einen Eintrag in einer Tabelle:

```
| ID       | Bereich                | Soll                        | Ist                         | Offene Arbeit                | Priorität | ADR       |
|----------|------------------------|-----------------------------|-----------------------------|------------------------------|-----------|-----------|
| PROJ-001 | architecture/intake    | Stündlicher Pull            | Tägliches Cron um 06:00 UTC | Cron-Intervall erhöhen       | P2        | —         |
| PROJ-002 | datamodel/rls          | RLS-Policy mit Parent-Check | Nur is_public-Check         | Policy-Präzisierung in 03    | P1        | ADR-0006  |
```

**ID-Konvention**: Projektspezifisches Präfix plus fortlaufende
Nummer, z. B. `PROJ-001`, `PROJ-002`. Das Präfix wird pro Projekt
einmal festgelegt und nie geändert. In Multi-Projekt-Setups
verhindert das Verwechslungen.

**Prioritäten**:

- **P1** — Diese Woche. Wichtig für das aktive Geschäft.
- **P2** — Dieses Quartal. Wichtig, aber nicht akut.
- **P3** — Nice-to-have. Blockiert nichts.

Bewusst keine P0-Kategorie. P0 wäre „Produktion kaputt, sofort
fixen" — solche Fälle gehören in Incident-Management, nicht ins
Delta-Register.

**Abschluss von Deltas**: Erledigte Einträge werden nicht
gelöscht, sondern mit Strikethrough und Datum markiert:

```
| ~~PROJ-011~~ | ~~outbound/email~~ | ~~Mail-Service verdrahten~~ | ~~erledigt YYYY-MM-DD~~ | — | ~~P1~~ | ADR-0014 |
```

So bleibt die Historie sichtbar.

**Bereichs-Notation**: Kurze Kennung aus der Topic-Datei plus
Sub-Aspekt, z. B. `architecture/intake`, `datamodel/rls`,
`deployment/cron`. Erleichtert das Filtern und Gruppieren, wenn
das Register wächst.

### Skalierung des Delta-Registers

Bei wenigen Einträgen ist eine flache Tabelle gut lesbar. Ab
etwa **30–50 Einträgen** wird das Register unhandlich. Pragmatische
Maßnahmen:

- **Erledigte Einträge ans Ende der Tabelle**, nicht in einen
  separaten Abschnitt — die Strikethrough-Konvention bleibt
  damit erhalten, der Lesefluss „aktive zuerst" wird gewahrt.
- **Bei deutlich >50 Einträgen**: aktive Einträge in
  `05-status.md`, erledigte in eine separate Datei
  `05-status-archive.md` mit gleicher Tabellenstruktur
  auslagern. Verweis von `05-status.md` auf das Archiv.
- **Gruppierung nach Bereich** durch Zwischenüberschriften
  (`### architecture`, `### datamodel`, `### deployment`) ist
  ein weiterer Schritt, wenn Filterung schwer fällt.

Diese Maßnahmen sind reaktiv — solange das Register lesbar ist,
ist die flache Tabelle die beste Form.

## 6. ADRs (`06-decisions.md`)

ADR steht für **Architecture Decision Record** — ein Format, das
ursprünglich 2011 von Michael Nygard (Software-Architekt)
geprägt wurde. UDDP übernimmt dieses Format unverändert, fügt
aber eine feste Nummerierung und Cross-Repo-Verweise hinzu.

Jedes ADR folgt dem Schema:

```
## ADR-0006 · <Titel der Entscheidung>

**Status:** Akzeptiert (YYYY-MM-DD)

### Kontext

<Warum diese Entscheidung jetzt getroffen wird. Welches Problem
liegt vor, welche Alternativen standen zur Wahl.>

### Entscheidung

<Was konkret entschieden wurde. Ein Satz, oder wenige.>

### Konsequenzen

<Was folgt daraus. Positive und negative Auswirkungen, offene
Folgefragen, Querverweise auf andere ADRs oder Deltas.>

### Verweise

- Implementierung: `<pfad/zur/umsetzung>`
- Verwandtes ADR im anderen Repo: `<andere-app/ADR-NNNN>`
- Betroffenes Delta: `PROJ-NNN`
```

**Wichtige Regeln für ADRs**:

Einmal committet, werden ADRs **nicht mehr editiert**. Wenn sich
eine Entscheidung ändert, schreibt man ein neues ADR, das das
alte ersetzt, mit einer Zeile wie `supersedes: ADR-0003`. Das
alte bleibt stehen. So bleibt die Entscheidungshistorie
nachvollziehbar — jemand, der in 18 Monaten fragt „warum haben
wir das damals so gemacht", bekommt eine Antwort, statt einer
redigierten Gegenwartsversion.

ADRs sollten nicht inflationär verwendet werden. Eine Mini-
Entscheidung gehört nicht in ein ADR, sondern wahlweise als
Konsequenz-Bullet eines bestehenden ADR oder als Delta. Die
Faustregel: Ein ADR lohnt sich, wenn die Entscheidung später
jemanden verwirren oder einen Commit in Frage stellen könnte.

## 7. `CLAUDE.md` und `AGENTS.md` — Pointer und Quelle

Verschiedene Coding-Agents suchen nach unterschiedlichen
Dateinamen, um Projekt-Disziplin zu lesen. Claude Code liest
`CLAUDE.md`. Andere Tools (Cursor, Aider, Copilot u. a.) folgen
dem informellen `agents.md`-Standard. Statt zwei parallele
Dateien zu pflegen — mit unvermeidlichem Drift-Risiko —
unterscheidet UDDP zwischen **Quelle** und **Pointer**:

- **`CLAUDE.md`** ist die **Quelle**. Hier lebt der gesamte
  inhaltliche Stand: Projekt-Beschreibung, Session-Disziplin,
  Doku-Struktur, Tech-Stack, Cross-Projekt-Regeln, Verhalten
  bei Doku/Code-Widerspruch. Nur diese Datei wird inhaltlich
  gepflegt.
- **`AGENTS.md`** ist der **Pointer**. Sie ist sehr kurz und
  verweist auf `CLAUDE.md`. Sie existiert nur, damit Tools, die
  nach dem `agents.md`-Standard suchen, einen klaren
  Einstiegspunkt finden.

### Aufbau von `AGENTS.md`

`AGENTS.md` enthält zwei BEGIN/END-markierte Sektionen:

```
<!-- BEGIN:tool-rules -->
<!-- Tool-generierte Sektionen dürfen hier eingefügt werden
     (z. B. von `create-next-app` für Next.js-spezifische
     Hinweise). Diese Sektion wird von Tools überschrieben.
     Eigene Inhalte gehören NICHT hierher, sondern in
     CLAUDE.md. -->
<!-- END:tool-rules -->

<!-- BEGIN:session-start -->
# Session-Start-Routine

Dieses Projekt nutzt UDDP (Uzun Digital Documentation Pattern).
Die operative Quelle für Session-Disziplin, Doku-Struktur und
Projekt-Regeln ist `CLAUDE.md` im Repo-Root. Lies sie vor jeder
inhaltlichen Arbeit, gefolgt von `docs/05-status.md` (offene
Deltas).

Diese Datei (`AGENTS.md`) ist nur Pointer für Coding-Agents, die
nach dem `agents.md`-Standard suchen. Inhalte werden hier nicht
gepflegt.
<!-- END:session-start -->
```

Die `tool-rules`-Sektion ist bewusst leer und für Tool-Output
reserviert. Frameworks wie `create-next-app` schreiben dort z. B.
Next.js-spezifische Hinweise hinein. Solange eigene Inhalte nur
in der `session-start`-Sektion und nicht in `tool-rules` stehen,
gehen Tool-Updates nicht verloren.

### Aufbau von `CLAUDE.md`

`CLAUDE.md` ist das operative Rückgrat. Sie enthält die
Sektionen:

- Projekt in 5 Zeilen
- Session-Start — Leseroutine
- Doku-Struktur
- Update-Pflicht bei jeder Code-Änderung
- Session-Typen (Doku-, Code-, Delta-, Read-only-Session)
- Commit-Disziplin
- Cross-Projekt-Regeln (optional, falls relevant)
- Verhalten bei Doku-/Code-Widerspruch

Ein vollständiges Skelett liegt im Template-Repo unter
`/CLAUDE.md`. Im Header der Datei steht ein expliziter
Verweis auf die Pointer-Rolle von `AGENTS.md`, damit das
Verhältnis selbsterklärend ist.

### Begründung dieser Trennung

Drei Gründe sprechen für Pointer/Quelle statt zwei
inhaltsgleiche Dateien:

- **Multi-Tool-Support**. Ein Projekt kann gleichzeitig mit
  Claude Code, Cursor und ChatGPT bearbeitet werden. Beide
  Datei-Standards werden bedient, ohne Inhaltspflege zu
  duplizieren.
- **Resilienz gegen Tool-Generierung**. Frameworks wie
  `create-next-app` schreiben in `AGENTS.md` (BEGIN/END-
  markierte Sektionen). Liegt die Projekt-Disziplin dort,
  riskiert jeder Tool-Update einen Merge-Konflikt. Liegt sie in
  `CLAUDE.md`, ist `AGENTS.md` frei für Tool-Output.
- **Aufgabentrennung**. `AGENTS.md` ist kurz, generisch und
  änderungsarm. `CLAUDE.md` ist projektspezifisch und
  änderungsreich. Die kurze Datei passt zum Tool-Standard, die
  lange zum Projekt.

Ohne `CLAUDE.md` liest der KI-Assistent die Doku nicht proaktiv.
Mit ihr — und mit `AGENTS.md` als Tool-übergreifendem
Einstiegspunkt — wird die Doku-Disziplin automatisch Teil jeder
Session, unabhängig vom verwendeten Tool.

## 8. Setup-Phasen für ein neues Projekt

Wenn UDDP in einem **bestehenden** Projekt eingeführt wird,
empfiehlt sich ein vierphasiges Vorgehen. Bei einem neuen Projekt,
das aus dem Template angezogen wird, entfallen Phase A und B
weitgehend — die Struktur ist bereits da.

**Phase A — Bestandsaufnahme** (nur bei bestehenden Projekten).
Welche Konzept-Dokumente existieren schon? Was ist der Ist-Zustand
im Code? Gibt es bereits eine `CLAUDE.md` oder `AGENTS.md`? Alles
bestehende Material in `_source/` verschieben. Wichtig:
Verschiebung per `git mv`, nicht per Explorer, damit die Git-
Historie erhalten bleibt.

**Phase B — Struktur festlegen** (nur bei bestehenden Projekten).
Skelett-Dateien für 01–06 (und bei Bedarf 07+) anlegen. Im
Template-Repo bereits erledigt.

**Phase C — Befüllen.** Pro Topic-Datei ein Zyklus: Plan
vorstellen, Review, Schreiben, Review, nächste Datei. Die Arbeit
läuft am besten zweistufig: Strategie, Konzept und Architektur in
einer Chat-Session mit einem allgemeinen Assistenten (z. B. Claude
im Chat); danach lokale Code-Sessions mit einem Coding-Agenten
(z. B. Claude Code), der direkten Filesystem-Zugriff hat.
Gefundene Abweichungen wandern als Delta-Einträge in
`05-status.md`. Architektur-Entscheidungen wandern als ADR in
`06-decisions.md`.

**Phase D — Disziplin verankern.** `CLAUDE.md`/`AGENTS.md` mit
der Session-Disziplin füllen. Ab jetzt wird bei jeder neuen
Session die Leseroutine automatisch aufgerufen, und bei jedem
Commit die Update-Pflicht geprüft.

Erfahrungswert aus der Praxis: Ein mittelgroßes Webprojekt
(einige tausend Codezeilen, eine Datenbank, eine Deployment-
Plattform) braucht etwa 4–6 Stunden fokussierte Arbeit für
Phase A bis D, verteilt auf eine bis zwei Sessions. Größere
Projekte proportional mehr.

## 9. Cross-Projekt-Regeln (optional)

Wenn mehrere Projekte sich Ressourcen teilen — etwa eine
gemeinsame Datenbank, gemeinsame Deployment-Infrastruktur oder
Schnittstellen — dann braucht das Pattern eine klare Single-
Source-of-Truth-Regel pro geteiltem Thema.

Beispiel: Zwei Anwendungen (etwa ein Backoffice-Tool und eine
öffentliche Website) teilen sich eine Datenbank. Das Datenmodell
wird in beiden Repos dokumentiert, aber als SoT gilt das Repo der
Anwendung, die das Schema primär definiert und migriert. Das
zweite Repo dokumentiert nur eigene Reads, Views und Policies und
verweist für das Schema-Gesamtbild auf das SoT-Repo.

Die Regel dazu in beiden `CLAUDE.md`:

> Schnittstellen-Änderung zwischen den Projekten (gemeinsames
> Schema, Webhook-Verträge, API-Calls) = `02-architecture.md` in
> **beiden** Repos aktualisieren. Schema-Änderung =
> `03-datamodel.md` im SoT-Repo aktualisieren, im anderen Repo
> Verweis-Update falls nötig.

Das verhindert, dass sich die beiden Repos auseinander entwickeln
und der KI-Assistent in einer Session im einen Repo nicht weiß,
was im anderen gerade passiert ist.

## 10. Agentische Runs (optional)

UDDP entstand aus manuellen KI-Sessions: Mensch sitzt am Rechner,
Assistent hilft, Code entsteht in einer interaktiven Schleife. Mit
reifer werdenden agentischen Setups (Claude Code mit Subagenten,
Headless-Runs, automatisierte Pipelines) treten zunehmend Sessions
auf, in denen ein KI-Agent weitgehend autonom Code produziert,
ohne dass jeder Schritt synchron beobachtet wird.

Solche Runs sind nachvollziehbarkeitsrelevant: wer hat wann was
gebaut, mit welcher Eingabe, welchen Subagenten, welchem Ergebnis.
Diese Information gehört projektnah dokumentiert, damit sie später
auffindbar bleibt und Drift zwischen autonom getroffenen
Entscheidungen und der manuell gepflegten Doku sichtbar wird. Die
optionale Datei `08-agent-runs.md` führt diese Runs als
tabellarisches Register, analog zum Delta-Register aus Abschnitt 5.

### Wann diese Erweiterung sinnvoll ist

`08-agent-runs.md` lohnt sich, sobald in einem Projekt regelmäßig
**autonome Agent-Sessions** stattfinden — also Sessions, in denen
ein Coding-Agent mit Subagenten, Hooks und mindestens teilweiser
Headless-Ausführung mehrere Code-Schritte ohne synchrone
menschliche Bestätigung durchläuft. Für rein interaktive Sessions
(Mensch fragt, Assistent antwortet, jeder Commit wird live
gesehen) ist sie überflüssig.

Sie ist auch sinnvoll, wenn solche Runs noch selten sind, das
Projekt aber agentisch gebaut werden soll — dann gibt das Register
von Anfang an einen Ort für Run-Dokumentation, anstatt sie später
nachträglich erfassen zu müssen.

### Aufbau

`08-agent-runs.md` folgt dem Frontmatter-Standard und enthält eine
Tabelle:

| ID                | Datum-Start | Datum-Ende | Auslöser            | Eingesetzte Subagenten         | Erzeugte Deltas / ADRs | Ergebnis              | Status   |
|-------------------|-------------|------------|---------------------|--------------------------------|------------------------|-----------------------|----------|
| <PRÄFIX>-RUN-0001 | YYYY-MM-DD  | YYYY-MM-DD | „Spec X umsetzen"   | architect, backend-dev, tester | <PRÄFIX>-014, ADR-0008 | Merge in main         | Erledigt |
| <PRÄFIX>-RUN-0002 | YYYY-MM-DD  | —          | „Bug PROJ-021 fixen"| backend-dev, tester            | —                      | Lauf abgebrochen, Cap | Aktiv    |

**ID-Konvention**: Projekt-Präfix plus `RUN-NNNN`, z. B.
`VLS-RUN-0001`. Gleicher Präfix wie Deltas, klar getrennter
Nummernraum durch das `RUN`-Wort. Run-IDs werden niemals
neu vergeben.

**Auslöser**: kurze textliche Beschreibung, was den Run gestartet
hat — eine User-Spec, ein GitHub-Issue, ein Cron-Trigger.

**Eingesetzte Subagenten**: Liste der Agent-Rollen, die im Run
aktiv waren (architect, frontend-dev, tester usw.). Gibt Hinweise
auf Komplexität und Fehlerquellen, wenn etwas nachträglich
aufgearbeitet werden muss.

**Erzeugte Deltas / ADRs**: Cross-Verweise auf das Delta-Register
und ADRs, die durch diesen Run entstanden sind. Macht sichtbar,
wo autonome Entscheidungen die Projekt-Doku verändert haben.

**Ergebnis**: kurze Zusammenfassung, was am Ende rauskam — Merge,
Pull Request offen, Lauf abgebrochen, etc. Nicht ausführlich.

**Status**: `Aktiv`, `Erledigt`, `Abgebrochen`. Erledigte und
abgebrochene Runs werden — analog zum Delta-Register — mit
Strikethrough markiert, nicht gelöscht.

### Detaillierte Run-Logs

Vollständige Schritt-für-Schritt-Logs (jeder Tool-Call, jedes
Zwischenartefakt, jeder Subagent-Output) gehören **nicht** in
`08-agent-runs.md`. Sie würden die Datei aufblähen und sind
maschinenlesbar besser außerhalb des Repos aufgehoben — in einer
Observability-Plattform, einer Datenbank, einer GitHub-Actions-
Run-Page. Eine optionale Spalte „Log-Verweis" kann auf solche
externen Quellen zeigen, wenn Auffindbarkeit der Volldokumentation
wichtig ist.

`08-agent-runs.md` ist Index und Audit-Trail, nicht
Volldokumentation.

### Verhältnis zu `00-handover-*.md`

UDDP kennt seit der Anfangsversion die optionalen
`00-handover-YYYY-MM-DD.md`-Dateien für einmalige menschliche
Übergaben. Diese bleiben unverändert bestehen — sie sind
einmalige, abgeschlossene Markdown-Dateien für „ich übergebe das
Projekt an Kollegen X". `08-agent-runs.md` ist demgegenüber ein
lebendiges, fortlaufendes Register. Beide Konventionen sind
komplementär; ein Projekt kann beide gleichzeitig nutzen.

### Auswirkung auf `CLAUDE.md`

Wer `08-agent-runs.md` einsetzt, ergänzt die „Update-Pflicht bei
jeder Code-Änderung"-Sektion in der projektspezifischen
`CLAUDE.md` um eine Bullet:

> **Agentischer Run** → Run-Eintrag bei Start in
> `08-agent-runs.md` anlegen, bei Ende Status auf `Erledigt` (oder
> `Abgebrochen`) setzen und mit Strikethrough markieren.

Die Vorlage-`CLAUDE.md` im Template-Repo enthält diese Bullet
bewusst nicht — sie würde das Template für die Mehrzahl der
Projekte unnötig länger machen.

## 11. Enforcement-Hooks (optional)

Die bisher beschriebene Disziplin — Leseroutine beim Start, Doku-
Pflicht nach jeder Änderung, Arbeit nur im eigenen Repo — steht in
`CLAUDE.md` als **Instruktion**. Eine KI-Session kann eine
Instruktion aber vergessen, verdrängen oder kreativ auslegen. Wer
die Disziplin nicht nur *beschreiben*, sondern *erzwingen* will,
kann sie als **Hooks** hinterlegen: deterministische Kommandos, die
die Agent-Harness (z. B. Claude Code) selbst an festen Lebenszyklus-
Punkten ausführt — nicht die KI. Was ein Hook blockt, lässt sich
nicht wegargumentieren.

Diese Erweiterung ist **optional** und für Projekte gedacht, die mit
Claude Code (oder einer kompatiblen Hook-fähigen Harness) gebaut
werden. Ein Referenz-Satz liegt im Template unter `.claude/hooks/`
samt `.claude/settings.json`; die Details stehen in
`.claude/hooks/README.md`.

### Die fünf Hooks

- **Session-Start-Briefing** (`SessionStart`): injiziert zu
  Session-Beginn automatisch den aktuellen Stand (Projekt,
  `last_reviewed`, Branch, uncommittete/ungepushte Änderungen,
  letzte Commits) und erzwingt die Leseroutine. Feuert auch nach
  einer Kontext-Kompaktierung, sodass sich die Session in langen
  Läufen erneut am aktuellen Stand verankert. Ersetzt das händische
  Einfügen eines „Start"-Prompts.
- **Projektordner-Grenzwächter** (`PreToolUse`): verweigert
  Schreibzugriffe außerhalb des eigenen Projektordners. Betrifft
  eine Änderung ein Nachbarprojekt, erzwingt der Hook einen
  **Handoff-Prompt** statt eigenmächtiger Edits im fremden Repo —
  die konsequente Umsetzung der Cross-Projekt-Regel aus Abschnitt 9.
  Gehören mehrere Repos bewusst zusammen (gemeinsamer Dach-Ordner),
  hebt eine Datei `.uddp-workspace` im Dach-Ordner die Grenze für
  genau diesen Umbrella auf — die Sub-Repos werden gegenseitig
  beschreibbar, alles außerhalb bleibt blockiert.
- **Überschreibschutz** (`PreToolUse`, seit 1.5): verweigert das
  Überschreiben einer bestehenden Datei, die **nicht aus Git
  wiederherstellbar** ist — ungetrackt, oder der Ordner steht
  überhaupt nicht unter Versionskontrolle. Getrackte Dateien
  bleiben frei überschreibbar; die holt `git checkout` zurück.
  Begründung siehe unten, „Warum ein eigener Überschreibschutz".
- **Doku-Nudge** (`PostToolUse`): erinnert einmal pro Session nach
  der ersten Code-Änderung an die Update-Pflicht.
- **Doku-Ende-Check** (`Stop`): hält das Session-Ende einmal an,
  wenn Code geändert, aber unter `docs/` nichts nachgezogen wurde —
  die maschinelle Absicherung der Update-Pflicht aus Abschnitt 7.
  Als „Doku nachgezogen" zählt ausschließlich eine Änderung unter
  `docs/`.

### Prinzipien

- **Fail-open**: jeder unerwartete Fehler im Hook lässt die Aktion
  durch. Ein Hook darf die Arbeit nie blockieren, nur die
  *Undiszipliniertheit*.
- **Self-detecting**: ohne `docs/05-status.md` sind die Doku-Hooks
  ein No-op — Nicht-UDDP-Ordner bleiben unberührt.
- **Portabel**: die Skripte lösen sich relativ zum Repo auf
  (`$env:CLAUDE_PROJECT_DIR`), ohne maschinenspezifische Pfade.
- **Escapes**: bewusste Ausnahmen über Umgebungsvariablen
  (`UDDP_UNLOCK` für den Grenzwächter, `UDDP_ALLOW_OVERWRITE` für
  den Überschreibschutz, `UDDP_NODOC` für den Ende-Check), gesetzt
  vor dem Start der Session.

Die Hooks sind bewusst kein Teil des Doku-*Kerns*: UDDP funktioniert
auch ohne sie. Sie sind die Antwort auf die Frage „wie halte ich
eine KI-Session zuverlässig bei der Konvention", wenn Erinnerung
allein nicht reicht.

### Warum ein eigener Überschreibschutz

Der naheliegende Einwand: Claude Code verweigert doch bereits das
Überschreiben einer Datei, die in dieser Session nicht gelesen
wurde. Das stimmt — greift aber an einer anderen Stelle. Die
Harness prüft **Kenntnis**, der Hook prüft **Wiederherstellbarkeit**.
Drei Fälle bleiben ohne ihn offen:

- **Lesen, dann überschreiben.** Von der Harness erlaubt, und für
  ungetrackte Arbeit genauso endgültig.
- **Der Shell-Pfad.** `> datei`, `Set-Content`, `cp`, `mv` laufen
  an der Write-Prüfung vorbei.
- **Andere Werkzeuge.** Ein zweiter Assistent, ein Skript, ein
  Headless-Run kennt die Regel nicht.

Der teuerste Moment eines Projekts ist die Frühphase: viel
entsteht, wenig ist committet, und parallel laufende Agenten
schreiben in denselben Ordner. Genau dort greift der Hook am
härtesten — in einem Ordner ohne Git ist danach *jedes*
Überschreiben blockiert, bis entweder gelesen, committet oder
bewusst gelöscht wurde. Das ist beabsichtigt und der Grund, warum
es den Escape `UDDP_ALLOW_OVERWRITE` gibt.

### Projektspezifische Konfiguration (`.claude/uddp.config.json`)

Welche Dateiart in einem Projekt die tragende ist, weiß nur das
Projekt. In einem Next.js-Repo ist es `.tsx`, in einem
Infrastruktur-Repo `.tf`, in einem regelgetriebenen Produkt eine
`.json` mit dem Zustandsautomaten. Die optionale, **committete**
Datei `.claude/uddp.config.json` erweitert oder kürzt die
Klassifikation:

```json
{
  "codeExtsAdd":  [".rules"],
  "codeExtsRemove": [".css"],
  "codeNamesAdd": ["Tiltfile"],
  "excludeAdd":   ["src/generated/*"],
  "docPathsAdd":  []
}
```

Sie gehört ins Repo, nicht in eine Umgebungsvariable: es ist eine
Eigenschaft des Projekts, nicht der Maschine, und muss mit dem
Klon mitwandern. Ohne sie gelten die Defaults; bei kaputtem JSON
fallen die Hooks stillschweigend auf die Defaults zurück.

Die Defaults zählen bewusst auch Konfiguration-als-Daten
(`.json`, `.yml`, `.toml`, `.tf`, `.xml`) als Code — dort steckt
oft mehr Produktverhalten als in einer Komponente. Lockfiles,
Build-Ordner und generierte Artefakte sind ausgenommen, weil ein
Hook, der bei jedem `package-lock.json` anschlägt, nach einer
Woche abgeschaltet wird.

### Grenze: die Session muss im Projektordner starten

Wird `claude` eine Ebene **oberhalb** des Projekts gestartet,
greifen die Hooks nicht wie gedacht:

- Bei **repo-lokaler** Installation wird `.claude/settings.json`
  des Projekts gar nicht geladen — es feuert kein einziger Hook.
  Das ist von innen nicht reparierbar.
- Bei **globaler** Installation (`~/.claude`) feuern sie, finden
  aber kein `docs/05-status.md`: die Doku-Hooks sind ein No-op,
  und der Grenzwächter nimmt den Elternordner als erlaubte
  Schreib-Wurzel — die Projektgrenze ist praktisch aufgehoben.

Seit 1.5 erkennt das Session-Start-Briefing diesen Fall (kein
`docs/05-status.md` hier, aber eines darunter) und warnt laut,
statt still wirkungslos zu bleiben. Die Regel bleibt trotzdem:
**eine Session pro Projektordner, gestartet im Projektordner.**

### Namenswechsel und Rückwärtskompatibilität

Mit 1.6 wurde das Pattern von UCDP in UDDP umbenannt. Für die
Hooks zerfällt das in zwei sehr unterschiedliche Klassen von
Namen:

**Repo-intern** — die Hook-Dateien (`uddp-*.ps1`), ihre Pfade in
`.claude/settings.json` und die Konfigdatei. Diese Namen sind nur
innerhalb eines Repos gekoppelt: `settings.json` zeigt auf die
Skripte daneben, beides wird zusammen migriert. Ein Repo auf 1.5
behält seine `ucdp-*.ps1`, ein Repo auf 1.6 hat `uddp-*.ps1` —
sie wissen nichts voneinander.

**Repo-übergreifend** — hier liegt das ganze Risiko, und es sind
genau zwei Dinge:

- die Umgebungsvariablen `UDDP_UNLOCK`, `UDDP_NODOC`,
  `UDDP_ALLOW_OVERWRITE`, `UDDP_SKIP_SECRETS`. Sie leben in der
  Shell, nicht im Repo — jede Session in jedem Projekt liest
  dieselbe Variable.
- der Umbrella-Marker `.uddp-workspace`. Er liegt im Dach-Ordner
  **über** mehreren Repos, wird aber vom Hook jedes einzelnen
  Sub-Repos gelesen.

Würden diese hart umgestellt, verlören alle noch nicht migrierten
Nachbarprojekte im selben Moment ihre Escapes und ihre
Umbrella-Freigabe — ohne dass sich in ihnen etwas geändert hat.
Deshalb gilt:

| Neu (ab 1.6) | Alt (bis 1.5) | Status |
|---|---|---|
| `UDDP_UNLOCK` | `UCDP_UNLOCK` | beide gültig |
| `UDDP_NODOC` | `UCDP_NODOC` | beide gültig |
| `UDDP_ALLOW_OVERWRITE` | `UCDP_ALLOW_OVERWRITE` | beide gültig |
| `UDDP_SKIP_SECRETS` | `UCDP_SKIP_SECRETS` | beide gültig |
| `.uddp-workspace` | `.ucdp-workspace` | beide gültig |
| `.claude/uddp.config.json` | `.claude/ucdp.config.json` | beide gültig, neue Datei gewinnt |

Die Altnamen sind **nicht befristet**. Sie kosten pro Stelle eine
Zeile und erlauben es, Projekte einzeln und in beliebiger
Reihenfolge zu migrieren — genau das, was ein Doku-Pattern nicht
erzwingen darf.

### Git-Hooks (`.githooks/`) — der andere Moment

Die Hooks oben greifen während einer Claude-Code-Session. Wer von
Hand committet, mit einem anderen Assistenten arbeitet oder die
Session-Hooks nicht aktiviert hat, ist von ihnen nicht erfasst.
Es gibt auch eine Lücke *innerhalb* von Claude Code: der
Doku-Ende-Check wertet den Arbeitsbaum aus und steigt aus, wenn
`git status` sauber ist — wer committet und dann die Session
beendet, umgeht ihn.

Der optionale Satz unter `.githooks/` schließt diesen Moment,
werkzeugunabhängig. Aktivierung pro Klon:

```bash
git config core.hooksPath .githooks
```

Die Aufteilung folgt einer klaren Linie:

- **Blockiert** wird nur, was unwiederbringlich oder gefährlich
  ist: gestagte `.env`-Dateien und bekannte Secret-Muster im
  Diff. Ein einmal gepushtes Geheimnis ist verbrannt, auch wenn
  der Commit später verschwindet. Das setzt um, was Abschnitt 12
  ohnehin fordert und Abschnitt 13 als Gegenmittel benennt.
- **Gewarnt** wird bei Code-Änderungen ohne `docs/`-Nachzug — im
  `pre-commit` und noch einmal deutlicher im `pre-push`.

Bewusst **nicht** erzwungen wird ein Doku- oder CHANGELOG-Eintrag
pro Commit. Das wäre die falsche Granularität: UDDPs Doku-Pflicht
hängt an der Arbeitseinheit, nicht am einzelnen Commit. Erzwungen
produziert sie Alibi-Zeilen — und ein Delta-Register voller
Alibi-Zeilen ist wertloser als eines mit einer ehrlichen Lücke.
Der harte Doku-Stopp bleibt beim Session-Ende-Check, wo die
Arbeitseinheit tatsächlich endet.

## 12. Geheimnisse und Secrets

Das Pattern hat eine harte Regel: **Secrets niemals in der Doku.**
Keine API-Keys, keine Webhook-Secrets, keine Connection-Strings
mit Passwort. In `04-deployment.md` stehen nur Variablennamen
(z. B. `EMAIL_API_KEY`, `WEBHOOK_SECRET`, `DATABASE_URL`), die
tatsächlichen Werte leben in `.env.local` (gitignored), in der
Secret-Verwaltung der Deployment-Plattform oder in einem
Password-Manager.

Diese Regel scheint offensichtlich, wird aber in der Praxis oft
verletzt, weil „nur eben kurz zur Doku dazupacken" praktisch ist.
Es lohnt sich, diese Regel in `CLAUDE.md` explizit zu formulieren
und vor jedem Commit zu prüfen.

## 13. Anti-Pattern — wie schlecht-praktiziertes UDDP aussieht

Wenn du einen oder mehrere der folgenden Punkte in deinem Repo
beobachtest, lohnt sich ein bewusstes Aufräumen — sonst verliert
das Pattern seine Wirkung.

**Veraltete `## Ist`-Sektionen.** Die Topic-Dateien tragen
`last_reviewed`-Daten, die Wochen oder Monate zurückliegen,
während der Code sich weiterentwickelt hat. Symptom: KI-
Assistenten antworten mit Annahmen über den Code, die nicht mehr
stimmen. Gegenmittel: bei jedem nicht-trivialen Commit mindestens
das `last_reviewed`-Datum bumpen, auch wenn nur kurz quer­
gelesen wurde.

**Inflationäre ADRs.** Jede kleine Entscheidung wird zum eigenen
ADR. Dadurch verlieren ADRs ihren Signal-Charakter („wichtig genug,
dass jemand es in 18 Monaten verstehen will"). Gegenmittel:
Faustregel anwenden — ein ADR lohnt sich, wenn die Entscheidung
später jemanden verwirren oder einen Commit in Frage stellen
könnte. Sonst Konsequenz-Bullet im bestehenden ADR oder Delta.

**Editierte ADRs.** Ein ADR wurde nachträglich „geglättet", weil
sich die Realität geändert hat. Damit ist die ursprüngliche
Begründung verloren. Gegenmittel: Niemals ein bestehendes ADR
ändern. Bei Wiederruf neues ADR schreiben mit `supersedes:
ADR-NNNN`.

**Delta-Friedhof.** Das Register hat 80 Einträge, davon sind 60
P3, niemand schaut mehr rein. Symptom: Deltas werden im Alltag
nicht mehr referenziert. Gegenmittel: regelmäßig (z. B.
quartalsweise) ausmisten — was länger als ein Jahr P3 ist und
nicht angegangen wurde, ist vermutlich kein echtes Delta, sondern
eine Wunschliste und kann gelöscht werden.

**Doku überholt Code.** Die Doku beschreibt Features, die nie
implementiert wurden, und niemand hat sie als Delta erfasst.
Symptom: Die `## Ist`-Sektion behauptet, etwas existiert, was
ein Blick in den Code widerlegt. Gegenmittel: bei jeder
Topic-Datei-Änderung kurz im Code prüfen, ob die `## Ist`-
Aussagen noch stimmen.

**Secrets in der Doku.** API-Keys oder Connection-Strings landen
in `04-deployment.md`, weil es „grade praktisch war". Gegenmittel:
strikte Trennung Variablenname (Doku) vs. Variablenwert (`.env`,
Secret-Manager). Pre-Commit-Check oder Code-Review explizit
darauf prüfen.

**`_source/`-Editierung.** Originaldokumente werden „mal eben
kurz angepasst, weil veraltet". Damit ist der historische Anker
verloren. Gegenmittel: `_source/` ist read-only, mental und
ggf. auch per Pre-Commit-Hook.

**Run-Friedhof.** Das Register `08-agent-runs.md` füllt sich mit
Dutzenden alten Runs ohne Statusbumps oder Strikethrough. Symptom:
Aktive Runs sind nicht mehr auffindbar, das Register wird
ignoriert. Gegenmittel: bei Run-Abschluss konsequent Status
setzen und Strikethrough anwenden; bei dauerhaft hoher Run-Anzahl
analog zum Delta-Register-Archiv eine Archiv-Datei einführen.

## 14. Was UDDP bewusst *nicht* ist

Das Pattern ist keine vollständige Software-Engineering-Methode.
Es ersetzt weder Code-Reviews, noch Tests, noch Issue-Tracker,
noch Projektmanagement-Tools. Es deckt explizit nur die
**Projekt-Dokumentation** ab und sorgt dafür, dass diese mit
einem KI-Assistenten zusammen produktiv gepflegt werden kann.

Es ist auch nicht für jedes Projekt sinnvoll. Für ein Wochenend-
Skript oder ein rein persönliches Tool ist der Overhead zu groß.
Die Investition lohnt sich ab dem Punkt, an dem ein Projekt länger
als einen Monat lebt, mehrere Code-Sessions über Zeit verteilt
stattfinden und ein KI-Assistent den Kontext nicht in einer
einzigen Sitzung im Kopf behalten kann.

## 15. Pattern-Versionierung

Die Pattern-Konvention selbst entwickelt sich weiter. Aktuelle 
Version: **1.6**. Änderungen werden als Anhang in dieser Datei
dokumentiert. Die Versionsreihe läuft über die Umbenennung hinweg
durch: 1.0–1.5 erschienen als UCDP, ab 1.6 als UDDP.

### Versionshistorie

- **1.0** (2026-04-24) — Erste öffentliche Version. Grundstruktur
  01–06, Frontmatter, Delta-Register, ADRs, AGENTS.md.
- **1.1** (2026-05-03) — Templates und Newsletter-Demo ergänzt;
  Anti-Pattern-Sektion; Skalierungs-Hinweise zum Delta-Register;
  Verhältnis zur Root-README geklärt; `CLAUDE.md` als
  primärer Name (`AGENTS.md` weiterhin als Alias erwähnt).
- **1.2** (2026-05-03) — Pointer/Quelle-Trennung zwischen
  `AGENTS.md` und `CLAUDE.md` formalisiert. `CLAUDE.md` ist
  die inhaltliche Quelle, `AGENTS.md` ein kurzer Pointer mit
  BEGIN/END-markierten Tool-Sektionen. Abschnitt 7 entsprechend
  umgeschrieben.
- **1.3** (2026-05-09) — Optionaler Abschnitt 10 „Agentische
  Runs" eingeführt. Neue optionale Datei `08-agent-runs.md` als
  Register autonomer Agent-Runs. ID-Konvention
  `<PRÄFIX>-RUN-NNNN`. Nummerierung 01–06 und 08 sind pattern-
  reserviert; 07 und 09+ projektspezifisch. Anti-Pattern
  „Run-Friedhof" ergänzt.
- **1.4** (2026-07-14) — Optionaler Abschnitt 11 „Enforcement-
  Hooks" eingeführt: die Session-Disziplin lässt sich maschinell
  erzwingen (SessionStart-Briefing, Projektordner-Grenzwächter,
  Doku-Nudge, Doku-Ende-Check). Referenz-Implementierung im
  Template unter `.claude/hooks/` + `.claude/settings.json`.
  Optional, fail-open, self-detecting; Nicht-Hook-Harnesses
  ignorieren `.claude/` folgenlos. Grenzwächter mit optionalem
  Workspace-Umbrella (damals `.ucdp-workspace`) für bewusst
  zusammengehörende Repos unter einem Dach-Ordner.
- **1.5** (2026-08-10) — Härtung der Enforcement-Schicht aus 1.4,
  aus dem Einsatz in mehreren Folgeprojekten:
  - **Überschreibschutz** als fünfter Hook: bestehende, nicht aus
    Git wiederherstellbare Dateien sind gegen Überschreiben
    gesperrt (Abschnitt 11).
  - **Eine Code-Klassifikation statt zweier.** Nudge und
    Ende-Check teilen sich eine gemeinsame Bibliothek (damals
    `ucdp-lib.ps1`); die Listen waren in 1.4 bereits
    auseinandergelaufen. Konfiguration-als-Daten (`.json`, `.yml`,
    `.toml`, `.tf` …) zählt jetzt als Code, Lockfiles und
    Build-Artefakte sind ausgenommen.
  - **Projektspezifische Konfiguration** (damals
    `.claude/ucdp.config.json`).
  - **Doku-Pflicht präzisiert**: nur Änderungen unter `docs/`
    quittieren sie. In 1.4 genügte jede beliebige `.md` im Repo.
  - **Warnung bei falschem Startordner** im Session-Start-Briefing.
  - **Grenzwächter versteht Git-Bash-Pfade** (`/c/…`,
    `/cygdrive/c/…`). Bis 1.4 wurde `/c/projekt` unter Windows zu
    `C:\c\projekt` normalisiert — der Hook blockierte damit den
    **eigenen** Projektordner, sobald ein Bash-Kommando ihn in
    MSYS-Schreibweise ansprach.
  - **Optionale Git-Hooks** unter `.githooks/`: Secret-/`.env`-Block
    beim Commit, Doku-Warnung bei Commit und Push.
  - **Pattern-Lizenz** von `LICENSE` nach `PATTERN-LICENSE.md`
    verschoben, damit sie nicht als Lizenz des Folgeprojekts
    erkannt wird.
  - **`CHANGELOG.md`-Gerüst** plus Abgrenzung zu `docs/`
    (Abschnitt 2).
  - `.gitignore` deckt `.claude/settings.local.json` ab.
- **1.6** (2026-08-10) — **Umbenennung: UCDP → UDDP.** Das Pattern
  hieß bis einschließlich 1.5 *Uzun Consulting Documentation
  Pattern*; mit der Umfirmierung auf **Uzun Digital** heißt es ab
  1.6 *Uzun Digital Documentation Pattern*. Inhaltlich ist 1.6
  identisch mit 1.5 — kein neues Konzept, keine neue Regel, keine
  Änderung an `docs/`.
  - Hook-Dateien heißen `uddp-*.ps1`, die Projekt-Konfiguration
    `.claude/uddp.config.json`, der Umbrella-Marker
    `.uddp-workspace`, die Escapes `UDDP_UNLOCK`, `UDDP_NODOC`,
    `UDDP_ALLOW_OVERWRITE`, `UDDP_SKIP_SECRETS`.
  - **Alle alten Namen bleiben unbefristet gültig** — siehe
    Abschnitt 11, „Namenswechsel und Rückwärtskompatibilität".
    Ein Projekt kann auf 1.6 gehoben werden, ohne dass ein
    Nachbarprojekt gleichzeitig migriert werden muss.
  - Nebeneffekt, der die Umbenennung unabhängig von der Firmierung
    rechtfertigt: **UCDP** ist die etablierte Abkürzung des
    *Uppsala Conflict Data Program*. **UDDP** ist deutlich weniger
    besetzt und damit auffindbar.

### Migration von v1.x auf 1.6

Bestehende Projekte auf 1.0–1.5 bleiben gültig. Wer nachziehen
will, sortiert nach Dringlichkeit. Die Reihenfolge gilt unabhängig
davon, von welcher Version aus migriert wird — der Ausgangsstand
wird am Repo abgelesen, nicht an einer notierten Versionsnummer
(die ein Folgeprojekt nirgends führt).

**Sofort, unabhängig von allem anderen** — eine Zeile, verhindert
einen committeten Schlüssel:

```gitignore
.claude/settings.local.json
.claude/launch.json
.claude/*.local.json
```

Ist die Datei bereits getrackt, reicht `.gitignore` nicht:

```bash
git rm --cached .claude/settings.local.json
```

Steckt in der Historie schon ein echter Schlüssel, ist er
verbrannt — rotieren, nicht nur löschen.

**Dringend, wenn das Projekt noch jung ist** (viel ungetrackte
Arbeit, mehrere Agenten): `.claude/hooks/uddp-overwrite-guard.ps1`
und `uddp-lib.ps1` kopieren und in `.claude/settings.json` als
`PreToolUse` mit Matcher `Write|NotebookEdit|Bash` eintragen.

**Empfohlen, sofern `.claude/hooks/` bereits existiert** (ab 1.4):
den ganzen Hook-Satz durch die 1.6-Fassung ersetzen und die Pfade
in `.claude/settings.json` mitziehen. Ohne das prüft der
Ende-Check `.json`/`.yml` nicht, lässt jede beliebige `.md` als
Doku-Nachweis durchgehen, und der Grenzwächter blockiert unter
Windows gelegentlich den eigenen Ordner (Git-Bash-Pfade). Alte
Dateinamen einfach löschen — `settings.json` zeigt danach auf die
neuen.

**Wenn `.claude/` gar nicht existiert** (1.0–1.3): Die Hooks sind
optional und nachrüstbar, aber keine Voraussetzung. Der Rest
dieser Migration funktioniert auch ohne sie.

**Wenn `AGENTS.md` noch die inhaltliche Quelle ist** (vor 1.2):
Pointer/Quelle-Trennung nach Abschnitt 7 nachziehen — Inhalt nach
`CLAUDE.md`, `AGENTS.md` auf den kurzen Pointer reduzieren.

**Optional**: `.githooks/`, `CHANGELOG.md`, `.gitattributes`,
`.claude/uddp.config.json`. Keines davon ist Voraussetzung für
die übrigen Punkte.

**Nur bei öffentlichen oder fremdgenutzten Repos**: prüfen, ob
eine aus dem Template mitkopierte CC-BY-`LICENSE` im Root liegt,
die nicht gemeint ist.

**Zur Umbenennung**: Es gibt keinen Zwang, alte Namen anzufassen.
Ein Projekt kann dauerhaft `.ucdp-workspace` und `UCDP_*`
weiterverwenden — die 1.6-Hooks lesen beides. Wer umbenennt,
benennt am besten zuerst die repo-internen Dinge um (Dateien,
`settings.json`, Konfigdatei) und zuletzt die repo-übergreifenden
(Marker im Dach-Ordner, Shell-Variablen), weil letztere alle
Projekte gleichzeitig betreffen.

Nichts davon berührt `docs/`. Die Struktur 01–06/08, das
Delta-Register und die ADRs sind seit 1.3 unverändert.

## 16. Abschluss

UDDP ist kein abgeschlossenes System, sondern ein in der Praxis
entstandenes und sich weiterentwickelndes Muster. Wenn du es in
eigenen Projekten einsetzt und merkst, dass etwas fehlt oder
verbessert werden kann, ist das Teil der erwarteten Dynamik.

Das Wichtigste ist der Kern: **Ziel und Ist getrennt führen,
Deltas sichtbar machen, Entscheidungen dauerhaft festhalten, dem
KI-Assistenten das nötige Rüstzeug an die Hand geben**. Der Rest
ist Geschmacksfrage und projektabhängig.

Viel Erfolg beim Einsatz.

---

*Dieses Pattern steht unter CC-BY-4.0 — siehe
[`PATTERN-LICENSE.md`](./PATTERN-LICENSE.md). Die Lizenz gilt für
das Pattern, **nicht** für Projekte, die daraus entstehen: dein
Code gehört dir und trägt die Lizenz, die du dafür wählst.*
