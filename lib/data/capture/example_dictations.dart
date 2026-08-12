/// The bundled example recordings and what a recogniser makes of them.
///
/// The transcripts are not what was *said* — they are what a real recogniser
/// (Whisper large-v3, German) returned for these files. That difference is the
/// point: the interpreter has to survive what a service hands it, not what a
/// nurse would write down. Three things a general model does to a wound
/// finding are visible here and are covered by tests:
///
/// * numbers arrive as digits (`4,2`), not as the spoken words that a
///   dictation grammar would suggest;
/// * the customer's vocabulary is foreign to it — *Exsudat* comes back as
///   "Excusat", *serös* as "seriös";
/// * a spoken correction ("Länge 3, äh nein, 4,1") stays in the text, and the
///   first number is the wrong one.
///
/// The recordings are synthetic findings spoken for this purpose; no patient
/// appears in them (`datenschutz-art9.md`).
library;

/// Asset file names under `assets/examples/`, in the order they are served.
const exampleDictations = <String>[
  'befund_01.m4a',
  'befund_02.m4a',
  'befund_03.m4a',
  'befund_04.m4a',
];

/// What the recogniser returned for each recording, verbatim.
const exampleTranscripts = <String, String>{
  // A complete finding, dictated cleanly.
  'befund_01.m4a':
      'Länge 4,2, Breite 2,8, Tiefe 0,5, Granulation 60%, Fibrin 40%, '
      'Excusat gering, seriös, Schmerz 3.',

  // A correction mid-sentence, the way it happens at the open dressing.
  'befund_02.m4a': 'Länge 3, äh nein, 4,1, Breite 2, Excusat mäßig, seriös.',

  // Half a metre of wound depth: the value the nurse has to be asked about.
  'befund_03.m4a': 'Länge 3,5, Breite 2, Tiefe 50, Granulationsgewebe 60%.',

  // Interrupted after two measurements.
  'befund_04.m4a': 'Länge 2,5, Breite 1,2',
};
