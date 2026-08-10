@/home/chweizerles/Documents/EpSchneiderJob/CLAUDE.md

# wunddoku

<!-- Diese Datei ist der projektspezifische Teil. Die gemeinsamen Konventionen
     kommen über den Import oben, die Regeln über .claude/rules/base. -->

## Kunde und Auftrag

- **Kunde:** _(wer nutzt die App, welche Branche)_
- **Auftraggeber:** Schneider Prozessautomatik
- **Problem in einem Satz:** _(was geht heute nicht, ohne Technikwort)_
- **Erfolgsmaß:** _(eingesparte Minuten je Vorgang, Fehlerquote gegen den Papierweg)_

## Datenkategorien

- **Verarbeitete Daten:** _(z. B. Name, Adresse, Fotos vom Objekt, Messwerte)_
- **Besondere Kategorien nach Art. 9 DSGVO:** ja — welche genau, ist noch zu präzisieren. `.claude/rules/art9.md` ist aktiv.
- **Verantwortlicher:** _(in der Regel der Kunde)_
- **Auftragsverarbeiter:** Schneider Prozessautomatik, dazu: _(Hosting, KI-Dienste, …)_

Bei „ja" ist `.claude/rules/art9.md` verlinkt und gilt zusätzlich.

## Ist-Prozess

_(Zwei bis drei Sätze, wie es heute läuft. Ausführlich in `docs/ux/ist-prozess.md`.)_

## Gewählter Stack

Begründungen stehen in `DECISIONS.md`. Hier nur das Ergebnis:

| Bereich | Gewählt |
|---|---|
| Zustandsverwaltung | |
| Lokale Datenhaltung | |
| Navigation | |
| Backend / Synchronisation | |
| Externe Dienste | |

## Projektbegriffe

_(Fachvokabular des Kunden mit den erlaubten Wertebereichen. Diese Begriffe werden
im Code als Enums oder Value Objects abgebildet, nicht als freie Strings.)_

## Befehle

```bash
flutter run -d linux -t lib/main_driver.dart      # App für die Agentenschleife
dart run tool/shot.dart <vm-service-uri> doc/screenshots/x.png  # Screenshot als Datei
flutter test                                                     # Tests
flutter test --update-goldens                                    # Goldens erneuern
flutter analyze                                                  # Analyzer
```
