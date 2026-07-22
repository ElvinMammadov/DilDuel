import 'package:equatable/equatable.dart';

/// A dictionary entry returned by a search query.
///
/// [key] is the source-language word; [value] is the translation.
/// The optional fields are only populated for DeAz (German → Azerbaijani)
/// entries and are `null` for AzDe entries.
class Word extends Equatable {
  const Word({
    this.key = '',
    this.value = '',
    this.dicType = '',
    this.article,
    this.gender,
    this.mainType,
    this.subType,
    this.genitive,
    this.plural,
    this.imperfekt,
    this.perfekt,
    this.comparative,
    this.superlative,
    this.example,
    this.sentence,
  });

  final String key;
  final String value;

  /// Table name used as the dictionary direction identifier ('DeAz' / 'AzDe').
  final String dicType;

  // ── DeAz-only grammatical fields ──────────────────────────────────────────

  /// Grammatical article (der / die / das / sich / …).
  final String? article;

  /// Grammatical gender (Masculine / Feminine / Neuter).
  final String? gender;

  /// Part of speech (Substantiv / Verb / Adjektiv / Adverb / …).
  final String? mainType;

  /// Sub-category (Transitives Verb / Reflexives Verb / Dative / …).
  final String? subType;

  /// Genitive form of a noun.
  final String? genitive;

  /// Plural form of a noun.
  final String? plural;

  /// Imperfekt (simple past) of a verb.
  final String? imperfekt;

  /// Perfekt (compound past) of a verb.
  final String? perfekt;

  /// Comparative form of an adjective.
  final String? comparative;

  /// Superlative form of an adjective.
  final String? superlative;

  /// Short usage example.
  final String? example;

  /// Full example sentence(s).
  final String? sentence;

  /// Whether this entry has any grammatical detail beyond key/value.
  bool get hasRichData =>
      article != null ||
      gender != null ||
      mainType != null ||
      genitive != null ||
      plural != null ||
      imperfekt != null ||
      perfekt != null ||
      comparative != null ||
      superlative != null;

  /// Whether this entry has conjugation / declension forms to display
  /// in the grammar table (genitive, plural, verb forms, etc.).
  /// False for AzDe words, which have no such columns.
  bool get hasGrammarForms =>
      genitive != null ||
      plural != null ||
      imperfekt != null ||
      perfekt != null ||
      comparative != null ||
      superlative != null;

  @override
  List<Object?> get props => <Object?>[
        key,
        value,
        dicType,
        article,
        gender,
        mainType,
        subType,
        genitive,
        plural,
        imperfekt,
        perfekt,
        comparative,
        superlative,
        example,
        sentence,
      ];
}
