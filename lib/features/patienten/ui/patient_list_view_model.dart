import 'package:flutter/foundation.dart';

import '../../../data/patient_repository.dart';
import '../../../data/visit_repository.dart';
import '../../../domain/model/ids.dart';
import '../../../domain/model/patient.dart';

/// Drives the patient list.
///
/// The tour is the day's structure, so this is the screen the app opens on:
/// the nurse arrives at a flat and picks the person in front of her before
/// anything else happens.
class PatientListViewModel extends ChangeNotifier {
  PatientListViewModel(this._patients, this._visits);

  final PatientRepository _patients;
  final VisitRepository _visits;

  List<Patient> _visible = const [];
  Set<PatientId> _openVisits = const {};
  String _query = '';
  bool _loading = true;

  /// The patients matching the current query, family name first.
  List<Patient> get visible => List.unmodifiable(_visible);

  /// Whether [patient] has a visit that was begun and never closed.
  bool hasOpenVisit(Patient patient) => _openVisits.contains(patient.id);

  /// The patients with an unfinished visit, in the order of [visible].
  ///
  /// They lead the list: an open visit is work that has to be finished today,
  /// and a name in a long alphabetical list does not say that.
  List<Patient> get unfinished =>
      List.unmodifiable(_visible.where(hasOpenVisit));

  /// Everyone else.
  List<Patient> get rest =>
      List.unmodifiable(_visible.where((p) => !hasOpenVisit(p)));

  /// Whether the list is shown in two groups.
  ///
  /// Only without a search term: someone typing a name is looking for that
  /// person, and a heading between them and the hit is in the way.
  bool get isGrouped => _query.isEmpty && unfinished.isNotEmpty;

  String get query => _query;

  /// Whether the first load is still running.
  bool get isLoading => _loading;

  /// Whether there is no patient at all yet — a different situation from a
  /// search that found nothing, and it needs different words.
  bool get isEmpty => !_loading && _visible.isEmpty && _query.isEmpty;

  /// Whether the search came up empty.
  bool get hasNoMatch => !_loading && _visible.isEmpty && _query.isNotEmpty;

  Future<void> load() async {
    _visible = await _patients.search(_query);
    _openVisits = await _visits.patientsWithOpenVisit();
    _loading = false;
    notifyListeners();
  }

  /// Narrows the list to [query].
  Future<void> searchFor(String query) async {
    _query = query;
    await load();
  }
}
