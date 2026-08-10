# Fachkataloge — recherchierter Stand

> Etablierte klinische Schemata mit festen Wertebereichen. Erfundene oder frei
> interpretierte Skalen sind hier ein Fehler, kein Designspielraum. Jeder Katalog
> unten hat eine Quelle; wo keine belastbare Quelle gefunden wurde, steht das so da.
>
> **Recherchiert am 2026-08-10.** Umsetzung in `lib/domain/katalog/`.

## Quellenlage in einem Satz

Für die Farbschema-Matrix, den Wundgrund, Wundrand, Wundumgebung, Exsudat, die
Uhrzeitmethode und ICD-10 liegen zitierfähige Primärquellen vor. **Für AVLON nicht** —
dazu unten ein eigener Abschnitt.

---

## 1. Farbschema-Matrix — WCS mod. G. Kammerlander

Das Briefing nennt eine „Farbschema-Matrix" bei Wundstatus/Wundgrund. Das ist das
**Wundklassifikationssystem WCS in der Modifikation von Gerhard Kammerlander**.
Belegt aus Kammerlanders eigener Veröffentlichung, dort als
*„Wundstadien nach WCS – mod. G. Kammerlander 1996/2001"* mit drei Kriterien.

**Kriterium 1 — Interpretation der Farben** (acht Stadien, verbatim):

| # | Bezeichnung | Gewebe |
|---|---|---|
| 1 | schwarz | Nekrose |
| 2 | schwarz-gelb | Nekrose + Fibrinbelag |
| 3 | schwarz-gelb-rot | Nekrose + Fibrinbelag + Granulation |
| 4 | gelb | Fibrinbelag |
| 5 | rot-gelb | Granulation + Fibrinbelag |
| 6 | rot | Granulation |
| 7 | rot-rosa | Granulation + Epithelisation |
| 8 | rosarot | Epithelisiert |

**Kriterium 2 — Erkennen des Exsudationsgrades.** Für die Stadien 2 bis 7 jeweils
`trocken · feucht · nass`. Zwei Stadien haben abweichende Wertebereiche:

- Stadium 1 (schwarz/Nekrose): *„schwarz (nekrotisch) trocken"*,
  *„schwarz (nekrotisch) feucht-nass"*, *„Rand der Nekrose fest verpackt"*,
  *„Rand der Nekrose teilweise locker"*
- Stadium 8 (rosarot/Epithelisiert): *„instabile, dünne brüchige Haut"*,
  *„teils ekzematisierte Haut"*, *„trockene Haut"*, *„normale Hautkonsistenz"*

**Kriterium 3 — Erkennen von möglichen lokalen Infektzeichen.** Eigenständiges
Ja/Nein, nicht Teil der Farbstufe.

> **Für das Datenmodell wichtig:** Die Zustandsachse ist **nicht** über alle Stadien
> gleich. Ein flaches Enum `trocken/feucht/nass` über alle acht Stufen wäre bereits
> eine Verfälschung. Der Zustand hängt vom Stadium ab — das gehört als abhängiger
> Wertebereich abgebildet, nicht als freies Nebeneinander.

*Quelle:* Gerhard Kammerlander, *Wundbeurteilung und Klassifikation — Zuordnung von
Verbandsmaterialien* (2001) und *Lokaltherapeutische Standards für Hautwunden,
Kurzübersicht Teil 1*, Akademie-ZWM / WFI Embrach.

---

## 2. Gewebeanteile am Wundgrund — Prozentangabe

Das Briefing verlangt Prozentanteile für Nekrose, Fibrin, Granulation,
Epithelisation. Eine veröffentlichte Assessmentvorlage einer Fachgesellschaft
formuliert die Regel ausdrücklich:

> *„Wundgrund, Angabe in % (wieviel % nimmt die Gewebsart/Struktur von 100 %
> Wundfläche ein?)"*

mit den Positionen: **Fibrinbelag · Nekrose trocken · Nekrose feucht ·
Granulationsgewebe · Epithelgewebe · Andere Strukturen**.

Zwei Festlegungen für das Modell:

- **Die Anteile summieren sich auf 100 %.** Das ist eine Invariante, keine
  Empfehlung — sie gehört ins Value Object und wird dort geprüft.
