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

<!-- Vorlage für neue Einträge:

## JJJJ-MM-TT — Thema

**Gewählt:**
**Warum:**
**Verworfen:**
**Rückholbar:**

-->
