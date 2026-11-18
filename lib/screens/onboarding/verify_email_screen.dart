import 'package:app/app/export.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/onboarding/onboarding_help_dialog.dart';
import 'package:app/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  final firebase_auth.User user;
  final bool isSelected;
  final bool isWhatsappSelected;
  final bool isSchoolSelected;
  final bool isEnable;
  const VerifyEmailScreen({
    required this.user,
    required this.isSelected,
    required this.isWhatsappSelected,
    required this.isSchoolSelected,
    required this.isEnable,
    super.key,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool checking = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        title: Text(l10n.verifyEmailTitle, style: context.semiBold20(color: ColorManager.blackMedium)),
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: ColorManager.blackMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: context.verticalSize(20)),
            Text(
              l10n.verifyEmailMessage,
              textAlign: TextAlign.center,
              style: context.regular16(color: ColorManager.blackMedium),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                onPressed: checking ? null : () => checkVerification(l10n),
                child:
                    checking
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                        : Text(l10n.iVerifiedContinue, style: context.semiBold14(color: ColorManager.white)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: ColorManager.kPrimary),
              onPressed: () async {
                await widget.user.sendEmailVerification();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verificationEmailResent)));
              },
              child: Text(l10n.resendVerificationEmail, style: context.semiBold14(color: ColorManager.kPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkVerification(AppLocalizations l10n) async {
    setState(() => checking = true);

    final screenContext = context;
    final authProvider = Provider.of<AuthenticationProvider>(screenContext, listen: false);
    final accProvider = Provider.of<AccountProvider>(screenContext, listen: false);
    try {
      final verified = await authProvider.reloadAndCheckVerified();
      if (!screenContext.mounted) return;

      if (verified) {
        final success = await authProvider.createAccount(
          isPhoneHide: widget.isSelected,
          isWhatsappHide: widget.isWhatsappSelected,
          isSchoolHide: widget.isSchoolSelected,
          isEnable: widget.isEnable,
        );
        if (!screenContext.mounted) return;

        if (success) {
          await accProvider.refreshCurrentUser();
          if (!screenContext.mounted) return;
          Navigator.pushAndRemoveUntil(
            screenContext,
            MaterialPageRoute(builder: (_) => const Home(index: 0)),
            (route) => false,
          );
        } else {
          await showOnboardingHelpDialog(
            screenContext,
            authProvider.errorMessage ?? 'Failed to complete setup.',
          );
        }
      } else {
        ScaffoldMessenger.of(screenContext).showSnackBar(SnackBar(content: Text(l10n.emailNotVerifiedYet)));
      }
    } catch (e) {
      if (screenContext.mounted) {
        await showOnboardingHelpDialog(screenContext, e.toString());
      }
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }
}
