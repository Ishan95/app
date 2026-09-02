import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/app/models/filter_model.dart';

class StaticDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final Map<String, List<String>> _cache = {};

  // Generic Lazy-Load Fetcher
  static Future<List<String>> _fetchList(String collection, String key) async {
    final docId = key.replaceAll('/', '_').replaceAll(' ', '_');
    final cacheKey = '${collection}_$docId';

    // Return from in-memory cache if available
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final doc = await _db.collection(collection).doc(docId).get(const GetOptions(source: Source.serverAndCache));
      if (doc.exists && doc.data()!.containsKey('items')) {
        List<String> list = List<String>.from(doc.data()!['items']);
        _cache[cacheKey] = list; // Cache it
        return list;
      }
    } catch (e) {
      print('Error fetching $cacheKey: $e');
    }
    return [];
  }

  // Load root constants (Runs once on Screen Init)
  static Future<void> loadRootData(FilterModel model) async {
    try {
      final doc = await _db
          .collection('static_data')
          .doc('app_constants')
          .get(const GetOptions(source: Source.serverAndCache));
      if (doc.exists) {
        final data = doc.data()!;
        model.category = List<String>.from(data['categories'] ?? []);
        model.gradeList = List<String>.from(data['grades'] ?? []);
        model.schemes = List<String>.from(data['schemes'] ?? []);
        model.provinces = List<String>.from(data['provinces'] ?? []);
        model.allDistricts = List<String>.from(data['all_districts'] ?? []);
      }
    } catch (e) {
      print('Error loading root data: $e');
    }
  }

  // Hierarchical Data Fetchers
  static Future<void> fetchDistricts(FilterModel model, String province) async {
    model.provinceDistricts[province] = await _fetchList('filter_province_districts', province);
  }

  static Future<void> fetchKalapas(FilterModel model, String district) async {
    model.districtKalapas[district] = await _fetchList('filter_district_kalapas', district);
  }

  static Future<void> fetchNurseInstitutions(FilterModel model, String district) async {
    model.districtInstitutionTypeForNurse[district] = await _fetchList('filter_district_inst_nurse', district);
  }

  static Future<void> fetchMAInstitutions(FilterModel model, String district) async {
    model.districtInstitutionTypeForMA[district] = await _fetchList('filter_district_inst_ma', district);
  }

  static Future<void> fetchPradesiyaSabhas(FilterModel model, String district) async {
    model.districtPradesiyaSabhas[district] = await _fetchList('filter_district_pradesiya_sabhas', district);
  }

  static Future<void> fetchPoliceDivisions(FilterModel model, String district) async {
    model.districtPoliceDivisions[district] = await _fetchList('filter_district_police_divs', district);
  }

  static Future<void> fetchDSDivisions(FilterModel model, String district) async {
    model.districtDsDivisions[district] = await _fetchList('filter_district_ds_divs', district);
  }

  static Future<void> fetchKottasas(FilterModel model, String kalapa) async {
    model.kalapaKottasa[kalapa] = await _fetchList('filter_kalapa_kottasa', kalapa);
  }

  static Future<void> fetchKottasasNational(FilterModel model, String kalapa) async {
    model.kalapaKottasaForNationalScl[kalapa] = await _fetchList('filter_kalapa_kottasa_national', kalapa);
  }

  static Future<void> fetchNurseOffices(FilterModel model, String institution) async {
    model.institutionTypeOfficesForNurse[institution] = await _fetchList('filter_inst_offices_nurse', institution);
  }

  static Future<void> fetchMAOffices(FilterModel model, String institution) async {
    model.institutionTypeOfficesForMA[institution] = await _fetchList('filter_inst_offices_ma', institution);
  }

  static Future<void> fetchPoliceStations(FilterModel model, String division) async {
    model.policeDivisionStations[division] = await _fetchList('filter_police_div_stations', division);
  }

  static Future<void> fetchGNDivisions(FilterModel model, String dsDivision) async {
    model.dsDivisionGnDivisions[dsDivision] = await _fetchList('filter_ds_div_gn_divs', dsDivision);
  }

  static Future<void> fetchSchools(FilterModel model, String kottasa) async {
    model.kottasaSchools[kottasa] = await _fetchList('filter_kottasa_schools', kottasa);
  }

  static Future<void> fetchNationalSchools(FilterModel model, String kottasa) async {
    model.kottasaNationalSchools[kottasa] = await _fetchList('filter_kottasa_schools_national', kottasa);
  }

  static Future<void> fetchSubjects(FilterModel model, String scheme) async {
    model.schemeSubjects[scheme] = await _fetchList('filter_scheme_subjects', scheme);
  }
}