- Die Vorlage trennt **Nekrose trocken** von **Nekrose feucht**. Das Briefing nennt
  nur „Nekrose". Rückfrage an den Auftraggeber, ob er die Trennung will; bis dahin
  wird „Nekrose" ungeteilt geführt, weil das seiner Vorgabe entspricht.

*Quelle:* Barbara Uebach, *Wundassessment / Wundverlaufsdokumentation*, Netzwerk
Hospiz- und Palliativversorgung Bonn/Rhein-Sieg, Fassung 22.01.2021, veröffentlicht
über die Deutsche Gesellschaft für Palliativmedizin.

---

## 3. Wundrand und Wundumgebung

Der Auftraggeber gibt in seiner Auditliste eigene Wertelisten vor. **Diese Listen
sind die Anforderung** — sie werden nicht durch eine Literaturfassung ersetzt.
Gegenübergestellt der veröffentlichten Vorlage, damit Abweichungen mit ihm geklärt
werden können statt still zu bleiben:

| | Auftraggeber (Auditliste) | Vorlage DGP/Uebach 2021 |
|---|---|---|
| **Wundrand** | Normal · Mazeration · Rötung · Trocken · Livide · Atroph · Ödematös | glatt · zerklüftet · nekrotisch · ödematös · mazeriert · gerötet |
| **Wundumgebung** | wie Wundrand, zusätzlich Infektion · Mykose · Juckreiz | reizlos · trocken/schuppig · verhärtet · infiltriert durch Tumorgewebe · gerötet · mazeriert · ödematös |

Beide Listen sind fachlich gängig; sie unterscheiden sich in der Schwerpunktsetzung
(der Auftraggeber bildet die Hautbeschaffenheit feiner ab, die Palliativvorlage die
Randform). Die Fachbegriffe der Auftraggeberliste sind klinisch belegt — *livide*
als Hinweis auf tiefe Gewebeschädigung, *Mazeration* als Aufweichung durch
Feuchtigkeit, *Atrophie blanche* im Zusammenhang chronisch venöser Insuffizienz.

**Mehrfachauswahl, nicht Einfachauswahl.** Ein Wundrand kann gleichzeitig gerötet
und ödematös sein. „Normal" beziehungsweise „reizlos" schließt alle anderen aus —
das ist eine Regel im Value Object, keine Sache der Oberfläche.

*Quellen:* Auditliste des Auftraggebers (`TestProject/projectAudit`); DGP/Uebach 2021;
Klinikum Passau, *Wundkompendium* (Begriffsdefinitionen Wundrand, Wundumgebung,
Mazeration); Mölnlycke, *Klassifikation von Wunden und deren Grunderkrankungen* (2025).

---

## 4. Exsudation

Der Auftraggeber gibt vor: Intensität **kein · gering · mäßig · stark**, Art
**serös · eitrig · blutig**.

Bemerkenswert: Die Palliativvorlage misst die Intensität **nicht** als Schätzurteil,
sondern an einem beobachtbaren Sachverhalt — dem Verband:

> *Verband trocken · Verband feucht · Verband nass · Verband nass, Kleidung feucht ·
> Verband nass, Kleidung nass*

Das ist die bessere Skala, weil sie beobachtet statt zu schätzen, und weil sie
zwischen zwei Personen reproduzierbar ist. Sie ersetzt die Vorgabe des Auftraggebers
nicht — sie ist ein **Vorschlag an ihn**, den die App als zweite, optionale Achse
mitführen kann. Als offene Frage notiert.

Kammerlanders Kriterium 2 (siehe oben) ist eine dritte, stadienabhängige Sicht auf
dasselbe. Alle drei zu verlangen wäre Formularlast; die Entscheidung, welche gilt,
gehört zum Auftraggeber.

---

## 5. Wundtaschen und Unterminierungen — Uhrzeitmethode

**Konvention:** Das Zifferblatt wird auf den Patienten gelegt, **12 Uhr zeigt zum
Kopf, 6 Uhr zu den Füßen**. Daraus folgen auch die Messachsen der Wunde.

Die Palliativvorlage schreibt das aus:

> *„Längste Länge (von 12 nach 6 Uhr) in cm"* · *„Unterminierung, Angabe nach der
> Uhrmethode (z. B. von 12 h – 3 h)"*

Zwei Konsequenzen fürs Modell, die man ohne die Quelle übersehen würde:

