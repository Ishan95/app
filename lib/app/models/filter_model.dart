class FilterModel {
  bool isNationalSchool;
  String job;
  String province;
  String district;
  String kalapa;
  String kottasa;
  String school;
  String kottasaForNationalScl;
  String nationalSchool;
  String institutionTypeForNurse;
  String officeForNurse;
  String institutionTypeForMA;
  String officeForMA;
  String institutionTypeForPS;
  String officeForPS;
  String pirivenaInstitute;
  String policeDivisions;
  String policeStations;
  String divisionalSecretariat;
  String gramaNiladhariDivision;
  String scheme;
  String subject;
  String subjectMedium;
  String grade;
  String choice1;
  String choice2;
  String choice3;

  List<String> category;
  List<String> gradeList;
  List<String> schemes;
  List<String> provinces;
  List<String> allDistricts;

  Map<String, List<String>> provinceDistricts;
  Map<String, List<String>> districtKalapas;
  Map<String, List<String>> kalapaKottasa;
  Map<String, List<String>> kottasaSchools;
  Map<String, List<String>> kalapaKottasaForNationalScl;
  Map<String, List<String>> kottasaNationalSchools;
  Map<String, List<String>> districtInstitutionTypeForNurse;
  Map<String, List<String>> institutionTypeOfficesForNurse;
  Map<String, List<String>> districtInstitutionTypeForMA;
  Map<String, List<String>> institutionTypeOfficesForMA;
  Map<String, List<String>> districtPradesiyaSabhas;
  Map<String, List<String>> districtPirivenas;
  Map<String, List<String>> districtPoliceDivisions;
  Map<String, List<String>> policeDivisionStations;
  Map<String, List<String>> districtDsDivisions;
  Map<String, List<String>> dsDivisionGnDivisions;
  Map<String, List<String>> schemeSubjects;

  FilterModel({
    this.isNationalSchool = false,
    this.job = '',
    this.province = '',
    this.district = '',
    this.kalapa = '',
    this.kottasa = '',
    this.school = '',
    this.kottasaForNationalScl = '',
    this.nationalSchool = '',
    this.institutionTypeForNurse = '',
    this.officeForNurse = '',
    this.institutionTypeForMA = '',
    this.officeForMA = '',
    this.institutionTypeForPS = '',
    this.officeForPS = '',
    this.pirivenaInstitute = '',
    this.policeDivisions = '',
    this.policeStations = '',
    this.divisionalSecretariat = '',
    this.gramaNiladhariDivision = '',
    this.scheme = '',
    this.subject = '',
    this.subjectMedium = '',
    this.grade = '',
    this.choice1 = '',
    this.choice2 = '',
    this.choice3 = '',

    this.category = const [],
    this.gradeList = const [],
    this.schemes = const [],
    this.provinces = const [],
    this.allDistricts = const [],

    Map<String, List<String>>? provinceDistricts,
    Map<String, List<String>>? districtKalapas,
    Map<String, List<String>>? kalapaKottasa,
    Map<String, List<String>>? kottasaSchools,
    Map<String, List<String>>? kalapaKottasaForNationalScl,
    Map<String, List<String>>? kottasaNationalSchools,
    Map<String, List<String>>? districtInstitutionTypeForNurse,
    Map<String, List<String>>? institutionTypeOfficesForNurse,
    Map<String, List<String>>? districtInstitutionTypeForMA,
    Map<String, List<String>>? institutionTypeOfficesForMA,
    Map<String, List<String>>? districtPradesiyaSabhas,
    Map<String, List<String>>? districtPirivenas,
    Map<String, List<String>>? districtPoliceDivisions,
    Map<String, List<String>>? policeDivisionStations,
    Map<String, List<String>>? districtDsDivisions,
    Map<String, List<String>>? dsDivisionGnDivisions,
    Map<String, List<String>>? schemeSubjects,
  }) : provinceDistricts = provinceDistricts ?? {},
       districtKalapas = districtKalapas ?? {},
       kalapaKottasa = kalapaKottasa ?? {},
       kottasaSchools = kottasaSchools ?? {},
       kalapaKottasaForNationalScl = kalapaKottasaForNationalScl ?? {},
       kottasaNationalSchools = kottasaNationalSchools ?? {},
       districtInstitutionTypeForNurse = districtInstitutionTypeForNurse ?? {},
       institutionTypeOfficesForNurse = institutionTypeOfficesForNurse ?? {},
       districtInstitutionTypeForMA = districtInstitutionTypeForMA ?? {},
       institutionTypeOfficesForMA = institutionTypeOfficesForMA ?? {},
       districtPradesiyaSabhas = districtPradesiyaSabhas ?? {},
       districtPirivenas = districtPirivenas ?? {},
       districtPoliceDivisions = districtPoliceDivisions ?? {},
       policeDivisionStations = policeDivisionStations ?? {},
       districtDsDivisions = districtDsDivisions ?? {},
       dsDivisionGnDivisions = dsDivisionGnDivisions ?? {},
       schemeSubjects = schemeSubjects ?? {};

  // Deep copy method
  FilterModel copy() {
    return FilterModel(
      isNationalSchool: this.isNationalSchool,
      job: this.job,
      province: this.province,
      district: this.district,
      kalapa: this.kalapa,
      kottasa: this.kottasa,
      school: this.school,
      kottasaForNationalScl: this.kottasaForNationalScl,
      nationalSchool: this.nationalSchool,
      institutionTypeForNurse: this.institutionTypeForNurse,
      officeForNurse: this.officeForNurse,
      institutionTypeForMA: this.institutionTypeForMA,
      officeForMA: this.officeForMA,
      institutionTypeForPS: this.institutionTypeForPS,
      officeForPS: this.officeForPS,
      pirivenaInstitute: this.pirivenaInstitute,
      policeDivisions: this.policeDivisions,
      policeStations: this.policeStations,
      divisionalSecretariat: this.divisionalSecretariat,
      gramaNiladhariDivision: this.gramaNiladhariDivision,
      scheme: this.scheme,
      subject: this.subject,
      subjectMedium: this.subjectMedium,
      grade: this.grade,
      choice1: this.choice1,
      choice2: this.choice2,
      choice3: this.choice3,

      category: List<String>.from(this.category),
      gradeList: List<String>.from(this.gradeList),
      schemes: List<String>.from(this.schemes),
      provinces: List<String>.from(this.provinces),
      allDistricts: List<String>.from(this.allDistricts),

      provinceDistricts: Map<String, List<String>>.from(this.provinceDistricts),
      districtKalapas: Map<String, List<String>>.from(this.districtKalapas),
      kalapaKottasa: Map<String, List<String>>.from(this.kalapaKottasa),
      kottasaSchools: Map<String, List<String>>.from(this.kottasaSchools),
      kalapaKottasaForNationalScl: Map<String, List<String>>.from(this.kalapaKottasaForNationalScl),
      kottasaNationalSchools: Map<String, List<String>>.from(this.kottasaNationalSchools),
      districtInstitutionTypeForNurse: Map<String, List<String>>.from(this.districtInstitutionTypeForNurse),
      institutionTypeOfficesForNurse: Map<String, List<String>>.from(this.institutionTypeOfficesForNurse),
      districtInstitutionTypeForMA: Map<String, List<String>>.from(this.districtInstitutionTypeForMA),
      institutionTypeOfficesForMA: Map<String, List<String>>.from(this.institutionTypeOfficesForMA),
      districtPradesiyaSabhas: Map<String, List<String>>.from(this.districtPradesiyaSabhas),
      districtPirivenas: Map<String, List<String>>.from(this.districtPirivenas),
      districtPoliceDivisions: Map<String, List<String>>.from(this.districtPoliceDivisions),
      policeDivisionStations: Map<String, List<String>>.from(this.policeDivisionStations),
      districtDsDivisions: Map<String, List<String>>.from(this.districtDsDivisions),
      dsDivisionGnDivisions: Map<String, List<String>>.from(this.dsDivisionGnDivisions),
      schemeSubjects: Map<String, List<String>>.from(this.schemeSubjects),
    );
  }

  // Equality check for unsaved changes
  bool isEqual(FilterModel other) {
    return isNationalSchool == other.isNationalSchool &&
        job == other.job &&
        province == other.province &&
        district == other.district &&
        kalapa == other.kalapa &&
        kottasa == other.kottasa &&
        school == other.school &&
        kottasaForNationalScl == other.kottasaForNationalScl &&
        nationalSchool == other.nationalSchool &&
        institutionTypeForNurse == other.institutionTypeForNurse &&
        officeForNurse == other.officeForNurse &&
        institutionTypeForMA == other.institutionTypeForMA &&
        officeForMA == other.officeForMA &&
        institutionTypeForPS == other.institutionTypeForPS &&
        officeForPS == other.officeForPS &&
        pirivenaInstitute == other.pirivenaInstitute &&
        policeDivisions == other.policeDivisions &&
        policeStations == other.policeStations &&
        divisionalSecretariat == other.divisionalSecretariat &&
        gramaNiladhariDivision == other.gramaNiladhariDivision &&
        scheme == other.scheme &&
        subject == other.subject &&
        subjectMedium == other.subjectMedium &&
        grade == other.grade &&
        choice1 == other.choice1 &&
        choice2 == other.choice2 &&
        choice3 == other.choice3;
  }
}
