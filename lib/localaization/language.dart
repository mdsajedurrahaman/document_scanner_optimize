class Language{
  final int id;
  final String name;
  final String languageCode;

  Language(this.id, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, 'English', 'en'),
      Language(2, 'Chinese', 'zh'),
      Language(3, 'Korean', 'ko'),
      Language(4, 'Japanese', 'ja'),
      Language(5, 'Russian', 'ru'),
      Language(6, 'Hindi', 'hi'),
      Language(7, 'Spanish', 'es'),
      Language(8, 'French', 'fr'),
      Language(9, 'Bengali', 'bn'),
      Language(10, 'Indonesian', 'id'),
      Language(11, 'Arabic', 'ar'),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Language && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}