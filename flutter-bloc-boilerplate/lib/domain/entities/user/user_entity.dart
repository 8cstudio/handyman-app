import 'package:equatable/equatable.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? accessToken;
  final UserRole role;
  final String? companyId;
  final String? phone;
  final String? avatarUrl;
  final String? providerStatus;
  final List<String>? providerSkills;
  final int? providerExperienceYears;
  final String? providerBio;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.accessToken,
    this.role = UserRole.customer,
    this.companyId,
    this.phone,
    this.avatarUrl,
    this.providerStatus,
    this.providerSkills,
    this.providerExperienceYears,
    this.providerBio,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final skills = json['provider_skills'];
    return UserEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      accessToken: json['access_token'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      companyId: json['company_id'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      providerStatus: json['provider_status'] as String?,
      providerSkills: skills is List ? skills.map((e) => e.toString()).toList() : null,
      providerExperienceYears: json['provider_experience_years'] as int?,
      providerBio: json['provider_bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'access_token': accessToken,
        'role': role.value,
        'company_id': companyId,
        'phone': phone,
        'avatar_url': avatarUrl,
        'provider_status': providerStatus,
        'provider_skills': providerSkills,
        'provider_experience_years': providerExperienceYears,
        'provider_bio': providerBio,
      };

  bool get isCustomer => role == UserRole.customer;
  bool get isProvider => role == UserRole.provider;
  bool get isProviderApproved => providerStatus == 'approved';
  bool get isProviderPending => providerStatus == 'pending';

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? accessToken,
    UserRole? role,
    String? companyId,
    String? phone,
    String? avatarUrl,
    String? providerStatus,
    List<String>? providerSkills,
    int? providerExperienceYears,
    String? providerBio,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      providerStatus: providerStatus ?? this.providerStatus,
      providerSkills: providerSkills ?? this.providerSkills,
      providerExperienceYears: providerExperienceYears ?? this.providerExperienceYears,
      providerBio: providerBio ?? this.providerBio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        accessToken,
        role,
        companyId,
        phone,
        avatarUrl,
        providerStatus,
        providerSkills,
        providerExperienceYears,
        providerBio,
      ];
}
