# User Flows — wunddoku

> Ein Flow je tragendem Ablauf, mit Entscheidungspunkten und Fehlerwegen — nicht nur
> dem Glücksfall. Mermaid, damit es versionierbar und diffbar bleibt.

## Der Gedanke, der alle Flows trägt

**Hände und Blick sind zu verschiedenen Zeiten frei.**

| Phase | Situation | Was die App verlangt | Rückmeldung |
|---|---|---|---|
| **A — am offenen Verband** | Handschuhe kontaminiert, beide Hände belegt, Blick auf der Wunde | Fotografieren, sprechen. Sonst nichts. | hörbar und spürbar, **nicht** visuell |
| **B — nach dem Verband** | Handschuhe aus, Hände frei, Patient wird versorgt zurückgelassen | Prüfen und korrigieren | visuell, alles auf einem Bild |
| **C — vor dem Verlassen** | Tasche packen, Verabschiedung | abschließen, ggf. Verlauf zeigen | visuell, kurz |

Die übliche Lösung — Formular mit Mikrofonknopf je Feld — verlangt Blick und
Bedienung genau in Phase A, wo beides nicht verfügbar ist. Deshalb sind Erfassung
und Prüfung hier bewusst **zeitlich getrennt**.

---

## Flow 1 — Besuch dokumentieren (Rahmen)

```mermaid
flowchart TD
  START([Pflegekraft öffnet die App<br/>in der Wohnung]) --> HEUTE[Heute: Patienten der Tour]
  HEUTE --> WAHL{Patient bekannt?}
  WAHL -->|ja| PAT[Patientenakte]
  WAHL -->|nein| NEU[Patient anlegen<br/>Name, Geburtsdatum, Adresse]
  NEU --> PAT
  PAT --> WUNDE{Wunde bekannt?}
  WUNDE -->|ja| AKTE[Wundakte mit Verlauf]
  WUNDE -->|nein| WNEU[Wunde anlegen<br/>Lokalisation, Entstehung]
  WNEU --> AKTE
  AKTE --> BESUCH[Besuch starten]

  subgraph A["Phase A — am offenen Verband"]
    BESUCH --> FOTO[Foto aufnehmen<br/>Geisterbild der Vorwoche]
    FOTO --> MARK[Kontur markieren]
    MARK --> SPRECH[Befund sprechen<br/>durchgehend, ohne Blick]
  end

  SPRECH --> HAENDE{{Neuer Verband angelegt,<br/>Handschuhe aus}}

  subgraph B["Phase B — Hände frei"]
    HAENDE --> PRUEF[Bestätigungsansicht<br/>alle Felder auf einem Bild]
    PRUEF --> KORR{Alles richtig?}
    KORR -->|nein| FELD[Einzelnes Feld korrigieren]
    FELD --> PRUEF
  end

  KORR -->|ja| UEBER[Übernehmen]

  subgraph C["Phase C — vor dem Verlassen"]
    UEBER --> LUECK{Unsichere Werte offen?}
    LUECK -->|ja| BLOCK[Speichern blockiert<br/>Werte einzeln entscheiden]
    BLOCK --> PRUEF
    LUECK -->|nein| SPEICH[Lokal gespeichert<br/>verschlüsselt]
    SPEICH --> LUECKE{Angaben fehlen?}
    LUECKE -->|ja| OFFEN[Befund gespeichert,<br/>sichtbar unvollständig]
    LUECKE -->|nein| FERTIG[Befund vollständig]
    OFFEN --> ZEIG
    FERTIG --> ZEIG{Verlauf zeigen?}
    ZEIG -->|ja| PATZEIG[Patientenansicht:<br/>nur diese Wunde]
    ZEIG -->|nein| ENDE
    PATZEIG --> ENDE([Besuch abgeschlossen])
  end

  style A fill:#fff4f4,stroke:#c36
  style B fill:#f4f8ff,stroke:#36c
  style C fill:#f4fff6,stroke:#3a6
  style BLOCK fill:#fde,stroke:#c36
```

**Warum das Speichern bei unsicheren Werten blockiert, bei fehlenden aber nicht:**
Eine Lücke sieht man als Lücke. Ein falsch verstandener Wert sieht aus wie ein
richtiger. **Lücke ist erlaubt, Rätsel nicht.**

---

