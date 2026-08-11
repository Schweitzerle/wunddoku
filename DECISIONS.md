# Entscheidungen — wunddoku

Je Entscheidung: was gewählt wurde, warum, was verworfen wurde, und wie teuer eine
Umkehr wäre. Drei bis fünf Zeilen genügen. Ablauf: `/eps:technikwahl`.

---

## 2026-08-10 — Projekt angelegt

**Gewählt:** Flutter, Gerüst aus dem Workspace-Template.
**Warum:** Cross-Platform-Vorgabe des Auftraggebers, vorhandene Erfahrung.
**Offen:** Zustandsverwaltung, lokale Datenhaltung, externe Dienste.

---

## 2026-08-10 — Gesundheitsdaten, Art.-9-Regel aktiv

**Gewählt:** Das Projekt wird als Art.-9-Projekt geführt. `.claude/rules/art9.md`
ist verlinkt und gilt zusätzlich zur Grundstufe.

**Warum:** Wundbefunde, Wundfotos und die Sprachaufnahmen, deren Inhalt der Befund
ist, sind Gesundheitsdaten. Alle drei Medienarten sind selbst besondere Daten, nicht
nur ihr Textniederschlag — das trifft Ablage, Verschlüsselung, Logging und jede
Übermittlung.

**Rollen:** Sanitätshaus = Verantwortlicher, diese Software = Auftragsverarbeiter
(Art. 28). Ein Unterauftragsverarbeiter entsteht erst, wenn Audio das Gerät verlässt.

**Folgen, die daraus schon feststehen:** verschlüsselte Ablage auf dem Gerät für
Datenbank *und* Medien, keine Fotos in Systemgalerie oder Cloud-Backup, keine
Inhalte in Logs, Zugriffsprotokoll ohne Inhalte, ausschließlich synthetische
Testdaten in Tests, Goldens und Abgabe-Screenshots.

**Nicht entschieden, sondern an den Verantwortlichen abgegeben:** die
Rechtsgrundlage nach Art. 9 Abs. 2 und die DSFA nach Art. 35. Beides ist in
`PROGRESS.md` als offene Frage notiert, nicht als stille Annahme.

**Rückholbar:** nein — die Einstufung ist keine Wahl, sondern eine Feststellung.

---

## 2026-08-10 — Kein Backend, rein lokal und offline-first

**Gewählt:** Alle Daten bleiben auf dem Gerät. Kein Server, keine Synchronisation,
kein externer Account.

**Warum:** Der Besuch findet in fremden Wohnungen statt, Netz ist dort der
Ausnahmefall und nicht der Normalfall — eine App, die online sein muss, löst das
Problem nicht. Ohne Übermittlung entfällt zugleich die gesamte
Auftragsverarbeiter-Kette für den Kern der Anwendung. Für das Testprojekt
verschiebt ein Backend den Schwerpunkt außerdem von Konzeption und
Interaktionsdesign auf Infrastruktur, und genau danach wird hier nicht bewertet.

**Verworfen:** Gegenstelle mit EU-Region für den Büro-Nachprozess. Fachlich richtig
für den Echtbetrieb, kostet aber Account und Geld und liegt damit über der
Freigabegrenze. Die Sync-Architektur samt Konfliktstrategie wird stattdessen
entworfen und begründet — als Dokument, nicht als Code.

**Rückholbar:** ja, wenn das Repository von Anfang an die einzige Quelle der
Wahrheit ist und die Datensätze ein Feld für den Übertragungszustand mitführen.
Nachträglich eingezogen wird das teuer, deshalb wird es jetzt mitgedacht.

---

## 2026-08-10 — Umfang des Testprojekts: ein Pfad vollständig

**Gewählt:** Ein durchgehender Pfad in voller Tiefe — Patient anlegen, Wunde
anlegen, Besuch dokumentieren mit Foto, Markierung und Maßen, Erfassung per
Sprache mit sichtbarer Rückkopplung, Verlauf über mehrere Besuche, PDF-Bericht.
Alle acht Befundkarten erscheinen im Datenmodell und im Screen-Inventar, zwei bis
drei davon in voller UI-Ausarbeitung.

