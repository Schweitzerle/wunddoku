import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// What the form collected.
class PatientDraft {
  const PatientDraft({
    required this.givenName,
    required this.familyName,
    required this.birthDate,
    required this.street,
    required this.postalCode,
    required this.city,
  });

  final String givenName;
  final String familyName;
  final DateTime birthDate;
  final String street;
  final String postalCode;
  final String city;
}

/// Records a new patient.
///
/// Only what the work needs: name and birth date to tell two people apart,
/// address because it is the place of the visit. Nothing "for later" — every
/// field here is health-adjacent data about someone who never met us
/// (`10-datenschutz-basis.md`).
class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({required this.onSave, super.key});

  final void Function(PatientDraft) onSave;

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _given = TextEditingController();
  final _family = TextEditingController();
  final _street = TextEditingController();
  final _postalCode = TextEditingController();
  final _city = TextEditingController();

  DateTime? _birthDate;
  bool _birthDateMissing = false;

  @override
  void dispose() {
    _given.dispose();
    _family.dispose();
    _street.dispose();
    _postalCode.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      // Wound care is largely geriatric; a hundred years back is the range
      // that actually occurs, and it saves scrolling through a century.
      firstDate: DateTime(now.year - 110),
      lastDate: now,
      initialDate: _birthDate ?? DateTime(now.year - 75),
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateMissing = false;
    });
  }

  void _save() {
    final birthDate = _birthDate;
    final formValid = _formKey.currentState!.validate();
    setState(() => _birthDateMissing = birthDate == null);
    if (!formValid || birthDate == null) return;

    widget.onSave(
      PatientDraft(
        givenName: _given.text,
        familyName: _family.text,
        birthDate: birthDate,
        street: _street.text,
        postalCode: _postalCode.text,
        city: _city.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientFormTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(spacing.s16),
            children: [
              _Field(
                controller: _given,
                label: l10n.patientGivenName,
                required: true,
              ),
              _Field(
                controller: _family,
                label: l10n.patientFamilyName,
                required: true,
              ),
              SizedBox(height: spacing.s8),
              _BirthDateField(
                date: _birthDate,
                missing: _birthDateMissing,
                onPick: _pickBirthDate,
              ),
              SizedBox(height: spacing.s16),
              _Field(controller: _street, label: l10n.patientStreet),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: _Field(
                      controller: _postalCode,
                      label: l10n.patientPostalCode,
                    ),
                  ),
                  SizedBox(width: spacing.s12),
                  Expanded(
                    child: _Field(controller: _city, label: l10n.patientCity),
                  ),
                ],
              ),
              SizedBox(height: spacing.s24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(spacing.s24 * 2.5),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: Text(l10n.patientSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.s8),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: !required
            ? null
            : (value) =>
                  (value ?? '').trim().isEmpty ? l10n.patientRequired : null,
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.date,
    required this.missing,
    required this.onPick,
  });

  final DateTime? date;
  final bool missing;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            date == null
                ? l10n.patientPickBirthDate
                : '${l10n.patientBirthDateLabel}: '
                      '${l10n.patientBirthDate(date!).replaceAll('geb. ', '')}',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(spacing.s24 * 2),
            alignment: Alignment.centerLeft,
          ),
        ),
        if (missing)
          Padding(
            padding: EdgeInsets.only(left: spacing.s12, top: spacing.s4),
            child: Text(
              l10n.patientRequired,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