## Flow 2 — Erfassung per Sprache und Rückkopplung

Der eigentliche Entwurfsraum. Nicht die Transkription, sondern was danach passiert.

```mermaid
flowchart TD
  A[Erfassung starten<br/>ein großer Knopf, unten, einhändig] --> PERM{Mikrofon erlaubt?}
  PERM -->|nein| PERMA[Erklärung, wofür.<br/>Alternative: Kartenmodus mit Auswahl]
  PERMA --> KARTE[Befund per Auswahl erfassen]
  PERM -->|ja| REC[Aufnahme läuft<br/>Pegel sichtbar, Dauerton-Indikator,<br/>Vibration bei Start]

  REC --> LOKAL[(Audio sofort lokal<br/>verschlüsselt gespeichert)]
  LOKAL --> STOP{Nutzer beendet}
  STOP --> NETZ{Netz und Dienst verfügbar?}

  NETZ -->|ja| TRANS[Transkription<br/>wörtlich]
  NETZ -->|nein| QUEUE[Warteschlange:<br/>'1 Aufnahme wartet auf Auswertung']
  QUEUE --> KARTE2[Befund jetzt per Auswahl erfassbar<br/>Audio bleibt als Beleg]
  QUEUE -.später, bei Netz.-> TRANS

  TRANS --> ZUORD[Feldzuordnung gegen den Fachkatalog<br/>Enums, Zahlen, Einheiten]
  ZUORD --> KONF{Sicherheit je Feld}

  KONF -->|hoch| OK[übernommen, normal dargestellt]
  KONF -->|mittel| MED[markiert, Blick empfohlen]
  KONF -->|niedrig| LOW[hervorgehoben und LEER<br/>blockiert das Speichern]
  KONF -->|nicht gesagt| GAP[als Lücke sichtbar<br/>wird nicht geraten]

  OK --> BEST[Bestätigungsansicht]
  MED --> BEST
  LOW --> BEST
  GAP --> BEST

  BEST --> TIP{Feld angetippt}
  TIP -->|Herkunft| HERK[Stelle im wörtlichen Transkript<br/>wird hervorgehoben]
  TIP -->|nachsprechen| NACH[kurzer Satz, nur dieses Feld]
  TIP -->|auswählen| AUSW[Liste der erlaubten Werte]
  HERK --> BEST
  NACH --> ZUORD
  AUSW --> BEST

  BEST --> FERT{Übernehmen}
  FERT -->|niedrige Sicherheit offen| STOPP[Speichern bleibt gesperrt,<br/>betroffene Felder benannt]
  STOPP --> BEST
  FERT -->|frei| UEB[In den Befund übernommen<br/>Transkript wird mitgespeichert]

  style LOW fill:#fde,stroke:#c36
  style STOPP fill:#fde,stroke:#c36
  style GAP fill:#ffd,stroke:#a80
```

**Vier Eigenschaften, die das Muster ausmachen:**

1. **Das wörtliche Transkript bleibt und wird gespeichert.** Es ist der Beleg, wenn
   ein Wert später bestritten wird, und der Rückweg bei Zuordnungsfehlern.
2. **Zuordnung ist ein eigener, sichtbarer Schritt** — Vorschlag mit Herkunft, nicht
   Text direkt ins Feld.
3. **Bestätigung vor Übernahme**, alle Felder auf einem Bild.
4. **Korrektur trifft ein Feld**, nie den ganzen Befund.

**Für jede Sprachaktion existiert eine gleichwertige Bedienung ohne Sprache**
(Kartenmodus). Sprache ist die Abkürzung, nicht der einzige Weg — das ist zugleich
die Antwort auf fehlende Mikrofonberechtigung, auf Lärm und auf den Fall, dass der
Patient nicht möchte, dass gesprochen wird.

---

## Flow 3 — Foto, Markierung, Maße