**Warum:** Der Auftraggeber hat die Aufgabe selbst implementiert und bewertet
Konzeption, Interaktionsdesign und Verständnis der Arbeitssituation. Acht mal
dasselbe Formularmuster zeigt davon nichts; ein Pfad, der die Rückkopplung bei der
Spracherfassung und die Verlaufsdarstellung wirklich durchdenkt, zeigt alles.

**Verworfen:** alle acht Karten fertig ausgebaut (Fläche statt Tiefe); breite
Klick-Demo ohne Logik (belegt weder das eine noch das andere).

**Rückholbar:** ja — die fehlenden Karten sind Wiederholung eines dann bereits
belegten Musters.

---

## 2026-08-10 — Lokale Datenhaltung: drift, verschlüsselt über SQLite3 Multiple Ciphers

**Gewählt:** `drift` 2.34.3 (27.07.2026, 160/160 Punkte, 2448 Likes) auf
`package:sqlite3` 3.5.1 (04.08.2026), Verschlüsselung über den Hook
`hooks: user_defines: sqlite3: source: sqlite3mc`. Schlüssel in
`flutter_secure_storage` 11.0.0 (06.08.2026, 160/160, 4471 Likes), also im
Android Keystore bzw. der iOS Keychain.

**Warum:** Art. 9 verlangt verschlüsselte ruhende Daten; das ist keine Option,
sondern Voraussetzung. drift gibt typsichere Abfragen und versionierte
Migrationen — bei einem Datenmodell mit acht Befundkarten und einem Verlauf über
Jahre ist der Migrationspfad kein Nebenaspekt.

**Der Fund, der die naheliegende Wahl gekippt hat:** Der übliche Weg zu
verschlüsseltem drift ist `sqlcipher_flutter_libs`. Dessen aktuelle Version heißt
**`0.7.0+eol`** (15.02.2026) und die Beschreibung sagt: *„Not used anymore, update
to version 3.x of package:sqlite3 instead"* — ab 0.7.0 tut das Paket nichts mehr.
Hätte ich aus der Erinnerung gewählt, wäre eine leere Abhängigkeit im Projekt
gelandet, die Verschlüsselung *verspricht* und nicht liefert. Bei
Gesundheitsdaten ist das der teuerste denkbare Fehler.

Drifts eigene Dokumentation empfiehlt heute `NativeDatabase` mit
**SQLite3 Multiple Ciphers** (`source: sqlite3mc`) statt SQLCipher; SQLCipher hat
seit drift 2.32.0 keinen einfachen Aufbau mehr. Dazu gehört ein Selbsttest beim
Öffnen — `PRAGMA cipher;` muss eine Zeile liefern —, damit eine unverschlüsselt
geöffnete Datenbank auffällt statt still zu funktionieren.

**Verworfen:** `sqlcipher_flutter_libs` (EOL, siehe oben). `isar` — letzte
Veröffentlichung 04/2023, stehen geblieben. `sqflite_sqlcipher` 3.4.1 — gepflegt,
aber ohne typsichere Abfrageschicht und ohne Migrationswerkzeug; das wäre
Handarbeit an genau der Stelle, die über Jahre wehtut. Reines `sqflite` — dasselbe
Argument, zusätzlich ohne Verschlüsselung.

**Rückholbar:** ja, der Zugriff liegt hinter der Repository-Schnittstelle. Der
Wechsel der Verschlüsselungsquelle (`sqlite3mc` ↔ `sqlcipher`) ist eine Zeile in
der `pubspec.yaml` plus ein Migrationslauf.

---

## 2026-08-10 — Medien verschlüsselt als Dateien, nicht als Blobs

**Gewählt:** Fotos und Audio liegen als Dateien im app-eigenen Verzeichnis
(`path_provider` 2.1.6), einzeln mit AES-GCM-256 verschlüsselt über
`cryptography` 2.9.0. Der Schlüssel kommt aus demselben Keystore-Eintrag wie der
Datenbankschlüssel, über eine eigene Ableitung.

