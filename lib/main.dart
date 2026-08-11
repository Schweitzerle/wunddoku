import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'domain/capture/transcript_interpreter.dart';
import 'features/besuch/ui/confirmation_screen.dart';
import 'features/besuch/ui/confirmation_view_model.dart';
import 'features/besuch/ui/field_presentation.dart';
import 'l10n/app_localizations.dart';
import 'shared/theme/app_theme.dart';

void main() => runApp(const WunddokuApp());

/// A dictation from the example set, used until the recording screen exists.
///
/// Synthetic on purpose: no real patient data reaches development, tests or
/// screenshots (`datenschutz-art9.md`). It exercises every row state — two
/// values heard clearly, one implausible, one inflected term, several fields
/// never mentioned.
const _exampleDictation =
    'Länge drei Komma fünf, Breite zwei, Tiefe fünfzig. '
    'Granulationsgewebe sechzig Prozent. Exsudat gering, serös.';

/// The application shell.
class WunddokuApp extends StatelessWidget {
  const WunddokuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: ConfirmationScreen(
      viewModel: ConfirmationViewModel(
        expectedSlots: FieldPresentation.woundBedSlots,
        result: const TranscriptInterpreter().interpret(_exampleDictation),
      ),
    ),
  );
}
