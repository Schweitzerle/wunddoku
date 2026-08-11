/// Parsing of spoken German numbers as they appear in dictated findings.
///
/// "drei Komma fünf", "dreieinhalb", "35", "3,5" and "null Komma fünf" all
/// denote plain numbers; transcription services render them inconsistently,
/// so the interpreter has to accept every form. Only the range needed for
/// wound documentation is covered: 0-99 plus decimals and halves.
library;

/// A word of the transcript with its position in the original string.
class Token {
  const Token(this.text, this.start, this.end);

  /// Lower-cased word with surrounding punctuation removed.
  final String text;

  final int start;
  final int end;
}

/// Splits [transcript] into [Token]s, keeping character offsets.
///
/// Surrounding punctuation is dropped from both the text and the offsets: the
/// offsets end up in the provenance highlight the nurse reads, and a trailing
/// comma in that highlight looks like part of the value.
List<Token> tokenize(String transcript) {
  final tokens = <Token>[];
  final trim = RegExp(r'^[^0-9a-zäöüß]+|[^0-9a-zäöüß]+$');
  for (final match in RegExp(r'\S+').allMatches(transcript)) {
    final raw = match.group(0)!.toLowerCase();
    final leading = trim.firstMatch(raw)?.start == 0
        ? trim.firstMatch(raw)!.end
        : 0;
    final text = raw.replaceAll(trim, '');
    if (text.isNotEmpty) {
      final start = match.start + leading;
      tokens.add(Token(text, start, start + text.length));
    }
  }
  return tokens;
}

/// A parsed number plus how many tokens it consumed.
class ParsedNumber {
  const ParsedNumber(this.value, this.tokensConsumed);

  final double value;
  final int tokensConsumed;
}

const _units = {
  'null': 0,
  'ein': 1,
  'eins': 1,
  'eine': 1,
  'zwei': 2,
  'drei': 3,
  'vier': 4,
  'fünf': 5,
  'sechs': 6,
  'sieben': 7,
  'acht': 8,
  'neun': 9,
  'zehn': 10,
  'elf': 11,
  'zwölf': 12,
  'dreizehn': 13,
  'vierzehn': 14,
  'fünfzehn': 15,
  'sechzehn': 16,
  'siebzehn': 17,
  'achtzehn': 18,
  'neunzehn': 19,
};

const _tens = {
  'zwanzig': 20,
  'dreißig': 30,
  'dreissig': 30,
  'vierzig': 40,
  'fünfzig': 50,
  'sechzig': 60,
  'siebzig': 70,
  'achtzig': 80,
  'neunzig': 90,
};

/// The integer a single word denotes, or null.
///
/// Handles units, tens and the compound `<unit>und<tens>` form
/// ("einundzwanzig").
int? _wordToInt(String word) {
  final direct = _units[word] ?? _tens[word];
  if (direct != null) return direct;

  // \w is ASCII-only in Dart regexes; umlauts and ß need their own class.
  final compound = RegExp(r'^([a-zäöüß]+?)und([a-zäöüß]+)$').firstMatch(word);
  if (compound != null) {
    final unit = _units[compound.group(1)];
    final tens = _tens[compound.group(2)];
    if (unit != null && tens != null && unit < 10) return tens + unit;
  }
  return null;
}

/// Tries to read a number starting at [tokens]`[index]`.
///
/// Returns null when the tokens do not begin with a number. Recognised forms,
/// in the order they are tried:
///
/// * digits with an optional decimal part: `3`, `3,5`, `3.5`
/// * halves: `anderthalb`, `einhalb`, `<zahl>einhalb` ("dreieinhalb")
/// * number words, optionally continued by `komma <ziffernwort>`
ParsedNumber? parseNumber(List<Token> tokens, int index) {
  if (index >= tokens.length) return null;
  final word = tokens[index].text;

  final digits = double.tryParse(word.replaceAll(',', '.'));
  if (digits != null) return ParsedNumber(digits, 1);

  if (word == 'anderthalb') return const ParsedNumber(1.5, 1);
  if (word == 'einhalb') return const ParsedNumber(0.5, 1);
  if (word.endsWith('einhalb')) {
    final base = _wordToInt(word.substring(0, word.length - 'einhalb'.length));
    if (base != null) return ParsedNumber(base + 0.5, 1);
  }

  final integer = _wordToInt(word);
  if (integer == null) return null;

  // "drei komma fünf" - a single digit word after "komma" is the fraction.
  if (index + 2 < tokens.length && tokens[index + 1].text == 'komma') {
    final fraction =
        _wordToInt(tokens[index + 2].text) ??
        double.tryParse(tokens[index + 2].text)?.toInt();
    if (fraction != null && fraction < 10) {
      return ParsedNumber(integer + fraction / 10, 3);
    }
  }
  return ParsedNumber(integer.toDouble(), 1);
}