**Warum:** Ein Wundfoto ist 2–5 MB. Als Blob in der Datenbank bläht es die Datei
auf, verlangsamt jede Sicherung und macht selektives Löschen teuer — und ein
Löschpfad je Datensatztyp ist nach der Datenschutz-Grundregel Pflicht. Als Datei
ist Löschen ein Aufruf. Das Betriebssystem verschlüsselt zwar ohnehin, aber die
Art.-9-Regel verlangt Verschlüsselung ruhender Daten ausdrücklich für Datenbank
**und** Mediendateien; die Geräteverschlüsselung als einzige Maßnahme wäre eine
Annahme über die Gerätekonfiguration des Kunden.

**Verworfen:** Blobs in der Datenbank (Größe, Löschpfad, Sicherung).
`encrypt` 5.0.3 — letzte Veröffentlichung 09/2023, drei Jahre alt. Verlassen auf
die Geräteverschlüsselung allein (siehe oben).

**Bekanntes Risiko:** `cryptography` erscheint unregelmäßig (zuletzt 11/2025,
150/160 Punkte) und hängt an einem Betreuer. Gegenmittel: die Verschlüsselung
sitzt hinter einer eigenen Schnittstelle, und mit `cryptography_plus` 3.0.0
(03/2026) existiert ein gepflegter, API-gleicher Fork als Ausweichweg.

**Rückholbar:** ja, hinter der Schnittstelle; ein Wechsel kostet einen
Neuverschlüsselungslauf über die vorhandenen Dateien.

---

## 2026-08-10 — Keine Zustandsverwaltungs-Bibliothek

**Gewählt:** Framework-Mittel. Das Repository ist die einzige Quelle der Wahrheit,
der Besuchsentwurf hängt an einem `ChangeNotifier`, der über den Besuchskorridor
gereicht wird; Autosave schreibt nach jedem Feld in die Datenbank.

**Warum:** Die Gegenprobe aus `/eps:technikwahl` lautet: wie viele Bildschirme
teilen sich Zustand? Hier ist es **ein** Ablauf mit vier Stationen und einem
Entwurf, der ohnehin nach jedem Feld persistiert werden muss. Wenn die Datenbank
die Wahrheit hält, bleibt für eine Zustandsbibliothek wenig zu tun. Riverpod ist
in den Workspace-Regeln ausdrücklich Rückfallposition und nicht Standard —
ungefragt mitzunehmen widerspräche der Haltung des Auftraggebers.

**Wann das neu zu prüfen ist** (benannt, damit die Entscheidung nicht aus
Trägheit stehenbleibt): sobald ein Screen mehr als zwei unabhängige asynchrone
Quellen zusammenführt, oder sobald die Auswertungs-Warteschlange von mehreren
Screens gleichzeitig beobachtet werden muss. Dann `flutter_riverpod` 3.4.2.

**Verworfen:** `flutter_riverpod` und `flutter_bloc` — beide gepflegt und
tragfähig, nur für diesen Zuschnitt ohne Gegenwert.

**Rückholbar:** ja. Ein Repository plus `ChangeNotifier` ist genau die Struktur,
in die Riverpod später ohne Umbau der Fachschicht eingezogen wird.

---

## 2026-08-10 — Kein Routing-Paket

**Gewählt:** `Navigator` aus dem Framework, benannte Routen.

**Warum:** Der Besuch ist bewusst ein linearer Korridor mit vier Stationen; daneben
stehen flache Listen. Es gibt keine Deep Links, kein Web-Ziel und keine
URL-Anforderung — die drei Gründe, aus denen `go_router` seinen Preis wert wäre.
Der Wiedereinstieg nach einer Unterbrechung kommt aus der Datenbank, nicht aus dem
Navigationszustand; ein Router hätte das ohnehin nicht gelöst.

**Verworfen:** `go_router` 17.4.0 (04.08.2026, 150/160, 5761 Likes) — gepflegt und
richtig, sobald Deep Links oder Web dazukommen.

