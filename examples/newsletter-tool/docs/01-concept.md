---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# 01 · Konzept

## Ziel

### Produktvision in einem Satz

newsletter-tool ist eine selbst-gehostete Newsletter-Anwendung
für einen Solo-Betreiber, der seine Abonnentenliste, seine
Ausgaben und seine Versand-Statistiken vollständig in eigener
Hand behalten will, ohne auf einen Drittanbieter wie Mailchimp
oder Substack angewiesen zu sein.

### Geschäftskontext

Der Betreiber führt einen wöchentlichen Newsletter zu einem
Fachthema mit aktuell rund 800 Abonnenten, geplant wachsend auf
einige tausend. Bisher nutzte er einen kommerziellen Anbieter,
will aber aus zwei Gründen wechseln: Erstens ist die monatliche
Gebühr ab einer bestimmten Listengröße erheblich; zweitens
möchte er die Abonnentendaten nicht in einem US-basierten Dienst
liegen haben, sondern in einer EU-Region.

newsletter-tool soll diese beiden Punkte adressieren — Self-
Hosting in der EU und Pay-per-Mail-Versand über einen
spezialisierten Mail-Anbieter — bei einem für eine Solo-Person
beherrschbaren Wartungsaufwand.

### Was das Projekt tut

**Abonnentenverwaltung:**

- Import einer bestehenden Abonnentenliste per CSV.
- Manuelles Anlegen, Bearbeiten und Entfernen einzelner
  Abonnenten im Admin-UI.
- Double-Opt-in-Anmeldung über ein öffentliches Anmeldeformular
  (eingebettet auf der Betreiber-Website).
- One-Click-Unsubscribe in jeder versandten Mail.

**Ausgabenverwaltung:**

- Erfassung von Newsletter-Ausgaben als Markdown im Admin-UI,
  mit Vorschau-Rendering.
- Anhängen von Bildern (gespeichert in Supabase Storage).
- Speicherung als Draft, Veröffentlichung als „bereit zum
  Versand", Versand-Auslösung manuell durch den Betreiber.

**Versand:**

- Versand der aktuellen Ausgabe an die gesamte aktive
  Abonnentenliste über Resend, in Batches von 100 pro Minute,
  um Rate-Limits zu respektieren.
- Eindeutiger Tracking-Pixel pro Empfänger für Open-Tracking
  (nur bei Opt-in-Zustimmung).
- Personalisierter Unsubscribe-Link pro Empfänger.

**Statistiken:**

- Pro Ausgabe: Anzahl Empfänger, Open-Rate, Bounce-Rate,
  Unsubscribe-Rate.
- Über alle Ausgaben hinweg: Wachstumskurve der Liste.

**Tracking — DSGVO-Hinweis:**

Open-Tracking erfolgt nur bei expliziter Einwilligung des
Abonnenten beim Anmeldevorgang. Wer nicht zustimmt, erhält
trotzdem den Newsletter, wird aber nicht im Open-Tracking
erfasst.

### Was das Projekt NICHT tut (Scope-Abgrenzung)

- **Keine A/B-Tests** auf Subject-Lines oder Inhalten.
- **Keine Segmentierung** der Abonnentenliste — alle aktiven
  Abonnenten erhalten jede Ausgabe.
- **Keine automatischen Sequenzen** (Drip-Campaigns,
  Begrüßungs-Serien).
- **Kein Multi-User-Setup** — genau ein Betreiber-Account.
- **Kein integrierter Editor** über Markdown hinaus.

### Zielgruppen / Nutzer

- **Betreiber**: einziger Admin-Nutzer. Authentifiziert sich per
  Supabase Auth (Magic Link).
- **Abonnenten**: keine direkte Interaktion mit der App außer
  Anmeldung über das Anmeldeformular und Unsubscribe-Klick in
  Mails.

### Erfolgskriterien

newsletter-tool gilt als erfolgreich produktiv, wenn:

1. Die bestehende Abonnentenliste vollständig und ohne
   Datenverlust aus dem alten Anbieter importiert ist.
2. Eine Newsletter-Ausgabe in unter 10 Minuten erstellt,
   geprüft und versandt werden kann.
3. Open-Tracking funktioniert für die Abonnenten, die
   eingewilligt haben — und garantiert nicht für die anderen.
4. Eine Bounce-Rate über 5% auf einer einzelnen Ausgabe wird
   per E-Mail an den Betreiber gemeldet.
5. Die monatlichen Betriebskosten unter 30 € liegen
   (Supabase Pro + Resend + Vercel Pro nicht zwingend, Hobby
   reicht initial).

### Nicht-funktionale Anforderungen

- **Volumen**: 800–5.000 Abonnenten, 1 Versand pro Woche, also
  3.200–20.000 Mails/Monat.
- **Verfügbarkeit**: keine harten SLA-Anforderungen. Versand
  ist nicht zeitkritisch — Verzögerung um Stunden ist okay.
- **DSGVO**: Daten in der EU (Supabase Frankfurt), Double-Opt-in,
  One-Click-Unsubscribe, Tracking nur bei Einwilligung.
- **Sprache**: deutsch (UI und Newsletter-Inhalte).
- **Performance**: Admin-UI lädt Listen unter 1s bei bis zu
  10.000 Einträgen.

## Ist

Implementierung ist gestartet. Aktueller Stand:

- Supabase-Schema deployed (Migrations 0001–0005).
- Admin-Login (Magic Link) funktioniert.
- Abonnentenverwaltung: CSV-Import + manuelles Anlegen/
  Bearbeiten implementiert. Anmeldeformular existiert noch
  nicht (siehe `NL-002`).
- Ausgabenerfassung: Markdown-Editor und Vorschau funktionieren.
- Versand: noch nicht implementiert (siehe `NL-001`).
- Tracking: noch nicht implementiert.

## Offene Deltas (→ 05-status.md)

Siehe `NL-001` (Versand), `NL-002` (Anmeldeformular),
`NL-003` (Tracking-Pixel), `NL-004` (Bounce-Alerts).