1. **Eine Unterminierung ist ein Bereich, keine Position.** „von 12 h bis 3 h", nicht
   „bei 2 Uhr". Das Briefing sagt „Uhrzeit-Position + Tiefe" — das Modell bildet
   deshalb `von`/`bis` ab, wobei ein Punktbefund der Fall `von == bis` ist. Ein
   reines Positionsfeld wäre nachträglich teuer zu erweitern.
2. **Der Bereich läuft über die 12 hinweg.** „von 10 h bis 2 h" ist gültig und
   umfasst vier Stunden, nicht acht. Modulo-Arithmetik im Value Object, keine
   Sortierung von klein nach groß.

Die Vorlage nennt die Breite *„von 9 nach 6 Uhr"* — das ist im Original erkennbar ein
Schreibfehler, die zur Länge senkrechte Achse ist 9 → 3 Uhr. Hier bewusst
abweichend umgesetzt und hier vermerkt, statt den Fehler zu übernehmen.

**Tiefe** wird mit der Knopfsonde gemessen; die Fläche planimetrisch in mm² bzw. cm².
Kammerlander beschreibt das im Abschnitt *Wundprotokoll* ausdrücklich als Messvorgang
mit Hilfsmitteln. Das stützt die Entscheidung, **keine Fläche aus dem Foto zu
rechnen**, solange kein Maßstab im Bild liegt.

---

## 6. Schmerz

Briefing: Intensität 0–10, Qualität (brennend/stechend/…), lokale und systemische
Schmerztherapie, Maßnahmen.

