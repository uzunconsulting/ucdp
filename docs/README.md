---
project: <projektname>
last_reviewed: <YYYY-MM-DD>
last_reviewed_by: <n>
---

# Projektdokumentation

Diese Dokumentation folgt dem Uzun Digital Documentation
Pattern (UDDP). Siehe [PATTERN.md](https://github.com/uzunconsulting/ucdp/blob/main/PATTERN.md)
für die vollständige Beschreibung der Konvention.

## Dateien

- `01-concept.md` — Produktvision (Ziel)
- `02-architecture.md` — System-Architektur (Ziel/Ist/Deltas)
- `03-datamodel.md` — Datenmodell (Ziel/Ist/Deltas)
- `04-deployment.md` — Infrastruktur und Deployment
  (Ziel/Ist/Deltas)
- `05-status.md` — Delta-Register (lebendes Dokument)
- `06-decisions.md` — ADRs (unveränderlich)
- `08-agent-runs.md` — Register autonomer Agent-Runs (optional;
  nur anlegen, wenn das Projekt agentisch gebaut wird, siehe
  PATTERN.md Abschnitt 10)
- `_source/` — Historische Originaldokumente (nicht editieren)

## Konventionen

- **Prioritäten**: P1 (diese Woche) / P2 (dieses Quartal) /
  P3 (nice-to-have)
- **Delta-IDs**: `<PRÄFIX>-NNN`, fortlaufend, niemals neu vergeben
- **Run-IDs** (falls `08-agent-runs.md` genutzt wird):
  `<PRÄFIX>-RUN-NNNN`, fortlaufend, niemals neu vergeben
- **ADRs**: fortlaufend nummeriert, einmal geschrieben nicht mehr
  editiert; bei Widerruf neues ADR mit `supersedes:`-Verweis
- **Secrets**: niemals in der Doku, nur Variablennamen
- **`_source/`**: read-only, niemals editieren

## Leseroutine für KI-Assistenten

Siehe `CLAUDE.md` im Projekt-Root.
