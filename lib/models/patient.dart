import 'risk_level.dart';

class ClinicalNote {
  final DateTime date;
  final String author;
  final String text;

  const ClinicalNote({
    required this.date,
    required this.author,
    required this.text,
  });
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
}

class Patient {
  final String id;
  final String name;
  final int age;
  final int gestationalWeek;
  final DateTime edd;
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
}
