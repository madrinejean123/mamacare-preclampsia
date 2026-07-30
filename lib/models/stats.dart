class WeekBucket {
  final int low;
  final int moderate;
  final int high;

  const WeekBucket({required this.low, required this.moderate, required this.high});

  factory WeekBucket.fromJson(Map<String, dynamic> json) => WeekBucket(
        low: (json['low'] as num).toInt(),
        moderate: (json['moderate'] as num).toInt(),
        high: (json['high'] as num).toInt(),
      );
}

class ClinicStats {
  final int activePatients;
  final int totalAssessments;
  final int assessmentsThisWeek;
  final int highRiskCount;
  final Map<String, int> riskDistribution; // {low, moderate, high}
  final List<WeekBucket> weeklyAssessments;

  const ClinicStats({
    required this.activePatients,
    required this.totalAssessments,
    required this.assessmentsThisWeek,
    required this.highRiskCount,
    required this.riskDistribution,
    required this.weeklyAssessments,
  });

  factory ClinicStats.fromJson(Map<String, dynamic> json) => ClinicStats(
        activePatients: (json['active_patients'] as num).toInt(),
        totalAssessments: (json['total_assessments'] as num).toInt(),
        assessmentsThisWeek: (json['assessments_this_week'] as num).toInt(),
        highRiskCount: (json['high_risk_count'] as num).toInt(),
        riskDistribution: Map<String, int>.from(json['risk_distribution'] as Map),
        weeklyAssessments: (json['weekly_assessments'] as List)
            .map((w) => WeekBucket.fromJson(w as Map<String, dynamic>))
            .toList(),
      );
}
