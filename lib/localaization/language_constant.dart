
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String LAGUAGE_CODE = 'languageCode';


const String ENGLISH = 'en';
const String CHINESE = 'zh';
const String KOREAN = 'ko';
const String JAPANESE = 'ja';
const String RUSSIAN = 'ru';
const String HINDI = 'hi';
const String SPANISH = 'es';
const String FRENCH = 'fr';
const String BENGALI = 'bn';
const String INDONESIAN = 'id';
const String ARABIC = 'ar';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, );
    case CHINESE:
      return const Locale(CHINESE, );
    case KOREAN:
      return const Locale(KOREAN, );
    case JAPANESE:
      return const Locale(JAPANESE, );
    case RUSSIAN:
      return const Locale(RUSSIAN, );
    case HINDI:
      return const Locale(HINDI, );
    case SPANISH:
      return const Locale(SPANISH, );
    case FRENCH:
      return const Locale(FRENCH, );
    case BENGALI:
      return const Locale(BENGALI, );
    case INDONESIAN:
      return const Locale(INDONESIAN, );
    case ARABIC:
      return const Locale(ARABIC, );
    default:
      return const Locale(ENGLISH,);
  }
}

AppLocalizations translation(BuildContext context) {
  return AppLocalizations.of(context)!;
}
