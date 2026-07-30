import 'risk_level.dart';

RiskLevel _levelFromCategory(String? category) {
  switch (category) {
    case 'high':
      return RiskLevel.high;
    case 'moderate':
      return RiskLevel.moderate;
    default:
      return RiskLevel.low;
  }
}

class ClinicalNote {
  final DateTime date;
  final String author;
  final String text;

  const ClinicalNote({
    required this.date,
    required this.author,
    required this.text,
  });

  factory ClinicalNote.fromJson(Map<String, dynamic> json) => ClinicalNote(
        date: DateTime.parse(json['created_at'] as String),
        author: json['author'] as String,
        text: json['text'] as String,
      );
}

class Assessment {
  final DateTime date;
  final int gestationalWeek;
  final double riskPercent;
  final RiskLevel riskLevel;
  final int systolicBp;
  final int diastolicBp;

  const Assessment({
    required this.date,
    required this.gestationalWeek,
    required this.riskPercent,
    required this.riskLevel,
    required this.systolicBp,
    required this.diastolicBp,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        date: DateTime.parse(json['created_at'] as String),
        gestationalWeek: (json['gestational_week'] as num?)?.toInt() ?? 0,
        riskPercent: (json['probability'] as num) * 100,
        riskLevel: _levelFromCategory(json['category'] as String?),
        systolicBp: (json['systolic_bp'] as num).round(),
        diastolicBp: (json['diastolic_bp'] as num).round(),
      );
}

class Patient {
  final String id;
  final String name;
  final int age;
  final int gestationalWeek;
  final DateTime? edd;
  final int gravida;
  final int para;
  final DateTime lastVisit;
  final int systolicBp;
  final int diastolicBp;
  final double riskPercent;
  final int riskWeek;
  final List<Assessment> assessments;
  final List<ClinicalNote> notes;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gestationalWeek,
    required this.edd,
    required this.gravida,
    required this.para,
    required this.lastVisit,
    required this.systolicBp,
    required this.diastolicBp,
    required this.riskPercent,
    required this.riskWeek,
    this.assessments = const [],
    this.notes = const [],
  });

  RiskLevel get riskLevel => RiskLevelX.fromPercent(riskPercent);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Builds from the lightweight GET /patients list shape (each entry
  /// carries only its latest assessment, not the full history).
  factory Patient.fromListJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    final latest = json['latest_assessment'] as Map<String, dynamic>?;

    return Patient(
      id: json['id'].toString(),
      name: json['name'] as String,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gestationalWeek: (json['gestational_week'] as num?)?.toInt() ?? 0,
      edd: json['edd'] != null ? DateTime.parse(json['edd'] as String) : null,
      gravida: (json['gravida'] as num?)?.toInt() ?? 0,
      para: (json['para'] as num?)?.toInt() ?? 0,
      lastVisit: latest != null ? DateTime.parse(latest['created_at'] as String) : createdAt,
      systolicBp: latest != null ? (latest['systolic_bp'] as num).round() : 0,
      diastolicBp: latest != null ? (latest['diastolic_bp'] as num).round() : 0,
      riskPercent: latest != null ? (latest['probability'] as num) * 100 : 0,
      riskWeek: 0,
    );
  }

  /// Builds from the full GET /patients/`id` shape (complete assessment
  /// and notes history), so riskWeek can be derived properly.
  factory Patient.fromDetailJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    final assessments = (json['assessments'] as List)
        .map((a) => Assessment.fromJson(a as Map<String, dynamic>))
        .toList();
    final notes = (json['notes'] as List)
        .map((n) => ClinicalNote.fromJson(n as Map<String, dynamic>))
        .toList();
    final latest = assessments.isNotEmpty ? assessments.last : null;

    var riskWeek = 0;
    for (final a in assessments) {
      if (a.riskLevel != RiskLevel.low) {
        riskWeek = a.gestationalWeek;
        break;
      }
    }

    return Patient(
      id: json['id'].toString(),
      name: json['name'] as String,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gestationalWeek: (json['gestational_week'] as num?)?.toInt() ?? 0,
      edd: json['edd'] != null ? DateTime.parse(json['edd'] as String) : null,
      gravida: (json['gravida'] as num?)?.toInt() ?? 0,
      para: (json['para'] as num?)?.toInt() ?? 0,
      lastVisit: latest?.date ?? createdAt,
      systolicBp: latest?.systolicBp ?? 0,
      diastolicBp: latest?.diastolicBp ?? 0,
      riskPercent: latest?.riskPercent ?? 0,
      riskWeek: riskWeek,
      assessments: assessments,
      notes: notes,
    );
  }
}