**Rückholbar:** ja, solange Screens ihre Argumente als einfache Objekte bekommen
und nicht aus dem Navigationszustand lesen.

---

## 2026-08-10 — Zeichnen und Einbrennen ohne Paket

**Gewählt:** `InteractiveViewer` plus `CustomPainter` für Markierung, Zoom und
Pan. Die eingebrannte Zweitdatei entsteht über `PictureRecorder` und `Canvas`
und wird als PNG geschrieben.

**Warum:** Das Framework kann beides. Die Markierung wird ohnehin als normalisierte
Geometrie gespeichert und nicht als Pixel — damit ist das Einbrennen ein
Zeichenvorgang auf einer zweiten Leinwand, kein Bildbearbeitungsproblem. Ein Paket
brächte hier nichts, das nicht schon da ist.

**Verworfen:** `photo_view` — letzte Veröffentlichung 04/2024. `image` 4.9.1 —
gutes Paket, aber für „Linie auf Bild zeichnen und als PNG speichern" nicht nötig.
`signature` — auf Unterschriften zugeschnitten, nicht auf Konturen über einem Bild.

**Zu prüfen auf dem Gerät:** ob die EXIF-Ausrichtung beim Dekodieren angewandt
wird. Wenn nicht, kommt `image` doch dazu — dann aber aus einem gemessenen Grund.

**Rückholbar:** ja.

---

## 2026-08-10 — Kamera, Audio, Bericht

**Gewählt:**
- `camera` 0.12.0+2 (13.07.2026, 160/160, 2595 Likes) — gebraucht wird der
  Sucher, weil die Voraufnahme als halbtransparentes Geisterbild darüberliegt.
  `image_picker` reicht dafür nicht, es liefert nur ein fertiges Bild.
- `record` 7.1.1 (29.06.2026, 160/160, 886 Likes) — Aufnahme in eine Datei, mit
  Pegel für die sichtbare Aufnahmerückmeldung.
- `pdf` 3.13.0 plus `printing` 5.15.0 für den Wundbericht — `printing` bringt
  Vorschau und Teilen mit, dadurch entfällt `share_plus` als zweite Abhängigkeit.

**Verworfen:** `image_picker` (kein Sucher, kein Overlay). `permission_handler`
13.0.0 — `camera` und `record` holen ihre Berechtigungen selbst; ein weiteres
Paket dafür wäre unnötig. Kommt dazu, falls später mehrere Berechtigungen
gebündelt erklärt werden sollen.

**Rückholbar:** ja, alle drei sitzen hinter projekteigenen Schnittstellen.

---

## 2026-08-11 — Befundwerte als Schlüssel-Wert-Tabelle, nicht als Spalten

**Gewählt:** Eine Tabelle `VisitValues` mit `(visitId, slotId)` als
Primärschlüssel, dazu `kind`, `number` und `code`. Der Typ steckt in `kind`;
das Repository bildet die Zeilen auf die versiegelten Wertetypen zurück.

**Warum:** Der Slot-Katalog wächst mit jeder Befundkarte, die der Auftraggeber
verlangt — acht Karten bedeuten je Karte eine Migration, wenn jedes Feld eine
Spalte bekommt. Mit der Schlüssel-Wert-Form kostet eine neue Karte keine
Schemaänderung. Der zweite Grund wiegt schwerer: **Autosave schreibt eine
Zeile.** Ein Feld zu sichern muss den Rest des Besuchs nicht anfassen, sonst
wird aus jedem Tastendruck ein Schreibvorgang über den ganzen Datensatz.

**Was der Ansatz kostet und wie es aufgefangen wird:** Die Datenbank kennt den
Typ nicht mehr. Deshalb trägt jede Zeile ihn in `kind`, und das Lesen ist
defensiv — eine Zeile ohne passenden Wert wird **verworfen**, nicht geraten.
Das Feld erscheint dann als sichtbare Lücke. Ein Wert, den niemand eingegeben
hat, wäre der schlechtere Ausgang.

