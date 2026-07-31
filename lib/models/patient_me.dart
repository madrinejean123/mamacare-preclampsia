class VitalPoint {
  final DateTime date;
  final int? gestationalWeek;
  final int systolicBp;
  final int diastolicBp;

  const VitalPoint({
    required this.date,
    required this.gestationalWeek,
    required this.systolicBp,
    required this.diastolicBp,
  });

  factory VitalPoint.fromJson(Map<String, dynamic> json) => VitalPoint(
        date: DateTime.parse(json['date'] as String),
        gestationalWeek: (json['gestational_week'] as num?)?.toInt(),
        systolicBp: (json['systolic_bp'] as num).round(),
        diastolicBp: (json['diastolic_bp'] as num).round(),
      );
}

/// The deliberately reduced view a patient sees of her own record — no raw
/// probability, category, clinical notes, or lab values. See PatientHomeScreen.
class PatientMeView {
  final int id;
  final String name;
  final int? gestationalWeek;
  final DateTime? edd;
  final String statusMessage;
  final List<VitalPoint> vitals;

  const PatientMeView({
    required this.id,
    required this.name,
    required this.gestationalWeek,
    required this.edd,
    required this.statusMessage,
    required this.vitals,
  });

  factory PatientMeView.fromJson(Map<String, dynamic> json) => PatientMeView(
        id: json['id'] as int,
        name: json['name'] as String,
        gestationalWeek: (json['gestational_week'] as num?)?.toInt(),
        edd: json['edd'] != null ? DateTime.parse(json['edd'] as String) : null,
        statusMessage: json['status_message'] as String,
        vitals: (json['vitals'] as List).map((v) => VitalPoint.fromJson(v as Map<String, dynamic>)).toList(),
      );
}
