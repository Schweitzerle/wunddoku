import 'package:flutter/foundation.dart';

import '../../../data/patient_repository.dart';
import '../../../domain/model/patient.dart';

/// Drives the patient list.
///
/// The tour is the day's structure, so this is the screen the app opens on:
/// the nurse arrives at a flat and picks the person in front of her before
/// anything else happens.
class PatientListViewModel extends ChangeNotifier {
  PatientListViewModel(this._patients);

  final PatientRepository _patients;

  List<Patient> _visible = const [];
  String _query = '';
  bool _loading = true;

  /// The patients matching the current query, family name first.
  List<Patient> get visible => List.unmodifiable(_visible);

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
    _loading = false;
    notifyListeners();
  }

  /// Narrows the list to [query].
  Future<void> searchFor(String query) async {
    _query = query;
    await load();
  }
}