**Verworfen:** Eine Spalte je Feld (Migrationslast, breite Schreibvorgänge).
JSON in einer Spalte (kein Zugriff auf einzelne Felder, keine Typprüfung beim
Lesen, und Autosave müsste das ganze Dokument neu schreiben).

**Rückholbar:** ja. Der Zugriff liegt hinter `VisitRepository`; eine spätere
Umstellung auf Spalten wäre eine Migration plus eine geänderte Abbildung.

---
## 2026-08-11 — Gestaltungsrichtung „Instrument", Schrift Geist

**Anlass:** Julians Einwand am fertigen Screen — funktional richtig, gestalterisch
Standardoptik. Berechtigt: die Konzeption stand, die Gestaltung war auf
Material-Default stehengeblieben, und drei Punkte aus der eigenen Regel
`22-design-tokens.md` waren verletzt (Hierarchie durch Größenkontrast, Rhythmus
statt gleichmäßigem Polster, Typografie mit Haltung).

**Gewählt — Richtung:** Der Screen liest sich wie ein Messgerät, nicht wie ein
Formular. Drei Zonen statt einer flachen Liste: was eine Entscheidung braucht wird
groß gezeichnet, Lücken fallen zu **einer** aufklappbaren Zeile zusammen,
Erledigtes sitzt kompakt am unteren Rand. Der Wert dominiert seine Bezeichnung im
Verhältnis 3:1; Feldbezeichnungen stehen in Versalien mit offener Laufweite.

**Warum jetzt und nicht am Ende:** Jeder weitere Screen erbt die Schwäche. Eine
Gestaltungsrunde über 16 Screens am Schluss ist teurer und riskanter als eine über
einen Referenzscreen, von dem die anderen abschauen. Die Tokens standen ohnehin
schon.

**Gewählt — Schrift:** `Geist` als variable Schrift, mitgeliefert unter
`assets/fonts/`.

| Achse | Geist | Inter (verworfen) |
|---|---|---|
| Lizenz | OFL-1.1 | OFL-1.1 |
| `tnum` (tabellarische Ziffern) | vorhanden | vorhanden |
| Dateigröße | **169 KB** | 877 KB |
| Achsen | `wght` | `opsz` + `wght` |
| Anmutung auf dem Gerät | enger, technischer | offener, weicher |

**Warum Geist:** Beide erfüllen die harte Anforderung (tabellarische Ziffern, damit
Maße und Verlaufsspalten untereinander stehen). Geist läuft schmaler — der
Kopfanker endet 75 px früher — und wirkt instrumentenhafter, was zur gewählten
Richtung passt. Es ist fünfmal kleiner. Inters Vorteil wäre die `opsz`-Achse; die
wird hier nirgends gesetzt und zahlt deshalb nichts ein. Belegt durch zwei
Screenshots vom selben Gerät bei identischem Layout:
`doc/screenshots/schrift-geist.png` und `schrift-inter.png`.

**Verworfen:** `IBM Plex Sans` — in der variablen Fassung von Google Fonts ließ
sich kein `tnum` nachweisen, damit scheidet es an der harten Anforderung aus.
`Roboto Flex` — technisch tauglich, aber zu nah am Systemdefault; das ist genau
die Standardoptik, die die Regel ausschließt. Systemschrift — dito.
Laufzeit-Nachladen (`google_fonts`) — funktioniert weder offline noch ohne
Übermittlung, beides hier ausgeschlossen.

**Nicht offensichtlich:** Gewichte müssen über `FontVariation` gesetzt werden.
Mit `FontWeight` allein synthetisiert Flutter bei einer variablen Schrift unter
einer Familie den Fettschnitt, statt die echte Achse zu benutzen.

**Rückholbar:** ja — die Familie steht an einer Stelle (`AppFontFamily`), die
Skala in `type_tokens.dart`. Feature-Code nennt keine Schrift.

---

## 2026-08-10 — Spracherkennung: Anbindung ohne Schlüssel entwickelbar

