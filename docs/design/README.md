# Gestaltungsentwurf aus Claude Design

Quelle: Projekt „Mobile app design form" (Claude Design), importiert am
2026-08-13 über `DesignSync`. Original: `wunddoku-app.dc.html`, je Screen
zerlegt unter `screens/`.

Der Entwurf ist keine Gegenposition, sondern eine **Verschärfung** des
festgelegten Wegs: er verwendet die Tokens aus `lib/shared/theme/`
unverändert — `#0F6E7E`, `#0F3B45`, `#3E5C63`, `#F7FAFA`, `#EDF2F3`,
`#E2EAEB`, `#728E95`, den Medienuntergrund `#3A3D40` — und dieselbe
Typoskala 30 / 22 / 20 / 16 / 13. Er heißt dort selbst „Ruhiges
Fachwerkzeug, geschärft".

| Datei | Screen |
|---|---|
| `1a` | Patienten — Startbildschirm |
| `1b` | Patient · Wunden |
| `1c` | Befund sprechen — Ruhezustand |
| `1d` | Aufnahme läuft |
| `1e` | Prüfen — Vorschläge entscheiden |
| `1f` | Karten — Erfassung ohne Sprache |
| `1g` | Wunde fotografieren |
| `1h` | Wunde markieren |
| `1i` | Besuch abschließen |
| `1j` | Verlauf |
| `0a`–`0d` | Ist-Zustand, aus dem Flutter-Code nachgebaut |

## Was der Entwurf ergänzt

- **Besuchsband** über dem Inhalt: Sprechen · Prüfen · Foto · Abschluss,
  immer sichtbar. Beantwortet die Frage „wo bin ich" strukturell, statt sie
  dem Bildschirmtitel zu überlassen.
- **Offline-Anzeige** in der Statuszeile — der Normalzustand im Feld, bisher
  nirgends sichtbar.
- **Die drei gleichwertigen Wege als drei gleich große Kacheln** über dem
  96-px-Ziel statt als Liste darunter.
- Trefferflächen als Zahl: Suchfeld 56 px, Patientenzeile 88 px, ein Weg
  zurück in eine Lücke 64 px.

`standardfallen.md` führt „drei gleich große Kacheln nebeneinander" als
Modellvorliebe. Hier ist die Gleichbehandlung inhaltlich richtig — Sprache,
Karten und Foto sind gleichwertige Wege, keine Rangfolge —, also gilt die
Ausnahme. Beim Übernehmen ist das die eine Stelle, an der gegen die Regel
entschieden wird, und sie steht deshalb hier.
