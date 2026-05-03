---
title: Uzun Consulting Documentation Pattern (UCDP)
version: 1.1
last_reviewed: 2026-05-03
author: Mustafa Uzun
---

# Uzun Consulting Documentation Pattern (UCDP)

Ein strukturiertes Muster für die Projektdokumentation von
Software-Vorhaben, die mit KI-Assistenten (Claude Code, ChatGPT,
Cursor, Cline o. Ä.) gebaut, gepflegt und weiterentwickelt
werden.

Das Pattern ist aus der Praxis entstanden — aus mehreren parallel
laufenden Projekten bei Uzun Consulting, die agentisch mit KI-
Assistenten gebaut werden. Ziel des Patterns ist, dass ein KI-
Assistent zu Beginn jeder Session den Projektstand selbständig
versteht, während der Arbeit konsistent pflegt und Drift zwischen
Konzept, Code und Dokumentation sichtbar macht — ohne dass der
Projektbetreuer das in jeder Session neu erklärt.

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
├── README.md            (Projekt-README — kein UCDP-Inhalt)
├── CLAUDE.md            (oder AGENTS.md — Session-Disziplin)
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
│   └── _source/         (historische Originaldokumente, nie editieren)
└── src/                 (oder app/, der Code-Pfad)
```

Die Nummerierung 01–06 ist fix. Zusätzliche Topic-Dateien
(07 und aufwärts) sind projektspezifisch erlaubt, wenn ein Thema
produktdefinierend ist und in 02–04 nicht gut untergebracht
werden kann — zum Beispiel `07-glossary.md` für Projekte mit
viel Fachsprache, oder `07-ai-evaluation.md` in einem Projekt,
dessen Kern eine KI-Bewertungslogik ist.

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
geprägt wurde. UCDP übernimmt dieses Format unverändert, fügt
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

## 7. `CLAUDE.md` / `AGENTS.md` — Session-Disziplin

Das ist die Datei, die dem KI-Assistenten am Anfang jeder Session
sagt, wie er mit der Dokumentation umgehen soll. Der Name hängt
vom Tool ab — Claude Code liest `CLAUDE.md`, andere Tools lesen
`AGENTS.md`, manche lesen beide. Inhaltlich identisch.

Ein vollständiges Skelett liegt im Template-Repo unter
`/CLAUDE.md`. Es enthält die Sektionen:

- Projekt in 5 Zeilen
- Session-Start — Leseroutine
- Doku-Struktur
- Update-Pflicht bei jeder Code-Änderung
- Session-Typen (Doku-, Code-, Delta-, Read-only-Session)
- Commit-Disziplin
- Cross-Projekt-Regeln (optional, falls relevant)
- Verhalten bei Doku-/Code-Widerspruch

Die `CLAUDE.md` ist das operative Rückgrat des Patterns. Ohne sie
liest der KI-Assistent die Doku nicht proaktiv. Mit ihr wird die
Doku-Disziplin automatisch Teil jeder Session.

## 8. Setup-Phasen für ein neues Projekt

Wenn UCDP in einem **bestehenden** Projekt eingeführt wird,
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

## 10. Geheimnisse und Secrets

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

## 11. Anti-Pattern — wie schlecht-praktiziertes UCDP aussieht

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

## 12. Was UCDP bewusst *nicht* ist

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

## 13. Pattern-Versionierung

Die Pattern-Konvention selbst entwickelt sich weiter. Aktuelle
Version: **1.1**. Änderungen werden als Anhang in dieser Datei
dokumentiert.

### Versionshistorie

- **1.0** (2026-04-24) — Erste öffentliche Version. Grundstruktur
  01–06, Frontmatter, Delta-Register, ADRs, AGENTS.md.
- **1.1** (2026-05-03) — Templates und Newsletter-Demo ergänzt;
  Anti-Pattern-Sektion; Skalierungs-Hinweise zum Delta-Register;
  Verhältnis zur Root-README geklärt; `CLAUDE.md` als
  primärer Name (`AGENTS.md` weiterhin als Alias erwähnt).

## 14. Abschluss

UCDP ist kein abgeschlossenes System, sondern ein in der Praxis
entstandenes und sich weiterentwickelndes Muster. Wenn du es in
eigenen Projekten einsetzt und merkst, dass etwas fehlt oder
verbessert werden kann, ist das Teil der erwarteten Dynamik.

Das Wichtigste ist der Kern: **Ziel und Ist getrennt führen,
Deltas sichtbar machen, Entscheidungen dauerhaft festhalten, dem
KI-Assistenten das nötige Rüstzeug an die Hand geben**. Der Rest
ist Geschmacksfrage und projektabhängig.

Viel Erfolg beim Einsatz.