**Gewählt:** Die Erkennung sitzt hinter einem projekteigenen Port. Dahinter
stehen zwei Adapter: einer aus aufgezeichneten Beispielaufnahmen samt erwarteter
Ausgabe, der ohne Schlüssel und ohne Netz läuft, und einer gegen Mistral, der
über eine Umgebungsvariable scharfgeschaltet wird. Fehlt der erwartete Wert bei
gewähltem Cloud-Adapter, scheitert der Start mit klarer Meldung statt still
weiterzulaufen.

**Warum:** Es liegt kein Mistral-Schlüssel vor, und die gesamte
Rückkopplungs-UX — Bestätigungsansicht, Sicherheitsgrade, Feldkorrektur — ist der
eigentliche Entwurfsraum und hängt nicht an der Erkennung. Mit
Beispielaufnahmen als Quelle ist sie vollständig entwickelbar, testbar und
vorführbar. Der Port ist zugleich die Vorbedingung dafür, On-Device-Erkennung
später gegen die Cloud zu stellen, ohne die App umzubauen — was die Art.-9-Regel
ausdrücklich als ernsthaft zu prüfende Alternative verlangt.

**Offen und ausdrücklich ungemessen:** ob Voxtral strukturierte Ausgabe direkt aus
Audio trägt (einstufig) oder ob Transkription plus Textmodell mit striktem Schema
stabiler ist (zweistufig). Beide Wege sind im Port vorgesehen. Ohne Schlüssel ist
das nicht messbar; ein Messskript, das ohne Schlüssel nichts kostet, gehört zum
Lieferumfang. Was gemessen wird, steht in `/eps:freihaendige-erfassung`:
Feldgenauigkeit gegen echte Aufnahmen, nicht Wortfehlerrate.

**Verworfen:** direkte Verdrahtung gegen Mistral (ohne Schlüssel nicht
entwickelbar, und der Anbieter wäre nicht mehr austauschbar).
`speech_to_text` 7.4.0 als Ersatz — der Systemdienst kennt das Fachvokabular
nicht und liefert keine Feldzuordnung; als zusätzlicher Offline-Entwurfsweg
bleibt er in Sichtweite, nicht als Ersatz.

**Datenschutz, noch nicht entscheidungsreif:** Bevor Audio das Gerät verlässt,
braucht es nach `datenschutz-art9.md` Anbieter, Zweck, Datenarten, Region,
Aufbewahrung und Trainingsverbot — und Zero Data Retention sichert Mistral nur im
Scale-Tarif zu. Solange das offen ist, läuft ausschließlich der Beispieladapter.

**Rückholbar:** ja, das ist der Zweck des Ports.

---

<!-- Vorlage für neue Einträge:

## JJJJ-MM-TT — Thema

**Gewählt:**
**Warum:**
**Verworfen:**
**Rückholbar:**

-->

---

## 2026-08-11 — Markierung als Geometrie, Fotos als verschlüsselte Dateien

**Gewählt:** Die Markierung wird als normalisierte Kontur (0..1, je Achse)
gespeichert, nicht als Pixel und nicht als Bild. Die eingebrannte Fassung ist
eine zweite Datei, die aus dieser Geometrie entsteht. Beide Bilder liegen im
`EncryptedMediaStore`; in der Datenbank steht nur der Handle plus die Kontur
als JSON (Schema v3, `VisitPhotos`).

**Warum:** Nur Geometrie überlebt Skalierung, Export, Gerätewechsel und bleibt
bearbeitbar — und nur so lassen sich zwei Besuche übereinanderlegen. Der
Vergleich über Wochen ist das, was den klinischen Wert trägt; ein Bild mit
eingebranntem Strich kann das nicht. Umgekehrt braucht der Büro-Nachprozess
ein Bild, das die Markierung ohne unsere App zeigt — daher beides.

**Verworfen:** Markierung nur im Bild (nicht vergleichbar, nicht korrigierbar).
Bilder als Blobs in der Datenbank (siehe Entscheidung vom 10.08.). Das Original
überschreiben (das Briefing verlangt ausdrücklich beide Fassungen).

**Bekanntes Risiko:** Die eingebrannte Kopie entsteht als PNG und ist damit
größer als ein JPEG-Original. Notiert in `PROGRESS.md`; ein JPEG-Encoder wäre
eine eigene Technikentscheidung.

