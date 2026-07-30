/// Exactly the fields the screening model (preeclampsia_app/api.py) consumes.
class PredictionInput {
  final double maternalAge;
  final double bmi;
  final double systolicBp;
  final double diastolicBp;
  final bool previousPreeclampsia;
  final bool gestationalDiabetes;
  final bool chronicHypertension;
  final bool familyHistory;
  final bool smoking;
  final bool alcohol;
  final bool physicalActivity;
  final bool employmentStatus;
  final double hemoglobinLevel;
  final double plateletCount;
  final double creatinineLevel;

  const PredictionInput({
    required this.maternalAge,
    required this.bmi,
    required this.systolicBp,
    required this.diastolicBp,
    required this.previousPreeclampsia,
    required this.gestationalDiabetes,
    required this.chronicHypertension,
    required this.familyHistory,
    required this.smoking,
    required this.alcohol,
    required this.physicalActivity,
    required this.employmentStatus,
    required this.hemoglobinLevel,
    required this.plateletCount,
    required this.creatinineLevel,
  });

  Map<String, dynamic> toJson() => {
        'maternal_age': maternalAge,
        'bmi': bmi,
        'systolic_bp': systolicBp,
        'diastolic_bp': diastolicBp,
        'previous_preeclampsia': previousPreeclampsia,
        'gestational_diabetes': gestationalDiabetes,
        'chronic_hypertension': chronicHypertension,
        'family_history': familyHistory,
        'smoking': smoking,
        'alcohol': alcohol,
        'physical_activity': physicalActivity,
        'employment_status': employmentStatus,
        'hemoglobin_level': hemoglobinLevel,
        'platelet_count': plateletCount,
        'creatinine_level': creatinineLevel,
      };
}
