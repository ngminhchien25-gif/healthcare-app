class HealthProfile {
  final String? memberId;
  final double? heightCm;
  final DateTime? dateOfBirth;
  final int gender;
  final String? bloodType;
  final String? medicalHistory;
  final DateTime? updatedAt;

  HealthProfile({
    this.memberId,
    this.heightCm,
    this.dateOfBirth,
    this.gender = 0,
    this.bloodType,
    this.medicalHistory,
    this.updatedAt,
  });

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      memberId: map['memberId'],
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'].toString())
          : null,
      gender: (map['gender'] as num?)?.toInt() ?? 0,
      bloodType: map['bloodType'],
      medicalHistory: map['medicalHistory'],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }
}