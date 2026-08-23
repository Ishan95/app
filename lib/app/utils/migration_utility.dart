import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/app/models/filter_model.dart';

class MigrationUtility {
  static Future<void> uploadFilterDataToFirestore(FilterModel oldModel) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    try {
      // Upload Root App Constants
      List<String> allDistricts = oldModel.provinceDistricts.values
          .expand((districtList) => districtList)
          .toList();

      DocumentReference rootRef = db.collection('static_data').doc('app_constants');
      batch.set(rootRef, {
        'categories': oldModel.category,
        'grades': oldModel.gradeList,
        'schemes': oldModel.schemeSubjects.keys.toList(),
        'provinces': oldModel.provinceDistricts.keys.toList(),
        'all_districts': allDistricts,
      }, SetOptions(merge: true));

      // Helper to batch upload Maps
      void queueMapUpload(Map<String, List<String>> dataMap, String collectionName) {
        for (var entry in dataMap.entries) {
          if (entry.key.isEmpty) continue;
          // Sanitize document ID to avoid slashes or invalid characters
          String docId = entry.key.replaceAll('/', '_').replaceAll(' ', '_');
          DocumentReference ref = db.collection(collectionName).doc(docId);
          batch.set(ref, {'items': entry.value}, SetOptions(merge: true));
        }
      }

      // Queue all hierarchical data
      queueMapUpload(oldModel.provinceDistricts, 'filter_province_districts');
      queueMapUpload(oldModel.districtKalapas, 'filter_district_kalapas');
      queueMapUpload(oldModel.kalapaKottasa, 'filter_kalapa_kottasa');
      queueMapUpload(oldModel.kottasaSchools, 'filter_kottasa_schools');
      queueMapUpload(oldModel.kalapaKottasaForNationalScl, 'filter_kalapa_kottasa_national');
      queueMapUpload(oldModel.kottasaNationalSchools, 'filter_kottasa_schools_national');
      queueMapUpload(oldModel.districtInstitutionTypeForNurse, 'filter_district_inst_nurse');
      queueMapUpload(oldModel.institutionTypeOfficesForNurse, 'filter_inst_offices_nurse');
      queueMapUpload(oldModel.districtInstitutionTypeForMA, 'filter_district_inst_ma');
      queueMapUpload(oldModel.institutionTypeOfficesForMA, 'filter_inst_offices_ma');
      queueMapUpload(oldModel.districtPoliceDivisions, 'filter_district_police_divs');
      queueMapUpload(oldModel.policeDivisionStations, 'filter_police_div_stations');
      queueMapUpload(oldModel.districtDsDivisions, 'filter_district_ds_divs');
      queueMapUpload(oldModel.dsDivisionGnDivisions, 'filter_ds_div_gn_divs');
      queueMapUpload(oldModel.schemeSubjects, 'filter_scheme_subjects');

      // Commit the batch
      await batch.commit();
      print("✅ Successfully migrated all lists to Firestore!");
    } catch (e) {
      print("❌ Error migrating data: $e");
    }
  }
}