---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# Architectural Decision Records

ADRs werden chronologisch nummeriert. Einmal geschrieben werden
sie nicht mehr editiert. Bei Widerruf: neues ADR mit
`supersedes: ADR-NNNN`-Verweis, das alte bleibt stehen.

---

## ADR-0001 · Self-Hosting statt kommerzieller Anbieter

**Status:** Akzeptiert (2026-04-15)

### Kontext

Der Betreiber nutzte bisher einen kommerziellen Newsletter-
Anbieter (Mailchimp). Mit wachsender Liste steigen die Kosten
deutlich; zudem liegen die Abonnentendaten in den USA, was bei
DSGVO-Anfragen umständlich ist.

Alternativen:

- (A) Beim aktuellen Anbieter bleiben.
- (B) Wechsel zu einem EU-basierten Anbieter (z. B.
  CleverReach, Mailjet).
- (C) Self-Hosting auf eigener Infrastruktur.

### Entscheidung

Option (C). Eigene Anwendung auf Vercel + Supabase + Resend.
Dadurch volle Datenkontrolle, EU-Hosting, vorhersagbare
Kosten.

### Konsequenzen

- **Positiv**: Kostenkontrolle, Datenhoheit, keine
  Abhängigkeit von einem einzelnen Anbieter.
- **Negativ**: Mehraufwand für Wartung, eigenes Risiko bei
  Bounces und Spam-Reputation. Kein integrierter
  Editor/Template-Designer.

### Verweise

- `docs/01-concept.md` → Geschäftskontext

---

## ADR-0002 · Batch-Versand mit 100 Mails/Minute über Cron-Worker

**Status:** Akzeptiert (2026-04-22)

### Kontext

Resend hat Rate-Limits auf der API. Bei 5.000 Empfängern in
einem einzigen Aufruf wäre das ein Burst, der je nach Tarif
abgelehnt würde. Außerdem wäre ein synchroner Versand im
HTTP-Request-Lifecycle problematisch (Vercel-Function-Timeout
bei 10s Hobby).

Alternativen:

- (A) Synchroner Versand im Request, alle Mails auf einmal.
- (B) Batch-Versand über Background-Job mit kleiner Batch-
  Größe.
- (C) Externe Queue (z. B. Inngest, Trigger.dev).

### Entscheidung

Option (B). `/api/cron/send-batch` läuft jede Minute, sendet
100 Mails pro Lauf. Bei 5.000 Empfängern dauert ein voller
Versand ~50 Minuten — akzeptabel, weil Newsletter nicht
zeitkritisch sind.

### Konsequenzen

- **Positiv**: Keine Rate-Limit-Probleme, keine externe
  Queue-Abhängigkeit, robust gegen Worker-Aussetzer
  (Idempotenz).
- **Negativ**: Versand verteilt sich auf bis zu eine Stunde —
  kein „Send and Done"-Erlebnis.

### Verweise

- `docs/02-architecture.md` → Send-Worker
- `docs/03-datamodel.md` → Tabelle `issue_recipients`,
  Unique-Constraint
- Betroffenes Delta: `NL-001`

---

## ADR-0003 · Tracking-Pixel-Insertion immer, Auswertung nur bei Consent

**Status:** Akzeptiert (2026-04-30)

### Kontext

Das Tracking-Pixel ist im HTML-Body der Mail eingebettet. Wenn
es nur für Consent-Empfänger eingefügt würde, könnten Mail-
Clients durch Diff-Analyse erkennen, ob ein Empfänger getrackt
wird oder nicht — was zwar nicht aktiv passiert, aber
theoretisch möglich wäre und in einer transparenten Auslegung
DSGVO-fragwürdig.

Alternativen:

- (A) Pixel nur bei Consent einfügen.
- (B) Pixel immer einfügen, Auswertung nur bei Consent.

### Entscheidung

Option (B). Das Pixel wird in jede Mail eingebettet. Der
Server beim Aufruf des Pixels prüft `subscribers.tracking_
consent` für den zugehörigen Empfänger und schreibt nur dann
einen Eintrag in `open_events`. Empfänger ohne Consent erzeugen
keinen Datensatz, sind aber technisch nicht von Empfängern mit
Consent unterscheidbar.

### Konsequenzen

- **Positiv**: Saubere DSGVO-Auslegung, kein Reverse-
  Engineering möglich. Keine A/B-Treatment-Effekte (z. B.
  unterschiedliche Mail-Größen für Consent-/Nicht-Consent-
  Empfänger).
- **Negativ**: Minimal höherer Server-Traffic, weil auch
  Nicht-Consent-Empfänger das Pixel laden — unproblematisch
  bei dem Volumen.

### Verweise

- `docs/02-architecture.md` → Tracking-Pixel-Endpoint
- `docs/03-datamodel.md` → Tabelle `subscribers`, Spalte
  `tracking_consent`
- Betroffenes Delta: `NL-003`

---

(Neue ADRs werden chronologisch unten angefügt. ADR-Nummern
werden niemals wiederverwendet.)
