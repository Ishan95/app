import 'package:app/app/export.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/providers/matching_provider.dart';
import 'package:app/screens/home/match_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  int _selectedChoiceFilter = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final acc = Provider.of<AccountProvider>(context, listen: false);
      final filter = Provider.of<FiltterProvider>(context, listen: false);
      if (acc.appUser != null) {
        Provider.of<MatchingProvider>(context, listen: false).findMatches(acc.appUser!, filter.allUsersData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBar(
          backgroundColor: ColorManager.white,
          elevation: 0.5,
          title: Text("Transfer Cycles", style: context.semiBold20(color: ColorManager.blackMedium)),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: ColorManager.kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedChoiceFilter,
                    icon: Icon(Icons.filter_list, color: ColorManager.kPrimary, size: 20),
                    dropdownColor: ColorManager.white,
                    style: context.semiBold14(color: ColorManager.kPrimary),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedChoiceFilter = newValue;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("1st Choice")),
                      DropdownMenuItem(value: 2, child: Text("2nd Choice")),
                      DropdownMenuItem(value: 3, child: Text("3rd Choice")),
                    ],
                  ),
                ),
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: ColorManager.kPrimary,
            unselectedLabelColor: ColorManager.grayText,
            indicatorColor: ColorManager.kPrimary,
            tabs: const [Tab(text: "2-Person"), Tab(text: "3-Person"), Tab(text: "4-Person")],
          ),
        ),
        body: Consumer<MatchingProvider>(
          builder: (context, matchingProvider, child) {
            if (matchingProvider.isLoading) {
              return Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40));
            }

            // Filter all matches by the selected Choice (1, 2, or 3)
            final choiceFilteredMatches =
                matchingProvider.matches.where((m) => m.matchedChoice == _selectedChoiceFilter).toList();

            // Separate the choice-filtered matches by cycle length for the Tabs
            final twoWay = choiceFilteredMatches.where((m) => m.matchType == MatchType.twoPerson).toList();
            final threeWay = choiceFilteredMatches.where((m) => m.matchType == MatchType.threePerson).toList();
            final fourWay = choiceFilteredMatches.where((m) => m.matchType == MatchType.fourPerson).toList();

            String choicePrefix =
                _selectedChoiceFilter == 1
                    ? "1st"
                    : _selectedChoiceFilter == 2
                    ? "2nd"
                    : "3rd";

            return TabBarView(
              children: [
                _buildMatchList(twoWay, "2-Person Matches ($choicePrefix Choice)"),
                _buildMatchList(threeWay, "3-Person Matches ($choicePrefix Choice)"),
                _buildMatchList(fourWay, "4-Person Matches ($choicePrefix Choice)"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMatchList(List<MutualTransferMatch> matches, String emptyTitle) {
    if (matches.isEmpty) {
      return Center(child: Text("No $emptyTitle found.", style: context.semiBold14(color: ColorManager.grayText)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];

        String cycleTypeText =
            match.matchType == MatchType.twoPerson
                ? "2-Person Cycle"
                : match.matchType == MatchType.threePerson
                ? "3-Person Cycle"
                : "4-Person Cycle";

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.autorenew, color: ColorManager.kPrimary),
                    const SizedBox(width: 8),
                    Text(cycleTypeText, style: context.bold16(color: ColorManager.blackMedium)),
                  ],
                ),
                const SizedBox(height: 12),
                ...match.cycle.map(
                  (u) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: ColorManager.grayText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${u.firstName} (${u.district})",
                            style: context.regular14(color: ColorManager.blackMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.bgForButton,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match)),
                      );
                    },
                    child: Text("View Cycle Flow", style: context.semiBold14(color: ColorManager.kPrimary)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
