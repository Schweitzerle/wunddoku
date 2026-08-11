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
}
