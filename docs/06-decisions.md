---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <n>
---

# Architectural Decision Records

ADRs werden chronologisch nummeriert. Einmal geschrieben werden
sie nicht mehr editiert. Bei Widerruf: neues ADR mit
`supersedes: ADR-NNNN`-Verweis, das alte bleibt stehen.

Format pro ADR: Status / Kontext / Entscheidung / Konsequenzen /
Verweise.

---

## ADR-0001 · <Titel der Entscheidung>

**Status:** Akzeptiert (<YYYY-MM-DD>)

### Kontext

<Welches Problem liegt vor? Welche Alternativen standen zur
Wahl? Warum jetzt?>

Alternativen:

- (A) <…>
- (B) <…>
- (C) <…>

### Entscheidung

<Was konkret entschieden wurde. Ein Satz, oder wenige.>

### Konsequenzen

- **Positiv**: <…>
- **Negativ**: <…>

### Verweise

- `<docs-pfad>` → <Sektion>
- Implementierung: `<code-pfad>`
- Verwandtes ADR: `<andere-app/ADR-NNNN>` (falls relevant)
- Betroffenes Delta: `<PRÄFIX>-NNN` (falls relevant)

---

(Neue ADRs werden chronologisch unten angefügt. ADR-Nummern
werden niemals wiederverwendet.)
