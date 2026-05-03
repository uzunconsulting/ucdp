---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <n>
---

# 04 · Deployment

## Ziel

### Deployment in einem Satz

<Wo läuft das Projekt, mit welchem Deployment-Verfahren.>

### Hosting-Bestandteile

| Komponente | Anbieter | Region | Tarif (initial) |
| ---------- | -------- | ------ | --------------- |
|            |          |        |                 |

### Domains und Subdomains

<App-URL, Mail-Absender, DNS-Einträge.>

### Environment-Variablen

<Nur Variablennamen, niemals Werte. Zwecks Übersicht gruppiert
(z. B. nach Anbieter).>

```
# <Gruppe>
VARIABLE_NAME              <kurze Beschreibung>
```

### Cron-Jobs

<Konfiguration in `vercel.json` o. Ä., Endpoints, Intervalle,
Authentifizierung.>

### Storage-Konfiguration

<Buckets, Berechtigungen, Unveränderbarkeit falls relevant.>

### Backups

<Datenbank, Storage, externe Sicherung. Aufbewahrungsfristen.>

### Logging und Monitoring

<Wo landen Logs? Wie sehen Failure-Alerts aus?>

### Environments

<Production / Preview / Development — separate Instanzen oder
gemeinsam? Welche Daten leben wo?>

### Setup-Checkliste (Go-Live)

<In Phasen gegliedert. Wird abgehakt beim ersten Deployment.>

**Phase 1 — Infrastruktur einrichten**

- [ ] <…>

**Phase 2 — …**

- [ ] <…>

### Disaster-Recovery-Verfahren

<Was tun bei Ausfall der einzelnen Komponenten?>

## Ist

(Bei Greenfield: leer lassen. Wird mit dem ersten erfolgreichen
Deployment befüllt.)

## Offene Deltas (→ 05-status.md)

(Werden im Status-Register angelegt.)
