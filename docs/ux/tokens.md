# Design-Tokens — wunddoku

> Wird ausgefüllt, **bevor** der erste Screen entsteht. Umsetzung in
> `lib/shared/theme/`, Regel in `22-design-tokens.md`.

## Gestaltungsrichtung

Der Bildschirm wird in einer fremden Wohnung gelesen, im Stehen, einhändig, in
Blicken von zwei bis drei Sekunden, bei Licht, das niemand ausgesucht hat — dunkler
Altbauflur, Gegenlicht am Fenster, Nachtbesuch mit Stehlampe. Der Patient sitzt
daneben und sieht mit. Das Gerät ist Werkzeug, nicht Aufenthaltsort.

Daraus folgt eine **Instrumenten-Haltung**: wenige Elemente, sehr großer
Größenkontrast, ruhige neutrale Flächen, und Farbe ausschließlich dort, wo sie eine
Aussage trägt. Nicht „clean minimal" — sondern *ablesbar auf Armlänge, in einem
Blick, mit Handschuhen*.

Drei Festlegungen, die aus der Fachlichkeit kommen und nicht aus dem Geschmack:

1. **Farbe ist in dieser App eine Vertrauensaussage.** Gesättigte Farbe bedeutet
   ausschließlich: „hier stimmt etwas nicht" oder „hier musst du entscheiden". Wo
   nichts zu entscheiden ist, ist die Oberfläche neutral. Deshalb gibt es keine
   dekorative Akzentfarbe und keine bunten Kategorie-Chips.
2. **Um ein Wundfoto herum ist die Oberfläche farbneutral.** Die Beurteilung
   unterscheidet Nekrose (schwarz), Fibrin (gelb), Granulation (rot),
   Epithelisation (rosa) — vier Farbeindrücke. Ein farbiger Rahmen, ein getönter
   Verlauf oder ein farbiger Overlay daneben verschiebt diese Wahrnehmung. Der
   Bildbereich sitzt deshalb in beiden Themes auf demselben neutralen Mittelgrau,
   ohne Tönung, ohne Schatten mit Farbanteil.
3. **Die Markierungsfarbe kommt in keiner Wunde vor.** Zyan und Magenta liegen
   maximal entfernt von allen Gewebefarben und sind damit auf jedem Wundfoto
   eindeutig als Fremdkörper erkennbar — die aktuelle Kontur in Zyan, die Kontur des
   Vorbesuchs beim Vergleich in Magenta.

**Referenzen:** medizinische Messgeräte und Cockpit-Anzeigen (Wert groß, Bezeichnung
klein, Zustand unübersehbar); Kamera-Apps für den ruhigen, neutralen Bildbereich.
**Gegenbeispiele:** pastellige Wellness-Apps (Farbe ohne Aussage), dichte
Klinik-Tabellenmasken (alles gleich betont, nichts auf einen Blick lesbar).

---

## Farbe

Basis über `ColorScheme.fromSeed`, gezielte Überschreibungen statt Handarbeit an
jedem Wert. Semantische Zusatzfarben in einer `ThemeExtension`.

**Seed:** `#0B5F6B` — gedecktes Blaugrün. Gewählt, weil es von allen Gewebefarben
weit entfernt liegt und in Nachbarschaft zu einem Wundfoto nicht mitfärbt.

| Rolle | Light | Dark | Wofür |
|---|---|---|---|
| primary | aus Seed | aus Seed | ausschließlich die primäre Aktion je Screen |
| onPrimary | aus Seed | aus Seed | Beschriftung darauf |
| surface | `#FCFCFD` | `#121315` | Grundfläche |
| surfaceContainer | `#F1F2F4` | `#1D1F21` | Karten, Zeilen |
| onSurface | `#16181A` | `#E6E8EA` | Text |
| onSurfaceVariant | `#4A4E52` | `#B4B8BC` | Feldbezeichnungen |
| outline | `#7A7E82` | `#8A8E92` | Trennlinien, Lückenrahmen |
| error | `#B3261E` | `#F2B8B5` | Fehler |
| **media-ground** | `#3A3D40` | `#3A3D40` | **identisch in beiden Themes** — Fläche hinter Wundfotos |
| **status-entscheiden** | `#B3261E` | `#F2B8B5` | niedrige Sicherheit, blockiert das Speichern |
| **status-pruefen** | `#8A5A00` | `#F5C46B` | mittlere Sicherheit, Blick empfohlen |
| **status-sicher** | `onSurface` | `onSurface` | **farblos** — Sicherheit ist der Normalfall und braucht keine Farbe |
| **status-luecke** | `outline` | `outline` | gestrichelter Rahmen, kein Wert |
| **status-offline** | `#4A4E52` | `#B4B8BC` | neutral: offline ist kein Fehler, sondern der Normalzustand |

Nur zwei gesättigte Farben tragen Zustand — Rot für „entscheiden", Bernstein für
„prüfen". Das ist bewusst wenig: Wo alles farbig ist, bedeutet Farbe nichts mehr.

**Farbe ist nie das einzige Merkmal.** Jeder Zustand hat zusätzlich ein Symbol und
einen Text; die Sicherheitsstufe steht im `semanticsLabel`. Damit trägt die
Unterscheidung auch bei Farbfehlsichtigkeit, bei Sonnenlicht und für Screenreader.

- **Kontrast geprüft:** *steht aus.* Zielwerte: 4,5:1 für Fließtext, 3:1 für große
  Schrift und Bedienelemente. Geprüft wird mit einem Skript über die Token-Tabelle,
  nicht per Augenmaß; Ergebnis kommt in Slice 1 hierher.

---

## Typografie