```mermaid
flowchart TD
  A[Kamera öffnen] --> VOR{Vorheriges Foto vorhanden?}
  VOR -->|ja| GEIST[Voraufnahme halbtransparent<br/>über dem Sucher]
  VOR -->|nein| FREI[Freie Aufnahme]
  GEIST --> SHOT[Auslösen]
  FREI --> SHOT
  SHOT --> ORIG[(Original speichern<br/>bitgleich, verschlüsselt,<br/>App-eigener Bereich)]
  ORIG --> BED[Aufnahmebedingungen mitschreiben:<br/>Zeit, Blitz, Ausrichtung]
  BED --> ZEICH[Kontur markieren]

  ZEICH --> MODUS{Wie markieren?}
  MODUS -->|ziehen| PFAD[Freihandkontur<br/>Zoom vorher möglich]
  MODUS -->|antippen| PUNKT[Punkt für Punkt setzen]
  MODUS -->|Form| FORM[Ellipse aufziehen und anpassen]
  PFAD --> GEO
  PUNKT --> GEO
  FORM --> GEO[(Markierung als Geometrie,<br/>normalisiert 0..1)]

  GEO --> MASS[Maße erfassen: Länge, Breite, Tiefe in cm]
  MASS --> QUELLE{Woher?}
  QUELLE -->|gesprochen| SPR[aus dem Diktat übernommen]
  QUELLE -->|getippt| TIP[Zahlenfeld, große Ziele]
  SPR --> PLAUS{Plausibel?}
  TIP --> PLAUS
  PLAUS -->|nein| WARN[Hinweis mit Grund,<br/>Wert bleibt änderbar, nicht verworfen]
  WARN --> MASS
  PLAUS -->|ja| FLAECHE[Fläche als Näherung L×B,<br/>ausdrücklich als Näherung beschriftet]

  FLAECHE --> ABGEL[(Abgeleitete Ansichtsdatei:<br/>Markierung eingebrannt)]
  ABGEL --> VERGL{Bedingungen wie beim letzten Mal?}
  VERGL -->|nein| KENN[Als eingeschränkt vergleichbar<br/>gekennzeichnet]
  VERGL -->|ja| OK([Aufnahme abgeschlossen])
  KENN --> OK

  style ORIG fill:#f4f8ff,stroke:#36c
  style GEO fill:#f4f8ff,stroke:#36c
  style ABGEL fill:#f4fff6,stroke:#3a6
```

**Drei Artefakte je Aufnahme,** wie in `/eps:bild-erfassung` gefordert: unverändertes
Original, Markierung als normalisierte Geometrie, daraus erzeugte Ansichtsdatei mit
eingebrannter Markierung. Das Briefing verlangt genau das — *„Original + Stiftmarkierung
als eingebrannte Zweitdatei"*.

**Die Fläche wird nicht aus dem Bild gerechnet.** Ohne Maßstab im Bild wäre das eine
erfundene Zahl. Gemessen wird wie heute mit dem Lineal, gesprochen wird der Wert, die
Fläche ist die klinisch übliche Näherung L×B und heißt auch so. Ein Maßstab per
mitfotografiertem Referenzobjekt steht in der Story Map unter „Später" —
als benannte Ausbaustufe, nicht als stille Auslassung.

**Ziehen hat immer eine Alternative** (WCAG 2.5.7): Punkt-für-Punkt-Setzen und eine
aufziehbare Ellipse. Mit Handschuhen ist die Ellipse oft der schnellere Weg.

---

## Flow 4 — Verlauf verstehen

Der eigentliche klinische Wert laut Briefing: *„verlauf soll verstanden werden ob
kleiner größer etc"*.

```mermaid
flowchart TD
  A[Wundakte öffnen] --> N{Wie viele Besuche?}
  N -->|0| LEER[Leerzustand: erklärt,<br/>was ein Besuch festhält.<br/>Aktion: ersten Besuch starten]
  N -->|1| EINS[Ein Besuch: Bild und Werte.<br/>Hinweis, dass ein Verlauf<br/>ab dem zweiten Besuch entsteht]
  N -->|2 und mehr| VERL[Verlaufsansicht]

  VERL --> ZEIT[Zeitachse mit Miniaturen]
  ZEIT --> WAHL{Was ansehen?}
  WAHL -->|zwei Bilder| SLIDE[Schieberegler zwischen<br/>zwei Zeitpunkten]
  WAHL -->|Zahlen| KURVE[Fläche und Tiefe über Zeit]
  WAHL -->|ein Besuch| DETAIL[Befund dieses Besuchs]

  SLIDE --> QUAL{Bedingungen vergleichbar?}
  QUAL -->|nein| HINW[Sichtbarer Hinweis:<br/>unterschiedlicher Abstand oder Licht]
  QUAL -->|ja| ZEIGE[Vergleich]
  HINW --> ZEIGE

  KURVE --> LUECK{Lücken in den Werten?}
  LUECK -->|ja| GESTR[Lücke bleibt Lücke,<br/>keine interpolierte Linie]
  LUECK -->|nein| LINIE[Durchgehende Linie]

  ZEIGE --> PAT{Dem Patienten zeigen?}
  LINIE --> PAT
  GESTR --> PAT
  DETAIL --> PAT
  PAT -->|ja| MODUS[Patientenansicht:<br/>nur diese Wunde,<br/>keine Navigation zu anderen Akten]
  PAT -->|nein| ENDE([zurück])
  MODUS --> ENDE

  style HINW fill:#ffd,stroke:#a80
  style GESTR fill:#ffd,stroke:#a80
  style MODUS fill:#f4fff6,stroke:#3a6
```

