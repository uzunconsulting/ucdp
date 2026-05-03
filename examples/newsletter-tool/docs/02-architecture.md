---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# 02 · Architektur

## Ziel

### Architektur in einem Satz

Eine Next.js-App auf Vercel mit Supabase als Datenbank, Auth
und Storage; Resend als Mail-Versender; ein Background-Worker
über Vercel Cron sendet die Ausgaben in Batches.

### Tech-Stack

- **Next.js (App Router)** — Admin-UI und API-Routen in einem
  Repo, ein Deployment.
- **TypeScript** durchgehend, strict mode.
- **Supabase**: Postgres, Auth (Magic Link), Storage für
  eingebettete Bilder.
- **Resend** für Mail-Versand.
- **Tailwind CSS** für Styling.
- **react-markdown** für die Ausgaben-Vorschau im Admin.
- **Zod** für Eingabe-Validierung.

### High-Level-Komponenten

```
                  Abonnenten (extern, Endnutzer)
                          │
              Anmeldeformular (öffentliche Seite)
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│         newsletter-tool (Next.js auf Vercel)            │
│                                                          │
│  /signup   ──► Anmelde-Form, Double-Opt-in              │
│  /admin/*  ──► Admin-UI (Auth-geschützt)                │
│                  ├── Abonnenten                          │
│                  ├── Ausgaben (Markdown-Editor)          │
│                  └── Statistiken                         │
│                                                          │
│  /api/cron/send-batch ──► Worker, batch-weiser Versand  │
│  /api/track/open/[id] ──► Tracking-Pixel-Endpoint       │
│  /api/unsubscribe/[token] ──► One-Click-Unsubscribe     │
│                                                          │
└────────────────────────────────────────────────────────┘
                  │              │
                  ▼              ▼
              Supabase        Resend
        (Postgres + Storage)  (Mail-Versand)
```

### Komponenten im Detail

**1. Anmelde-Formular** (`/signup`)

Öffentlich erreichbar, nimmt E-Mail und Tracking-Einwilligung
entgegen. Validiert per Zod, schreibt in `subscribers` mit
Status `pending`, verschickt eine Bestätigungs-Mail mit Token-
Link. Klick auf den Link bestätigt das Abo (Status auf
`active`).

**2. Admin-UI** (`/admin/*`, geschützt durch Magic-Link-Auth)

Routen:

- `/admin` — Dashboard (Listenwachstum, letzte Ausgabe).
- `/admin/subscribers` — Liste mit CSV-Import, Suche, Bulk-
  Aktionen.
- `/admin/issues` — Ausgaben-Liste, Status (Draft/Bereit/
  Versendet).
- `/admin/issues/[id]` — Editor für eine einzelne Ausgabe.
- `/admin/stats` — Übersicht der Statistiken pro Ausgabe.

**3. Send-Worker** (`/api/cron/send-batch`, jede Minute)

Wenn eine Ausgabe vom Betreiber als „Versand starten" markiert
wurde, läuft der Worker im Minutentakt und sendet 100 Mails pro
Lauf an noch nicht zugestellte Empfänger. Idempotent: jeder
Empfänger landet pro Ausgabe genau einmal in der Sende-Tabelle
(`issue_recipients` mit Unique-Constraint).

**4. Tracking-Pixel-Endpoint** (`/api/track/open/[id]`)

Verarbeitet Aufrufe des in der Mail eingebetteten Pixels.
Schreibt einen Eintrag in `open_events`, wenn der Empfänger
beim Versand eingewilligt hat. Antwortet immer mit einem 1x1-
Pixel-GIF, unabhängig vom Tracking-Status — sonst würde ein
Mail-Client erkennen, ob getrackt wird.

**5. Unsubscribe-Endpoint** (`/api/unsubscribe/[token]`)

Token-basierter One-Click-Unsubscribe. Setzt
`subscribers.status` auf `unsubscribed`. Direkter Erfolg ohne
Bestätigungsklick (RFC 8058 List-Unsubscribe-Post-Konformität).

### Externe Schnittstellen

**Resend (ausgehend):**

- API für Mail-Versand mit personalisierten Headern für
  List-Unsubscribe.
- Resend-Webhook (eingehend): Bounce- und Complaint-Events
  → setzen `subscribers.status` auf `bounced` bzw.
  `complained`.

**Supabase Auth (eingehend):**

- Magic-Link-Login für Admin. Kein Passwort.

### Architektur-Prinzipien

- **Idempotenz im Versand**: jeder Empfänger pro Ausgabe genau
  einmal. Garantiert über `issue_recipients`-Unique-Constraint.
- **Tracking nur bei Einwilligung**: Pixel-Insertion und
  Open-Event-Logging beide getrennt schaltbar pro Empfänger.
- **DSGVO-Default-Aus**: Tracking-Einwilligung ist standardmäßig
  ausgeschaltet, muss aktiv angekreuzt werden.

## Ist

Stand 2026-05-03:

- Admin-UI: `/admin`, `/admin/subscribers`, `/admin/issues`
  implementiert (`app/admin/*`).
- `/signup`: nicht implementiert (Delta `NL-002`).
- `/api/cron/send-batch`: nicht implementiert (Delta `NL-001`).
- `/api/track/open/[id]`: nicht implementiert (Delta `NL-003`).
- `/api/unsubscribe/[token]`: implementiert
  (`app/api/unsubscribe/[token]/route.ts`).
- Resend-Webhook: nicht implementiert (Delta `NL-004`).

## Offene Deltas (→ 05-status.md)

`NL-001` Versand, `NL-002` Anmeldeformular,
`NL-003` Tracking-Pixel, `NL-004` Bounce-Webhook.
