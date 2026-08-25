import 'package:app/app/export.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:flutter/material.dart';

class MatchDetailsScreen extends StatelessWidget {
  final MutualTransferMatch match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
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

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorManager.gray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentPerson.firstName ?? "Unknown", style: context.bold16(color: ColorManager.blackMedium)),
                          const SizedBox(height: 4),
                          Text("Current Post: ${currentPerson.district}", style: context.regular14(color: ColorManager.grayText)),
                          const Divider(),
                          Text("Transfers to: ${nextPerson.district}", style: context.semiBold14(color: ColorManager.kPrimary)),
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
                child: Text("Cycle completes back to ${match.cycle.first.firstName}", style: context.bold16(color: ColorManager.blackMedium)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
