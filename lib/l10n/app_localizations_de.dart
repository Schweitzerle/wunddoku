// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'wunddoku';

  @override
  String get confirmationTitle => 'Prüfen';

  @override
  String confirmationSummary(int taken, int check, int missing) {
    return '$taken übernommen · $check prüfen · $missing fehlen';
  }

  @override
  String get confirmationEmpty => 'Noch nichts erfasst.';

  @override
  String get confirmationEmptyHint =>
      'Sprich den Befund ein — hier siehst du danach, was verstanden wurde.';

  @override
  String get confirmationBackToCapture => 'Zur Erfassung';

  @override
  String get confirmationAccept => 'Übernehmen';

  @override
  String confirmationBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Werte müssen noch entschieden werden.',
      one: 'Ein Wert muss noch entschieden werden.',
    );
    return '$_temp0';
  }

  @override
  String get confidenceHigh => 'Sicher erkannt';

  @override
  String get confidenceMedium => 'Bitte prüfen';

  @override
  String get confidenceLow => 'Entscheiden';

  @override
  String get confidenceMissing => 'fehlt';

  @override
  String get fieldLengthCm => 'Länge';

  @override
  String get fieldWidthCm => 'Breite';

  @override
  String get fieldDepthCm => 'Tiefe';

  @override
  String get fieldExudateAmount => 'Exsudat';

  @override
  String get fieldExudateKind => 'Exsudatart';

  @override
  String get fieldPainScore => 'Schmerz';

  @override
  String get fieldTissueNecrosis => 'Nekrose';

  @override
  String get fieldTissueFibrin => 'Fibrin';

  @override
  String get fieldTissueGranulation => 'Granulation';

  @override
  String get fieldTissueEpithelialisation => 'Epithelisation';

  @override
  String get fieldTissueOther => 'Andere Strukturen';

  @override
  String valueCentimetres(String value) {
    return '$value cm';
  }

  @override
  String valuePercent(int value) {
    return '$value %';
  }

  @override
  String valuePainScore(int value) {
    return '$value von 10';
  }

  @override
  String get exudateAmountNone => 'kein';

  @override
  String get exudateAmountSlight => 'gering';

  @override
  String get exudateAmountModerate => 'mäßig';

  @override
  String get exudateAmountHeavy => 'stark';

  @override
  String get exudateKindSerous => 'serös';

  @override
  String get exudateKindPurulent => 'eitrig';

  @override
  String get exudateKindBloody => 'blutig';

  @override
  String get provenanceTitle => 'Wortlaut';

  @override
  String get provenanceHint => 'Aus diesem Teil der Aufnahme stammt der Wert.';

  @override
  String get actionShowProvenance => 'Wortlaut zeigen';

  @override
  String get actionDiscardValue => 'Wert verwerfen';

  @override
  String get actionAcceptValue => 'Wert übernehmen';

  @override
  String get close => 'Schließen';

  @override
  String get captureTitle => 'Befund sprechen';

  @override
  String get captureIdleHint =>
      'Sprich Maße, Wundgrund, Exsudat und Schmerz — in beliebiger Reihenfolge.';

  @override
  String get captureExampleOne =>
      '„Länge drei Komma fünf, Breite zwei, Tiefe null Komma fünf.“';

  @override
  String get captureExampleTwo =>
      '„Granulation sechzig Prozent, Fibrin vierzig Prozent. Exsudat gering, serös.“';

  @override
  String captureStandingValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Werte erfasst',
      one: '1 Wert erfasst',
    );
    return '$_temp0';
  }

  @override
  String captureStandingGaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Angaben fehlen',
      one: '1 Angabe fehlt',
      zero: 'vollständig',
    );
    return '$_temp0';
  }

  @override
  String captureStandingPhoto(int count, int marked) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    String _temp1 = intl.Intl.pluralLogic(
      marked,
      locale: localeName,
      other: ' · $marked mit Markierung',
      zero: '',
    );
    return '$_temp0$_temp1';
  }

  @override
  String get captureStart => 'Aufnahme starten';

  @override
  String get captureStop => 'Fertig';

  @override
  String get captureRecording => 'Aufnahme läuft';

  @override
  String captureElapsed(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get captureInterpreting => 'Wird ausgewertet …';

  @override
  String get captureQueued => '1 Aufnahme wartet auf Auswertung.';

  @override
  String get captureQueuedHint =>
      'Die Aufnahme ist gespeichert. Du kannst den Befund jetzt über die Karten erfassen.';

  @override
  String get captureNoMicrophone => 'Ohne Mikrofon geht es auch.';

  @override
  String get captureNoMicrophoneHint =>
      'Das Mikrofon nimmt nur auf, während du den Knopf gedrückt hältst — für den Befund am offenen Verband. Ohne Mikrofon erfasst du denselben Befund über die Karten.';

  @override
  String get captureUseCards => 'Über Karten erfassen';

  @override
  String captureRecognizedSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Angaben erkannt',
      one: '1 Angabe erkannt',
      zero: 'Noch nichts erkannt',
    );
    return '$_temp0';
  }

  @override
  String confirmationGapsCollapsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Angaben fehlen',
      one: 'Eine Angabe fehlt',
    );
    return '$_temp0';
  }

  @override
  String get confirmationGapsNone => 'Nichts fehlt.';

  @override
  String confirmationSettledHeading(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Werte übernommen',
      one: '1 Wert übernommen',
    );
    return '$_temp0';
  }

  @override
  String get confirmationAllClear => 'Alles geprüft.';

  @override
  String confirmationNeedsDecision(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Werte brauchen dich',
      one: '1 Wert braucht dich',
    );
    return '$_temp0';
  }

  @override
  String get cardsTitle => 'Befund erfassen';

  @override
  String get cardsWoundBed => 'Wundgrund';

  @override
  String get cardsMeasurements => 'Maße';

  @override
  String get cardsExudation => 'Exsudation';

  @override
  String cardsTissueRemainder(int percent) {
    return '$percent % nicht vergeben';
  }

  @override
  String cardsTissueOver(Object percent) {
    return '$percent % zu viel vergeben';
  }

  @override
  String get cardsTissueComplete => 'Vollständig verteilt';

  @override
  String cardsIncrease(String field) {
    return '$field erhöhen';
  }

  @override
  String cardsDecrease(String field) {
    return '$field verringern';
  }

  @override
  String get cardsNotEnteredShort => '—';

  @override
  String get cardsDone => 'Fertig';

  @override
  String get markingTitle => 'Wunde markieren';

  @override
  String get markingHint =>
      'Umrande die Wunde. Das Original bleibt unverändert.';

  @override
  String get markingToolEllipse => 'Ellipse';

  @override
  String get markingToolPoints => 'Punkte';

  @override
  String get markingToolFreehand => 'Freihand';

  @override
  String get markingUndo => 'Letzten Punkt zurück';

  @override
  String get markingClear => 'Markierung löschen';

  @override
  String get markingDone => 'Markierung übernehmen';

  @override
  String get markingEmptyHint => 'Noch nichts markiert.';

  @override
  String get markingPreviousVisit => 'Voriger Besuch ist mit eingeblendet';

  @override
  String get photoTitle => 'Wunde fotografieren';

  @override
  String get photoHint =>
      'Gleicher Abstand wie beim letzten Mal — das Geisterbild hilft beim Ausrichten.';

  @override
  String get photoHintFirst =>
      'Erstes Foto dieser Wunde. Formatiere frontal und mit gleichbleibendem Abstand.';

  @override
  String get photoGhost => 'Voriges Foto einblenden';

  @override
  String get photoShutter => 'Foto aufnehmen';

  @override
  String get photoAccept => 'Foto übernehmen';

  @override
  String get photoRetake => 'Neu aufnehmen';

  @override
  String get photoDeniedTitle => 'Kein Zugriff auf die Kamera';

  @override
  String get photoDeniedBody =>
      'Die Berechtigung fehlt. In den Einstellungen erteilen oder den Befund ohne Foto erfassen.';

  @override
  String get photoUnavailableTitle => 'Keine Kamera gefunden';

  @override
  String get photoFailedTitle => 'Kamera lässt sich nicht starten';

  @override
  String get photoSkip => 'Ohne Foto weiter';

  @override
  String get photoRetry => 'Erneut versuchen';

  @override
  String get captureTakePhoto => 'Wunde fotografieren';

  @override
  String get closingTitle => 'Besuch abschließen';

  @override
  String get closingComplete => 'Befund vollständig';

  @override
  String closingGaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Angaben fehlen',
      one: 'Eine Angabe fehlt',
    );
    return '$_temp0';
  }

  @override
  String get closingGapsHint =>
      'Lücken dürfen mitgehen. Der Befund wird als unvollständig geführt.';

  @override
  String closingRecorded(int count) {
    return '$count erfasst';
  }

  @override
  String get closingMissingHeader => 'Fehlt noch';

  @override
  String closingTissueRemainder(int sum) {
    return 'Gewebeanteile ergeben $sum %, nicht 100 %.';
  }

  @override
  String closingPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: 'Ein Foto',
      zero: 'Kein Foto',
    );
    return '$_temp0';
  }

  @override
  String closingPhotoMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mit Markierung',
      one: 'mit Markierung',
    );
    return '$_temp0';
  }

  @override
  String get closingNoPhotoHint =>
      'Ohne Foto lässt sich der Verlauf später nicht vergleichen.';

  @override
  String get closingFinish => 'Besuch abschließen';

  @override
  String get closingFinishWithGaps => 'Mit Lücken abschließen';

  @override
  String get closingBack => 'Zurück zur Erfassung';

  @override
  String get closingDone => 'Besuch abgeschlossen.';

  @override
  String get captureFinishVisit => 'Besuch abschließen';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historyEmpty => 'Noch kein Besuch dokumentiert.';

  @override
  String get historyEmptyHint =>
      'Ein Besuch hält Maße, Wundgrund und ein Foto fest. Ab dem zweiten Besuch zeigt der Verlauf, ob die Wunde kleiner wird.';

  @override
  String get historySingleHint =>
      'Der Vergleich entsteht ab dem zweiten Besuch.';

  @override
  String historyDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get historyAreaLabel => 'Fläche';

  @override
  String historyArea(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString cm²';
  }

  @override
  String get historyAreaApprox => 'Fläche als Näherung: Länge × Breite.';

  @override
  String historyAreaIncrease(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString cm² größer als beim vorigen Besuch';
  }

  @override
  String historyAreaDecrease(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString cm² kleiner als beim vorigen Besuch';
  }

  @override
  String get historyAreaUnchanged => 'unverändert zum vorigen Besuch';

  @override
  String historyDepth(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return 'Tiefe $valueString cm';
  }

  @override
  String get historyNoMeasurements => 'Keine Maße erfasst';

  @override
  String get historyVisitOpen => 'Besuch offen';

  @override
  String get historyVisitWithGaps => 'Mit Lücken abgeschlossen';

  @override
  String get historyPhotoMissing => 'Foto nicht lesbar';

  @override
  String get historyNoPhoto => 'Kein Foto';

  @override
  String get captureShowHistory => 'Verlauf';

  @override
  String get reportTitle => 'Wundbericht';

  @override
  String get reportPatient => 'Patientin/Patient';

  @override
  String reportBirthDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'geboren am $dateString';
  }

  @override
  String get reportWound => 'Wunde';

  @override
  String get reportDiagnosis => 'Diagnose (ICD-10-GM)';

  @override
  String reportPeriod(DateTime from, DateTime to) {
    final intl.DateFormat fromDateFormat = intl.DateFormat.yMd(localeName);
    final String fromString = fromDateFormat.format(from);
    final intl.DateFormat toDateFormat = intl.DateFormat.yMd(localeName);
    final String toString = toDateFormat.format(to);

    return 'Zeitraum $fromString bis $toString';
  }

  @override
  String reportCreatedAt(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Erstellt am $dateString';
  }

  @override
  String reportDepthValue(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString cm';
  }

  @override
  String reportPage(int page, int total) {
    return 'Seite $page von $total';
  }

  @override
  String get reportGapNotice =>
      'Dieser Bericht enthält unvollständige Befunde. Fehlende Angaben sind als „fehlt“ ausgewiesen und nicht geschätzt.';

  @override
  String get reportCourseHeading => 'Verlauf';

  @override
  String get reportColumnDate => 'Datum';

  @override
  String get reportColumnArea => 'Fläche';

  @override
  String get reportColumnDepth => 'Tiefe';

  @override
  String get reportColumnStatus => 'Vollständigkeit';

  @override
  String get reportStatusComplete => 'vollständig';

  @override
  String reportStatusGaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Angaben fehlen',
      one: 'eine Angabe fehlt',
    );
    return '$_temp0';
  }

  @override
  String reportVisitHeading(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Besuch vom $dateString';
  }

  @override
  String get reportPhotoMissing => 'Kein Foto zu diesem Besuch.';

  @override
  String get reportPhotoFirst =>
      'Erstes Foto dieser Wunde — ohne Vorbild aufgenommen, Abstand daher nicht abgeglichen.';

  @override
  String reportPhotoCaption(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Aufnahme vom $dateString, Markierung eingebrannt.';
  }

  @override
  String get reportNoVisits =>
      'Für den gewählten Zeitraum liegt kein Besuch vor.';

  @override
  String get reportShare => 'Bericht erzeugen';

  @override
  String get patientsTitle => 'Patienten';

  @override
  String get patientsSearch => 'Name suchen';

  @override
  String get patientsEmpty => 'Noch kein Patient angelegt.';

  @override
  String get patientsEmptyHint =>
      'Leg den ersten an, dann kann der Besuch beginnen.';

  @override
  String patientsNoMatch(String query) {
    return 'Kein Treffer für „$query“.';
  }

  @override
  String get patientsAdd => 'Patient anlegen';

  @override
  String patientsUnfinishedHeading(int count) {
    return 'Besuch offen · $count';
  }

  @override
  String patientsRestHeading(int count) {
    return 'Alle übrigen · $count';
  }

  @override
  String get patientOpenVisitBadge => 'Besuch offen';

  @override
  String patientBirthDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'geb. $dateString';
  }

  @override
  String patientWoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wunden',
      one: '1 Wunde',
      zero: 'keine Wunde',
    );
    return '$_temp0';
  }

  @override
  String get patientFormTitle => 'Neuer Patient';

  @override
  String get patientGivenName => 'Vorname';

  @override
  String get patientFamilyName => 'Nachname';

  @override
  String get patientBirthDateLabel => 'Geburtsdatum';

  @override
  String get patientStreet => 'Straße und Hausnummer';

  @override
  String get patientPostalCode => 'PLZ';

  @override
  String get patientCity => 'Ort';

  @override
  String get patientSave => 'Anlegen';

  @override
  String get patientRequired => 'Pflichtangabe';

  @override
  String get patientPickBirthDate => 'Geburtsdatum wählen';

  @override
  String get woundsTitle => 'Wunden';

  @override
  String get woundsEmpty =>
      'Für diesen Patienten ist noch keine Wunde angelegt.';

  @override
  String patientAddress(String street, String postalCode, String city) {
    return '$street, $postalCode $city';
  }

  @override
  String get woundsHeading => 'Wunden';

  @override
  String get woundNoPhoto => 'kein Foto';

  @override
  String get woundPhotoMissing => 'Foto fehlt';

  @override
  String get woundShowHistory => 'Verlauf ansehen';

  @override
  String get woundsAdd => 'Wunde anlegen';

  @override
  String woundOpenSince(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'seit $dateString in Behandlung';
  }

  @override
  String woundClosedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'abgeheilt am $dateString';
  }

  @override
  String woundVisitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Besuche',
      one: '1 Besuch',
      zero: 'noch kein Besuch',
    );
    return '$_temp0';
  }

  @override
  String get woundFormTitle => 'Neue Wunde';

  @override
  String get woundLocation => 'Lokalisation';

  @override
  String get woundLocationHint => 'z. B. linker Unterschenkel, distal';

  @override
  String get woundLocationRequired =>
      'Ohne Lokalisation lassen sich zwei Wunden nicht auseinanderhalten.';

  @override
  String get woundIcd10 => 'ICD-10-Code (optional)';

  @override
  String get woundSave => 'Anlegen';

  @override
  String get woundStartVisit => 'Besuch beginnen';

  @override
  String get captureFinishShort => 'Abschließen';

  @override
  String get captureMetricValues => 'Werte';

  @override
  String get captureMetricPhotos => 'Fotos';

  @override
  String get captureMetricGaps => 'fehlen';

  @override
  String get captureMetricComplete => 'vollständig';

  @override
  String get captureMarkedShort => 'markiert';

  @override
  String captureContext(String patient, String wound) {
    return '$patient · $wound';
  }

  @override
  String get captureWaysHeading => 'Andere Wege';

  @override
  String get captureExamplesHeading => 'So kann das klingen';

  @override
  String get captureTopicMeasurements => 'Maße';

  @override
  String get captureTopicWoundBed => 'Wundgrund';

  @override
  String get captureTopicExudate => 'Exsudat';

  @override
  String get captureTopicPain => 'Schmerz';

  @override
  String get captureTopicsHeading => 'Sprich der Reihe nach oder durcheinander';

  @override
  String get captureWayCards => 'Karten';

  @override
  String get captureWayPhoto => 'Foto';

  @override
  String get captureWayHistory => 'Verlauf';

  @override
  String get visitStepSpeak => 'Sprechen';

  @override
  String get visitStepCheck => 'Prüfen';

  @override
  String get visitStepPhoto => 'Foto';

  @override
  String get visitStepClosing => 'Abschluss';

  @override
  String visitStepPosition(int position, int total, String step) {
    return 'Schritt $position von $total: $step';
  }

  @override
  String visitHeaderDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'dd.MM.',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Besuch · $dateString';
  }

  @override
  String historyChartSpan(DateTime from, DateTime to) {
    final intl.DateFormat fromDateFormat = intl.DateFormat.yMd(localeName);
    final String fromString = fromDateFormat.format(from);
    final intl.DateFormat toDateFormat = intl.DateFormat.yMd(localeName);
    final String toString = toDateFormat.format(to);

    return '$fromString bis $toString';
  }

  @override
  String historyChartLatest(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return 'zuletzt $valueString cm²';
  }

  @override
  String historyChartFirst(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return 'zu Beginn $valueString cm²';
  }
}
