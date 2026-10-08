/// Locations of the public privacy policy and legal notice (Impressum).
///
/// The pages exist in English (site root), German and Azerbaijani; any other
/// language falls back to English.
abstract final class LegalLinks {
  static const String _baseUrl = 'https://elvinmammadov.github.io/Dictionary/';
  static const Set<String> _localizedLanguages = <String>{'de', 'az'};

  /// The privacy policy page for [languageCode].
  static Uri privacyPolicy(String languageCode) =>
      _page(languageCode, 'privacy');

  /// The legal notice (Impressum) page for [languageCode].
  static Uri impressum(String languageCode) => _page(languageCode, 'impressum');

  static Uri _page(String languageCode, String slug) {
    final String prefix =
        _localizedLanguages.contains(languageCode) ? '$languageCode/' : '';
    return Uri.parse('$_baseUrl$prefix$slug/');
  }
}
