---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# Status — offene Deltas Ziel ↔ Ist

## Offene Deltas

| ID     | Bereich                       | Soll                                                          | Ist                                | Offene Arbeit                                              | Priorität | ADR       |
|--------|-------------------------------|---------------------------------------------------------------|------------------------------------|------------------------------------------------------------|-----------|-----------|
| NL-001 | architecture/send             | Versand-Worker schickt 100 Mails/Min an pending-Empfänger     | Stub-Endpoint, kein Versand        | Resend-Integration, Idempotenz-Test, Bounce-Handling       | P1        | ADR-0002  |
| NL-002 | architecture/signup           | Anmelde-Formular mit Double-Opt-in                            | nicht vorhanden                    | `/signup`-Seite bauen, Bestätigungs-Mail-Template           | P1        | —         |
| NL-003 | architecture/tracking         | Tracking-Pixel-Endpoint mit Consent-Check                     | nicht vorhanden                    | `/api/track/open/[id]`, Pixel-Insertion in Mail-Body        | P2        | ADR-0003  |
| NL-004 | architecture/bounces          | Resend-Webhook setzt Status auf bounced/complained            | nicht vorhanden                    | Webhook-Endpoint, HMAC-Validierung, Status-Update           | P2        | —         |
| NL-005 | datamodel/cleanup             | DSGVO-Lösch-Workflow für Subscriber-Anfragen                  | manuell per SQL                    | UI-Action im Admin, Audit-Log, kaskadiertes Löschen         | P3        | —         |
| ~~NL-006~~ | ~~deployment/setup~~       | ~~Custom Domain newsletter.beispiel-domain.de~~              | ~~erledigt 2026-04-28~~            | —                                                          | ~~P1~~    | —         |

## Konventionen

- **Priorität**: P1 (diese Woche) / P2 (dieses Quartal) /
  P3 (nice-to-have).
- **ID**: `NL-NNN`, fortlaufend, niemals neu vergeben.
- **Bereich**: Topic-Datei plus Sub-Aspekt.
- **Abschluss**: Strikethrough mit Datum, nicht löschen.

## Erläuterungen

### NL-001 (Versand-Worker)

Die Architektur sieht einen Worker vor, der jede Minute 100
Mails verschickt. Aktuell ist `/api/cron/send-batch` nur ein
Stub, der HTTP 200 zurückgibt und ansonsten nichts tut. Die
eigentliche Logik (Resend-Aufruf, Status-Update in
`issue_recipients`, Fehlerbehandlung) muss noch implementiert
werden. Wichtig: Idempotenz testen — der gleiche Empfänger
darf bei Worker-Wiederläufen nicht doppelt zugestellt werden.
ADR-0002 begründet die Batch-Größe von 100/Min.

### NL-003 (Tracking-Pixel)

Tracking ist scope-relevant (DSGVO). Die Implementierung muss
sicherstellen, dass das Pixel nur bei Empfängern mit
`tracking_consent = true` ein Event erzeugt — nicht durch
Weglassen des Pixels (das wäre erkennbar), sondern durch
stilles Ignorieren auf Server-Seite. Siehe ADR-0003 für die
Begründung des Verfahrens.
