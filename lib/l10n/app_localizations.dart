import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// Name der Anwendung, erscheint im Fenstertitel und im Umschalter.
  ///
  /// In de, this message translates to:
  /// **'wunddoku'**
  String get appTitle;

  /// Titel der Bestätigungsansicht, in der die Pflegekraft die erkannten Felder durchsieht.
  ///
  /// In de, this message translates to:
  /// **'Prüfen'**
  String get confirmationTitle;

  /// Kopfzeile der Bestätigungsansicht. Fasst zusammen, wie viele Felder sicher erkannt wurden, wie viele einen Blick brauchen und wie viele gar nicht gesagt wurden.
  ///
  /// In de, this message translates to:
  /// **'{taken} übernommen · {check} prüfen · {missing} fehlen'**
  String confirmationSummary(int taken, int check, int missing);

  /// Leerzustand der Bestätigungsansicht, wenn sie ohne vorherige Aufnahme geöffnet wurde.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts erfasst.'**
  String get confirmationEmpty;

  /// Erklärender Satz im Leerzustand der Bestätigungsansicht. Sagt, wofür der Screen da ist.
  ///
  /// In de, this message translates to:
  /// **'Sprich den Befund ein — hier siehst du danach, was verstanden wurde.'**
  String get confirmationEmptyHint;

  /// Aktion im Leerzustand der Bestätigungsansicht, führt zurück zum Sprechen.
  ///
  /// In de, this message translates to:
  /// **'Zur Erfassung'**
  String get confirmationBackToCapture;

  /// Primäre Aktion der Bestätigungsansicht: die geprüften Werte in den Befund übernehmen.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get confirmationAccept;

  /// Hinweis unter dem gesperrten Übernehmen-Knopf, wenn Werte mit niedriger Sicherheit offen sind.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Ein Wert muss noch entschieden werden.} other{{count} Werte müssen noch entschieden werden.}}'**
  String confirmationBlocked(int count);

  /// Semantik-Label für ein Feld mit hoher Erkennungssicherheit. Wird vom Screenreader vorgelesen, weil die Stufe sonst nur an Symbol und Farbe hinge.
  ///
  /// In de, this message translates to:
  /// **'Sicher erkannt'**
  String get confidenceHigh;

  /// Semantik-Label und Aufschrift für ein Feld mit mittlerer Erkennungssicherheit.
  ///
  /// In de, this message translates to:
  /// **'Bitte prüfen'**
  String get confidenceMedium;

  /// Semantik-Label und Aufschrift für ein Feld mit niedriger Erkennungssicherheit. Solche Felder sperren das Speichern.
  ///
  /// In de, this message translates to:
  /// **'Entscheiden'**
  String get confidenceLow;

  /// Aufschrift für ein Feld, zu dem nichts gesagt wurde. Bewusst leer statt geraten.
  ///
  /// In de, this message translates to:
  /// **'fehlt'**
  String get confidenceMissing;

  /// Feldbezeichnung für die Wundlänge in Zentimetern.
  ///
  /// In de, this message translates to:
  /// **'Länge'**
  String get fieldLengthCm;

  /// Feldbezeichnung für die Wundbreite in Zentimetern.
  ///
  /// In de, this message translates to:
  /// **'Breite'**
  String get fieldWidthCm;

  /// Feldbezeichnung für die Wundtiefe in Zentimetern.
  ///
  /// In de, this message translates to:
  /// **'Tiefe'**
  String get fieldDepthCm;

  /// Feldbezeichnung für die Exsudatmenge.
  ///
  /// In de, this message translates to:
  /// **'Exsudat'**
  String get fieldExudateAmount;

  /// Feldbezeichnung für die Art des Exsudats.
  ///
  /// In de, this message translates to:
  /// **'Exsudatart'**
  String get fieldExudateKind;

  /// Feldbezeichnung für die Schmerzintensität auf der Skala 0 bis 10.
  ///
  /// In de, this message translates to:
  /// **'Schmerz'**
  String get fieldPainScore;

  /// Feldbezeichnung für den Gewebeanteil Nekrose am Wundgrund. Fachbegriff des Kunden, wird nicht umformuliert.
  ///
  /// In de, this message translates to:
  /// **'Nekrose'**
  String get fieldTissueNecrosis;

  /// Feldbezeichnung für den Gewebeanteil Fibrinbelag am Wundgrund.
  ///
  /// In de, this message translates to:
  /// **'Fibrin'**
  String get fieldTissueFibrin;

  /// Feldbezeichnung für den Gewebeanteil Granulationsgewebe am Wundgrund.
  ///
  /// In de, this message translates to:
  /// **'Granulation'**
  String get fieldTissueGranulation;

  /// Feldbezeichnung für den Gewebeanteil Epithelgewebe am Wundgrund.
  ///
  /// In de, this message translates to:
  /// **'Epithelisation'**
  String get fieldTissueEpithelialisation;

  /// Feldbezeichnung für sonstige sichtbare Strukturen am Wundgrund, etwa freiliegende Sehne oder Knochen.
  ///
  /// In de, this message translates to:
  /// **'Andere Strukturen'**
  String get fieldTissueOther;

  /// Ein Maß in Zentimetern, wie es in der Bestätigungszeile steht.
  ///
  /// In de, this message translates to:
  /// **'{value} cm'**
  String valueCentimetres(String value);

  /// Ein Gewebeanteil in Prozent.
  ///
  /// In de, this message translates to:
  /// **'{value} %'**
  String valuePercent(int value);

  /// Die Schmerzintensität auf der Skala 0 bis 10.
  ///
  /// In de, this message translates to:
  /// **'{value} von 10'**
  String valuePainScore(int value);

  /// Exsudatmenge: kein Exsudat. Wert aus dem Fachkatalog des Kunden.
  ///
  /// In de, this message translates to:
  /// **'kein'**
  String get exudateAmountNone;

  /// Exsudatmenge: geringe Menge.
  ///
  /// In de, this message translates to:
  /// **'gering'**
  String get exudateAmountSlight;

  /// Exsudatmenge: mäßige Menge.
  ///
  /// In de, this message translates to:
  /// **'mäßig'**
  String get exudateAmountModerate;

  /// Exsudatmenge: starke Menge.
  ///
  /// In de, this message translates to:
  /// **'stark'**
  String get exudateAmountHeavy;

  /// Exsudatart: serös. Fachbegriff, nicht übersetzen.
  ///
  /// In de, this message translates to:
  /// **'serös'**
  String get exudateKindSerous;

  /// Exsudatart: eitrig.
  ///
  /// In de, this message translates to:
  /// **'eitrig'**
  String get exudateKindPurulent;

  /// Exsudatart: blutig.
  ///
  /// In de, this message translates to:
  /// **'blutig'**
  String get exudateKindBloody;

  /// Überschrift des Herkunftsbelegs: zeigt die Stelle im wörtlichen Transkript, aus der ein Wert stammt.
  ///
  /// In de, this message translates to:
  /// **'Wortlaut'**
  String get provenanceTitle;

  /// Erklärung über dem hervorgehobenen Transkriptausschnitt im Herkunftsbeleg.
  ///
  /// In de, this message translates to:
  /// **'Aus diesem Teil der Aufnahme stammt der Wert.'**
  String get provenanceHint;

  /// Aktion in der Feldzeile: die Herkunft des Werts im Transkript anzeigen.
  ///
  /// In de, this message translates to:
  /// **'Wortlaut zeigen'**
  String get actionShowProvenance;

  /// Aktion in der Feldzeile: den vorgeschlagenen Wert verwerfen, das Feld bleibt leer.
  ///
  /// In de, this message translates to:
  /// **'Wert verwerfen'**
  String get actionDiscardValue;

  /// Aktion in der Feldzeile: einen unsicheren Wert bewusst bestätigen.
  ///
  /// In de, this message translates to:
  /// **'Wert übernehmen'**
  String get actionAcceptValue;

  /// Schließt einen Dialog oder ein Blatt.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// Titel des Aufnahme-Screens, auf dem der Befund am offenen Verband diktiert wird.
  ///
  /// In de, this message translates to:
  /// **'Befund sprechen'**
  String get captureTitle;

  /// Erklärender Satz im Leerzustand des Aufnahme-Screens. Sagt, was gesprochen werden kann.
  ///
  /// In de, this message translates to:
  /// **'Sprich Maße, Wundgrund, Exsudat und Schmerz — in beliebiger Reihenfolge.'**
  String get captureIdleHint;

  /// Erster Beispielsatz im Leerzustand des Aufnahme-Screens. Fachvokabular des Kunden, nicht umformulieren.
  ///
  /// In de, this message translates to:
  /// **'„Länge drei Komma fünf, Breite zwei, Tiefe null Komma fünf.“'**
  String get captureExampleOne;

  /// Zweiter Beispielsatz im Leerzustand des Aufnahme-Screens.
  ///
  /// In de, this message translates to:
  /// **'„Granulation sechzig Prozent, Fibrin vierzig Prozent. Exsudat gering, serös.“'**
  String get captureExampleTwo;

  /// Primäre Aktion des Aufnahme-Screens. Großer Knopf im unteren Bereich, einhändig erreichbar.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme starten'**
  String get captureStart;

  /// Beendet die laufende Aufnahme.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get captureStop;

  /// Zustandsanzeige, solange das Mikrofon offen ist. Muss unübersehbar sein, weil in fremden Wohnungen Dritte mithören.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme läuft'**
  String get captureRecording;

  /// Mitlaufende Aufnahmedauer, Minuten und Sekunden zweistellig.
  ///
  /// In de, this message translates to:
  /// **'{minutes}:{seconds}'**
  String captureElapsed(String minutes, String seconds);

  /// Zustand zwischen dem Ende der Aufnahme und der Bestätigungsansicht.
  ///
  /// In de, this message translates to:
  /// **'Wird ausgewertet …'**
  String get captureInterpreting;

  /// Hinweis, wenn ohne Netz aufgenommen wurde. Die Aufnahme ist gesichert, die Auswertung kommt später.
  ///
  /// In de, this message translates to:
  /// **'1 Aufnahme wartet auf Auswertung.'**
  String get captureQueued;

  /// Erklärung unter dem Warteschlangen-Hinweis: was jetzt möglich ist.
  ///
  /// In de, this message translates to:
  /// **'Die Aufnahme ist gespeichert. Du kannst den Befund jetzt über die Karten erfassen.'**
  String get captureQueuedHint;

  /// Überschrift, wenn die Mikrofonberechtigung fehlt. Bewusst kein Fehlerton — der Kartenmodus ist gleichwertig.
  ///
  /// In de, this message translates to:
  /// **'Ohne Mikrofon geht es auch.'**
  String get captureNoMicrophone;

  /// Erklärt, wofür das Mikrofon gebraucht wird und was ohne es geht. Steht anstelle einer bloßen Berechtigungsmeldung.
  ///
  /// In de, this message translates to:
  /// **'Das Mikrofon nimmt nur auf, während du den Knopf gedrückt hältst — für den Befund am offenen Verband. Ohne Mikrofon erfasst du denselben Befund über die Karten.'**
  String get captureNoMicrophoneHint;

  /// Aktion, die zum Kartenmodus führt — der gleichwertige Weg ohne Sprache.
  ///
  /// In de, this message translates to:
  /// **'Über Karten erfassen'**
  String get captureUseCards;

  /// Zwischenstand während der Aufnahme. Blick darauf ist möglich, aber nicht nötig.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch nichts erkannt} =1{1 Angabe erkannt} other{{count} Angaben erkannt}}'**
  String captureRecognizedSoFar(int count);

  /// Zusammengefasste Zeile für alle Felder, zu denen nichts gesagt wurde. Aufklappbar. Ersetzt eine Zeile je Lücke, damit der Platz denen gehört, die eine Entscheidung brauchen.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Eine Angabe fehlt} other{{count} Angaben fehlen}}'**
  String confirmationGapsCollapsed(int count);

  /// Steht anstelle der Lückenzeile, wenn jedes erwartete Feld einen Wert hat.
  ///
  /// In de, this message translates to:
  /// **'Nichts fehlt.'**
  String get confirmationGapsNone;

  /// Überschrift des kompakten Bereichs mit den sicher erkannten Werten am unteren Ende der Liste.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Wert übernommen} other{{count} Werte übernommen}}'**
  String confirmationSettledHeading(num count);

  /// Steht oben, wenn kein Wert mehr eine Entscheidung braucht.
  ///
  /// In de, this message translates to:
  /// **'Alles geprüft.'**
  String get confirmationAllClear;

  /// Anker am Kopf der Bestätigungsansicht: wie viele Werte noch eine Entscheidung oder einen Blick brauchen. Wichtigste Orientierung des Screens.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Wert braucht dich} other{{count} Werte brauchen dich}}'**
  String confirmationNeedsDecision(num count);

  /// Titel des Kartenmodus — der Erfassung ohne Sprache.
  ///
  /// In de, this message translates to:
  /// **'Befund erfassen'**
  String get cardsTitle;

  /// Überschrift der Karte für die Gewebeanteile am Wundgrund. Fachbegriff des Kunden.
  ///
  /// In de, this message translates to:
  /// **'Wundgrund'**
  String get cardsWoundBed;

  /// Überschrift der Karte für Länge, Breite und Tiefe.
  ///
  /// In de, this message translates to:
  /// **'Maße'**
  String get cardsMeasurements;

  /// Überschrift der Karte für Menge und Art des Exsudats.
  ///
  /// In de, this message translates to:
  /// **'Exsudation'**
  String get cardsExudation;

  /// Restanzeige über den Gewebeanteilen. Der Wundgrund ist ein Ganzes; angezeigt wird, was noch zu verteilen ist, statt einen Fehler zu melden.
  ///
  /// In de, this message translates to:
  /// **'{percent} % nicht vergeben'**
  String cardsTissueRemainder(int percent);

  /// Restanzeige, wenn mehr als 100 % verteilt wurden.
  ///
  /// In de, this message translates to:
  /// **'{percent} % zu viel vergeben'**
  String cardsTissueOver(Object percent);

  /// Restanzeige, wenn die Gewebeanteile genau 100 % ergeben.
  ///
  /// In de, this message translates to:
  /// **'Vollständig verteilt'**
  String get cardsTissueComplete;

  /// Semantik-Label des Plus-Knopfes an einem Wert.
  ///
  /// In de, this message translates to:
  /// **'{field} erhöhen'**
  String cardsIncrease(String field);

  /// Semantik-Label des Minus-Knopfes an einem Wert.
  ///
  /// In de, this message translates to:
  /// **'{field} verringern'**
  String cardsDecrease(String field);

  /// Platzhalter anstelle eines Werts, der noch nicht erfasst wurde. Bewusst leer statt null.
  ///
  /// In de, this message translates to:
  /// **'—'**
  String get cardsNotEnteredShort;

  /// Primäre Aktion des Kartenmodus: die erfassten Werte übernehmen.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get cardsDone;

  /// Titel des Screens, auf dem die Wunde im Foto umrandet wird.
  ///
  /// In de, this message translates to:
  /// **'Wunde markieren'**
  String get markingTitle;

  /// Erklärung unter dem Titel. Sagt zu, dass das Foto selbst nicht angetastet wird — die Markierung entsteht als zweite Datei.
  ///
  /// In de, this message translates to:
  /// **'Umrande die Wunde. Das Original bleibt unverändert.'**
  String get markingHint;

  /// Werkzeug: eine Ellipse aufziehen. Mit Handschuhen meist der schnellste Weg.
  ///
  /// In de, this message translates to:
  /// **'Ellipse'**
  String get markingToolEllipse;

  /// Werkzeug: Punkt für Punkt antippen. Die Alternative ohne Ziehgeste (WCAG 2.5.7).
  ///
  /// In de, this message translates to:
  /// **'Punkte'**
  String get markingToolPoints;

  /// Werkzeug: Kontur mit dem Finger nachziehen.
  ///
  /// In de, this message translates to:
  /// **'Freihand'**
  String get markingToolFreehand;

  /// Nimmt den zuletzt gesetzten Punkt der Markierung zurück.
  ///
  /// In de, this message translates to:
  /// **'Letzten Punkt zurück'**
  String get markingUndo;

  /// Verwirft die ganze Markierung; das Foto bleibt.
  ///
  /// In de, this message translates to:
  /// **'Markierung löschen'**
  String get markingClear;

  /// Primäre Aktion: die Markierung übernehmen und weiter zu den Maßen.
  ///
  /// In de, this message translates to:
  /// **'Markierung übernehmen'**
  String get markingDone;

  /// Hinweis unter der gesperrten Übernehmen-Aktion, solange keine Kontur gezeichnet wurde.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts markiert.'**
  String get markingEmptyHint;

  /// Hinweis, dass die Kontur des letzten Besuchs halbtransparent mitläuft — Grundlage für den Vergleich.
  ///
  /// In de, this message translates to:
  /// **'Voriger Besuch ist mit eingeblendet'**
  String get markingPreviousVisit;

  /// Titel des Screens mit dem Sucher.
  ///
  /// In de, this message translates to:
  /// **'Wunde fotografieren'**
  String get photoTitle;

  /// Hinweis über dem Sucher, wenn ein Foto des vorigen Besuchs vorliegt.
  ///
  /// In de, this message translates to:
  /// **'Gleicher Abstand wie beim letzten Mal — das Geisterbild hilft beim Ausrichten.'**
  String get photoHint;

  /// Hinweis über dem Sucher, wenn es noch kein Vorfoto gibt.
  ///
  /// In de, this message translates to:
  /// **'Erstes Foto dieser Wunde. Formatiere frontal und mit gleichbleibendem Abstand.'**
  String get photoHintFirst;

  /// Schalter, der das halbtransparente Foto des letzten Besuchs über den Sucher legt.
  ///
  /// In de, this message translates to:
  /// **'Voriges Foto einblenden'**
  String get photoGhostOn;

  /// Schalter, der das eingeblendete Foto des letzten Besuchs wieder ausblendet.
  ///
  /// In de, this message translates to:
  /// **'Voriges Foto ausblenden'**
  String get photoGhostOff;

  /// Auslöser. Größte Fläche des Screens, weil mit Handschuhen bedient.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get photoShutter;

  /// Primäre Aktion in der Kontrolle nach der Aufnahme.
  ///
  /// In de, this message translates to:
  /// **'Foto übernehmen'**
  String get photoAccept;

  /// Verwirft die Aufnahme und kehrt zum Sucher zurück.
  ///
  /// In de, this message translates to:
  /// **'Neu aufnehmen'**
  String get photoRetake;

  /// Überschrift, wenn die Kameraberechtigung fehlt.
  ///
  /// In de, this message translates to:
  /// **'Kein Zugriff auf die Kamera'**
  String get photoDeniedTitle;

  /// Erklärung und Ausweg, wenn die Kameraberechtigung fehlt. Der Befund darf nie an der Kamera scheitern.
  ///
  /// In de, this message translates to:
  /// **'Die Berechtigung fehlt. In den Einstellungen erteilen oder den Befund ohne Foto erfassen.'**
  String get photoDeniedBody;

  /// Überschrift, wenn das Gerät keine nutzbare Kamera meldet.
  ///
  /// In de, this message translates to:
  /// **'Keine Kamera gefunden'**
  String get photoUnavailableTitle;

  /// Überschrift, wenn die Kamera vorhanden ist, aber nicht startet.
  ///
  /// In de, this message translates to:
  /// **'Kamera lässt sich nicht starten'**
  String get photoFailedTitle;

  /// Ausweg aus jedem Kamerafehler: der Befund läuft ohne Foto weiter.
  ///
  /// In de, this message translates to:
  /// **'Ohne Foto weiter'**
  String get photoSkip;

  /// Startet die Kamera nach einem Fehler noch einmal.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get photoRetry;

  /// Aktion im Aufnahme-Screen: zum Sucher wechseln. Gehört in Phase A, weil das Foto nach dem Verband nichts mehr wert ist.
  ///
  /// In de, this message translates to:
  /// **'Wunde fotografieren'**
  String get captureTakePhoto;

  /// Titel des Abschluss-Screens.
  ///
  /// In de, this message translates to:
  /// **'Besuch abschließen'**
  String get closingTitle;

  /// Ankerzeile, wenn jede erwartete Angabe erfasst ist.
  ///
  /// In de, this message translates to:
  /// **'Befund vollständig'**
  String get closingComplete;

  /// Ankerzeile, wenn Angaben fehlen. Lücken sind erlaubt und werden benannt, nicht versteckt.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Eine Angabe fehlt} other{{count} Angaben fehlen}}'**
  String closingGaps(int count);

  /// Erklärung unter der Ankerzeile, wenn Angaben fehlen. Die zentrale Regel des Projekts: eine Lücke darf mitgehen, ein unklarer Wert nicht.
  ///
  /// In de, this message translates to:
  /// **'Lücken dürfen mitgehen. Der Befund wird als unvollständig geführt.'**
  String get closingGapsHint;

  /// Zählt die erfassten Angaben in der Zusammenfassung.
  ///
  /// In de, this message translates to:
  /// **'{count} erfasst'**
  String closingRecorded(int count);

  /// Überschrift über der Liste der fehlenden Angaben. Jede Zeile führt zurück in die Erfassung.
  ///
  /// In de, this message translates to:
  /// **'Fehlt noch'**
  String get closingMissingHeader;

  /// Hinweis, wenn die Gewebeanteile am Wundgrund nicht auf 100 Prozent aufgehen.
  ///
  /// In de, this message translates to:
  /// **'Gewebeanteile ergeben {sum} %, nicht 100 %.'**
  String closingTissueRemainder(int sum);

  /// Zeile in der Zusammenfassung: wie viele Fotos zum Besuch gehören.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Kein Foto} =1{Ein Foto} other{{count} Fotos}}'**
  String closingPhoto(int count);

  /// Zusatz zur Fotozeile: wie viele Fotos eine Markierung tragen.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{mit Markierung} other{{count} mit Markierung}}'**
  String closingPhotoMarked(int count);

  /// Hinweis, wenn kein Foto zum Besuch gehört. Kein Verbot — der Vergleich über Wochen trägt aber den klinischen Wert.
  ///
  /// In de, this message translates to:
  /// **'Ohne Foto lässt sich der Verlauf später nicht vergleichen.'**
  String get closingNoPhotoHint;

  /// Primäre Aktion, wenn der Befund vollständig ist.
  ///
  /// In de, this message translates to:
  /// **'Besuch abschließen'**
  String get closingFinish;

  /// Primäre Aktion, wenn Angaben fehlen. Bewusst anders beschriftet, damit der Unterschied nicht untergeht.
  ///
  /// In de, this message translates to:
  /// **'Mit Lücken abschließen'**
  String get closingFinishWithGaps;

  /// Führt zurück in den Befund, um eine Lücke noch zu füllen.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Erfassung'**
  String get closingBack;

  /// Rückmeldung nach dem Abschluss, wird auch vom Screenreader angesagt.
  ///
  /// In de, this message translates to:
  /// **'Besuch abgeschlossen.'**
  String get closingDone;

  /// Aktion im Aufnahme-Screen: zum Abschluss wechseln, wenn alles erfasst ist.
  ///
  /// In de, this message translates to:
  /// **'Besuch abschließen'**
  String get captureFinishVisit;

  /// Titel der Wundakte: alle Besuche dieser Wunde in ihrer zeitlichen Folge.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get historyTitle;

  /// Leerzustand der Wundakte.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Besuch dokumentiert.'**
  String get historyEmpty;

  /// Erklärung im Leerzustand: wofür der Verlauf da ist.
  ///
  /// In de, this message translates to:
  /// **'Ein Besuch hält Maße, Wundgrund und ein Foto fest. Ab dem zweiten Besuch zeigt der Verlauf, ob die Wunde kleiner wird.'**
  String get historyEmptyHint;

  /// Hinweis, wenn erst ein Besuch dokumentiert ist. Aus einem Punkt wird keine Kurve gezeichnet.
  ///
  /// In de, this message translates to:
  /// **'Der Vergleich entsteht ab dem zweiten Besuch.'**
  String get historySingleHint;

  /// Datum eines Besuchs in der Verlaufsliste.
  ///
  /// In de, this message translates to:
  /// **'{date}'**
  String historyDate(DateTime date);

  /// Bezeichnung der Wundfläche in der Verlaufsliste und über der Kurve.
  ///
  /// In de, this message translates to:
  /// **'Fläche'**
  String get historyAreaLabel;

  /// Die Wundfläche in Quadratzentimetern.
  ///
  /// In de, this message translates to:
  /// **'{value} cm²'**
  String historyArea(num value);

  /// Sagt, wie die Fläche entsteht. Sie ist kein gemessener Wert, und das muss dranstehen.
  ///
  /// In de, this message translates to:
  /// **'Fläche als Näherung: Länge × Breite.'**
  String get historyAreaApprox;

  /// Veränderung der Fläche gegenüber dem vorherigen Besuch; das Vorzeichen steckt in der Zahl.
  ///
  /// In de, this message translates to:
  /// **'{value} cm² zum vorigen Besuch'**
  String historyAreaChange(num value);

  /// Die Wundtiefe in Zentimetern.
  ///
  /// In de, this message translates to:
  /// **'Tiefe {value} cm'**
  String historyDepth(num value);

  /// Zeile für einen Besuch ohne Maße. Bewusst leer statt geschätzt.
  ///
  /// In de, this message translates to:
  /// **'Keine Maße erfasst'**
  String get historyNoMeasurements;

  /// Kennzeichnet den Besuch, an dem gerade gearbeitet wird.
  ///
  /// In de, this message translates to:
  /// **'Besuch offen'**
  String get historyVisitOpen;

  /// Kennzeichnet einen Besuch, der bewusst unvollständig abgeschlossen wurde.
  ///
  /// In de, this message translates to:
  /// **'Mit Lücken abgeschlossen'**
  String get historyVisitWithGaps;

  /// Platzhalter, wenn die Bilddatei fehlt oder nicht entschlüsselt werden kann. Die übrigen Daten des Besuchs bleiben nutzbar.
  ///
  /// In de, this message translates to:
  /// **'Foto nicht lesbar'**
  String get historyPhotoMissing;

  /// Platzhalter für einen Besuch ohne Foto in der Verlaufsliste.
  ///
  /// In de, this message translates to:
  /// **'Kein Foto'**
  String get historyNoPhoto;

  /// Aktion im Aufnahme-Screen: die bisherigen Besuche dieser Wunde ansehen.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get captureShowHistory;

  /// Überschrift des PDF-Berichts für den behandelnden Arzt.
  ///
  /// In de, this message translates to:
  /// **'Wundbericht'**
  String get reportTitle;

  /// Feldbezeichnung im Berichtskopf.
  ///
  /// In de, this message translates to:
  /// **'Patientin/Patient'**
  String get reportPatient;

  /// Geburtsdatum im Berichtskopf.
  ///
  /// In de, this message translates to:
  /// **'geboren am {date}'**
  String reportBirthDate(DateTime date);

  /// Feldbezeichnung für die Lokalisation der Wunde im Berichtskopf.
  ///
  /// In de, this message translates to:
  /// **'Wunde'**
  String get reportWound;

  /// Feldbezeichnung für den ICD-10-Code im Berichtskopf.
  ///
  /// In de, this message translates to:
  /// **'Diagnose (ICD-10-GM)'**
  String get reportDiagnosis;

  /// Der abgedeckte Zeitraum im Berichtskopf.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum {from} bis {to}'**
  String reportPeriod(DateTime from, DateTime to);

  /// Erstellungsdatum in der Fußzeile jeder Seite.
  ///
  /// In de, this message translates to:
  /// **'Erstellt am {date}'**
  String reportCreatedAt(Object date);

  /// Seitenzahl in der Fußzeile.
  ///
  /// In de, this message translates to:
  /// **'Seite {page} von {total}'**
  String reportPage(int page, int total);

  /// Hinweis auf der ersten Seite, wenn mindestens ein Besuch Lücken hat. Ein Bericht, der Lücken glattbügelt, ist gefährlicher als einer, der sie zeigt.
  ///
  /// In de, this message translates to:
  /// **'Dieser Bericht enthält unvollständige Befunde. Fehlende Angaben sind als „fehlt“ ausgewiesen und nicht geschätzt.'**
  String get reportGapNotice;

  /// Überschrift der Verlaufstabelle im Bericht.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get reportCourseHeading;

  /// Spaltenkopf der Verlaufstabelle.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get reportColumnDate;

  /// Spaltenkopf der Verlaufstabelle.
  ///
  /// In de, this message translates to:
  /// **'Fläche'**
  String get reportColumnArea;

  /// Spaltenkopf der Verlaufstabelle.
  ///
  /// In de, this message translates to:
  /// **'Tiefe'**
  String get reportColumnDepth;

  /// Spaltenkopf der Verlaufstabelle: ob der Befund vollständig ist.
  ///
  /// In de, this message translates to:
  /// **'Vollständigkeit'**
  String get reportColumnStatus;

  /// Zellwert der Verlaufstabelle für einen vollständigen Befund.
  ///
  /// In de, this message translates to:
  /// **'vollständig'**
  String get reportStatusComplete;

  /// Zellwert der Verlaufstabelle für einen unvollständigen Befund.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{eine Angabe fehlt} other{{count} Angaben fehlen}}'**
  String reportStatusGaps(int count);

  /// Überschrift eines Besuchsabschnitts im Bericht.
  ///
  /// In de, this message translates to:
  /// **'Besuch vom {date}'**
  String reportVisitHeading(DateTime date);

  /// Vermerk anstelle eines Fotos im Bericht.
  ///
  /// In de, this message translates to:
  /// **'Kein Foto zu diesem Besuch.'**
  String get reportPhotoMissing;

  /// Vergleichbarkeitsvermerk am ersten Foto. Zwei Bilder nebeneinander behaupten sonst eine Aussage, die die Aufnahmesituation nicht trägt.
  ///
  /// In de, this message translates to:
  /// **'Erstes Foto dieser Wunde — ohne Vorbild aufgenommen, Abstand daher nicht abgeglichen.'**
  String get reportPhotoFirst;

  /// Bildunterschrift im Bericht.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme vom {date}, Markierung eingebrannt.'**
  String reportPhotoCaption(DateTime date);

  /// Text, wenn der Bericht keinen Besuch enthält.
  ///
  /// In de, this message translates to:
  /// **'Für den gewählten Zeitraum liegt kein Besuch vor.'**
  String get reportNoVisits;

  /// Aktion im Verlauf: den Wundbericht als PDF erzeugen und weitergeben.
  ///
  /// In de, this message translates to:
  /// **'Bericht erzeugen'**
  String get reportShare;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
