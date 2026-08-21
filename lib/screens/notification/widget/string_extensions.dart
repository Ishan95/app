extension InstitutionShortener on String {
  String toShortInstitutionType() {
    if (contains("National Hospital")) return "NH";
    if (contains("Teaching Hospital")) return "TH";
    if (contains("District General Hospital")) return "DGH";
    if (contains("Provincial General Hospital")) return "PGH";
    if (contains("Base Hospital")) return "BH";
    if (contains("Divisional Hospital")) return "DH";
    if (contains("Cancer Hospital")) return "CH";
    if (contains("Mental Hospital")) return "MH";
    if (contains("Maternity Hospital")) return "MH";
    if (contains("Chest Hospital")) return "CH";
    if (contains("Rehabilitation Hospital")) return "RH";
    if (contains("Specialized Hospital")) return "SH";
    if (contains("PMCU")) return "PMCU";
    if (contains("MOH")) return "MOH";
    if (contains("Other")) return "Other";

    return this; // Fallback to raw string if no match
  }

  String toShortInstitutionTypeForMA() {
    if (contains("Ministries")) return "Ministry";
    if (contains("Departments")) return "Department";
    if (contains("District Secretariats")) return "District Secretariat";
    if (contains("Divisional Secretariats")) return "Divisional Secretariat";
    if (contains("Education offices")) return "Education office";
    if (contains("Other institutions")) return "Other institution";

    return this; // Fallback to raw string if no match
  }
}