Die Palliativvorlage nutzt die **NRS (Numeric Rating Scale)** und erfasst sie
ausdrücklich **bezogen auf den Verbandwechsel** („Schmerzen durch den
Verbandwechsel"). Diese Bezugnahme ist wichtig: Wundschmerz in Ruhe und Schmerz beim
Verbandwechsel sind verschiedene Größen, und für die Therapieentscheidung ist der
zweite der handlungsleitende. Als Vorschlag an den Auftraggeber notiert.

Die Qualitätsliste („brennend/stechend/…") ist im Briefing offen gelassen. Sie wird
**nicht erfunden**: bis zur Klärung mit dem Auftraggeber wird eine Mehrfachauswahl
mit den im Briefing genannten Ankern plus Freitextergänzung geführt, und die
Vollständigkeit der Liste steht als offene Frage.

---

## 7. ICD-10-GM

**Herausgeber:** BfArM im Auftrag des Bundesministeriums für Gesundheit.
**Aktuelle Fassung:** ICD-10-GM Version 2026, anzuwenden seit 01.01.2026.
**Rechtslage:** amtliches Werk, gemeinfrei; die Klassifikationsdateien stehen
kostenfrei zum Download, es gelten die Downloadbedingungen des BfArM.
**Formate:** systematisches Verzeichnis als PDF, ODT, HTML, **ClaML/XML**, Metadaten,
Überleitungstabellen; alphabetisches Verzeichnis zusätzlich als TXT/CSV.

Für die App relevant: **ClaML/XML** ist die maschinenlesbare Fassung und die richtige
Quelle für einen mitgelieferten Offline-Katalog. Ein Online-Nachschlagedienst kommt
nicht in Frage — die App arbeitet ohne Netz, und eine Diagnosesuche, die in der
Wohnung nicht funktioniert, ist keine.

**Zuschnitt:** Der vollständige Katalog hat rund 16.000 Endstellen. Für die
Wundversorgung ist der weit überwiegende Teil davon irrelevant. Vorgehen: eine
kuratierte Teilmenge (Ulcus cruris, Dekubitus, diabetisches Fußsyndrom, Wunden nach
Lokalisation) als schneller Vorschlagsweg, mit Volltextsuche über den gesamten
Katalog als Rückfall. Die Teilmenge wird mit dem Auftraggeber abgestimmt.

*Quelle:* BfArM, Kodiersysteme — ICD-10-GM Version 2026, inkl. Downloadhinweise.

---

## 8. AVLON — Quellenlage unzureichend

**Was gesichert ist:** AVLON existiert und stammt aus dem Kammerlander-Umfeld. Die
Akademie-ZWM führt es im eigenen Verlagsangebot als Poster
**„AVLON Wund- und Dekubitusklassifikation"** (A3/A4, laminiert, 9,00 €).

**Was nicht gesichert ist:** die Definitionen der Grade. Weder die Auflösung des
Akronyms noch die Abstufung Ia bis IV ist in einer frei zugänglichen Quelle
veröffentlicht. Geprüft wurden: die Publikationsseite der Akademie-ZWM und drei ihrer
Volltexte, die Klassifikationsübersicht des Wundzentrums Hamburg, das Wundkompendium
des Klinikums Passau, die Klassifikationslegende von Mölnlycke (2025) sowie mehrere
gezielte Suchen. Ergebnis: **keine belastbare Fassung der Gradeinteilung.**

Die Auflösung des Akronyms im Briefing — Arteriell, Venös, Lymphangiös,
Osteo-Arthropathie, Neuropathie — ist plausibel und deckt sich mit Kammerlanders
Arbeitsschwerpunkten (venöse und lymphangiöse Stauung, Ulcus cruris, Dekubitus). Sie
ist damit aber **eine Angabe des Auftraggebers, keine geprüfte Quelle.**

**Was daraus folgt — und was ausdrücklich nicht passiert:**

Es wird keine Gradeinteilung erfunden. Stattdessen:

- Die fünf Dimensionen werden genau so abgebildet, wie der Auftraggeber sie nennt.
- Die Gradskala wird als **eine** geschlossene Aufzählung an genau einer Stelle
  definiert, so dass ihr Austausch eine Zeile kostet, sobald die verbindliche
  Fassung vorliegt.
- Die vorläufige Skala trägt im Code einen Doc-Kommentar, der auf diesen Abschnitt
  verweist und sie als vorläufig kennzeichnet.
- Der Beschaffungsweg steht in `PROGRESS.md`: **den Auftraggeber fragen** — er hat
  die Aufgabe selbst umgesetzt und besitzt die Definition. Alternativ das Poster für
  9 € bestellen; das kostet Geld und geht deshalb über Julian, nicht über den Agenten.

Das ist der ehrliche Umgang mit einer Lücke: sie benennen, den Einbau so bauen, dass
das Schließen billig ist, und die Beschaffung an die Person geben, die sie leisten
kann.

---

## Quellenverzeichnis

- Gerhard Kammerlander, *Wundbeurteilung und Klassifikation — Zuordnung von Verbandsmaterialien* (2001) — [akademie-zwm.ch](https://www.akademie-zwm.ch/uploads/tx_scpublications/Wundbeurteilung_und_Klassifikation_-__2001.pdf)
- Gerhard Kammerlander / Thomas Eberlein, *Lokaltherapeutische Standards für Hautwunden — Kurzübersicht Teil 1* — [akademie-zwm.ch](https://www.akademie-zwm.ch/uploads/tx_scpublications/Wundtherapie_-_Grundsatzartikel-Uebersicht-Einteilung_1-3.pdf)
- Akademie-ZWM, Verlagsangebot Wund- und Hautposter (Nachweis der Existenz von AVLON) — [akademie-zwm.ch](https://www.akademie-zwm.ch/shop/wund-und-hautposter.html)
- Barbara Uebach, *Wundassessment / Wundverlaufsdokumentation*, Stand 22.01.2021, Deutsche Gesellschaft für Palliativmedizin — [dgpalliativmedizin.de](https://www.dgpalliativmedizin.de/images/Wundassessment_Verlaufsdokumentation_22.01.2021_2.pdf)
- Klinikum Passau, *Leitfaden zum modernen Wundmanagement* — [klinikum-passau.de](https://www.klinikum-passau.de/fileadmin/user_upload/downloads/broschueren/Wundkompendium-Broschuere.pdf)
- Mölnlycke, *Klassifikation von Wunden und deren Grunderkrankungen* (2025) — [molnlycke.com](https://www.molnlycke.com/globalassets/local/de/wissen/woundcare/downloads/2025/wunddokumentation-und-verbandwechsel/2025-molnlycke-legende-wunddoku.pdf)
- BfArM, *ICD-10-GM Version 2026* — [klassifikationen.bfarm.de](https://klassifikationen.bfarm.de/icd-10-gm/kode-suche/htmlgm2026/index.htm), Downloadhinweise — [bfarm.de](https://www.bfarm.de/DE/Kodiersysteme/Services/Downloads/hinweise_downloads.html)
- Draco, *Unterminierung* — [draco.de](https://www.draco.de/unterminierung/)
