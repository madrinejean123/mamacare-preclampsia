import 'prediction_input.dart';
import 'risk_level.dart';

/// Result returned by the screening API for a single assessment, plus the
/// context needed to render the result screen without re-fetching anything.
class PredictionResult {
  final double probability; // 0.0 .. 1.0, as returned by the model
  final RiskLevel level;
  final PredictionInput input;
  final String? patientId;
  final String? patientName;
  final int? gestationalWeek;

  const PredictionResult({
    required this.probability,
    required this.level,
    required this.input,
    this.patientId,
    this.patientName,
    this.gestationalWeek,
  });

  double get percent => probability * 100;

  factory PredictionResult.fromJson(
    Map<String, dynamic> json, {
    required PredictionInput input,
    String? patientId,
    String? patientName,
    int? gestationalWeek,
  }) {
    final level = switch (json['category']) {
      'high' => RiskLevel.high,
      'moderate' => RiskLevel.moderate,
      _ => RiskLevel.low,
    };
    return PredictionResult(
      probability: (json['probability'] as num).toDouble(),
      level: level,
      input: input,
      patientId: patientId,
      patientName: patientName,
      gestationalWeek: gestationalWeek,
    );
  }
}
