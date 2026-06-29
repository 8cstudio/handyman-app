import 'package:equatable/equatable.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  final String? phone;
  final String? companyId;
  final List<String>? skills;
  final int? experienceYears;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    this.role = UserRole.customer,
    this.phone,
    this.companyId,
    this.skills,
    this.experienceYears,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'role': role.value,
        'phone': phone,
        'company_id': companyId,
        'skills': skills,
        'experience_years': experienceYears,
      };

  @override
  List<Object?> get props =>
      [email, password, name, role, phone, companyId, skills, experienceYears];
}
