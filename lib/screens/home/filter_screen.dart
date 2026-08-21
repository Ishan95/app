import 'package:app/app/export.dart';
import 'package:app/app/models/filter_model.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/app/utils/custom_toast.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterModel filterData;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool locationFilter = false;
  bool schoolFilter = false;
  bool subjectFilter = false;
  bool gradeFilter = false;
  bool originalLocationFilter = false;
  bool originalSchoolFilter = false;
  bool originalSubjectFilter = false;
  bool originalgradeFilter = false;

  // late FilterModel originalFilterDetails;
  FilterModel originalFilterDetails = FilterModel();

  late List<String> allNames;
  late List<String> filteredNames;
  String? selectedName;
  String? originalSelectedName;
  bool showList = false;
  final accProvider = Provider.of<AccountProvider>(ContextHelper.navigatorKey.currentContext!, listen: false);

  @override
  void initState() {
    super.initState();
    _loadFilterData(); // Call the async method
    allNames =
        (accProvider.appUser?.job == "Provincial School Teacher"
                ? originalFilterDetails.kottasaSchools.values
                : accProvider.appUser?.job == "National School Teacher"
                ? originalFilterDetails.kottasaSchools.values
                : accProvider.appUser?.job == "Nurse"
                ? originalFilterDetails.institutionTypeOfficesForNurse.values
                : accProvider.appUser?.job == "Management Assistant"
                ? originalFilterDetails.institutionTypeOfficesForMA.values
                : accProvider.appUser?.job == "Police Officer"
                ? originalFilterDetails.policeDivisionStations.values
                : originalFilterDetails.dsDivisionGnDivisions.values)
            .expand((offices) => offices)
            .toList();
    filteredNames = allNames;
    _focusNode.addListener(() {
      setState(() {
        showList = _focusNode.hasFocus;
      });
    });
  }

  Future<void> _loadFilterData() async {
    final prefs = await SharedPreferences.getInstance();

    final filter = FilterModel(
      province: prefs.getString('province') ?? '',
      district: prefs.getString('district') ?? '',
      kalapa: prefs.getString('kalapa') ?? '',
      school: prefs.getString('school') ?? '',
      scheme: prefs.getString('scheme') ?? '',
      subject: prefs.getString('subject') ?? '',
      grade: prefs.getString('grade') ?? '',
    );

    locationFilter = prefs.getString('locationViaFilter') == "true";
    schoolFilter = prefs.getString('schoolViaFilter') == "true";
    subjectFilter = prefs.getString('subjectViaFilter') == "true";
    gradeFilter = prefs.getString('gradeViaFilter') == "true";

    selectedName = prefs.getString('selectedName');
    _controller.text = selectedName ?? '';
    originalSelectedName = selectedName;

    originalLocationFilter = locationFilter;
    originalSchoolFilter = schoolFilter;
    originalSubjectFilter = subjectFilter;
    originalgradeFilter = gradeFilter;

    Provider.of<FiltterProvider>(context, listen: false).filterDetails = filter;
    originalFilterDetails = filter.copy();
    setState(() {
      allNames =
          (accProvider.appUser?.job == "Provincial School Teacher"
                  ? originalFilterDetails.kottasaSchools.values
                  : accProvider.appUser?.job == "National School Teacher"
                  ? originalFilterDetails.kottasaNationalSchools.values
                  : accProvider.appUser?.job == "Nurse"
                  ? originalFilterDetails.institutionTypeOfficesForNurse.values
                  : accProvider.appUser?.job == "Management Assistant"
                  ? originalFilterDetails.institutionTypeOfficesForMA.values
                  : accProvider.appUser?.job == "Police Officer"
                  ? originalFilterDetails.policeDivisionStations.values
                  : originalFilterDetails.dsDivisionGnDivisions.values)
              .expand((schools) => schools)
              .toSet()
              .toList()
            ..sort();

      filteredNames = List.from(allNames);
    }); // To update the UI after loading
  }

  void _filterNames(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNames = allNames;
      } else {
        filteredNames = allNames.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _hideList() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus(); // lose focus
    }
    setState(() {
      showList = false;
    });
  }

  void _confirmAlertDialog(
    BuildContext context,
    String title,
    String content,
    String confirmText,
    VoidCallback onConfirm,
    VoidCallback onCancel,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, textAlign: TextAlign.start, style: context.bold16(color: ColorManager.blackMedium)),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(color: ColorManager.blackMedium.withOpacity(0.8)),
            ),

            actions: [
              TextButton(
                onPressed: onCancel,
                child: Text('Cancel', style: context.semiBold14(color: ColorManager.blackMedium)),
              ),
              TextButton(
                onPressed: onConfirm,
                child: Text(confirmText, style: context.semiBold14(color: ColorManager.red)),
              ),
            ],
          ),
    );
  }

  Future<bool?> _saveAlertDialog(BuildContext context, String title, String content, String confirmText) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, textAlign: TextAlign.start, style: context.bold16(color: ColorManager.blackMedium)),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(color: ColorManager.blackMedium.withOpacity(0.8)),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: context.semiBold14(color: ColorManager.blackMedium)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText, style: context.semiBold14(color: ColorManager.red)),
              ),
            ],
          ),
    );
  }

  bool get hasUnsavedChanges {
    final filter = Provider.of<FiltterProvider>(context, listen: false).filterDetails;
    return !filter.isEqual(originalFilterDetails) ||
        locationFilter != originalLocationFilter ||
        schoolFilter != originalSchoolFilter ||
        subjectFilter != originalSubjectFilter ||
        gradeFilter != originalgradeFilter ||
        selectedName != originalSelectedName;
  }

  void _resetFilters() async {
    final filter = Provider.of<FiltterProvider>(context, listen: false);
    filter.filterDetails = FilterModel();
    setState(() {
      locationFilter = false;
      schoolFilter = false;
      subjectFilter = false;
      gradeFilter = false;
      selectedName = null;
      originalSelectedName = null;
      originalFilterDetails = filter.filterDetails.copy();
      originalLocationFilter = locationFilter;
      originalSchoolFilter = schoolFilter;
      originalSubjectFilter = subjectFilter;
      originalgradeFilter = gradeFilter;
      _controller.clear();
      // selectedName = null;
      filteredNames = allNames;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('province');
    await prefs.remove('district');
    await prefs.remove('kalapa');
    await prefs.remove('school');
    await prefs.remove('scheme');
    await prefs.remove('subject');
    await prefs.remove('grade');
    await prefs.remove('selectedName');
    await prefs.remove('locationViaFilter');
    await prefs.remove('schoolViaFilter');
    await prefs.remove('subjectViaFilter');
    await prefs.remove('gradeViaFilter');
    filter.clearFilters();
    Navigator.of(ContextHelper.navigatorKey.currentContext!)
      ..pop()
      ..pop();
  }

  String _buildFilterSummary(FilterModel filter) {
    List<String> summary = [];
    if (locationFilter) {
      if (filter.province.isNotEmpty) {
        summary.add('Province: ${filter.province}');
      }
      if (filter.district.isNotEmpty) {
        summary.add('District: ${filter.district}');
      }
      if (filter.kalapa.isNotEmpty) summary.add('Kalapa: ${filter.kalapa}');
      // if (filter.school.isNotEmpty) summary.add('School: ${filter.school}');
    }
    if (schoolFilter && selectedName != null && selectedName!.isNotEmpty) {
      summary.add(
        '${(accProvider.appUser?.job == "Provincial School Teacher" || accProvider.appUser?.job == "National School Teacher") ? "School" : "Office"}: $selectedName',
      );
    }
    if (subjectFilter) {
      if (filter.scheme.isNotEmpty) summary.add('Scheme: ${filter.scheme}');
      if (filter.subject.isNotEmpty) summary.add('Subject: ${filter.subject}');
    }
    // if (schoolFilter && selectedName != null && selectedName!.isNotEmpty) {
    //   summary.add('Name: $selectedName');
    // }
    if (gradeFilter) {
      if (filter.grade.isNotEmpty) summary.add('Grade: ${filter.grade}');
    }
    return summary.isNotEmpty ? summary.join('\n') : 'No filters selected.';
  }

  bool get isDefaultFilters {
    final filter = Provider.of<FiltterProvider>(context, listen: false).filterDetails;
    return filter.isEqual(FilterModel()) &&
        !locationFilter &&
        !schoolFilter &&
        !subjectFilter &&
        !gradeFilter &&
        (selectedName == null || selectedName!.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideList,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: ColorManager.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: ColorManager.white,
          elevation: 0.5,
          title: Text('Filter', style: context.semiBold20(color: ColorManager.blackMedium)),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              hasUnsavedChanges
                  ? _confirmAlertDialog(
                    context,
                    'Are you sure you want to go back?',
                    'You have unsaved changes. This will undo your changes to previous Stage',
                    'GO BACK',
                    () =>
                        Navigator.of(context)
                          ..pop()
                          ..pop(),
                    () => Navigator.of(context).pop(),
                  )
                  : Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back, size: context.verticalSize(25), color: ColorManager.blackMedium),
          ),
          actions: [
            if (!isDefaultFilters)
              TextButton(
                onPressed:
                    () => _confirmAlertDialog(
                      context,
                      'Reset All Filters?',
                      'This action will clear all of your currently selected filters and cannot be undone. You will have to re-select them to apply them again',
                      'Reset',
                      _resetFilters,
                      () => Navigator.of(context).pop(),
                    ),
                child: Text('Reset', style: context.semiBold14(color: ColorManager.red)),
              ),
            SizedBox(width: 4),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: context.padding(horizontal: 20, top: 10),
            child: Consumer<FiltterProvider>(
              builder: (context, filter, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SizedBox(height: context.verticalSize(80)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Location Filter According to choice",
                          style: context.semiBold14(color: ColorManager.blackMedium),
                        ),
                        Switch(
                          value: locationFilter,
                          activeColor: ColorManager.kPrimary,
                          activeTrackColor: ColorManager.kPrimary.withOpacity(0.5),
                          inactiveThumbColor: ColorManager.gray,
                          inactiveTrackColor: ColorManager.grayLight,
                          onChanged: (value) {
                            setState(() {
                              locationFilter = value;
                              schoolFilter = false;
                            });
                          },
                        ),
                      ],
                    ),
                    locationFilter
                        ? Column(
                          children: [
                            SizedBox(height: context.verticalSize(8)),
                            Container(
                              height: context.verticalSize(40),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: ColorManager.whiteddd,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                value: filter.filterDetails.province.isNotEmpty ? filter.filterDetails.province : null,
                                hint: Text(
                                  "Select Province",
                                  style: context.regular14(color: ColorManager.disabledText),
                                ),
                                items:
                                    filter.filterDetails.provinceDistricts.keys
                                        .map(
                                          (province) => DropdownMenuItem(
                                            value: province,
                                            child: Text(
                                              province,
                                              style: context.regular14(color: ColorManager.blackMedium),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    filter.filterDetails.province = value ?? '';
                                    filter.filterDetails.district = ''; // reset district
                                    filter.filterDetails.kalapa = ''; // reset kalapa
                                    filter.filterDetails.school = ''; // reset School
                                  });
                                },
                                dropdownColor: ColorManager.white,
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                isExpanded: true,
                              ),
                            ),

                            SizedBox(height: context.verticalSize(filter.filterDetails.province.isNotEmpty ? 20 : 0)),

                            // District Dropdown
                            filter.filterDetails.province.isNotEmpty
                                ? Container(
                                  height: context.verticalSize(40),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ColorManager.whiteddd,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value:
                                        filter.filterDetails.district.isNotEmpty ? filter.filterDetails.district : null,
                                    hint: Text(
                                      "Select District",
                                      style: context.regular14(color: ColorManager.disabledText),
                                    ),
                                    items:
                                        (filter.filterDetails.province.isNotEmpty
                                                ? filter.filterDetails.provinceDistricts[filter
                                                        .filterDetails
                                                        .province] ??
                                                    []
                                                : <String>[])
                                            .map(
                                              (district) => DropdownMenuItem(
                                                value: district,
                                                child: Text(
                                                  district,
                                                  style: context.regular14(color: ColorManager.blackMedium),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        filter.filterDetails.district = value ?? '';
                                        filter.filterDetails.kalapa = ''; // reset kalapa
                                        filter.filterDetails.school = ''; // reset School
                                      });
                                    },
                                    dropdownColor: ColorManager.white,
                                    underline: const SizedBox(),
                                    icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                    isExpanded: true,
                                  ),
                                )
                                : SizedBox.shrink(),
                            SizedBox(height: context.verticalSize(filter.filterDetails.district.isNotEmpty ? 20 : 0)),
                          ],
                        )
                        : SizedBox.shrink(),
                    SizedBox(height: context.verticalSize(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${(accProvider.appUser?.job == "Provincial School Teacher" || accProvider.appUser?.job == "National School Teacher") ? "School" : "Office"}  Filter",
                          style: context.semiBold14(color: ColorManager.blackMedium),
                        ),
                        Switch(
                          value: schoolFilter,
                          activeColor: ColorManager.kPrimary,
                          activeTrackColor: ColorManager.kPrimary.withOpacity(0.5),
                          inactiveThumbColor: ColorManager.gray,
                          inactiveTrackColor: ColorManager.grayLight,
                          onChanged: (value) {
                            setState(() {
                              schoolFilter = value;
                              locationFilter = false;
                            });
                          },
                        ),
                      ],
                    ),
                    schoolFilter
                        ? Column(
                          children: [
                            SizedBox(height: context.verticalSize(5)),
                            Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  showList = hasFocus;
                                });
                              },
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                cursorColor: ColorManager.kPrimary,
                                decoration: InputDecoration(
                                  hintText: "Search a name...",
                                  hintStyle: TextStyle(color: ColorManager.grayText),
                                  prefixIcon: Icon(Icons.search, color: ColorManager.grayText),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: ColorManager.gray, width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: ColorManager.kPrimary, width: 1.5),
                                  ),
                                ),
                                style: TextStyle(color: ColorManager.blackMedium),
                                onChanged: (query) {
                                  _filterNames(query);
                                  setState(() {
                                    showList = true; // show list when typing
                                  });
                                },
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (showList)
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: 200, // limit dropdown height
                                ),
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ColorManager.gray),
                                ),
                                child:
                                    filteredNames.isEmpty
                                        ? Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            "No results found",
                                            style: context.regular14(color: ColorManager.grayText),
                                          ),
                                        )
                                        : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: filteredNames.length,
                                          itemBuilder: (context, index) {
                                            final name = filteredNames[index];
                                            return ListTile(
                                              title: Text(
                                                name,
                                                style: context.regular14(color: ColorManager.blackMedium),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  selectedName = name;
                                                  _controller.text = name;
                                                  _hideList();
                                                });
                                              },
                                            );
                                          },
                                        ),
                              ),
                          ],
                        )
                        : SizedBox.shrink(),
                    SizedBox(height: context.verticalSize(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (accProvider.appUser?.job == "Provincial School Teacher" ||
                                  accProvider.appUser?.job == "National School Teacher")
                              ? "Scheme & Subject Filter"
                              : "Grade Filter",
                          style: context.semiBold14(color: ColorManager.blackMedium),
                        ),
                        Switch(
                          value:
                              (accProvider.appUser?.job == "Provincial School Teacher" ||
                                      accProvider.appUser?.job == "National School Teacher")
                                  ? subjectFilter
                                  : gradeFilter,
                          activeColor: ColorManager.kPrimary,
                          activeTrackColor: ColorManager.kPrimary.withOpacity(0.5),
                          inactiveThumbColor: ColorManager.gray,
                          inactiveTrackColor: ColorManager.grayLight,
                          onChanged: (value) {
                            setState(() {
                              if ((accProvider.appUser?.job == "Provincial School Teacher" ||
                                  accProvider.appUser?.job == "National School Teacher")) {
                                subjectFilter = value;
                              } else {
                                gradeFilter = value;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    ((accProvider.appUser?.job == "Provincial School Teacher" ||
                                    accProvider.appUser?.job == "National School Teacher") &&
                                subjectFilter ||
                            gradeFilter)
                        ? Column(
                          children: [
                            SizedBox(height: context.verticalSize(8)),
                            Container(
                              height: context.verticalSize(40),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: ColorManager.whiteddd,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                value:
                                    (accProvider.appUser?.job == "Provincial School Teacher" ||
                                            accProvider.appUser?.job == "National School Teacher")
                                        ? filter.filterDetails.scheme.isNotEmpty
                                            ? filter.filterDetails.scheme
                                            : null
                                        : filter.filterDetails.grade.isNotEmpty
                                        ? filter.filterDetails.grade
                                        : null,
                                hint: Text(
                                  "Select ${(accProvider.appUser?.job == "Provincial School Teacher" || accProvider.appUser?.job == "National School Teacher") ? "Scheme" : "Grade"}",
                                  style: context.regular14(color: ColorManager.disabledText),
                                ),
                                items:
                                    ((accProvider.appUser?.job == "Provincial School Teacher" ||
                                                accProvider.appUser?.job == "National School Teacher")
                                            ? filter.filterDetails.schemeSubjects.keys
                                            : filter.filterDetails.gradeList)
                                        .map(
                                          (scheme) => DropdownMenuItem(
                                            value: scheme,
                                            child: Text(
                                              scheme,
                                              style: context.regular14(color: ColorManager.blackMedium),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    if ((accProvider.appUser?.job == "Provincial School Teacher" ||
                                        accProvider.appUser?.job == "National School Teacher")) {
                                      filter.filterDetails.scheme = value ?? '';
                                      filter.filterDetails.subject = ''; // reset subject
                                    } else {
                                      filter.filterDetails.grade = value ?? '';
                                    }
                                  });
                                },
                                dropdownColor: ColorManager.white,
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                isExpanded: true,
                              ),
                            ),

                            SizedBox(
                              height: context.verticalSize(
                                (filter.filterDetails.scheme.isNotEmpty || filter.filterDetails.grade.isNotEmpty)
                                    ? 20
                                    : 0,
                              ),
                            ),

                            // District Dropdown
                            (filter.filterDetails.scheme != "PRIMARY" && filter.filterDetails.scheme.isNotEmpty)
                                ? Container(
                                  height: context.verticalSize(40),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ColorManager.whiteddd,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value:
                                        filter.filterDetails.subject.isNotEmpty ? filter.filterDetails.subject : null,
                                    hint: Text(
                                      "Select Subject",
                                      style: context.regular14(color: ColorManager.disabledText),
                                    ),
                                    items:
                                        (filter.filterDetails.scheme.isNotEmpty
                                                ? filter.filterDetails.schemeSubjects[filter.filterDetails.scheme] ?? []
                                                : <String>[])
                                            .map(
                                              (subject) => DropdownMenuItem(
                                                value: subject,
                                                child: Text(
                                                  subject,
                                                  style: context.regular14(color: ColorManager.blackMedium),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        filter.filterDetails.subject = value ?? '';
                                      });
                                    },
                                    dropdownColor: ColorManager.white,
                                    underline: const SizedBox(),
                                    icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                    isExpanded: true,
                                  ),
                                )
                                : SizedBox.shrink(),
                            filter.filterDetails.scheme != "PRIMARY"
                                ? SizedBox(height: context.verticalSize(20))
                                : SizedBox.shrink(),
                          ],
                        )
                        : SizedBox.shrink(),
                    SizedBox(height: context.verticalSize(100)),
                    CenterTextIconButton(
                      onPress: () async {
                        if (hasUnsavedChanges) {
                          final filterDetails = Provider.of<FiltterProvider>(context, listen: false).filterDetails;
                          final summary = _buildFilterSummary(filterDetails);

                          if (summary == 'No filters selected.') {
                            toastErrorMessage("Please select at least one filter before saving.");
                            return; // Don't proceed if no filters are selected
                          }

                          if (filterDetails.province.isNotEmpty && filterDetails.district.isEmpty) {
                            toastErrorMessage("Please select a district for the selected province.");
                            return;
                          }

                          final shouldSave = await _saveAlertDialog(context, 'Confirm Filters', summary, 'Save');

                          if (shouldSave == true) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('province', filterDetails.province);
                            await prefs.setString('district', filterDetails.district);
                            await prefs.setString('kalapa', filterDetails.kalapa);
                            await prefs.setString('school', filterDetails.school);
                            await prefs.setString('scheme', filterDetails.scheme);
                            await prefs.setString('subject', filterDetails.subject);
                            await prefs.setString('grade', filterDetails.grade);
                            await prefs.setString('locationViaFilter', locationFilter ? "true" : "false");
                            await prefs.setString('schoolViaFilter', schoolFilter ? "true" : "false");
                            await prefs.setString('subjectViaFilter', subjectFilter ? "true" : "false");
                            await prefs.setString('gradeViaFilter', gradeFilter ? "true" : "false");
                            await prefs.setString('selectedName', selectedName ?? '');

                            originalFilterDetails = filterDetails.copy();
                            originalSelectedName = selectedName;
                            originalLocationFilter = locationFilter;
                            originalSchoolFilter = schoolFilter;
                            originalSubjectFilter = subjectFilter;
                            originalgradeFilter = gradeFilter;

                            print(filterDetails.district);
                            print(filterDetails.school);
                            print(filterDetails.scheme);
                            print(filterDetails.subject);
                            filter.applyFilters(
                              district: summary.contains('District:') ? filterDetails.district : null,
                              school: schoolFilter && selectedName != "" ? selectedName : null,
                              scheme: summary.contains('Scheme:') ? filterDetails.scheme : null,
                              subject: summary.contains('Subject:') ? filterDetails.subject : null,
                              grade: summary.contains('Grade:') ? filterDetails.grade : null,
                              job: accProvider.appUser?.job,
                            );
                            Navigator.pop(context);
                          }
                        } else {
                          print('No changes to save.');
                        }
                      },
                      // isLoading: auth.getIsSignIn,
                      buttonText: "Save Changes",
                      gradientColors: hasUnsavedChanges ? ColorManager.gradientButtons2 : ColorManager.gradientGray,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      // ),
    );
  }
}
