# newsletter-tool

> Diese Datei ist das operative Rückgrat für KI-Assistenten und
> die **Quelle** für Session-Disziplin, Doku-Struktur und
> Projekt-Regeln.
>
> **Verhältnis zu `AGENTS.md`**: `AGENTS.md` im Repo-Root ist
> nur Pointer auf diese Datei (für Tools, die nach dem
> `agents.md`-Standard suchen). Inhaltliche Pflege erfolgt
> ausschließlich hier.

## Projekt in 5 Zeilen

newsletter-tool ist eine Self-hosted-Newsletter-Anwendung für
einen Solo-Betreiber. Es importiert Abonnenten via CSV, verwaltet
Newsletter-Ausgaben als Markdown, verschickt sie über Resend an
die Abonnentenliste und trackt Open-Rates über Tracking-Pixel.
Tech-Stack: Next.js + Supabase + Resend + Vercel. Status: in
Entwicklung. Keine Nachbarprojekte.

## Session-Start — Leseroutine

Vor der ersten inhaltlichen Aktion in jeder Session in dieser
Reihenfolge lesen:

1. `docs/README.md` — Doku-Konventionen
2. `docs/05-status.md` — aktuelle Deltas
3. `docs/01-concept.md` — Ziel verinnerlichen
4. Topic-Datei passend zum Session-Thema:
    - Architektur-Frage → `docs/02-architecture.md`
    - Schema-/DB-Frage → `docs/03-datamodel.md`
    - Deployment-/Infrastruktur-Frage → `docs/04-deployment.md`
5. `docs/06-decisions.md` — bei Architektur- oder Strategie­
   fragen

Der Code unter `app/`, `components/`, `lib/`, `supabase/` ist
Single Source of Truth für die Implementierung.

## Doku-Struktur

```
docs/
├── README.md                Doku-Konventionen
├── 01-concept.md            Produktvision, Scope
├── 02-architecture.md       Tech-Stack, Komponenten
├── 03-datamodel.md          Tabellen, RLS, Migrationen
├── 04-deployment.md         Vercel, Supabase, Resend, Cron
├── 05-status.md             Delta-Register
├── 06-decisions.md          ADRs
└── _source/                 historische Originaldokumente
```

ID-Präfix für Deltas: **`NL`** (z. B. `NL-001`).

## Update-Pflicht bei jeder Code-Änderung

Kein Commit ohne Doku-Bewertung. Vor jedem Commit prüfen:

- **Neues Feature / Architektur-Änderung** → `## Ist` der
  betroffenen Topic-Datei aktualisieren, `last_reviewed` bumpen.
- **Bewusste Designentscheidung** → ADR in `06-decisions.md`.
- **Schema-Änderung** → `03-datamodel.md` aktualisieren,
  Migration in `supabase/migrations/` mit fortlaufender Nummer.
- **Deployment-Änderung** → `04-deployment.md` aktualisieren.
- **Reiner Refactor** → nur `last_reviewed` bumpen.
- **Delta erledigt** → Eintrag in `05-status.md` mit
  Strikethrough markieren, nicht löschen.

## Session-Typen

- **Doku-Session**: Doku IST die Arbeit. Code unberührt.
- **Code-Session**: Code wird geändert, Doku wird mitgepflegt.
- **Delta-Arbeit**: Umsetzung eines konkreten Delta-Eintrags.
- **Read-only**: Nur Nachschlagen.

## Commit-Disziplin

- Explizites Staging — niemals `git add .` ohne `git status`-
  Check.
- Commit-Messages auf Deutsch, imperativ, knapp.
- Pro Commit ein logisch abgeschlossener Schritt.
- **Secrets niemals in Commits** — nur Variablennamen in
  `04-deployment.md`.

## Wenn Doku und Code widersprechen

1. Widerspruch explizit benennen, nicht still auflösen.
2. Entscheiden: Doku falsch (korrigieren) oder Code vom Ziel
   abgewichen (Delta in `05-status.md` anlegen).
3. Wenn unklar: ADR schreiben.

## Projekt-spezifische Hinweise

- **Tracking-Pixel und DSGVO**: Open-Tracking ist nur mit
  expliziter Einwilligung erlaubt (siehe `01-concept.md`,
  Sektion „Tracking"). Bei Code-Änderungen am Tracking immer
  prüfen, dass Opt-out funktioniert.
- **Keine Mail an unsubscribed Abonnenten**: harte Pflicht-
  Prüfung im Send-Pfad. Tests existieren in
  `lib/__tests__/sendlist.test.ts`.
