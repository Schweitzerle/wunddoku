import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// What the wound form collected.
class WoundDraft {
  const WoundDraft({required this.location, required this.icd10Code});

  final String location;
  final String? icd10Code;
}

/// Records a new wound of a patient.
///
/// Two fields, one of them optional. The location is free text on purpose:
/// whether the customer keeps a body-site catalogue is an open question, and
/// inventing one would put words in the nurse's mouth that her colleagues do
/// not use (`PROGRESS.md`).
class WoundFormScreen extends StatefulWidget {
  const WoundFormScreen({required this.onSave, super.key});

  final void Function(WoundDraft) onSave;

  @override
  State<WoundFormScreen> createState() => _WoundFormScreenState();
}

class _WoundFormScreenState extends State<WoundFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  final _icd10 = TextEditingController();

  @override
  void dispose() {
    _location.dispose();
    _icd10.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final code = _icd10.text.trim();
    widget.onSave(
      WoundDraft(
        location: _location.text,
        icd10Code: code.isEmpty ? null : code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.woundFormTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(spacing.s16),
            children: [
              TextFormField(
                controller: _location,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.woundLocation,
                  hintText: l10n.woundLocationHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.woundLocationRequired
                    : null,
              ),
              SizedBox(height: spacing.s16),
              TextFormField(
                controller: _icd10,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.woundIcd10,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: spacing.s24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(spacing.s24 * 2.5),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: Text(l10n.woundSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
