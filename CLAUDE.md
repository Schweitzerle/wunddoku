@/home/chweizerles/Documents/EpSchneiderJob/CLAUDE.md

# wunddoku

<!-- Diese Datei ist der projektspezifische Teil. Die gemeinsamen Konventionen
     kommen über den Import oben, die Regeln über .claude/rules/base. -->

## Kunde und Auftrag

- **Kunde:** Sanitätshaus mit ambulanter Wundversorgung. Drei Pflegekräfte fahren
  Touren zu Patienten nach Hause — Verbandwechsel, Desinfektion, Kontrolle.
  Arbeitsbedingungen: Handschuhe an, beide Hände am Verband, fremde Wohnung,
  wechselndes Licht, oft kein Netz, Patient sitzt daneben und hört mit.
- **Auftraggeber:** Schneider Prozessautomatik
- **Problem in einem Satz:** Der Befund entsteht am Bett, aufgeschrieben wird er
  Stunden später im Büro aus dem Gedächtnis.
- **Erfolgsmaß:** Nachdokumentation im Büro geht gegen null; ein Wundbefund ist
  vor dem Verlassen der Wohnung vollständig. Gegenprobe: Anteil der Befunde, die
  ohne Nacharbeit im Büro auskommen, und die Zeit vom Betreten der Wohnung bis
  zum fertigen Befund. Absolutwerte sind noch beim Auftraggeber zu erfragen
  (siehe `PROGRESS.md`, offene Fragen).

## Datenkategorien

- **Verarbeitete Daten:**
  - Wundbefunde — Maße, Gewebeanteile, AVLON-Grade, Wundrand, Wundumgebung,
    Exsudation, Wundtaschen, Schmerz und Schmerztherapie, ICD-10-Diagnose
  - Wundfotos — Original und eingebrannte Markierungsfassung
  - Sprachaufnahmen der Pflegekraft, deren Inhalt der Befund ist
  - Patientenstammdaten — Name, Anschrift (zugleich Besuchsort), Geburtsdatum
  - Urheber und Zeitpunkt je Befund (Pflegekraft), damit mittelbar
    Beschäftigtendaten
- **Besondere Kategorien nach Art. 9 DSGVO:** **ja** — Gesundheitsdaten, in
  Text-, Bild- und Audioform. `.claude/rules/art9.md` ist aktiv.
  Nicht verarbeitet und bewusst nicht erhoben: Biometrie zur Identifizierung
  (die Stimme dient der Eingabe, nicht dem Wiedererkennen), Zahlungsdaten,
  ethnische Herkunft, Religion, Gewerkschaftszugehörigkeit.
- **Verantwortlicher:** das Sanitätshaus
- **Auftragsverarbeiter:** Schneider Prozessautomatik (diese Software).
  Unterauftragsverarbeiter entsteht erst, wenn Audio das Gerät verlässt —
  derzeit Mistral als Kandidat, Entscheidung offen in `DECISIONS.md`.

Bei „ja" ist `.claude/rules/art9.md` verlinkt und gilt zusätzlich.

## Ist-Prozess

Die Pflegekraft versorgt die Wunde, merkt sich Maße und Aussehen und dokumentiert
abends im Büro nach — mehrere Stunden und mehrere Patienten später. Fotos entstehen
mit dem Privat- oder Diensthandy und werden nachträglich zugeordnet. Der Verlauf
einer Wunde über Wochen lässt sich aus dieser Dokumentation nur schwer ablesen,
obwohl genau er den klinischen Wert trägt. Ausführlich in `docs/ux/ist-prozess.md`.

## Gestaltungsrichtung

**Ruhiges Fachwerkzeug** (`/eps:ui-gestaltung`, `stilrichtungen.md`)

- **Regler:** Varianz 3, Bewegung 3, Dichte 3 — die Startwerte für „Erfassung im
  Feld, mit Handschuhen". Derselbe Screen wird zwanzigmal am Tag bedient; hohe
  Varianz kostet dann Wiedererkennung, hohe Dichte Treffsicherheit.
