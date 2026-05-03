---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <n>
---

# 03 · Datenmodell

## Ziel

### Datenmodell in einem Satz

<Welche Datenbank, welche zentralen Konzepte, welche besonderen
Eigenschaften (RLS, Append-only, Multi-Tenant, …).>

### Konventionen

<Tabellen-Naming, Primärschlüssel-Strategie, Zeitstempel,
Geld-/Zeit-Behandlung, Sprache der Spalten, Soft-Delete-
Strategie.>

### Tabellen — Übersicht

```
<gruppierte Auflistung der Tabellen>
```

### Tabelle: `<tabellenname>`

<Beschreibung des Tabellenzwecks.>

| Spalte | Typ | Nullable | Bemerkung |
| ------ | --- | -------- | --------- |
|        |     |          |           |

### Beziehungen — ER-Skizze

```
<ASCII-ER-Diagramm oder strukturierte Beschreibung>
```

### Row-Level-Security (oder vergleichbar)

<Policy-Strategie, falls relevant.>

### Migrationsstrategie

<Tool, Reihenfolge der initialen Migrationen, Branching-Verhalten.>

### Storage-Layout

<Falls Datei-Ablage relevant ist: Bucket-Struktur, Pfad-
Konvention, Berechtigungen.>

### Nicht-funktionale Aspekte

<Backups, PII, Aufbewahrungsfristen, Anonymisierung.>

## Ist

(Bei Greenfield: leer lassen. Wird mit dem Migrationsstand der
Datenbank befüllt.)

## Offene Deltas (→ 05-status.md)

(Werden im Status-Register angelegt.)
