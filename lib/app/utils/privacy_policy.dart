import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri privacyPolicyUrl = Uri.parse('https://ishan95.github.io/privacy_policy/');

Future<void> openPrivacyPolicy(BuildContext context) async {
  try {
    if (await launchUrl(privacyPolicyUrl, mode: LaunchMode.externalApplication)) {
      return;
    }
  } catch (_) {
    // Show the same actionable message for platform errors and launch failures.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.privacyPolicyOpenError)),
  );
}
