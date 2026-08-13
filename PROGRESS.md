# Stand — wunddoku

> Wird nach jedem Arbeitspaket nachgezogen. Repo plus diese Datei müssen reichen,
> damit eine frische Session weitermacht.

**Zuletzt aktualisiert:** 2026-08-13

## Wo wir stehen

`/eps:projekt-start`, `/eps:ux-prozess` und die erste Runde `/eps:technikwahl`
sind durch. Es liegen vor:

- UX-Konzept unter `docs/ux/` — Ist-Prozess, 10 Job Stories, Story Map mit vier
  Slices, Aktivierungsereignis, fünf Flows, 16 Screens mit Zuständen, Tokens,
  Nachprozess
- `docs/fachkataloge.md` — Katalogrecherche gegen Primärquellen
- `lib/domain/catalog/` — sechs Value-Object-Dateien, 32 Tests grün,
  Analyzer sauber
- Technikentscheidungen für Slice 1 in `DECISIONS.md`
- verschlüsselte Datenbank samt Patient-Repository
- Sprachstrecke Stufe 1: Transkript → typisierte Vorschläge, ohne Schlüssel
- Theme in der Gestaltungsrichtung „Instrument", gebündelte Schrift
- **Besuchskorridor lauffähig**: Aufnahme (Phase A) → Bestätigung (Phase B),
  auf dem Gerät belegt
- **Foto mit Markierung**: Sucher mit Geisterbild der Voraufnahme, Markierung
  als normalisierte Geometrie, eingebrannte Zweitdatei, verschlüsselte
  Medienablage — auf dem Gerät belegt

- **Abschluss**: Lücken benannt, Abschluss nie gesperrt, Besuch wird als
  vollständig oder als „mit Lücken" geführt; danach beginnt der nächste Besuch

- **Verlauf**: Kurve der Fläche über die Besuche (Lücken bleiben Lücken),
  Besuchsliste mit Miniaturen, Veränderung gegen den Nachbarbesuch
- **PDF-Wundbericht**: Kopf, Verlaufstabelle, je Besuch Foto und Befund;
  Lücken als „fehlt", Vergleichbarkeitsvermerk am ersten Foto

Damit ist Slice 1 inhaltlich zu. Der vollständige Durchlauf auf dem Gerät
(Motorola edge 30 ultra) ist am 2026-08-12 gelaufen — Sprache, Karten, Foto,
Markierung, Abschluss, Verlauf, Bericht — und hat drei Fehler zutage gefördert,
die alle drei Tests und Analyzer passiert hatten (siehe unten).

## Nächste drei Schritte

1. Weiter durch den Entwurf, in der festgelegten Reihenfolge: 1a/1b Patienten
   und Wunden, 1e Prüfen, 1i Abschluss, 1j Verlauf, zuletzt 1f/1g/1h Karten,
   Foto, Markierung. Das Besuchsband (`VisitStep`, `VisitHeader`) steht bereit
   und muss auf 1e, 1g/1h und 1i mit dem jeweiligen Schritt gesetzt werden.
2. `/eps:abgabe` vorbereiten
3. Offene Fragen an den Auftraggeber bündeln (siehe unten) — die Wortliste der
   Pflegekräfte ist davon die wertvollste

## Erledigt (Befund sprechen gegen den Entwurf, 2026-08-13)

Screen 1c aus `docs/design/screens/` übernommen, aber nicht nachgebaut: der
Entwurf ist in HTML entstanden und nie gegen 200 % Textskalierung oder 320 dp
gelaufen. Drei Stellen tragen dort nicht und sind anders gelöst.

- **Besuchsband** (`VisitStep`, `VisitBand`, `VisitHeader` in
  `features/besuch/ui/widgets/visit_chrome.dart`): vier Segmente, gefüllt bis
  zum aktuellen Schritt — der Fortschritt hängt damit an der **Position**, nicht
  allein an der Farbe. Ein Semantik-Knoten für das ganze Band.
- **Kopfzeile aus der AppBar in den Body.** 56 dp fest tragen keine beschriftete
  Aktion bei großer Schrift. „Abschließen" steht jetzt als Wort da; ein Haken
  ist für „Besuch beenden" eine Ratesache.
- **Drei gleichwertige Wege als drei Kacheln** über dem 96-dp-Ziel, in einer
  abgesetzten Zone am unteren Rand.
- **Beispielsätze bleiben stehen**, auch wenn der Besuch läuft. Vorher wichen
  sie dem Stand und hinterließen ein halbes leeres Telefondisplay zwischen Akte
  und Daumenzone — genau der Leerraum, den Julian am Gerät bemängelt hat.

### Wo der Entwurf nicht trägt, und was stattdessen gilt

- **Vier Bandbeschriftungen passen bei 200 % nicht auf eine Zeile.** Gemessen
  statt geschätzt (`TextPainter` im `LayoutBuilder`); jenseits der Passung steht
  nur noch der aktuelle Schritt da. Die Segmente tragen die Position weiter.
