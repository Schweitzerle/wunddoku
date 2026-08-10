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

1. Persistenz: verschlüsselte drift-Datenbank aufsetzen, Selbsttest
   `PRAGMA cipher;` beim Öffnen, Repository-Schnittstelle, Migrationsgerüst
2. Sprach-Port mit Beispieladapter — Transkript, Feldzuordnung,
   Sicherheitsgrade; ohne Schlüssel vollständig testbar
3. Erster Screen des Besuchskorridors samt Bestätigungsansicht, mit Goldens

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
