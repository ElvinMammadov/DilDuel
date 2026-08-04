/// Translates German grammatical terms into their Azerbaijani equivalents.
///
/// Values are taken directly from the dictionary abbreviation table.
/// When a term is not found, the original German string is returned as-is,
/// so this is safe to call even for unknown / composite values.
class GrammarTypeTranslator {
  GrammarTypeTranslator._();

  // ── Main-type (Wortart) translations ──────────────────────────────────────

  static const Map<String, String> _azMain = <String, String>{
    'Adjektiv': 'sifət',
    'Adverb': 'zərf',
    'Artikel': 'artikl',
    'Konjunktion': 'bağlayıcı',
    'Komparativ': 'sifətin müqaisə dərəcəsi',
    'Partikel': 'ədat',
    'Plural': 'cəm',
    'Pronomen': 'əvəzlik',
    'Pronomen/Adjektiv': 'əvəzlik/sifət',
    // DB typo ("Prposition") and correct form both handled
    'Prposition': 'sözönü',
    'Präposition': 'sözönü',
    'Substantiv': 'isim',
    'Substantiv (Plural)': 'isim (cəm)',
    'Superlativ': 'sifətin üstünlük dərəcəsi',
    'Verb': 'fel',
    'Zahlwort': 'say',
  };

  // ── Sub-type (verb mode / case) translations ───────────────────────────────

  static const Map<String, String> _azSub = <String, String>{
    'Transitives Verb': 'təsirli fel',
    'Intransitives Verb': 'təsirsiz fel',
    'Reflexives Verb': 'qayıdış feli',
    'Modalverb': 'modal fel',
    // Compound sub-types that appear verbatim in the DB
    'Intransitives Verb, s': 'təsirsiz fel, s',
    'Intransitives Verb / Transitives Verb': 'təsirsiz fel / təsirli fel',
    'Transitives Verb, Intransitives Verb': 'təsirli fel, təsirsiz fel',
    'Transitives Verb/Intransitives Verb': 'təsirli fel/təsirsiz fel',
    // Case labels
    'Akkusativ': 'ittiham hal',
    'Akkusativ, Dativ': 'ittiham hal, yönlük hal',
    'Dat. (plural), Genitiv': 'yönlük hal (cəm), yiyəlik hal',
    'Dativ': 'yönlük hal',
    'Dative': 'yönlük hal',
    'Dative / Akkusativ': 'yönlük hal / ittiham hal',
    'Genitiv': 'yiyəlik hal',
    'Plural': 'cəm',
    // Degree labels
    'Komparativ': 'sifətin müqaisə dərəcəsi',
    'Superlativ': 'sifətin üstünlük dərəcəsi',
    // Tense labels (can appear in AzDe sub-type column)
    'Imperfekt': 'Imperfekt keçmiş zaman forması',
    'Perfekt': 'Perfekt keçmiş zaman forması',
  };

  // ── Gender translations ───────────────────────────────────────────────────

  static const Map<String, String> _azGender = <String, String>{
    // English (as stored in the Word entity)
    'Masculine': 'Kişi',
    'Feminine': 'Qadın',
    'Neuter': 'Orta cins',
    // German variants
    'Maskulinum': 'Kişi',
    'Femininum': 'Qadın',
    'Neutrum': 'Orta cins',
    'maskulin': 'Kişi',
    'feminin': 'Qadın',
    'neutral': 'Orta cins',
    'männlich': 'Kişi',
    'weiblich': 'Qadın',
    'sächlich': 'Orta cins',
  };

  /// Returns the Azerbaijani translation of [term] (grammatical gender).
  ///
  /// Falls back to [term] unchanged when no mapping is found.
  static String gender(String term) => _azGender[term.trim()] ?? term;
  ///
  /// Falls back to [term] unchanged when no mapping is found.
  static String mainType(String term) => _azMain[term.trim()] ?? term;

  /// Returns the Azerbaijani translation of [term] (sub-type / case label).
  ///
  /// Falls back to [term] unchanged when no mapping is found.
  static String subType(String term) => _azSub[term.trim()] ?? term;
}

