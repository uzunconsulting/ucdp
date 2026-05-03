---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <n>
---

# Status — offene Deltas Ziel ↔ Ist

Dieses Register listet bekannte Abweichungen zwischen dem Ziel-
zustand (siehe Topic-Dateien `01`–`04`) und dem aktuellen
Implementierungsstand. Erledigte Deltas werden mit Strikethrough
und Datum markiert, **nicht gelöscht**.

## Offene Deltas

| ID         | Bereich               | Soll                          | Ist                          | Offene Arbeit                  | Priorität | ADR       |
|------------|-----------------------|-------------------------------|------------------------------|--------------------------------|-----------|-----------|
| <PRÄFIX>-001 | architecture/example  | <Sollzustand kurz>            | <Istzustand kurz>            | <Was zu tun ist>               | P2        | —         |

<Beispielzeile oben durch echte Einträge ersetzen oder löschen,
sobald die ersten echten Deltas vorliegen.>

## Konventionen

- **Priorität**: P1 (diese Woche) / P2 (dieses Quartal) /
  P3 (nice-to-have, blockiert nichts).
- **ID**: `<PRÄFIX>-NNN`, fortlaufend, niemals neu vergeben.
- **Bereich**: Kennung aus den Topic-Dateien (`concept`,
  `architecture`, `datamodel`, `deployment`) plus Sub-Aspekt,
  z. B. `architecture/intake`.
- **Abschluss**: erledigte Deltas werden mit Strikethrough und
  Datum markiert, **nicht gelöscht**:

```
| ~~<PRÄFIX>-001~~ | ~~architecture/example~~ | ~~Sollzustand~~ | ~~erledigt YYYY-MM-DD~~ | — | ~~P2~~ | — |
```

## Erläuterungen zu einzelnen Einträgen

Wenn ein Delta zu komplex für eine Tabellenzeile ist, kommt eine
freitextliche Erläuterung in diesen Abschnitt mit der Delta-ID
als Überschrift.

(initial leer)
