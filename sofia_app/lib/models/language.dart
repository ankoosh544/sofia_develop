class Language {
  final String name;
  final String flag;
  final String languageCode;

  Language(this.name, this.flag, this.languageCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          languageCode == other.languageCode;

  @override
  int get hashCode => languageCode.hashCode;

  static List<Language> languageList() {
    return <Language>[
      Language('English', '🇺🇸', 'en'),
      Language('Italian', '🇮🇹', 'it'),
      Language('Spanish', '🇪🇸', 'es'),
      // Add more languages as needed
    ];
  }
}