Zwei Ehrlichkeitsregeln: **keine interpolierte Linie über fehlende Messungen**, und
**Bilder aus zu verschiedenen Aufnahmesituationen werden gekennzeichnet**, statt
kommentarlos nebeneinandergestellt zu werden. Beides sind Stellen, an denen eine
hübsche Darstellung eine Aussage suggerieren würde, die die Daten nicht hergeben.

Die **Patientenansicht** ist kein Beiwerk: Wer dem Patienten den Bildschirm hinhält,
darf dabei nicht die Liste der anderen Patienten zeigen.

---

## Flow 5 — Wundbericht ins Büro

```mermaid
flowchart TD
  A[Bericht erzeugen] --> ZEIT{Zeitraum}
  ZEIT --> INHALT[Auswahl: welche Besuche,<br/>welche Bilder, Verlaufskurve]
  INHALT --> LUECK{Unvollständige Befunde enthalten?}
  LUECK -->|ja| MARK[Im Bericht als unvollständig<br/>ausgewiesen, nicht verschwiegen]
  LUECK -->|nein| VOLL[Vollständig]
  MARK --> VORSCHAU
  VOLL --> VORSCHAU[Vorschau, seitengenau]
  VORSCHAU --> OK{Freigeben?}
  OK -->|nein| INHALT
  OK -->|ja| PDF[(PDF erzeugt,<br/>im App-Bereich abgelegt)]
  PDF --> TEIL{Weitergabe}
  TEIL -->|Systemdialog| WARN[Hinweis vor dem Teilen:<br/>Gesundheitsdaten verlassen die App]
  TEIL -->|nur speichern| ABL([abgelegt])
  WARN --> BEST{bestätigt?}
  BEST -->|ja| RAUS([geteilt, im Zugriffsprotokoll vermerkt])
  BEST -->|nein| ABL

  style WARN fill:#fde,stroke:#c36
```

Der Bericht ist der Punkt, an dem der Nutzen für Dritte sichtbar wird — und
gleichzeitig der Punkt, an dem Gesundheitsdaten den geschützten Bereich verlassen.
Deshalb steht dort eine bewusste Bestätigung und ein Eintrag im Zugriffsprotokoll,
kein stiller Systemdialog.

---

## Fehler- und Randwege, die in jedem Flow gelten

| Fall | Verhalten |
|---|---|
| App wird unterbrochen (Anruf, Akku, Zurück) | Autosave nach jedem Feld; Wiedereinstieg an derselben Stelle mit sichtbarem Hinweis, wo es weitergeht |
| Kein Netz | Kein Unterschied im Ablauf. Audio in die Warteschlange, Status in Nutzersprache: „1 Aufnahme wartet auf Auswertung" |
| Mikrofon verweigert | Kartenmodus, gleichwertig bedienbar; Erklärung wofür, nicht bloß „Berechtigung fehlt" |
| Kamera verweigert | Befund ohne Foto möglich, Foto als Lücke sichtbar |
| Speicher voll | Vor der Aufnahme geprüft, nicht danach; Aufnahme wird nicht begonnen, wenn sie nicht gesichert werden kann |
| Auswertung schlägt fehl | Audio bleibt erhalten, Fehler mit Grund und einer Handlung — kein stiller Wiederholungsversuch |
| Gerät verloren | Ruhende Daten verschlüsselt, Zugang gesperrt; siehe `datenschutz-art9.md` |
