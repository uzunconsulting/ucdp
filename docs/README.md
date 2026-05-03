---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <n>
---

# Projektdokumentation

Diese Dokumentation folgt dem Uzun Consulting Documentation
Pattern (UCDP). Siehe [PATTERN.md](https://github.com/uzunconsulting/ucdp/blob/main/PATTERN.md)
für die vollständige Beschreibung der Konvention.

## Dateien

- `01-concept.md` — Produktvision (Ziel)
- `02-architecture.md` — System-Architektur (Ziel/Ist/Deltas)
- `03-datamodel.md` — Datenmodell (Ziel/Ist/Deltas)
- `04-deployment.md` — Infrastruktur und Deployment
  (Ziel/Ist/Deltas)
- `05-status.md` — Delta-Register (lebendes Dokument)
- `06-decisions.md` — ADRs (unveränderlich)
- `_source/` — Historische Originaldokumente (nicht editieren)

## Konventionen

- **Prioritäten**: P1 (diese Woche) / P2 (dieses Quartal) /
  P3 (nice-to-have)
- **Delta-IDs**: `<PRÄFIX>-NNN`, fortlaufend, niemals neu vergeben
- **ADRs**: fortlaufend nummeriert, einmal geschrieben nicht mehr
  editiert; bei Widerruf neues ADR mit `supersedes:`-Verweis
- **Secrets**: niemals in der Doku, nur Variablennamen
- **`_source/`**: read-only, niemals editieren

## Leseroutine für KI-Assistenten

Siehe `CLAUDE.md` im Projekt-Root.
