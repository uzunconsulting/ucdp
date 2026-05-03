---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# 04 · Deployment

## Ziel

### Deployment in einem Satz

Die Anwendung läuft auf Vercel (Hobby-Tarif initial), mit
Supabase Frankfurt als Backend und Resend als Mail-Versender,
deployed über Git-Push auf den `main`-Branch.

### Hosting-Bestandteile

| Komponente            | Anbieter | Region        | Tarif (initial) |
| --------------------- | -------- | ------------- | --------------- |
| Web-App + API-Routen  | Vercel   | Frankfurt     | Hobby           |
| Datenbank + Storage   | Supabase | eu-central-1  | Free            |
| E-Mail-Versand        | Resend   | EU            | Free-Tier       |
| DNS                   | Cloudflare | —          | Free            |
| Quellcode             | GitHub   | —             | privat          |

### Domains und Subdomains

- **App**: `newsletter.beispiel-domain.de`
- **Mail-Absender**: `newsletter@beispiel-domain.de`

DNS-Einträge:

- **CNAME** für `newsletter.beispiel-domain.de` → Vercel.
- **DKIM** (drei CNAMEs von Resend).
- **SPF** als TXT-Eintrag.
- **DMARC** als TXT-Eintrag, initial `p=none`.

### Environment-Variablen

```
# Supabase
NEXT_PUBLIC_SUPABASE_URL          public
NEXT_PUBLIC_SUPABASE_ANON_KEY     public
SUPABASE_SERVICE_ROLE_KEY         server-only

# Resend
RESEND_API_KEY                    Mail-Versand
RESEND_WEBHOOK_SECRET             Bounce/Complaint-Webhook-Validierung
RESEND_FROM_EMAIL                 newsletter@beispiel-domain.de
RESEND_FROM_NAME                  „Beispiel Newsletter"

# Cron
CRON_SECRET                       Header-Token für Worker

# Operative
NEXT_PUBLIC_APP_URL               https://newsletter.beispiel-domain.de
TRACKING_PIXEL_BASE_URL           https://newsletter.beispiel-domain.de/api/track/open
```

### Cron-Jobs

`vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron/send-batch",
      "schedule": "* * * * *"
    }
  ]
}
```

`/api/cron/send-batch` (jede Minute) holt die nächsten 100
`pending`-Empfänger einer im Status `sending` befindlichen
Ausgabe ab und versendet sie über Resend. Idempotent über die
Unique-Constraint auf `issue_recipients`.

### Storage-Konfiguration

Bucket `issue-images/` ist privat. Zugriff über signed URLs
(7 Tage gültig). URLs werden beim Veröffentlichen einer Ausgabe
in das `body_html` eingebettet.

### Backups

- **Supabase Free**: 7 Tage Retention. Reicht initial.
- **Manueller Export**: monatlicher `pg_dump` als
  Sicherheitsmaßnahme, abgelegt auf NAS.

### Logging und Monitoring

- Vercel-Logs für Echtzeit-Debugging.
- Bounce-Rate über 5% pro Ausgabe → Mail an Betreiber.

### Environments

- **Production**: `main`-Branch, eigene Supabase-Instanz,
  Resend mit verifizierter Produktiv-Domain.
- **Preview**: pro Pull-Request, eigene Supabase-Instanz,
  Resend im Test-Modus (sendet nur an verifizierte Test-
  Adresse).
- **Local Dev**: Lokale Supabase via Docker
  (`supabase start`).

### Setup-Checkliste (Go-Live)

**Phase 1 — Infrastruktur**

- [ ] Supabase-Projekt angelegt, Region eu-central-1.
- [ ] GitHub-Repo mit Vercel verbunden.
- [ ] Custom Domain in Vercel konfiguriert.
- [ ] Resend-Account, Domain verifiziert (DKIM/SPF/DMARC).
- [ ] Alle Env-Vars in Vercel gesetzt.

**Phase 2 — Datenbank**

- [ ] Migrations 0001–0005 deployed.
- [ ] RLS-Tests durchgelaufen (`supabase/tests/rls.sql`).
- [ ] Betreiber-Account in Supabase Auth angelegt.

**Phase 3 — Daten-Import**

- [ ] CSV-Export aus dem alten Anbieter heruntergeladen.
- [ ] CSV-Import über Admin-UI durchgeführt, Fehlerbericht
      geprüft.
- [ ] Stichproben gegen die alte Anbieter-Liste verifiziert.

**Phase 4 — Test-Versand**

- [ ] Test-Ausgabe an eine Liste mit 3 Test-Empfängern
      (eigene Adressen) versandt.
- [ ] Open-Tracking mit aktiviertem Consent geprüft.
- [ ] Open-Tracking ohne Consent geprüft (kein Event).
- [ ] Unsubscribe-Klick getestet.

**Phase 5 — Cutover**

- [ ] Erste echte Ausgabe an die volle Liste versandt.
- [ ] Bounce-Rate nach 24h geprüft.
- [ ] Alter Anbieter-Account gekündigt (oder vorerst pausiert,
      bis sicher ist, dass alles funktioniert).

### Disaster-Recovery-Verfahren

- **Vercel-Ausfall**: Versand pausiert sich von selbst (Worker
  läuft nicht), läuft nach Wiederherstellung weiter, da
  Idempotenz garantiert ist.
- **Supabase weg**: aus Backup wiederherstellen. Bei Bedarf
  pgdump-Backup nutzen.
- **Resend weg**: kein Versand möglich. Worker setzt
  Empfänger auf `failed`, kann später erneut auf `pending`
  gesetzt werden.

## Ist

Stand 2026-05-03:

- Vercel-Projekt deployed, Custom Domain aktiv.
- Supabase Free, eu-central-1.
- Resend verifiziert.
- Cron-Job läuft, aber `/api/cron/send-batch` ist noch ein
  Stub (siehe Delta `NL-001`).

## Offene Deltas (→ 05-status.md)

Siehe `NL-001` für den Versand-Worker.
