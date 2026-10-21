import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/privacy_policy.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      heightFactor: 1,
      child: Semantics(
        link: true,
        child: InkWell(
          onTap: () => openPrivacyPolicy(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              l10n.privacyPolicy,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorManager.kPrimary,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: ColorManager.kPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
