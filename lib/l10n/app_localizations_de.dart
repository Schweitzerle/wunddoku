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
}
