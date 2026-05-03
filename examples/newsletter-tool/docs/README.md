---
project: newsletter-tool
last_reviewed: 2026-05-03
last_reviewed_by: Demo Author
---

# Projektdokumentation

Diese Dokumentation folgt dem Uzun Consulting Documentation
Pattern (UCDP). Siehe [PATTERN.md](https://github.com/uzunconsulting/ucdp/blob/main/PATTERN.md)
für die vollständige Beschreibung der Konvention.

## Dateien

- `01-concept.md` — Produktvision (Ziel)
- `02-architecture.md` — System-Architektur
- `03-datamodel.md` — Datenmodell
- `04-deployment.md` — Infrastruktur und Deployment
- `05-status.md` — Delta-Register (lebendes Dokument)
- `06-decisions.md` — ADRs (unveränderlich)
- `_source/` — Historische Originaldokumente

## Konventionen

- **Prioritäten**: P1 (diese Woche) / P2 (dieses Quartal) /
  P3 (nice-to-have)
- **Delta-IDs**: `NL-NNN`, fortlaufend
- **ADRs**: fortlaufend nummeriert, einmal geschrieben unverändert
- **Secrets**: niemals in der Doku
- **`_source/`**: read-only

## Leseroutine für KI-Assistenten

Siehe `CLAUDE.md` im Projekt-Root.
