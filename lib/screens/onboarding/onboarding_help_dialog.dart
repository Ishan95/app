import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _supportEmail = 'mutualtransfer.gov.lk@gmail.com';
const _supportWhatsApp = '94713905383';

enum _HelpChannel { email, whatsapp }

Future<void> showOnboardingHelpDialog(
  BuildContext context,
  String errorMessage,
) async {
  final l10n = AppLocalizations.of(context)!;
  final choice = await showDialog<_HelpChannel>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text(l10n.cantCreateAccount),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 16),
                Text(l10n.needHelp),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, _HelpChannel.email),
              child: Text(l10n.email),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pop(dialogContext, _HelpChannel.whatsapp),
              child: const Text('WhatsApp'),
            ),
          ],
        ),
  );

  if (!context.mounted || choice == null) return;

  final supportMessage =
      '${l10n.whatsappSupportMessage}\n\n${l10n.errorPrefix}: $errorMessage';
  final Uri uri;
  if (choice == _HelpChannel.email) {
    uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query:
          'subject=${Uri.encodeComponent('Mutual Transfer profile creation help')}'
          '&body=${Uri.encodeComponent(supportMessage)}',
    );
  } else {
    uri = Uri.parse(
      'https://wa.me/$_supportWhatsApp?text=${Uri.encodeComponent(supportMessage)}',
    );
  }

  bool opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // The message below gives the user the support address if no app can open the link.
  }

  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open a support app. Email mutualtransfer.gov.lk@gmail.com.',
        ),
      ),
    );
  }
}
