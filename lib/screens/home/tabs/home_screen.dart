import 'package:app/app/export.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/screens/home/filter_screen.dart';
import 'package:app/screens/notification/widget/person_card.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final filterProvider = Provider.of<FiltterProvider>(context, listen: false);
      await filterProvider.getAllUserDetails();
      await filterProvider.reapplySavedFilters();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding(horizontal: 15),
      child: Consumer2<AccountProvider, FiltterProvider>(
        builder: (context, acc, filter, child) {
          final currentUserJob = acc.appUser?.job;

          // Strict filtering: users only see profiles matching their own job role
          final displayedUsers =
              filter.filteredUsersData.where((user) {
                if (currentUserJob == null || currentUserJob.isEmpty) {
                  return false; // Or return true if users without a set job should see all
                }
                return user.job == currentUserJob;
              }).toList();
          if (acc.appUser?.isEnable == false) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your account has been disabled. Please contact support for more information.',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (filter.isLoading) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40)),
            );
          }
          if (filter.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${filter.errorMessage}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await filter.getAllUserDetails();
                        await filter.reapplySavedFilters();
                      }, //filter.getAllUserDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.verticalSize(50)),
                // Center(
                //   child: Text(
                //     'Filter',
                //     style: context.semiBold20(color: ColorManager.blackMedium),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FilterScreen()));
                      },
                      child: Row(
                        children: [
                          Text("Filter your Results", style: context.semiBold14(color: ColorManager.blackMedium)),
                          SizedBox(width: context.horizontalSize(10)),
                          CircleAvatar(
                            backgroundColor: ColorManager.bgForButton,
                            // radius: 20,
                            radius: 10,
                            child: Icon(
                              // Icons.filter_list,
                              Icons.arrow_right,
                              color: ColorManager.kPrimary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Results: ${displayedUsers.length}",
                      style: context.semiBold14(color: ColorManager.blackMedium),
                    ),
                  ],
                ),
                SizedBox(height: context.verticalSize(30)),
                displayedUsers.isEmpty
                    ? Expanded(
                      child: Center(
                        child: Text("No Data Found!", style: context.semiBold14(color: ColorManager.grayText)),
                      ),
                    )
                    : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        // itemCount: filter.filteredUsersData.length,
                        itemCount: displayedUsers.length,
                        itemBuilder: (context, index) {
                          final user = displayedUsers[index];
                          // print(user.uid);
                          final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: PersonCard(
                              personDetails: PersonDetailsModel(
                                uid:
                                    user.uid == "UNKNOWN"
                                        ? currentUser?.displayName == user.firstName
                                            ? "${currentUser?.uid}"
                                            : "UNKNOWN"
                                        : user.uid,
                                nicNo: user.nicNo ?? '--',
                                firstName: user.firstName ?? '--',
                                lastName: user.lastName ?? '',
                                authEmail: user.authEmail,
                                // email: "${user['email'] ?? '--'}",
                                age: user.age ?? 0,
                                phone: user.phone ?? "",
                                isPhoneHide: user.isPhoneHide,
                                isSchoolHide: user.isSchoolHide,
                                job: user.job ?? '--',
                                province: user.province ?? '--',
                                district: user.district ?? '--',
                                kalapa: user.kalapa ?? '--',
                                institutionTypeForNurse: user.institutionTypeForNurse ?? '--',
                                officeForNurse: user.officeForNurse ?? '--',
                                institutionTypeForMA: user.institutionTypeForMA ?? '--',
                                officeForMA: user.officeForMA ?? '--',
                                policeDivisions: user.policeDivisions ?? '--',
                                policeStations: user.policeStations ?? '--',
                                divisionalSecretariat: user.divisionalSecretariat ?? '--',
                                gramaNiladhariDivision: user.gramaNiladhariDivision ?? '--',
                                kottasa: user.kottasa ?? '--',
                                school: user.school ?? '--',
                                kottasaForNationalScl: user.kottasaForNationalScl ?? '--',
                                nationalSchool: user.nationalSchool ?? '--',
                                scheme: user.scheme ?? '--',
                                subject: user.subject ?? '--',
                                grade: user.grade ?? '--',
                                choice1: user.choice1 ?? '--',
                                choice2: user.choice2 ?? '--',
                                choice3: user.choice3 ?? '--',
                                note: user.note ?? '--',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                SizedBox(height: context.verticalSize(100)),
              ],
            );
          }
        },
      ),
    );
  }
}
