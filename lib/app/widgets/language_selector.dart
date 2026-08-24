import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:app/app/utils/color_manager.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: localeProvider.locale,
        icon: Icon(Icons.language, color: ColorManager.kPrimary),
        dropdownColor: ColorManager.kPrimaryBlack,
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            localeProvider.setLocale(newLocale);
          }
        },
        items: [
          DropdownMenuItem(
            value: Locale('en'),
            child: Text('English', style: TextStyle(color: ColorManager.blackMedium)),
          ),
          DropdownMenuItem(
            value: Locale('si'),
            child: Text('සිංහල', style: TextStyle(color: ColorManager.blackMedium)),
          ),
          DropdownMenuItem(
            value: Locale('ta'),
            child: Text('தமிழ்', style: TextStyle(color: ColorManager.blackMedium)),
          ),
        ],
      ),
    );
  }
}
