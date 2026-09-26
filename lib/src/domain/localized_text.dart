import 'package:flutter/foundation.dart';

/// A piece of content translated in several languages, keyed by language code.
///
/// Falls back to English, then to the first available translation, so the UI
/// never shows an empty string when a translation is missing.
@immutable
class LocalizedText {
  const LocalizedText(this.values);

  factory LocalizedText.fromJson(Object? json) {
    if (json is String) return LocalizedText({'en': json});
    if (json is Map<String, dynamic>) {
      return LocalizedText(json.map((k, v) => MapEntry(k, v.toString())));
    }
    throw FormatException('Invalid localized text: $json');
  }

  static const fallbackLanguage = 'en';

  final Map<String, String> values;

  String resolve(String languageCode) =>
      values[languageCode] ??
      values[fallbackLanguage] ??
      (values.isEmpty ? '' : values.values.first);

  Map<String, String> toJson() => values;

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && mapEquals(other.values, values);

  @override
  int get hashCode => Object.hashAllUnordered(
        values.entries.map((e) => Object.hash(e.key, e.value)),
      );
}
