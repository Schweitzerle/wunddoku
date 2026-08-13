import 'package:flutter/material.dart';

import '../../../app/bootstrap.dart';
import '../../../data/media/media_store.dart';
import '../../../domain/model/ids.dart';
import '../../../domain/model/patient.dart';
import '../../../domain/model/wound.dart';
import 'patient_form_screen.dart';
import 'patient_list_screen.dart';
import 'patient_list_view_model.dart';
import 'patient_screen.dart';
import 'wound_form_screen.dart';

/// The way into a visit: patient, then wound, then the corridor.
///
/// Deliberately three steps and not a "start visit" button on the home
/// screen: a finding belongs to a person and to one of their wounds, and
/// everything downstream — course, report, deletion path — hangs off that
/// pair.
class PatientsFlow extends StatefulWidget {
  const PatientsFlow({
    required this.dependencies,
    required this.openVisit,
    required this.openHistory,
    super.key,
  });

  final AppDependencies dependencies;

  /// Opens the visit corridor for a wound.
  ///
  /// Passed in rather than imported so this feature does not reach into the
  /// visit feature (`21-flutter-architektur.md`).
  final Widget Function(WoundId wound) openVisit;

  /// Opens the course of a wound without starting a visit.
  ///
  /// Passed in for the same reason as [openVisit]: the course lives in
  /// another feature, and features do not import each other.
  final Widget Function(WoundId wound) openHistory;

  @override
  State<PatientsFlow> createState() => _PatientsFlowState();
}

class _PatientsFlowState extends State<PatientsFlow> {
  late final PatientListViewModel _list;
  Map<PatientId, int> _woundCounts = const {};

  @override
  void initState() {
    super.initState();
    _list = PatientListViewModel(
      widget.dependencies.patients,
      widget.dependencies.visits,
    );
    _refreshCounts();
  }

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  Future<void> _refreshCounts() async {
    final counts = await widget.dependencies.wounds.countsByPatient();
    if (!mounted) return;
    setState(() => _woundCounts = counts);
  }

  Future<void> _addPatient() async {
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => PatientFormScreen(
          onSave: (draft) async {
            final patient = await widget.dependencies.patients.create(
              givenName: draft.givenName,
              familyName: draft.familyName,
              birthDate: draft.birthDate,
              street: draft.street,
              postalCode: draft.postalCode,
              city: draft.city,
            );
            navigator.pop();
            if (mounted) await _openPatient(patient);
          },
        ),
      ),
    );
    await _list.load();
    await _refreshCounts();
  }

  Future<void> _openPatient(Patient patient) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PatientHome(
          dependencies: widget.dependencies,
          patient: patient,
          openVisit: widget.openVisit,
          openHistory: widget.openHistory,
        ),
      ),
    );
    if (!mounted) return;
    // Reloads the list as well as the counts: the visit that was just closed
    // is what the "Besuch offen" mark hangs on, and a mark that outlives the
    // visit sends the nurse back into a flat she is finished with.
    await _list.load();
    await _refreshCounts();
  }

  @override
  Widget build(BuildContext context) => PatientListScreen(
    viewModel: _list,
    woundCount: (patient) => _woundCounts[patient.id] ?? 0,
    onOpen: _openPatient,
    onAdd: _addPatient,
  );
}

/// One patient with their wounds, loaded from the record.
class _PatientHome extends StatefulWidget {
  const _PatientHome({
    required this.dependencies,
    required this.patient,
    required this.openVisit,
    required this.openHistory,
  });

  final AppDependencies dependencies;
  final Patient patient;
  final Widget Function(WoundId wound) openVisit;
  final Widget Function(WoundId wound) openHistory;

  @override
  State<_PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<_PatientHome> {
  List<Wound> _wounds = const [];
  Map<WoundId, WoundStanding> _standings = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final wounds = await widget.dependencies.wounds.ofPatient(
      widget.patient.id,
    );
    // One course per wound, and a patient has one or two of them. The card
    // is the only place the state of a wound is visible before opening it,
    // and a card without it is a label on a folder.
    final standings = <WoundId, WoundStanding>{};
    for (final wound in wounds) {
      standings[wound.id] = await _standingOf(wound.id);
    }
    if (!mounted) return;
    setState(() {
      _wounds = wounds;
      _standings = standings;
      _loading = false;
    });
  }

  /// Reads the last visit of [wound] into what its card shows.
  Future<WoundStanding> _standingOf(WoundId wound) async {
    final history = await widget.dependencies.visits.historyOf(wound);
    if (history.isEmpty) return const WoundStanding.none();

    final last = history.entries.last;
    return WoundStanding(
      visitCount: history.entries.length,
      areaCm2: last.areaCm2,
      areaChangeCm2: history.areaChangeBefore(last),
      // The marked copy where there is one: the outline is what makes two
      // photos of the same wound comparable at a glance.
      photoRef: last.markedPhotoRef ?? last.photoRef,
    );
  }

  Future<void> _showHistory(WoundId wound) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => widget.openHistory(wound)));
    await _load();
  }

  Future<void> _addWound() async {
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => WoundFormScreen(
          onSave: (draft) async {
            final wound = await widget.dependencies.wounds.create(
              patient: widget.patient.id,
              location: draft.location,
              icd10Code: draft.icd10Code,
            );
            navigator.pop();
            // Straight into the visit: a wound is recorded because someone is
            // standing at the dressing, not to fill a list.
            if (mounted) await _openWound(wound.id);
          },
        ),
      ),
    );
    await _load();
  }

  Future<void> _openWound(WoundId wound) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => widget.openVisit(wound)));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PatientScreen(
      patient: widget.patient,
      wounds: _wounds,
      standingOf: (wound) =>
          _standings[wound.id] ?? const WoundStanding.none(),
      loadPhoto: (ref) => widget.dependencies.visits.photoBytes(MediaRef(ref)),
      onOpenWound: (wound) => _openWound(wound.id),
      onShowHistory: (wound) => _showHistory(wound.id),
      onAddWound: _addWound,
    );
  }
}