- **Weil:** Pflegekraft in fremder Wohnung, belasteter Kontext, der Patient sitzt
  daneben und sieht mit. Die Oberfläche darf niemanden zusätzlich aufregen.
- **Konkret:** gedämpftes Blaugrün als einziger Akzent (`#0F6E7E` hell,
  `#7FD1DE` dunkel), Radius 12 auf Karten und 8 auf Feldern, Größenkontrast
  1,875 zwischen Bildschirmtitel und Fließtext, Signalfarben nur bei echtem
  Zustand — Bernstein für „prüfen", Rot für „entscheiden".
- **Nicht: Werkstatt und Baustelle.** Sicherheitsorange ist im Feld gut sichtbar,
  steht in einem Wundbefund aber für etwas anderes — die Farbe würde als Aussage
  über die Wunde gelesen, nicht als Bedienhinweis.

Wo Farbe die Hierarchie nicht macht, macht sie die Größe: das ist der Preis einer
gedämpften Palette und der Grund für den hohen Größenkontrast.

Der Untergrund hinter Wundfotos (`mediaGround`) folgt **keinem** der beiden
Themes. Die Gewebebeurteilung unterscheidet vier Farbeindrücke; ein Rahmen, der
zwischen Tag- und Nachtschicht wechselt, verschiebt diese Wahrnehmung.

## Gewählter Stack

Begründungen stehen in `DECISIONS.md`. Hier nur das Ergebnis — leere Zeilen sind
noch nicht entschieden und laufen über `/eps:technikwahl`.

| Bereich | Gewählt |
|---|---|
| Zustandsverwaltung | keine Bibliothek — Repository plus `ChangeNotifier` |
| Lokale Datenhaltung | `drift` auf `sqlite3`, verschlüsselt über `sqlite3mc` |
| Medien | Dateien im App-Bereich, AES-GCM-256 (`cryptography`), Schlüssel im Keystore |
| Navigation | `Navigator` aus dem Framework, benannte Routen |
| Backend / Synchronisation | keins — rein lokal, offline-first |
| Kamera / Audio / Bericht | `camera`, `record`, `pdf` + `printing` |
| Markierung im Bild | `InteractiveViewer` + `CustomPainter`, kein Paket |
| Spracherkennung | eigener Port; Beispieladapter ohne Schlüssel, Mistral-Adapter zuschaltbar |

## Projektbegriffe

Das Fachvokabular kommt aus etablierten klinischen Schemata und wird gegen
Primärquellen recherchiert, bevor es Code wird. Erlaubte Wertebereiche werden als
Enums oder Value Objects abgebildet, nie als freie Strings:

- **AVLON nach Kammerlander** — Arteriell, Venös, Lymphangiös, Osteo-Arthropathie,
  Neuropathie, je Dimension Grad Ia–IV
- **Gewebeanteile am Wundgrund** — Nekrose, Fibrin, Granulation, Epithelisation,
  in Prozent, Summe 100
- **Wundrand** und **Wundumgebung** — Normal, Mazeration, Rötung, Trocken, Livide,
  Atroph, Ödematös; Umgebung zusätzlich Infektion, Mykose, Juckreiz
- **Exsudation** — Intensität kein/gering/mäßig/stark, Art serös/eitrig/blutig
- **Wundtaschen und Unterminierungen** — Position als Uhrzeit 1–12, Tiefe in cm
- **Schmerz** — Intensität 0–10, Qualität, lokale und systemische Therapie
- **ICD-10-GM** — Diagnosekatalog

Der recherchierte Stand mit Quellenangabe steht in `docs/fachkataloge.md`.

## Befehle

```bash
flutter run -d linux -t lib/main_driver.dart      # App für die Agentenschleife
dart run tool/shot.dart <vm-service-uri> doc/screenshots/x.png  # Screenshot als Datei
flutter test                                                     # Tests
flutter test --update-goldens                                    # Goldens erneuern
flutter analyze                                                  # Analyzer
```
