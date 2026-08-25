import 'package:app/app/export.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchDetailsScreen extends StatelessWidget {
  final MutualTransferMatch match;

  const MatchDetailsScreen({super.key, required this.match});

  Future<void> contactWhatsApp(String phone, String message) async {
    if (!phone.startsWith('+')) {
      phone = '+$phone';
    }
    final encodedMessage = Uri.encodeComponent(message);
    final uriApp = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
    final uriWeb = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    try {
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.platformDefault);
        return;
      }
      print("WhatsApp not available");
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final FiltterProvider filterProvider = Provider.of<FiltterProvider>(context, listen: false);
    final String? currentUserId = filterProvider.firebaseUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    String choicePrefix =
        match.matchedChoice == 1
            ? "1st"
            : match.matchedChoice == 2
            ? "2nd"
            : "3rd";

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        title: Text("Cycle Details", style: context.semiBold20(color: ColorManager.blackMedium)),
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: ColorManager.blackMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This match fulfills your $choicePrefix Choice!",
                      style: context.semiBold14(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "This cycle requires all ${match.cycle.length} people to confirm the transfer. If one cancels, the cycle breaks.",
                style: context.regular14(color: ColorManager.kPrimary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: match.cycle.length,
              itemBuilder: (context, index) {
                final currentPerson = match.cycle[index];
                final nextPerson = match.cycle[(index + 1) % match.cycle.length];

                bool isProvincialTeacher = currentPerson.job == "Provincial School Teacher";
                bool isNationalTeacher = currentPerson.job == "National School Teacher";
                bool isTeacher = isProvincialTeacher || isNationalTeacher;

                String schoolName = "";
                if (isProvincialTeacher) {
                  schoolName = currentPerson.school ?? "Unknown School";
                } else if (isNationalTeacher) {
                  schoolName = currentPerson.nationalSchool ?? "Unknown National School";
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentPerson.uid != currentUserId ? ColorManager.lightGray : ColorManager.kPrimary,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPerson.firstName ?? "Unknown",
                            style: context.bold16(color: ColorManager.blackMedium),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Current Post: ${currentPerson.district}",
                            style: context.regular14(color: ColorManager.grayText),
                          ),
                          if (isTeacher && schoolName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text("School: $schoolName", style: context.regular14(color: ColorManager.blackMedium)),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("Contact:", style: context.semiBold14(color: ColorManager.blackMedium)),
                              const SizedBox(width: 8),
                              Text(
                                currentPerson.phone ?? "N/A",
                                style: context.semiBold14(color: ColorManager.blackMedium),
                              ),
                            ],
                          ),
                          if (currentPerson.whatsapp != null && currentPerson.whatsapp!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Whatsapp:", style: context.semiBold14(color: ColorManager.blackMedium)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child:
                                      currentPerson.uid == currentUserId
                                          ? Text(
                                            currentPerson.whatsapp!,
                                            style: context.semiBold14(color: ColorManager.blackMedium),
                                          )
                                          : InkWell(
                                            onTap: () {
                                              contactWhatsApp(
                                                currentPerson.whatsapp!,
                                                "Hi ${currentPerson.firstName}, I found your profile in a transfer cycle on the app!",
                                              );
                                            },
                                            child: Text(
                                              l10n.chatWithWhatsapp,
                                              style: context
                                                  .semiBold14(color: Colors.green)
                                                  .copyWith(decoration: TextDecoration.underline),
                                            ),
                                          ),
                                ),
                              ],
                            ),
                          ],

                          const Divider(height: 24),
                          Text(
                            "Transfers to: ${nextPerson.district}",
                            style: context.semiBold14(color: ColorManager.kPrimary),
                          ),
                        ],
                      ),
                    ),
                    if (index < match.cycle.length)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Icon(Icons.arrow_downward, color: ColorManager.kPrimary, size: 30),
                      ),
                  ],
                );
              },
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.blackMedium.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Cycle completes back to ${match.cycle.first.firstName}",
                  style: context.bold16(color: ColorManager.blackMedium),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
