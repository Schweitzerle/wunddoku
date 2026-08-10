# Der Nachprozess im Büro

> Die App ist der Erfassungspunkt eines Prozesses, nicht sein Zweck. Der Wert
> entsteht dort, wo das Erfasste gebraucht wird.

## Was heute hinten herausfällt

| Ergebnis | Empfänger | Auslöser | Format heute |
|---|---|---|---|
| Wunddokumentation in der Akte | Sanitätshaus selbst, Nachweispflicht | jeder Besuch | abends getippt |
| Wundbericht | behandelnder Arzt *(Annahme)* | Arztkontakt, Verlaufsfrage, Therapiewechsel | eigens geschriebenes Dokument |
| ICD-10-Diagnose | Arztkommunikation, Abrechnung | Anlegen der Wunde | im Kopf bzw. im Bericht |

Der Bericht wird heute **ein zweites Mal formuliert** — derselbe Befund, neu in Worte
gefasst. Genau diese Doppelarbeit fällt weg, wenn der Befund strukturiert vorliegt.

## Was die App liefert

**Slice 1:** PDF-Wundbericht je Wunde über einen wählbaren Zeitraum. Enthält
Stammdaten in dem Umfang, den der Empfänger braucht, Verlauf der Maße, die
markierten Fotos der ausgewählten Besuche, und die Befundkarten je Besuch in
Fachsprache.

Drei Eigenschaften, die den Bericht brauchbar machen:

- **Unvollständiges wird als unvollständig ausgewiesen.** Ein Bericht, der Lücken
  glattbügelt, ist gefährlicher als einer, der sie zeigt.
- **Fotos mit Aufnahmedatum und Vergleichbarkeitsvermerk.** Zwei Bilder
  nebeneinander behaupten sonst eine Aussage, die die Aufnahmesituation nicht trägt.
- **Kein neu formulierter Fachsatz.** Der Berichtstext entsteht aus den strukturierten
  Werten, nicht aus einer zweiten Eingabe.

## Warum kein Backend — und was stattdessen mitgedacht wird

Die Entscheidung steht in `DECISIONS.md`: rein lokal, offline-first, keine
Gegenstelle. Für den Echtbetrieb ist das nicht das Ende der Geschichte, deshalb wird
die Anschlussfähigkeit **jetzt** hergestellt, statt später nachgerüstet:

- Das Repository ist von Anfang an die einzige Quelle der Wahrheit; ViewModels sehen
  nie eine Datenquelle direkt.
- Jeder Datensatz führt ein Feld für den Übertragungszustand mit, auch solange
  nichts überträgt.
- **Konfliktstrategie: nur anfügen.** Jeder Besuch ist ein neuer Eintrag, nichts wird
  nachträglich überschrieben. Bei Verlaufsdokumentation ist das nicht die bequemste,
  sondern die einzige fachlich vertretbare Antwort — ein rückwirkend geänderter
  Befund wäre in einer Nachweisdokumentation ein Problem, kein Komfortgewinn.
  Korrekturen entstehen als Korrektureintrag mit Bezug, nicht als Überschreibung.
- Der Übertragungsstatus hat schon jetzt seinen Platz in der Oberfläche — die
  Warteschlange für die Sprachauswertung benutzt genau dasselbe Muster
  („1 Aufnahme wartet auf Auswertung"). Kommt später die Synchronisation dazu,
  ist die Sprache dafür bereits eingeführt.

Damit ist der Weg zur Büro-Gegenstelle offen, ohne dass für das Testprojekt ein
Server, ein Account oder eine Auftragsverarbeitung entsteht.
