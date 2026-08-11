import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wunddoku/l10n/app_localizations.dart';
import 'package:wunddoku/shared/theme/app_theme.dart';

/// Wraps [child] in the real theme and localisations.
///
/// Tests run against the same [AppTheme] the app uses, so a golden actually
/// covers the token values and not a default Material look.
class TestApp extends StatelessWidget {
  const TestApp({
    required this.child,
    this.brightness = Brightness.light,
    this.textScale = 1.0,
    super.key,
  });

  final Widget child;
  final Brightness brightness;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('de'),
    debugShowCheckedModeBanner: false,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: child,
  );
}