- **Drei Kacheln nebeneinander brechen bei 200 % auf 320 dp mitten im Wort**
  („Verla / uf"). Jenseits der Passung werden sie zur Liste und wandern aus der
  Daumenzone in den Lesebereich: bei doppelter Schrift gewinnt das eine Ziel,
  das sich nicht verschieben darf.
- **Das Datum in der Kopfzeile steht ganz da oder gar nicht.** „Besu…" liest
  sich wie ein abgeschnittener Wert; die Aktion daneben braucht den Platz mehr.
- **Kacheln mit Umriss statt mit Füllung.** In dieser Palette liegen zwei
  Flächentöne nie weiter als 1,2:1 auseinander — eine getönte Fläche sagt drinnen
  „Ziel" und in der Sonne nichts. Der Umriss (`outline`, 1,5 px) liegt bei
  3,06:1 auf `surface`.
- **Radius 20 auf Karten nicht übernommen.** Die Richtung in `CLAUDE.md` legt
  12 auf Karten und 8 auf Feldern fest; r20 bleibt der oberen Kante der
  Daumenzone vorbehalten.
- **Offline-Anzeige bewusst nicht übernommen** (Vorgabe von Julian): Die App ist
  offline-first, kein Netz ist der Normalzustand, und Normalzustände werden
  nicht dauerhaft angezeigt.

Nebenbei: `VisitRepository.startedAt` liest das Besuchsdatum zurück, damit ein
am nächsten Morgen fortgesetzter Entwurf nicht wie der heutige Besuch aussieht.
`OutlinedButton` bekommt projektweit 48 dp Mindesthöhe statt Materials 40.

**298 Tests grün**, Analyzer sauber, Goldens in Telefonmaß erneuert und die
Bilddiffs angesehen. Noch nicht auf dem Gerät gelaufen.

**Offen an diesem Screen:** der Aufnahmezustand (Entwurf 1d) ist unverändert —
Timer und Pegel kleben oben, darunter steht das halbe Display leer. Der Entwurf
schaltet diesen Zustand bewusst dunkel und zeigt „Bisher verstanden" als Chips;
beides ist noch nicht entschieden.

## Erledigt (der Weg in den Besuch, 2026-08-12)

Slice 1 hatte ein Loch: die App startete direkt im Besuch auf einer fest
verdrahteten Demo-Wunde, und der Bericht trug einen Patienten, den niemand
ausgewählt hatte. Die ersten beiden Schritte der Story Map fehlten.

- `WoundRepository` neu: anlegen mit Pflicht-Lokalisation (ohne sie lassen sich
  zwei Wunden eines Patienten nicht auseinanderhalten), offene Wunden zuerst,
  abgeheilte darunter statt versteckt, Wiederöffnen für die Wunde, die erneut
  aufbricht. Je Liste **eine** gruppierte Zählabfrage statt einer je Zeile.
- Drei Screens: Patientenliste mit Suche, Patientenschirm mit den Wunden,
  je ein Formular für Patient und Wunde. Leerzustand und „kein Treffer" sind
  zwei verschiedene Situationen und stehen als zwei verschiedene Sätze da.
- Eine neu angelegte Wunde führt **direkt** in den Besuch: sie wird erfasst,
  weil jemand am Verband steht, nicht um eine Liste zu füllen.
- Der Korridor bekommt die Wunde von außen; ein Befund kann nicht mehr auf
  einer Wunde landen, die niemand gewählt hat.

Auf dem Gerät durchgespielt: bestehender Patient → Wunde → Besuch mit Stand,
und neu anlegen → Wunde → leerer Besuch. **291 Tests grün.**

## Erledigt (Erkennergrößen gemessen, 2026-08-12)

Fünf Whisper-Größen an denselben vier Aufnahmen, bewertet nach dem, was im
**Befund** ankommt statt danach, wie der Text aussieht. Der Vergleich läuft als
Test mit (`test/domain/recogniser_size_test.dart`); Tabelle und Folgerungen in
`DECISIONS.md`.

Zwei Ergebnisse, die die Entscheidung tragen:

- **`base` erfindet Messwerte.** Aus „Breite 2" wurde „breite 2,5", die Tiefe
  fiel weg. Eine Lücke ist sichtbar und erlaubt; ein erfundener Messwert sieht
  aus wie ein erhobener. Damit scheiden `tiny` und `base` aus — nicht wegen der
  Qualität, sondern wegen der Art des Fehlers.
- **Größer ist nicht durchgehend besser.** `medium` hört die Selbstkorrektur,
  verliert aber das Exsudat („Exkursat"); `small` umgekehrt. Erst `large-v3`
  trägt beides — und ist mit 3,1 GB und 0,88× Echtzeit auf einer Desktop-CPU
  für ein Feldgerät zu groß.

Die Messung lief nicht auf dem Handy; grob geschätzt läge `small` dort bei
1,2–1,8× Echtzeit. On-Device ist damit **weder abgehakt noch bestätigt**.

## Erledigt (echte Beispielaufnahmen, 2026-08-12)

Vier Aufnahmen von Julian eingesprochen, lokal mit Whisper large-v3
transkribiert (nichts hat den Rechner verlassen). Die Transkripte sind jetzt
das, was der Erkenner **zurückgibt**, nicht das, was gesprochen wurde — und
daran hingen zwei Fehler:

- **Fachvokabular fiel aus dem Befund.** Das Modell kennt den Katalog des
  Kunden nicht: *Exsudat* kam als „Excusat" zurück, *serös* als „seriös".
  Beide Felder blieben leer. Jetzt fängt eine begrenzte Editierdistanz gegen
  den Katalog das ab — mit mittlerer Sicherheit, damit die Pflegekraft
  bestätigt, statt dass hinter ihrem Rücken geschrieben wird.
- **Eine gesprochene Korrektur wurde ignoriert.** „Länge 3, äh nein, 4,1"
  schrieb 3 cm in die Akte. Die Rücknahme wird jetzt gehört; der korrigierte
  Wert geht mit Prüfvermerk hinein, weil zwei Zahlen für ein Feld fielen.
- Ziffern statt Zahlwörter („4,2") konnte der Interpreter schon.

`ExampleAudioRecorder` schreibt die Aufnahmen als echte Dateien heraus und
reicht bei jeder Aufnahme die nächste durch — ein Durchlauf spielt alle vier
Fälle. Auf dem Gerät belegt: befund_01 ergibt sechs übernommene Werte und zwei
Prüffälle (genau die zwei verstümmelten Wörter), befund_02 zeigt Länge 4,1 cm
statt 3.

Gesamtlauf **262 grün**, Analyzer sauber.

## Erledigt (Review-Durchgang, 2026-08-12)

Code-Review und UX-Review liefen in frischem Kontext über den Tagesdiff. Beide
fanden denselben schwersten Punkt, was ihn glaubwürdig macht:

- **Lückenfarbe fiel als Fließtext unter die Kontrastgrenze.** `status.luecke`
  ist als Umrissfarbe dokumentiert und mit 3:1 geprüft, trägt aber die
  Lückenzeilen auf vier Screens. Im hellen Theme 3,99:1 auf dem Untergrund und
  3,65:1 auf der Karte — unter den 4,5:1 der eigenen Regel, und zwar in dem
  Zustand, den eine Pflegekraft die meiste Zeit eines Besuchs sieht. Farbe
  nachgezogen, beide Textpaare im Kontrasttest ergänzt.
- **„0 cm² kleiner als beim vorigen Besuch"** bei gleich gebliebener Fläche —
  eine Bewegung, die es nicht gab. Eigene Formulierung plus Test.
- **Wachstum war die leisere der beiden Zeilen.** Es bekam die gedämpfte
  Beschriftungsfarbe, der Rückgang die volle — die Liste zog das Auge zu den
  guten Besuchen. Wachstum trägt jetzt dasselbe Bernstein wie „prüfen".
- **„2 Fotos mit Markierung"** behauptete zu viel: die Zahl war der Fotostand,
  „mit Markierung" ein angeklebter fester Text. Nach einer Wiederholungsaufnahme
  ist genau ein Foto markiert. Jetzt wird gezählt, in einer Plural-Zeichenkette
  statt zwei zusammengesetzten — so wie der Abschluss-Screen es schon machte.
- **Fotozahlen waren ein Handstand.** Sie werden jetzt nach jedem Schreiben aus
  dem Repository gelesen, damit ein späterer Lösch- oder Wiederholungspfad sie
  nicht auseinanderlaufen lässt.
- Fehlender Golden und fehlender Kontrast-Durchgang für den Stand nachgeholt;
  der Stand steht jetzt **vor** dem Hinweis, weil er die Frage beantwortet, mit
  der eine Pflegekraft nach einer Unterbrechung zurückkommt.

Zwei Befunde bewusst abgelehnt:

- *Live-Region für den Stand*: der Stand ist Dauerzustand, keine Ankündigung
  eines Ergebnisses. Beim Zurückkehren aus Foto oder Prüfen setzt der
  Screenreader den Fokus ohnehin neu in den Screen; eine Live-Region würde bei
  jedem Rebuild dazwischenreden.
- *Welche Felder fehlen, schon im Stand nennen*: der Abschluss-Screen nennt sie
  und ist die Stelle, an der es zählt — vor dem Verlassen der Wohnung. Der
  Erfassungs-Screen bleibt ein Ziel für den Daumen, keine Liste.

Gesamtlauf **252 grün**, Analyzer sauber, Goldens erneuert und die Bilddiffs
angesehen. Beides auf dem Gerät belegt, hell und dunkel.

## Erledigt (Gerätedurchlauf und drei Fehler, 2026-08-12)

- **Ein verworfener Wert landete trotzdem im Befund.** Der Prüfen-Screen und
  sein ViewModel waren beide richtig; der Korridor speicherte aber alle
  Vorschläge des Interpreters statt der entschiedenen. „Tiefe fünfzig"
  verwerfen änderte nur das Bild — Akte, Verlauf und Bericht trugen einen halben
  Meter Wundtiefe als Befund, den niemand erhoben hat. Auf dem Gerät gefunden,
  Test in `test/widget_test.dart` nachgezogen.
- **Wachstum war stumm.** Der Verlauf schrieb „-6 cm² zum vorigen Besuch" beim
  Rückgang und „6 cm² zum vorigen Besuch" beim Wachstum. Beide Richtungen stehen
  jetzt in Worten da; ein Minuszeichen ist im fremden Flur mit Handschuhen keine
  Aussage.
- **Fotoplatzhalter unlesbar im hellen Theme.** Der Untergrund hinter Fotos
  folgt bewusst nicht dem Theme, die Beschriftung darauf tat es doch. Neues
  Token `onMediaGround`, in beiden Themes gleich, mit Kontrastpaar im Test.
- **Erfassungs-Screen ohne Gedächtnis.** Nach fünf Werten, Foto und Markierung
  sah er aus wie frisch gestartet. `VisitStanding` zählt jetzt Werte, Lücken und
  Fotos; die Beispielsätze weichen dem Stand, sobald es einen gibt.
- **Schalter für das Geisterbild beschriftete die Aktion statt den Zustand.**
  „Voriges Foto ausblenden" bei eingeblendetem Geist und eingeschaltetem
  Schalter — TalkBack las „ausblenden, eingeschaltet". Jetzt nennt die
  Beschriftung den Zustand.
- **Flackernder Golden gefunden und behoben.** `pumpAndSettle` kehrt zurück,
  sobald die Frames ruhig sind; das Dekodieren eines Fotos ist kein Frame. Etwa
  jeder fünfte Gesamtlauf nahm leere Miniaturen auf. Die Goldens warten jetzt
  auf jedes Bild.
- Gesamtlauf **247 grün** (fünf Läufe hintereinander), Analyzer sauber, Goldens
  erneuert und der Bilddiff angesehen.

## Erledigt (Verlauf und Bericht, 2026-08-11)

- `WoundHistory` als reine Domänenstruktur; `historyOf` liest Besuche, Werte
  und Fotohandles in drei Abfragen statt einer je Besuch.
- `AreaChart` selbst gezeichnet: eine Reihe, wenige Punkte, und die eine
  Regel — **keine Interpolation** — bricht eine allgemeine Diagrammbibliothek
  standardmäßig. Skala beginnt bei null.
- Veränderung wird nur gegen den **Nachbarbesuch** ausgesagt.
- `ReportContent` ist wortlose Struktur, der Text entsteht erst beim Rendern.
- `FieldPresentation` liegt jetzt in `lib/shared/text/` — `data/` darf kein
  Feature importieren.
- Gesamtlauf **243 grün**.

### Zwei Befunde aus dem gerenderten Muster

Ein Testlauf kann ein PDF nicht ansehen. Erst der gerenderte Musterbericht
zeigte: das Erstelldatum stand als roher `DateTime` in der Fußzeile (der
Platzhalter trug kein `format`), und jede Zelle der Spalte „Tiefe"
wiederholte das Wort „Tiefe". Beides behoben.

## Erledigt (Abschluss des Besuchs, 2026-08-11)

- `ClosingSummary` als reine Ableitung aus dem Entwurf — die tragende Regel
  ist ohne Widget prüfbar.
- `ClosingScreen`: Ankerzeile, Fotozeile, Gewebe-Rest, Lückenliste (jede Zeile
  führt zurück in die Erfassung), Abschluss mit zwei Beschriftungen.
- Gewebe-Rest wird nur gemeldet, wenn überhaupt ein Anteil erfasst wurde —
  sonst doppelt der Hinweis die Lückenliste.
- Korridor ruft `completeVisit` und startet den nächsten Besuch.
- 14 neue Tests plus ein Korridor-Test auf den Datenbankstatus. Gesamtlauf
  **217 grün**.

### Beleg auf dem Gerät

Der offene Besuch aus der Vorsitzung zeigte 7 fehlende Angaben, „Ein Foto ·
mit Markierung" und 80 % Gewebeanteile — also hat das Foto den App-Neustart
überlebt. Nach „Mit Lücken abschließen" meldet derselbe Screen einen frischen
Besuch: 9 fehlende Angaben, kein Foto.

## Erledigt (Foto, Markierung, Medienablage, 2026-08-11)

- `EncryptedMediaStore` — AES-GCM-256 je Datei, Nonce und MAC in der Datei,
  Schlüssel per HKDF aus dem Datenbankschlüssel abgeleitet. Löschen entfernt
  Zeile und beide Dateien.
- `WoundCamera` als Port; `PhotoScreen` mit Geisterbild der Voraufnahme
  (35 %, über `Image.opacity` statt `Opacity` — sonst `saveLayer` je Bild über
  dem laufenden Sucher). Jeder Kamerafehler endet in „Ohne Foto weiter".
- `MarkingScreen` mit drei Werkzeugen (Ellipse, Punkte, Freihand), Undo,
  Löschen; Zeichenfläche trägt das Seitenverhältnis des Fotos.
- Schema v3: `VisitPhotos` hält Handles und Geometrie, keine Bytes.
- Korridor: Foto → Markierung → Speichern in einem Zug.
- Gesamtlauf **202 grün**, Analyzer sauber.

### Beleg auf dem Gerät (Motorola edge 30 ultra)

Sucher, Auslöser, Kontrolle und Ellipse durchgespielt. Danach:

```
$ adb shell run-as de.paschneider.wunddoku ls -l files/media
-rw------- 882367 markedphoto_5c006eaa96132834c999240b2beb5eb4.bin
-rw------- 235238 photo_5a9245b6d54ff40f75ec478e706c63e8.bin

$ ... head -c 16 files/media/photo_5a92...bin | xxd
00000000: 336f 6973 5e4c 8243 68c3 e799 5237 a550
```

Kein JPEG-Magic (`ff d8 ff`), also verschlüsselt. `cache/` ist leer — die
Klartext-Zwischendatei des Kamera-Plugins wird nach dem Auslesen gelöscht.

## Erledigt (Korridor auf der Datenbank, 2026-08-11)

- `lib/app/bootstrap.dart`: öffnet die verschlüsselte Datenbank mit dem
  Schlüssel aus dem Keystore und baut die Repositories. Async, deshalb ein
  Ladezustand in der Hülle.
- **Wiedereinstieg aus dem Datensatz**, nicht aus dem Navigationsstapel: beim
  Start wird der unfertige Besuch fortgesetzt, sonst einer angelegt; der
  Entwurf wird zurückgelesen.
- Übernommene Vorschläge und das wörtliche Transkript werden durchgeschrieben.
- **Fehlgeschlagener Start ist bewusst eine Sackgasse.** Wenn der
  Verschlüsselungs-Selbsttest verweigert, sagt die App das und verweist auf
  Papier, statt den Korridor zu öffnen — weiterzumachen hieße,
  Gesundheitsdaten ungeschützt abzulegen.
- Demo-Patient und -Wunde werden beim ersten Start angelegt (synthetisch),
  solange es keine Patientenliste gibt.
- 4 neue Tests, darunter „unfertiger Besuch wird fortgesetzt" und
  „abgeschlossener Besuch wird nicht wieder aufgenommen". Gesamtlauf
  **147 grün**.

### Beleg auf dem Gerät

**Unterbrechung überlebt.** Im Kartenmodus Granulation 60 % und Fibrin 20 %
erfasst, dann `adb shell am force-stop` — kein sauberes Beenden, wie bei
leerem Akku. Nach dem Neustart steht derselbe Stand da, inklusive
„20 % nicht vergeben":
`doc/screenshots/persistenz-vorher.png` und `persistenz-nachher.png`
(der zweite ist ein Geräte-Screenshot mit Statusleiste, kein Driver-Bild).

**Die Datei ist wirklich verschlüsselt.** Erste 16 Bytes der Datenbank auf
dem Gerät:

```
$ adb shell run-as de.paschneider.wunddoku cat app_flutter/wunddoku.sqlite | head -c 16 | xxd
00000000: 605a d77a 4142 17a1 4fa8 6110 653e 0e5b  `Z.zAB..O.a.e>.[
```

Unverschlüsselt stünde dort `53 51 4c 69 74 65 20 66 6f 72 6d 61 74 20 33`
(„SQLite format 3"). Damit ist die Art.-9-Anforderung nicht nur konfiguriert,
sondern am Artefakt nachgewiesen.

## Erledigt (Persistenz des Besuchsentwurfs, 2026-08-11)

- `VisitRepository` mit `startVisit`, `openDraft`, `saveValue`, `loadDraft`,
  `completeVisit`, `saveTranscript`.
- **Autosave nach jedem einzelnen Feld**, nicht am Ende. Nicht abgewartet:
  ein Schritt muss sich sofort anfühlen, und auf einen Plattenschreibvorgang
  wartet die Pflegekraft nicht.
- Schema v2 mit Migrationspfad; Werte als Schlüssel-Wert-Tabelle, Begründung
  und Verworfenes in `DECISIONS.md`.
- Defensives Lesen: eine Zeile, die sich nicht dekodieren lässt, fällt heraus
  und hinterlässt eine sichtbare Lücke — statt eines Werts, den niemand
  eingegeben hat.
- Löschpfad reicht bis zu den Befunden: Patient löschen nimmt Wunden, Besuche
  **und** Werte mit. Mit Test belegt.
- 10 neue Tests, darunter der Fall, auf den es ankommt: App mitten im Besuch
  weg, frische Session liest den Stand zurück. Gesamtlauf **144 grün**.

## Erledigt (Kartenmodus, 2026-08-11)

Der gleichwertige Weg ohne Sprache — bis dahin boten ihn zwei Screens an, aber
er führte ins Leere.

- **Kein Tippen.** Jeder Wert wird gewählt oder gestuft; zwei 64-dp-Ziele
  links und rechts eines großen Werts lassen sich mit Handschuhen bedienen,
  eine Tastatur nicht. Jeder Schritt ist zusätzlich spürbar, damit eine Reihe
  von Tipps zählbar bleibt, ohne hinzusehen.
- **Die 100-%-Invariante als Rest, nicht als Fehler.** „100 % nicht vergeben"
  → „Vollständig verteilt" → „5 % zu viel vergeben". Die Pflegekraft verteilt
  ein Ganzes; der Rest sagt ihr, was als Nächstes zu tun ist, während eine
  Fehlermeldung ihr nur sagt, dass sie falsch lag.
- **Übervergabe ist erlaubt**, solange umverteilt wird. Erst einen Wert senken
  zu müssen, bevor ein anderer steigen darf, ist langsamer und lehrt nichts.
- **Null ist keine Angabe.** Ein Anteil zurück auf 0 und ein Maß zurück auf
  0 cm werden wieder zur Lücke, nicht zum Wert 0.
- **Widerspruch ausgeschlossen**: „kein Exsudat" löscht die Arten und nimmt
  sie aus der Bedienung — der Katalog verbietet das Paar.
- Erreichbar aus dem Normalzustand, nicht nur nach einem verweigerten Mikrofon.
- Neu: `VisitDraft` als gemeinsames Ziel. Beide Wege schreiben dorthin, und
  nichts danach kann sie auseinanderhalten.
- 20 neue Tests, zwei Goldens. Gesamtlauf **134 grün**, Analyzer sauber.
- Beleg auf dem Gerät: `doc/screenshots/karten-geraet.png` (leer) und
  `karten-verteilt.png` (60 % Granulation, 40 % Fibrin, vollständig).

## Erledigt (Gestaltungsrunde, 2026-08-11)

Anlass war Julians Einwand am fertigen Screen: funktional richtig,
gestalterisch Standardoptik. Berechtigt — drei Punkte aus `22-design-tokens.md`
waren verletzt. Begründung und Verworfenes in `DECISIONS.md`.

- **Bestätigungsansicht als Referenzscreen umgebaut**: drei Zonen statt einer
  flachen Liste. Was eine Entscheidung braucht, wird groß gezeichnet; Lücken
  fallen zu **einer** aufklappbaren Zeile zusammen; Erledigtes sitzt kompakt am
  unteren Rand. Damit ist der Gerätebefund vom Vortag behoben.
- **Anker statt Kleingedrucktem**: „2 Werte brauchen dich" als Headline, die
  Zahlen darunter. Vorher stand die wichtigste Orientierung in 13 px grau.
- **Größenkontrast 3:1** wie in `tokens.md` spezifiziert, aber bis dahin nicht
  umgesetzt (Wert 40 px, Bezeichnung 13 px in Versalien mit offener Laufweite).
- **Schrift gewählt und gebündelt**: Geist, variabel, OFL-1.1, 169 KB, mit
  tabellarischen Ziffern. Zwei Kandidaten auf demselben Gerät bei identischem
  Layout verglichen — `doc/screenshots/schrift-geist.png` und `schrift-inter.png`.
- **Besuchskorridor verdrahtet**: Aufnahme führt in die Prüfung, Rückkehr setzt
  den Besuch zurück. Vorher stand jeder Screen für sich.

**Gefundener Layoutfehler:** Der Kopfbereich war zentriert statt links bündig —
eine `Column` ohne `stretch` schrumpft auf ihre breiteste Zeile, die äußere
`Column` zentriert sie dann. Behoben.

## Erledigt (Aufnahme-Screen, 2026-08-11)

- `CaptureScreen` samt `CaptureViewModel` und `AudioRecorder`-Port. Zustände als
  `sealed class`: idle, recording, interpreting, done, queued, unavailable.
- Phase A umgesetzt: eine große Aktion im unteren Erreichbarkeitsbereich,
  Pegelanzeige, mitlaufende Dauer, Aufnahmezustand über Sicht **und** Haptik
  **und** Text.
- Keine Sackgassen: verweigertes Mikrofon führt zum Kartenmodus (gleichwertig
  formuliert, nicht als Trostpreis), fehlender Erkenner reiht die Aufnahme ein
  statt zu scheitern — das Audio bleibt erhalten.
- **Zwei echte Fehler, vom Test gefunden:**
  - `dispose()` schloss das Mikrofon nicht. Screen verlassen hieß: Mikrofon
    läuft weiter, ohne dass etwas davon auf dem Bildschirm steht. Genau der
    Fall, den JS-8 ausschließt. Jetzt beendet `dispose()` die Aufnahme, mit
    eigenem Test.
  - `HapticFeedback` warf ohne Plattform-Plugin und blockierte damit den Start
    der Aufnahme. Haptik ist Quittung, kein Tor — läuft jetzt ungeawaitet und
    fehlertolerant. Ein Gerät ohne Vibration muss aufnehmen können.
- 11 neue Tests, Goldens für Leerzustand und Aufnahme. Gesamtlauf **114 grün**,
  Analyzer sauber.

## Beleg auf dem Gerät (2026-08-11)

`flutter run -d ZY22G54KRS -t lib/main_driver.dart` auf einem **motorola edge
30 ultra, Android 15**; Screenshot über `tool/shot.dart`:
`doc/screenshots/bestaetigung-geraet.png` (1080×2400, synthetische Daten).

Bestätigt, was die Goldens mit Testschrift nicht zeigen konnten:

- Sortierung nach Dringlichkeit trägt — blockierender Wert oben, dann „prüfen",
  dann die Lücken, erledigte Werte unten.
- „Entscheiden" steht dort, wo sonst die geratene Zahl stünde.
- Zusammenfassung, Sperrgrund und deaktivierter Knopf sitzen zusammen am
  unteren Rand, einhändig erreichbar.
- Typografie ist auf Armlänge lesbar; die Zeilenhöhe passt zur
  Handschuh-Annahme.

**Entwurfsbefund aus dem Gerätelauf, noch offen:** Vier Lücken-Zeilen füllen
fast den halben Bildschirm und schieben die erledigten Werte aus dem Blick. Mit
allen acht Befundkarten wird die Liste unbrauchbar lang. Vorschlag für die
nächste Runde: Lücken zu **einer** aufklappbaren Zeile zusammenfassen
(„4 Angaben fehlen"), damit der Platz denen gehört, die Aufmerksamkeit
brauchen.

## Erledigt (Theme und Bestätigungsansicht, 2026-08-11)

- `lib/shared/theme/`: Farb-, Typo-, Abstands- und Motion-Tokens als
  `ThemeExtension`. Die in `docs/ux/tokens.md` offen gelassene Kontrastprüfung
  ist jetzt ein **Test**: elf Token-Paare gegen die WCAG-Formel, beide Themes,
  grün.
- Bestätigungsansicht (`features/besuch/ui/`) — der Kernscreen:
  Zeile mit Wert, Sicherheitsgrad und Herkunft; Sortierung nach Dringlichkeit
  statt nach Formularreihenfolge; Lücke erlaubt, unsicherer Wert sperrt das
  Speichern und wird als Wort statt als geratene Zahl gezeigt.
- Herkunftsbeleg: Antippen öffnet das wörtliche Transkript mit hervorgehobener
  Fundstelle.
- Barrierefreiheit: vier `meetsGuideline`-Prüfungen, Sicherheitsgrad als Wort
  im Semantik-Label, 200-%-Textskalierung und 320 dp ohne Überlauf.
- Goldens für Light, Dark und 200 % unter `test/features/goldens/`.
- 34 neue Tests; Gesamtlauf **103 grün**, Analyzer sauber.

## Stolpersteine

- **`printing` 5.15.0 verlangt Dart ≥ 3.12**, hier läuft 3.11.3. Version aus
  `DECISIONS.md` gegen die SDK-Grenze prüfen, nicht nur gegen pub.dev.
- **Die eingebaute PDF-Schrift Helvetica kennt kein „ und kein —.** Ohne
  eingebettete Schrift druckt der Bericht die Formulierungen des Kunden mit
  Löchern; im Testlauf sieht man nur eine Warnzeile.
- **Ein Platzhalter ohne `format` landet als `toString()` im Text.** Bei
  `DateTime` also `2026-08-11 00:00:00.000`. Sichtbar erst im gerenderten
  Dokument.
- **`InteractiveViewer`: `toScene` nur außerhalb des Kindbaums.** Sitzt der
  Gestenerkenner *im* transformierten Teilbaum, hat Flutter die Zeigerposition
  schon zurückgerechnet — ein zweiter Aufruf verschiebt die Marke doppelt. Bei
  Skalierung 1 fällt das nie auf, also auch nicht im Test ohne Zoom.
- **Zeichenfläche muss das Bildseitenverhältnis tragen.** Sonst normalisiert
  der Editor gegen die Widget-Box und der Brenner gegen das Bild; bei
  Letterbox-Balken landet die Marke in der Kopie woanders. Im Golden sichtbar,
  im Verhaltenstest nicht.
- **Ein synthetischer Pinch hat nicht die Skalierung, die man setzt.** Der
  Touch-Slop frisst einen Teil der Bewegung. Für exakte Zoom-Tests den
  `TransformationController` setzen statt zu ziehen — und um die Bildmitte
  skalieren, sonst liegt der Tap außerhalb des Bildes.
- **Die eingebrannte Kopie ist PNG und damit größer als das JPEG-Original**
  (Beleg auf dem Gerät: 235 KB → 882 KB bei einem dunklen Bild). Bei einem
  hellen 12-MP-Foto kann das ein Vielfaches werden. Wenn der Speicherbedarf
  auffällt: die Kopie als JPEG kodieren — das braucht ein Paket und damit eine
  Runde `/eps:technikwahl`.
- **Echte Codec-Arbeit kommt in der Fake-Async-Zone nie zurück.** Ein
  Widget-Test, der Bilder dekodiert oder kodiert, braucht `runAsync` — oder,
  wenn der Aufruf im Widget steckt, eine Naht wie `VisitCorridor.burn`.
- Der Trust-Dialog muss einmal interaktiv bestätigt werden (`eps` im
  Projektverzeichnis), sonst greifen die `permissions.allow`-Einträge aus
  `.claude/settings.json` nicht.
- `\w` in Dart-RegExp ist ASCII. Umlaute brauchen eine eigene Zeichenklasse,
  sonst fallen „dreißig" und „fünf" durch die Zahlwort-Erkennung.
- **`flutter run -d linux` schlägt fehl:** `flutter_secure_storage_linux`
  verlangt das Systempaket `libsecret-1 >= 0.18.4`, das hier nicht installiert
  ist. Installation wäre eine Änderung außerhalb des Projekts und braucht
  sudo — geht über Julian. Der schnelle Layout-Durchlauf auf dem Desktop
  entfällt damit vorerst; geprüft wird auf dem Android-Emulator, wo der
  Keystore ohnehin die echte Ablage ist.
- Goldens laufen mit Testschrift (Kästchen statt Buchstaben). Sie belegen
  Layout, Farbe und Hierarchie, **nicht** die Typografie. Dafür braucht es
  Screenshots vom Gerät.
- **Variable Schriften brauchen `FontVariation`.** Mit `FontWeight` allein
  synthetisiert Flutter den Fettschnitt, statt die echte Gewichtsachse zu
  benutzen — sichtbar erst auf dem Gerät.
- **`scrollUntilVisible` reicht für einen Tap nicht.** Es hört auf, sobald das
  Widget den Viewport berührt; der Tap verfehlt dann. `ensureVisible`
  hinterherschicken.
- `find.bySemanticsLabel` findet nur gebaute Zeilen. Was unterhalb der
  Sichtkante liegt, muss im Test erst sichtbar gescrollt werden.
- **`await` auf echte Futures hängt im Widget-Test.** Wer im Test etwas
  awaitet, das auf einen `StreamController.close()` oder einen Dienst wartet,
  wartet ewig — die FakeAsync-Zone dreht sich nur bei `pump`. Gegenmittel:
  `tester.runAsync(...)`. Kostete hier sieben Minuten Testlaufzeit bis zum
  Timeout.
- **Android-Plattform 37 heißt im SDK `android-37.0`**, Gradle sucht
  `android-37`. Jedes Modul, das gegen 37 kompiliert, scheitert. Projektlokal
  auf 36 festgenagelt (`android/build.gradle.kts`), weil ein Symlink im SDK
  außerhalb des Projekts läge.
- Emulator überlastet diese Maschine (14 GB, davon 12 belegt). **Auf dem
  angeschlossenen Gerät testen**, nicht im Emulator. Testläufe mit
  `--concurrency=1`, sonst kommt der OOM-Killer.

## Erledigt (Sprachstrecke Stufe 1, 2026-08-10)

- `TranscriptInterpreter` (reines Dart): Transkript → typisierte Vorschläge
  für Maße (mit mm/cm-Umrechnung), Gewebeanteile (beide Wortstellungen),
  Exsudation, Schmerz-NRS. Jeder Vorschlag trägt Sicherheitsgrad und
  **Span im Transkript** (Herkunftsbeleg für JS-4).
- Regeln umgesetzt: Wert außerhalb der Plausibilität wird behalten, aber
  `low` (blockiert Speichern); Nichtgesagtes erzeugt keinen Vorschlag;
  gebeugte Katalognamen („Granulationsgewebe") treffen mit `medium`.
- Deutsche Zahlwörter 0–99 inkl. „einunddreißig", „drei Komma fünf",
  „dreieinhalb". Stolperstein: `\w` in Dart-RegExp ist ASCII — Umlaute
  brauchen eine eigene Zeichenklasse.
- `SpeechRecognizer`-Port plus `CannedSpeechRecognizer`; die Mistral-Fassung
  kommt erst, wenn die Datenschutzangaben entscheidungsreif sind
  (`DECISIONS.md`).
- 21 neue Tests; Gesamtlauf 69 grün, Analyzer sauber.

## Erledigt (Persistenz, 2026-08-10)

- Verschlüsselte drift-Datenbank: `sqlite3` 3.x als SQLite3 Multiple Ciphers
  über den `hooks: user_defines`-Eintrag in der `pubspec.yaml`. Beleg: der
  `PRAGMA cipher;`-Selbsttest läuft als Test auf dem Host durch — der
  Hook-Build greift auch unter `flutter test`.
- `AppDatabase.encrypted` verweigert das Öffnen ohne Cipher (StateError) und
  prüft das Schlüsselformat, bevor der Schlüssel in ein SQL-Literal gelangt.
- Schlüssel: 32 Zufallsbytes, erzeugt beim ersten Start, abgelegt über
  `flutter_secure_storage` (Keystore/Keychain). Schnittstelle
  `DatabaseKeyStore` für Tests attrappierbar.
- Schema v1: Patients / Wounds / Visits, Fremdschlüssel mit `ON DELETE
  CASCADE` — Patient löschen nimmt Wunden und Besuche mit (Löschpfad).
  Jede Tabelle trägt bereits das `synchronized`-Feld aus der
  Offline-first-Entscheidung.
- `PatientRepository` mit Anlegen, Suche, Sortierung, Löschen; 10 neue Tests,
  Gesamtlauf 48 Tests grün, Analyzer sauber.

## Offene Fragen

**An den Auftraggeber** (Annahme in Klammern, bis dahin gilt sie):

- Wie lange dauert ein Besuch heute, und wie viele Minuten fallen abends je
  Patient im Büro an? *(Annahme: 3–5 Patienten je Tour, ~10 Min Nachdokumentation
  je Wunde.)* Ohne diese Zahl bleibt das Erfolgsmaß qualitativ.
- Nach welchem Schema wird heute dokumentiert — Papierbogen, Wundmanagement-
  Software, freier Text? Gibt es einen bestehenden Bogen, an dem sich die
  Kartenreihenfolge orientieren soll?
- Wer bekommt den PDF-Wundbericht — Arzt, Kasse, interne Pflegedokumentation?
  *(Annahme: behandelnder Arzt; damit ist die Zielsprache Fachsprache.)*
- Gibt es beim Sanitätshaus einen bestehenden AV-Vertrag und eine DSFA, in die
  sich die App einfügt?
- **Wie sprechen die drei Pflegekräfte den Befund tatsächlich?** Der Testlauf
  mit echten Aufnahmen (2026-08-12) hat gezeigt, dass ein allgemeiner Erkenner
  am Fachvokabular scheitert: *Exsudat* kam als „Excusat" zurück, *serös* als
  „seriös". Die App fängt das inzwischen ab, aber sie fängt nur, was sie kennt.
  Gebraucht wird die Liste der Wörter, die im Alltag wirklich fallen —
  Abkürzungen („Granu", „Epi"), Kurzformen, regionale Varianten. Diese Liste ist
  billiger als jedes Modelltraining und wirkt sofort.

**Aus der Katalogrecherche (2026-08-10), Einzelheiten in `docs/fachkataloge.md`:**

- **AVLON: die Auditliste gibt die Klassifikation falsch wieder.** Nicht „je
  Dimension ein Grad Ia–IV", sondern **eine** Tiefenskala Ia/Ib/II/III/IV/**V**
  plus die fünf Zusatzmerkmale A/V/L/O/N, die dazukommen. Am Originalposter
  geprüft und so umgesetzt. Dem Auftraggeber gegenüber ansprechen, weil er es
  anders formuliert hat — sinnvoll als Frage, nicht als Korrektur.
- **Kurzschreibweise des zusammengesetzten AVLON-Befunds abstimmen.** Das Poster
  legt keine fest; die App schreibt „Grad III + A + N". Der Wert erscheint im
  Bericht, also gehört die Schreibweise abgeglichen.
- **Verbrennung und Erfrierung sind laut Poster außerhalb des AVLON-Geltungs-
  bereichs.** Kommen solche Wunden im Alltag des Sanitätshauses vor? Wenn ja,
  braucht dieser Fall eine eigene Behandlung in der Oberfläche.
- Soll **Nekrose** in trocken und feucht getrennt werden, wie es die
  DGP-Vorlage tut? Das Briefing nennt sie ungeteilt. *(Annahme: ungeteilt.)*
- **Exsudatmenge** — Schätzurteil (kein/gering/mäßig/stark, wie im Briefing) oder
  beobachtbarer Verbandzustand (trocken → nass, Kleidung feucht/nass, wie in der
  DGP-Vorlage)? Der zweite Weg ist zwischen zwei Personen reproduzierbar.
  *(Annahme: Briefing gilt, der zweite Weg wird als Vorschlag vorgelegt.)*
- **Schmerz-NRS** auf den Verbandwechsel bezogen oder auf den Ruheschmerz?
  *(Annahme: Verbandwechsel, weil handlungsleitend.)*
- Vollständige Liste der **Schmerzqualitäten** — das Briefing lässt sie mit
  „brennend/stechend/…" offen. Wird nicht erfunden.
- Welcher **ICD-10-Zuschnitt** ist im Alltag gemeint? Der Gesamtkatalog hat rund
  16.000 Endstellen. *(Annahme: kuratierte Wundversorgungs-Teilmenge als
  Vorschlagsweg, Volltextsuche als Rückfall.)*

**An Julian:**

- Bis wann soll die Abgabe stehen? Der Umfang wird danach geschnitten.
- Das AVLON-Poster liegt als `wund_hautposter_7.pdf` im Workspace-Wurzelverzeichnis
  und ist dort **nicht** von `.gitignore` erfasst. Es ist ein kostenpflichtiges,
  mit Wasserzeichen versehenes Dokument und sollte nicht in die Git-Historie
  geraten. Die Datei liegt außerhalb des Projektverzeichnisses — Änderung daran
  geht über Julian.

**Noch offen, wird im Projekt entschieden:**

- Trägt Voxtral strukturierte Ausgabe direkt aus Audio, oder ist der zweistufige
  Weg stabiler? Ohne Mistral-Key nicht messbar — siehe `DECISIONS.md`.

## Entschieden mit Julian (2026-08-10)

- **Umfang:** ein Pfad vollständig — Patient → Wunde → Besuch → Foto mit
  Markierung und Maßen → Spracherfassung mit Rückkopplung → Verlauf → PDF. Alle
  acht Befundkarten im Datenmodell und im Screen-Inventar, zwei bis drei in
  voller UI-Ausarbeitung.
- **Backend:** keins. Rein lokal, offline-first. Sync-Architektur wird entworfen
  und begründet, nicht gebaut.
- **„Personalakten" aus der Mitschrift** heißt Patientenakten. Die Pflegekräfte
  erscheinen nur als angemeldeter Nutzer und als Urheber eines Befunds.
- **Mistral-Key:** kommt bis zur Abgabe nicht. Sprachstrecke muss ohne Key
  vollständig entwickelbar und vorführbar sein.

## Stolpersteine

- Stoppen der Aufnahme braucht im Widget-Test `tester.runAsync` — im gefälschten
  Async-Zone kehrt der Recorder nie zurück, und der Test hängt ohne Fehlermeldung
  im Aufnahmezustand.
- Der Trust-Dialog muss einmal interaktiv bestätigt werden (`eps` im
  Projektverzeichnis), sonst greifen die `permissions.allow`-Einträge aus
  `.claude/settings.json` nicht.
