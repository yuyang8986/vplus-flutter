import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';

class AppLocalizationHelper {
  final Locale locale;

  AppLocalizationHelper(this.locale);

  static AppLocalizationHelper of(BuildContext context) {
    return Localizations.of<AppLocalizationHelper>(
        context, AppLocalizationHelper);
  }

  static const LocalizationsDelegate<AppLocalizationHelper> delegate =
      _AppLocalizationDelegate();

  static Map<String, String> localizedStrings;

  Future<String> getCurrentLanguageCode() async {
    var hive = await Hive.openBox("languageSetting");
    String languageCode = hive.get('currentLangugaeCode')['languageCode'];
    return languageCode;
  }

  Future<bool> reLoadLanguage(String languageCode) async {
    try {
      if (languageCode != null && languageCode.length > 0) {
        var hive = await Hive.openBox("languageSetting");
        await hive.put('currentLangugaeCode', {
          "languageCode": languageCode,
        });
        return true;
      }
      return false;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<bool> loadLanguage() async {
    try {
      var hive = await Hive.openBox("languageSetting");
      var currentLanguageCode = hive.get('currentLangugaeCode');
      String languageCode;
      if (currentLanguageCode != null) {
        languageCode = currentLanguageCode['languageCode'].toString();
      }

      String jsonString;

      if (languageCode != null && languageCode != "") {
        jsonString =
            await rootBundle.loadString('assets/languages/$languageCode.json');
      } else {
        jsonString = await rootBundle
            .loadString('assets/languages/${locale.languageCode}.json');

        await reLoadLanguage(locale.languageCode.toString());
      }

      Map<String, dynamic> jsonMap = json.decode(jsonString);
      localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      return true;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  String translate(String key) {
    return localizedStrings[key];
  }
}

//LocalizationsDelege is a factory for a set of localizaed resources
class _AppLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizationHelper> {
  //This delegate instance will never change
  //It can provide a constant constructor
  const _AppLocalizationDelegate();

  static List<String> supportedLanguages = ['en', 'zh'];

  @override
  bool isSupported(Locale locale) {
    return supportedLanguages.contains(locale.languageCode.toString());
  }

  @override
  Future<AppLocalizationHelper> load(Locale locale) async {
    AppLocalizationHelper localizations = new AppLocalizationHelper(locale);
    await localizations.loadLanguage();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