Anforderungen aus der Sache: **Ziffern mit fester Breite** (Maße und Verlaufsspalten
müssen untereinander stehen), großer Gewichtsumfang für Größenkontrast ohne zweite
Familie, saubere Umlaute, und die Datei muss **mitgeliefert** werden — eine Schrift,
die zur Laufzeit nachgeladen wird, funktioniert weder offline noch datenschutzfrei.

Eine Familie, differenziert über Gewicht und Größe. Die konkrete Familie läuft über
`/eps:technikwahl` (Kriterien: Lizenz für Kundensoftware, variabler Schnitt,
`tnum`-Feature, Dateigröße).

| Rolle | Größe | Zeilenhöhe | Schnitt | Wofür |
|---|---|---|---|---|
| display | 40 | 1.10 | 700 | Messwert, groß, mit `tnum` |
| headline | 28 | 1.20 | 600 | Screentitel |
| title | 20 | 1.30 | 600 | Kartenüberschrift |
| body | 17 | 1.45 | 400 | Fließtext, Transkript |
| bodyStrong | 17 | 1.45 | 600 | erkannter Wert in der Bestätigungszeile |
| label | 13 | 1.30 | 500 | Feldbezeichnung, Einheiten |

- **Skalenverhältnis:** ~1,25 (Major Third), von 13 aufwärts gerundet auf ganze Punkte
- **Familien:** eine
- **Größenkontrast display zu label: Faktor 3.** Das ist die Hierarchie — der Wert
  wird gelesen, die Bezeichnung nur bei Bedarf.
- **Prüfung bei 200 %:** Zeilen brechen um statt abzuschneiden; keine feste Höhe an
  textführenden Behältern; geprüft auf 320 dp Breite

---

## Abstand und Form

- **Abstandsskala:** 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 (Basis 4)
- **Rhythmus statt gleichmäßigem Polster:** 16 innerhalb einer Karte, 24 zwischen
  Abschnitten, 48 vor der primären Aktion. Der große Abstand vor dem Hauptknopf ist
  Teil der Bedienbarkeit — er verhindert Fehlgriffe mit Handschuhen.
- **Radien:** xs 4 · sm 8 · md 12 (Karten) · lg 20 · full (primäre Aktion als Pille)
- **Erhebung:** flach. Trennung über Fläche und Abstand, nicht über Schatten —
  Schatten sind bei Sonnenlicht unsichtbar und kosten `saveLayer`.
- **Trefferflächen:** ≥ 48 dp, in der Bestätigungsansicht ≥ 64 dp je Zeile.
  WCAG 2.2 SC 2.5.8 verlangt 24×24 CSS-Pixel als AA-Untergrenze; die
  Plattformvorgabe ist strenger und bleibt hier die Messlatte.
- **Daumenzone:** primäre Aktion in den unteren 30 % des Bildschirms; Löschen und
  Verwerfen ausdrücklich außerhalb.

---

## Bewegung

M3 Expressive gilt hier als **Gestaltungsrichtung, nicht als Bauteillager**:
Flutter 3.41.5 liefert in `material/motion.dart` nur `Durations` und `Easing`, keine
Spring-Tokens und keine Formbibliothek. Federbasierte Bewegung ist damit Eigenbau
über `SpringDescription` aus `physics.dart` — als Eigenbau benannt, nicht als
Framework-Funktion ausgegeben.

| Token | Art | Werte | Wofür |
|---|---|---|---|
| `spatialDefault` | Feder | mass 1 · stiffness 380 · damping 30 | Bewegung von Elementen, Screenwechsel im Besuchskorridor |
| `spatialFast` | Feder | mass 1 · stiffness 700 · damping 34 | kleine Positionswechsel, Zeilen, die nach oben sortiert werden |
| `effectsDefault` | Dauer | 200 ms · `Easing.standard` | Farbe, Deckkraft, Zustandswechsel |
| `kurz` | Dauer | 120 ms · `Easing.standardAccelerate` | Antippquittung |

Die Federwerte sind **Startwerte und auf dem Gerät nachzujustieren** — Desktop-Motion
täuscht. Nachweis über die Agentenschleife auf Android, nicht per Augenmaß auf Linux.

**Wo Bewegung etwas erklärt** — und nur dort:

- In der Bestätigungsansicht sortieren sich Zeilen sichtbar nach oben, sobald ein
  Feld entschieden ist. Die Bewegung zeigt, dass die Arbeit weniger wird.
- Der Wechsel zwischen den vier Stationen des Besuchs läuft räumlich in eine
  Richtung, damit „wo bin ich" ohne Lesen beantwortet ist.
- Der Aufnahmezustand pulsiert langsam — als zweiter, nicht als einziger Träger der
  Information.

**Grenzen:** Bewegung nur auf `transform`- und opazitätsartigen Eigenschaften.
`MediaQuery.disableAnimations` wird respektiert; nicht wesentliche Animation entfällt
dann vollständig, und **keine Information hängt allein an Bewegung** — der
Aufnahmezustand bleibt dann über Symbol, Text und Haptik erkennbar.

---

## Umsetzung

```
lib/shared/theme/
  app_theme.dart        // ThemeData light/dark aus den Tokens
  color_tokens.dart     // ColorScheme + StatusColors ThemeExtension
  type_tokens.dart      // TextTheme, tabellarische Ziffern
  space_tokens.dart     // Abstände, Radien, Trefferflächen
  motion_tokens.dart    // SpringDescription, Dauern
```

Feature-Code liest ausschließlich über `Theme.of(context)`. Eine hartkodierte Farbe
oder Größe im Feature-Code ist ein Review-Befund.
