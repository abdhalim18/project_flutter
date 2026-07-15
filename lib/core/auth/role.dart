enum AppRole {
  admin,
  kasir;

  static AppRole fromDb(String value) {
    return AppRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => AppRole.kasir,
    );
  }
}