**Rückholbar:** ja. Die Geometrie ist die Quelle, die Kopie jederzeit neu
erzeugbar.

---

## 2026-08-11 — Kamera hinter einem eigenen Port

**Gewählt:** `WoundCamera` als projekteigene Schnittstelle mit drei Methoden;
`PackageWoundCamera` benutzt `camera` 0.12.0+2. Der Fehlerfall ist ein
Rückgabewert (`CameraFailure`), keine Ausnahme. Die Kamera wird pro Besuch am
Sucher frisch gebaut und beim Verlassen freigegeben.

**Warum:** Der Foto-Screen trägt die tragende Idee des Bildteils — das
Geisterbild der Voraufnahme — und ist zugleich der einzige Screen, der gegen
echte Hardware nicht reproduzierbar testbar ist. Hinter dem Port sind Sucher,
Auslöser, Kontrolle und alle drei Fehlerzustände im Widget-Test belegt. Dass
jeder Fehlerzustand einen Screen hat, ist der Grund für den Rückgabewert:
„keine Berechtigung" ist ein Zustand der Oberfläche, keine Ausnahme.

**Verworfen:** `camera` direkt im Screen (nicht testbar). `image_picker`
(kein Sucher, damit kein Geisterbild).

**Rückholbar:** ja, das ist der Zweck des Ports.

---

## 2026-08-11 — Bericht: `printing` 5.14.3 statt 5.15.0, Schrift eingebettet

**Gewählt:** `pdf` 3.12.0 mit `printing` 5.14.3. Der Bericht bettet die
gebündelte Schrift Geist ein; die Berichtsstruktur entsteht als reine
Dart-Struktur (`ReportContent`) und wird erst beim Rendern in Sprache
gebracht.

**Warum die ältere Fassung:** `printing` 5.15.0 verlangt Dart ≥ 3.12.0, dieses
Projekt läuft auf 3.11.3 (Flutter 3.41.5). Die Entscheidung vom 10.08. nannte
5.15.0 — das war gegen pub.dev richtig und gegen die SDK-Grenze falsch.

**Warum die Schrift eingebettet wird:** Die eingebaute Helvetica des
PDF-Formats kennt weder deutsche Anführungszeichen noch Geviertstrich. Ohne
eingebettete Schrift druckt der Bericht die Formulierungen des Kunden mit
Löchern. Ein Test prüft, dass `FontFile2` in der Datei steht.

**Verworfen:** Nur ASCII-Zeichen in den Berichtstexten (verbiegt die Sprache
des Kunden). Systemschrift des Geräts (auf iOS und Android verschieden, damit
kein reproduzierbares Dokument).

**Rückholbar:** ja.

---

## 2026-08-11 — Fläche als Länge × Breite, ausgewiesen als Näherung

**Gewählt:** Die Verlaufsgröße ist Länge × Breite der beiden größten
Durchmesser. Sie steht in der Oberfläche und im Bericht mit dem Zusatz
„Näherung: Länge × Breite".

**Warum:** Es ist die Größe, die Wunddokumentationsschemata führen, und sie
bleibt zwischen Besuchen vergleichbar, gerade weil sie immer gleich grob
gerechnet wird. Die Fläche innerhalb der gezeichneten Kontur wäre genauer
*aussehend*, hinge aber am Zeichnen und am Aufnahmeabstand — zwei Quellen für
scheinbare Veränderung ohne klinische Veränderung.

**Verworfen:** Ellipsenformel (π/4 · L · B) — suggeriert Genauigkeit, die ein
Zollstock an einer Wunde nicht hat. Fläche aus der Kontur (nicht vergleichbar,
siehe oben). Interpolation fehlender Messungen (zeichnet eine Messung, die
niemand gemacht hat).

**Offen an den Auftraggeber:** ob das Sanitätshaus eine andere Flächenformel
führt. Notiert in `PROGRESS.md`.

**Rückholbar:** ja, die Rohmaße stehen im Datensatz.

