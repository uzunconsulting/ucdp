# UDDP Git-Hooks (optional)

Die Hooks unter [`../.claude/hooks/`](../.claude/hooks/) greifen **während einer
Claude-Code-Session**. Wer von Hand committet, mit einem anderen Assistenten
arbeitet oder die Session-Hooks nicht aktiviert hat, ist von ihnen nicht
erfasst. Diese Hooks hier decken den anderen Moment ab: den **Commit** und den
**Push** — werkzeugunabhängig.

Es gibt auch eine Lücke *innerhalb* von Claude Code, die sie schließen: der
Doku-Ende-Check steigt aus, wenn `git status` sauber ist. Wer seinen Code
committet und dann die Session beendet, umgeht ihn heute schon.

## Aktivieren

Pro Klon einmalig — Git-Hooks wandern nicht automatisch mit dem Repo mit:

```bash
git config core.hooksPath .githooks
```

Prüfen, ob es greift:

```bash
git config --get core.hooksPath
```

Unter Windows laufen die Hooks über die mit Git ausgelieferte `sh`. Die
`.gitattributes` im Repo-Root erzwingt für `.githooks/**` LF-Zeilenenden —
ohne das scheitert der Hook mit „bad interpreter".

## Was sie tun

| Hook | Verhalten | Wirkung |
|---|---|---|
| `pre-commit` | **blockt** | gestagte `.env`-Dateien (`.env.example` & Co. sind ausgenommen) |
| `pre-commit` | **blockt** | bekannte Secret-Muster in hinzugefügten Zeilen: Anthropic-/OpenAI-Keys, AWS-Access-Keys, GitHub- und GitLab-Token, Slack-Token, Google-API-Keys, private Schlüssel, JWTs |
| `pre-commit` | **warnt** | generisch aussehende Zugangsdaten-Zuweisungen (`token = "…"`) |
| `pre-commit` | **warnt** | Code gestagt, `docs/` unberührt |
| `pre-push` | **warnt** | der gesamte Push enthält Code-Änderungen, aber keine unter `docs/` |

## Warum blocken und warnen sich unterscheiden

Blockiert wird nur, was **unwiederbringlich oder gefährlich** ist. Ein Secret,
das einmal gepusht wurde, ist verbrannt, auch wenn der Commit später
verschwindet — das rechtfertigt einen harten Stopp. Fehlende Doku dagegen ist
jederzeit nachholbar.

Ein erzwungener `docs/`- oder CHANGELOG-Eintrag **pro Commit** hätte zudem die
falsche Granularität: UDDPs Doku-Pflicht hängt an der Arbeitseinheit, nicht am
einzelnen Commit. Erzwungen produziert sie Alibi-Zeilen, und Alibi-Zeilen sind
schlimmer als eine ehrliche Lücke — sie machen das Delta-Register unglaubwürdig.
Deshalb: `pre-commit` erinnert, `pre-push` erinnert deutlicher, blockiert wird
nicht. Der harte Doku-Stopp bleibt beim Session-Ende-Check, wo die Arbeitseinheit
tatsächlich endet.

## Notausgänge

```bash
UDDP_SKIP_SECRETS=1 git commit -m "…"   # nur der Secret-Scan aus (UCDP_SKIP_SECRETS gilt weiter)
git commit --no-verify                   # alle pre-commit-Prüfungen aus
git push --no-verify                     # pre-push aus
```

## Ergänzen

`pre-push` hat am Ende eine auskommentierte Zeile für ein Build-Gate. Projekte
mit Tests oder Typecheck hängen ihren Aufruf dort an — dann blockiert er auch,
und zwar an der Stelle, an der ein Blocker sinnvoll ist.

## Löschen

Ungenutzt? `.githooks/` löschen. Nichts anderes im Pattern hängt davon ab.
