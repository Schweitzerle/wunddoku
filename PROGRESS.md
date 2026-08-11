# Stand — wunddoku

> Wird nach jedem Arbeitspaket nachgezogen. Repo plus diese Datei müssen reichen,
> damit eine frische Session weitermacht.

**Zuletzt aktualisiert:** 2026-08-10

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

Noch kein Screen, keine Persistenz, keine Abhängigkeit außer dem Gerüst.

## Nächste drei Schritte

1. Kartenmodus — der gleichwertige Weg ohne Sprache, den Aufnahme-Screen und
   Bestätigungsansicht schon anbieten
2. Wound-/Visit-Repository plus Autosave, damit der Besuchsentwurf die
   Unterbrechung übersteht
3. Beispielaufnahmen (Audio) einsprechen lassen und als Fixtures ablegen —
   dann trägt der `CannedSpeechRecognizer` echte Dateien statt nur Namen

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
  Screenshots vom Emulator.
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

- Der Trust-Dialog muss einmal interaktiv bestätigt werden (`eps` im
  Projektverzeichnis), sonst greifen die `permissions.allow`-Einträge aus
  `.claude/settings.json` nicht.
