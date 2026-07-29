import '../models/factor.dart';
import '../models/patient.dart';
import '../models/risk_level.dart';

/// Placeholder data so the UI can be built and reviewed before the
/// Laravel API and ML model are wired up.
class MockData {
  MockData._();

  static final List<Patient> patients = [
    Patient(
      id: 'p1',
      name: 'Grace Achieng',
      age: 27,
      gestationalWeek: 31,
      edd: DateTime(2026, 10, 4),
      gravida: 2,
      para: 1,
      lastVisit: DateTime(2026, 7, 24),
      systolicBp: 148,
      diastolicBp: 96,
      riskPercent: 71,
      riskWeek: 24,
      assessments: [
        Assessment(date: DateTime(2026, 5, 2), gestationalWeek: 12, riskPercent: 14, riskLevel: RiskLevel.low, systolicBp: 112, diastolicBp: 72),
        Assessment(date: DateTime(2026, 5, 30), gestationalWeek: 16, riskPercent: 18, riskLevel: RiskLevel.low, systolicBp: 116, diastolicBp: 74),
        Assessment(date: DateTime(2026, 6, 27), gestationalWeek: 20, riskPercent: 33, riskLevel: RiskLevel.moderate, systolicBp: 128, diastolicBp: 82),
        Assessment(date: DateTime(2026, 7, 11), gestationalWeek: 24, riskPercent: 42, riskLevel: RiskLevel.moderate, systolicBp: 134, diastolicBp: 88),
        Assessment(date: DateTime(2026, 7, 24), gestationalWeek: 31, riskPercent: 71, riskLevel: RiskLevel.high, systolicBp: 148, diastolicBp: 96),
      ],
      notes: [
        ClinicalNote(date: DateTime(2026, 7, 24), author: 'Amina N.', text: 'BP elevated at this visit, counselled on danger signs and scheduled recheck in 3 days.'),
        ClinicalNote(date: DateTime(2026, 7, 11), author: 'Amina N.', text: 'Mild oedema noted in lower limbs. Advised rest and salt reduction.'),
      ],
    ),
    Patient(
      id: 'p2',
      name: 'Sarah Namuli',
      age: 24,
      gestationalWeek: 27,
      edd: DateTime(2026, 11, 2),
      gravida: 1,
      para: 0,
      lastVisit: DateTime(2026, 7, 23),
      systolicBp: 142,
      diastolicBp: 92,
      riskPercent: 66,
      riskWeek: 22,
      assessments: [
        Assessment(date: DateTime(2026, 6, 1), gestationalWeek: 14, riskPercent: 12, riskLevel: RiskLevel.low, systolicBp: 110, diastolicBp: 70),
        Assessment(date: DateTime(2026, 6, 29), gestationalWeek: 18, riskPercent: 21, riskLevel: RiskLevel.moderate, systolicBp: 118, diastolicBp: 76),
        Assessment(date: DateTime(2026, 7, 13), gestationalWeek: 22, riskPercent: 47, riskLevel: RiskLevel.moderate, systolicBp: 130, diastolicBp: 86),
        Assessment(date: DateTime(2026, 7, 23), gestationalWeek: 27, riskPercent: 66, riskLevel: RiskLevel.high, systolicBp: 142, diastolicBp: 92),
      ],
      notes: [
        ClinicalNote(date: DateTime(2026, 7, 23), author: 'Amina N.', text: 'Referred to Mulago NRH for specialist review, pending confirmation.'),
      ],
    ),
    Patient(
      id: 'p3',
      name: 'Amina Nakato',
      age: 30,
      gestationalWeek: 24,
      edd: DateTime(2026, 12, 20),
      gravida: 3,
      para: 2,
      lastVisit: DateTime(2026, 7, 22),
      systolicBp: 126,
      diastolicBp: 80,
      riskPercent: 42,
      riskWeek: 24,
      assessments: [
        Assessment(date: DateTime(2026, 6, 10), gestationalWeek: 16, riskPercent: 15, riskLevel: RiskLevel.low, systolicBp: 108, diastolicBp: 68),
        Assessment(date: DateTime(2026, 7, 8), gestationalWeek: 20, riskPercent: 24, riskLevel: RiskLevel.moderate, systolicBp: 118, diastolicBp: 76),
        Assessment(date: DateTime(2026, 7, 22), gestationalWeek: 24, riskPercent: 42, riskLevel: RiskLevel.moderate, systolicBp: 126, diastolicBp: 80),
      ],
      notes: const [],
    ),
    Patient(
      id: 'p4',
      name: 'Rita Kobusingye',
      age: 33,
      gestationalWeek: 33,
      edd: DateTime(2026, 9, 12),
      gravida: 2,
      para: 1,
      lastVisit: DateTime(2026, 7, 21),
      systolicBp: 124,
      diastolicBp: 79,
      riskPercent: 38,
      riskWeek: 28,
      assessments: [
        Assessment(date: DateTime(2026, 5, 20), gestationalWeek: 20, riskPercent: 16, riskLevel: RiskLevel.low, systolicBp: 112, diastolicBp: 70),
        Assessment(date: DateTime(2026, 6, 24), gestationalWeek: 28, riskPercent: 30, riskLevel: RiskLevel.moderate, systolicBp: 120, diastolicBp: 76),
        Assessment(date: DateTime(2026, 7, 21), gestationalWeek: 33, riskPercent: 38, riskLevel: RiskLevel.moderate, systolicBp: 124, diastolicBp: 79),
      ],
      notes: const [],
    ),
    Patient(
      id: 'p5',
      name: 'Doreen Apio',
      age: 22,
      gestationalWeek: 18,
      edd: DateTime(2027, 1, 15),
      gravida: 1,
      para: 0,
      lastVisit: DateTime(2026, 7, 12),
      systolicBp: 110,
      diastolicBp: 70,
      riskPercent: 9,
      riskWeek: 0,
      assessments: [
        Assessment(date: DateTime(2026, 6, 14), gestationalWeek: 14, riskPercent: 7, riskLevel: RiskLevel.low, systolicBp: 108, diastolicBp: 68),
        Assessment(date: DateTime(2026, 7, 12), gestationalWeek: 18, riskPercent: 9, riskLevel: RiskLevel.low, systolicBp: 110, diastolicBp: 70),
      ],
      notes: const [],
    ),
    Patient(
      id: 'p6',
      name: 'Betty Auma',
      age: 29,
      gestationalWeek: 20,
      edd: DateTime(2026, 12, 30),
      gravida: 2,
      para: 1,
      lastVisit: DateTime(2026, 7, 18),
      systolicBp: 114,
      diastolicBp: 72,
      riskPercent: 12,
      riskWeek: 0,
      assessments: [
        Assessment(date: DateTime(2026, 7, 18), gestationalWeek: 20, riskPercent: 12, riskLevel: RiskLevel.low, systolicBp: 114, diastolicBp: 72),
      ],
      notes: const [],
    ),
  ];

  static Patient patientById(String id) =>
      patients.firstWhere((p) => p.id == id, orElse: () => patients.first);

  static const List<Factor> sampleFactors = [
    Factor(label: 'Diastolic BP', value: '96 mmHg', contribution: 0.34, isRisk: true),
    Factor(label: 'Urine protein', value: '2+', contribution: 0.26, isRisk: true),
    Factor(label: 'BMI', value: '31.4', contribution: 0.15, isRisk: true),
    Factor(label: 'Gravida', value: '2 (multigravida)', contribution: -0.08, isRisk: false),
    Factor(label: 'Gestational age', value: '31 weeks', contribution: 0.06, isRisk: true),
  ];
}
