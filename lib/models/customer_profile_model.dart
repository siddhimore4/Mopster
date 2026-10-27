class CustomerProfileModel {
  final String id;
  final String phone;
  final String fullName;
  final String email;
  final String dhuleArea;
  final String homeAddress;
  final List<String> additionalAddresses;
  final String role; // 'customer', 'admin', 'dispatcher'
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerProfileModel({
    required this.id,
    required this.phone,
    this.fullName = '',
    this.email = '',
    this.dhuleArea = 'Deopur',
    this.homeAddress = '',
    this.additionalAddresses = const [],
    this.role = 'customer',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCustomer => role.toLowerCase() == 'customer';

  String get displayName =>
      fullName.trim().isNotEmpty ? fullName.trim() : 'Mopster Customer';

  String get initials {
    if (fullName.trim().isEmpty) return 'M';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get formattedPhone {
    final clean = phone.replaceAll(' ', '').trim();
    if (clean.startsWith('+91') && clean.length == 13) {
      return '+91 ${clean.substring(3, 8)} ${clean.substring(8)}';
    }
    return phone;
  }

  CustomerProfileModel copyWith({
    String? phone,
    String? fullName,
    String? email,
    String? dhuleArea,
    String? homeAddress,
    List<String>? additionalAddresses,
    String? role,
    DateTime? updatedAt,
  }) {
    return CustomerProfileModel(
      id: id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dhuleArea: dhuleArea ?? this.dhuleArea,
      homeAddress: homeAddress ?? this.homeAddress,
      additionalAddresses: additionalAddresses ?? this.additionalAddresses,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'phone': phone.isNotEmpty ? phone : null,
      'full_name': fullName,
      'email': email.isNotEmpty ? email : null,
      'dhule_area': dhuleArea,
      'home_address': homeAddress,
      'additional_addresses': additionalAddresses,
      'role': role,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory CustomerProfileModel.fromSupabaseMap(Map<String, dynamic> map) {
    List<String> addresses = [];
    if (map['additional_addresses'] != null) {
      if (map['additional_addresses'] is List) {
        addresses = (map['additional_addresses'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return CustomerProfileModel(
      id: map['id'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      dhuleArea: map['dhule_area'] as String? ?? 'Deopur',
      homeAddress: map['home_address'] as String? ?? '',
      additionalAddresses: addresses,
      role: map['role'] as String? ?? 'customer',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'email': email,
      'dhule_area': dhuleArea,
      'home_address': homeAddress,
      'additional_addresses': additionalAddresses,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel.fromSupabaseMap(json);
  }
}
