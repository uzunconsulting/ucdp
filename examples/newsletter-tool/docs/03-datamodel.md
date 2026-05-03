---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# 03 · Datenmodell

## Ziel

### Datenmodell in einem Satz

Postgres-Schema in Supabase mit fünf Haupttabellen:
Abonnenten, Ausgaben, Sende-Tabelle (Empfänger pro Ausgabe),
Open-Events, Admin-Sessions — alles unter Row-Level-Security,
Zeitstempel auf jeder Tabelle, fortlaufende Migrationen.

### Konventionen

- **Schema**: `public`.
- **Primärschlüssel**: `uuid` mit Default `gen_random_uuid()`.
- **Zeitstempel**: jede Tabelle hat `created_at timestamptz NOT
  NULL DEFAULT now()`.
- **Soft-Delete**: vermieden. Abonnenten werden nicht gelöscht,
  sondern auf Status `unsubscribed`/`bounced`/`complained`
  gesetzt.

### Tabellen — Übersicht

```
subscribers           Abonnentenliste
issues                Newsletter-Ausgaben
issue_recipients      Eine Zeile pro (Ausgabe × Empfänger)
open_events           Tracking-Events
```

### Tabelle: `subscribers`

| Spalte                | Typ           | Nullable | Bemerkung                              |
| --------------------- | ------------- | -------- | -------------------------------------- |
| id                    | uuid PK       | nein     | gen_random_uuid()                      |
| email                 | text          | nein     | unique, lowercase                      |
| status                | text          | nein     | 'pending' / 'active' / 'unsubscribed' /|
|                       |               |          | 'bounced' / 'complained'               |
| tracking_consent      | boolean       | nein     | default false                          |
| confirm_token         | text          | ja       | für Double-Opt-in                      |
| confirm_token_expires | timestamptz   | ja       |                                        |
| unsubscribe_token     | text          | nein     | unique, dauerhaft gültig               |
| confirmed_at          | timestamptz   | ja       |                                        |
| created_at            | timestamptz   | nein     |                                        |
| updated_at            | timestamptz   | nein     |                                        |

### Tabelle: `issues`

| Spalte         | Typ           | Nullable | Bemerkung                              |
| -------------- | ------------- | -------- | -------------------------------------- |
| id             | uuid PK       | nein     |                                        |
| title          | text          | nein     |                                        |
| subject        | text          | nein     | Subject-Line der Mail                  |
| body_markdown  | text          | nein     | Quelle                                 |
| body_html      | text          | ja       | gerendert beim Speichern               |
| status         | text          | nein     | 'draft' / 'ready' / 'sending' / 'sent' |
| send_started_at| timestamptz   | ja       |                                        |
| send_finished_at| timestamptz  | ja       |                                        |
| created_at     | timestamptz   | nein     |                                        |
| updated_at     | timestamptz   | nein     |                                        |

### Tabelle: `issue_recipients`

| Spalte           | Typ           | Nullable | Bemerkung                              |
| ---------------- | ------------- | -------- | -------------------------------------- |
| id               | uuid PK       | nein     |                                        |
| issue_id         | uuid FK       | nein     | → issues.id                            |
| subscriber_id    | uuid FK       | nein     | → subscribers.id                       |
| status           | text          | nein     | 'pending' / 'sent' / 'failed' /        |
|                  |               |          | 'bounced' / 'complained'               |
| sent_at          | timestamptz   | ja       |                                        |
| resend_message_id| text          | ja       |                                        |
| error_message    | text          | ja       |                                        |
| created_at       | timestamptz   | nein     |                                        |

- **Unique** auf `(issue_id, subscriber_id)` — verhindert
  Doppelversand bei Worker-Wiederläufen.
- **Index** auf `(issue_id, status)` für die Worker-Query
  „nächste 100 pending".

### Tabelle: `open_events`

| Spalte             | Typ           | Nullable | Bemerkung                              |
| ------------------ | ------------- | -------- | -------------------------------------- |
| id                 | uuid PK       | nein     |                                        |
| issue_recipient_id | uuid FK       | nein     | → issue_recipients.id                  |
| opened_at          | timestamptz   | nein     |                                        |
| user_agent         | text          | ja       |                                        |
| created_at         | timestamptz   | nein     |                                        |

- Es ist explizit erlaubt, dass derselbe Empfänger mehrere
  Open-Events pro Ausgabe erzeugt (Mehrfach-Öffnung).
  Statistiken zählen unique über `issue_recipient_id`.

### Beziehungen — ER-Skizze

```
subscribers 1 ──*  issue_recipients *──1 issues
                           │
                           1──* open_events
```

### Row-Level-Security

- Alle Tabellen mit RLS aktiv.
- Zugriff nur über Service-Role (in API-Routen) oder
  authentifizierte User mit Eintrag in `auth.users` (das ist
  der Betreiber selbst).
- Öffentliche Endpoints (`/signup`, `/api/track/open`,
  `/api/unsubscribe`) nutzen Service-Role und führen eigene
  Token-Validierung durch.

### Migrationsstrategie

Supabase CLI mit Migrationsdateien in `supabase/migrations/`.
Initial-Reihenfolge:

1. `0001_init.sql` — Extensions, RLS-Boilerplate.
2. `0002_subscribers.sql`
3. `0003_issues.sql`
4. `0004_issue_recipients.sql`
5. `0005_open_events.sql`

### Storage-Layout

```
issue-images/    (privat, signed URLs für Mail-Body)
  {issue_id}/
    {hash}.{ext}
```

### Nicht-funktionale Aspekte

- **Backups**: Supabase Pro nicht zwingend (Free reicht für
  diesen Maßstab), aber empfohlen sobald >2.000 Abonnenten.
- **PII**: E-Mail-Adressen sind PII; alle in Frankfurt
  (Supabase eu-central-1).
- **DSGVO-Lösch-Anfragen**: physische Löschung aus
  `subscribers` möglich, da keine handelsrechtliche
  Aufbewahrungspflicht. Open-Events werden mit dem
  Subscriber kaskadiert gelöscht.

## Ist

Stand 2026-05-03:

- Migrationen 0001–0005 deployed.
- Indexe alle gesetzt wie geplant.
- RLS-Policies aktiv und getestet (siehe
  `supabase/tests/rls.sql`).

## Offene Deltas (→ 05-status.md)

Keine offenen Deltas im Datenmodell.
