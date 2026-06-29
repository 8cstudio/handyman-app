enum UserRole {
  superAdmin('super_admin'),
  companyAdmin('company_admin'),
  provider('provider'),
  customer('customer');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.customer,
    );
  }
}
