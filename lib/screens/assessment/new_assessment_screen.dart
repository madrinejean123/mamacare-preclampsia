import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/patient.dart';
import '../../models/prediction_input.dart';
import '../../services/patient_service.dart';
import '../../services/prediction_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/add_patient_dialog.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/step_indicator.dart';

const _steps = ['Patient', 'Measurements', 'Risk factors', 'Labs & notes', 'Result'];

class NewAssessmentScreen extends StatefulWidget {
  const NewAssessmentScreen({super.key});

  @override
  State<NewAssessmentScreen> createState() => _NewAssessmentScreenState();
}

class _NewAssessmentScreenState extends State<NewAssessmentScreen> {
  int _step = 0;
  bool _submitting = false;
  String? _submitError;

  String? _patientId;
  String? _patientName;

  // Measurements
  final _maternalAgeController = TextEditingController(text: '28');
  final _gestAgeController = TextEditingController(text: '28');
  final _systolicController = TextEditingController(text: '120');
  final _diastolicController = TextEditingController(text: '78');
  final _weightController = TextEditingController(text: '68');
  final _heightController = TextEditingController(text: '162');

  // Risk factors — these map 1:1 to the model's inputs.
  bool _previousPreeclampsia = false;
  bool _gestationalDiabetes = false;
  bool _chronicHypertension = false;
  bool _familyHistory = false;
  bool _smoking = false;
  bool _alcohol = false;
  bool _physicalActivity = false;
  bool _employmentStatus = false;

  // Labs — these map 1:1 to the model's inputs.
  final _hemoglobinController = TextEditingController(text: '12.0');
  final _plateletController = TextEditingController(text: '250');
  final _creatinineController = TextEditingController(text: '0.8');

  // Clinical notes only — the model does not consume these.
  String _protein = 'Negative';
  String _oedema = 'None';
  String _dangerSigns = 'None reported';

  double get _bmi {
    final w = double.tryParse(_weightController.text) ?? 0;
    final h = (double.tryParse(_heightController.text) ?? 0) / 100;
    if (h == 0) return 0;
    return w / (h * h);
  }

  @override
  void initState() {
    super.initState();
    // BMI is derived from these, so redraw whenever either changes.
    _weightController.addListener(_onBmiInputChanged);
    _heightController.addListener(_onBmiInputChanged);
  }

  void _onBmiInputChanged() => setState(() {});

  @override
  void dispose() {
    _weightController.removeListener(_onBmiInputChanged);
    _heightController.removeListener(_onBmiInputChanged);
    _maternalAgeController.dispose();
    _gestAgeController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _hemoglobinController.dispose();
    _plateletController.dispose();
    _creatinineController.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  Future<void> _next() async {
    if (_step == _steps.length - 2) {
      await _runPrediction();
      return;
    }
    setState(() => _step += 1);
  }

  Future<void> _runPrediction() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    final input = PredictionInput(
      maternalAge: double.tryParse(_maternalAgeController.text) ?? 0,
      bmi: _bmi,
      systolicBp: double.tryParse(_systolicController.text) ?? 0,
      diastolicBp: double.tryParse(_diastolicController.text) ?? 0,
      previousPreeclampsia: _previousPreeclampsia,
      gestationalDiabetes: _gestationalDiabetes,
      chronicHypertension: _chronicHypertension,
      familyHistory: _familyHistory,
      smoking: _smoking,
      alcohol: _alcohol,
      physicalActivity: _physicalActivity,
      employmentStatus: _employmentStatus,
      hemoglobinLevel: double.tryParse(_hemoglobinController.text) ?? 0,
      plateletCount: double.tryParse(_plateletController.text) ?? 0,
      creatinineLevel: double.tryParse(_creatinineController.text) ?? 0,
    );

    try {
      final result = await PredictionService().predict(
        input,
        patientId: _patientId,
        patientName: _patientName,
        gestationalWeek: int.tryParse(_gestAgeController.text),
        proteinUrine: _protein,
        oedema: _oedema,
        dangerSigns: _dangerSigns,
      );
      if (!mounted) return;
      context.go('/assess/result', extra: result);
    } on PredictionApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/assess',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New assessment', style: AppTextStyles.screenTitle(context)),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.of(context).card,
                  border: Border.all(color: AppColors.of(context).line),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepIndicator(steps: _steps, currentIndex: _step),
                    const SizedBox(height: 28),
                    _stepBody(phone),
                    if (_submitError != null) ...[
                      const SizedBox(height: 16),
                      AlertStrip(
                        icon: Icons.error_outline_rounded,
                        tone: AlertTone.danger,
                        text: _submitError!,
                      ),
                    ],
                    const SizedBox(height: 28),
                    _footer(phone),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBody(bool phone) {
    switch (_step) {
      case 0:
        return _PatientStep(
          patientId: _patientId,
          onChanged: (id, name) => setState(() {
            _patientId = id;
            _patientName = name;
          }),
        );
      case 1:
        return _MeasurementsStep(
          phone: phone,
          maternalAge: _maternalAgeController,
          gestAge: _gestAgeController,
          systolic: _systolicController,
          diastolic: _diastolicController,
          weight: _weightController,
          height: _heightController,
          bmi: _bmi,
        );
      case 2:
        return _RiskFactorsStep(
          previousPreeclampsia: _previousPreeclampsia,
          gestationalDiabetes: _gestationalDiabetes,
          chronicHypertension: _chronicHypertension,
          familyHistory: _familyHistory,
          smoking: _smoking,
          alcohol: _alcohol,
          physicalActivity: _physicalActivity,
          employmentStatus: _employmentStatus,
          onPreviousPreeclampsia: (v) => setState(() => _previousPreeclampsia = v),
          onGestationalDiabetes: (v) => setState(() => _gestationalDiabetes = v),
          onChronicHypertension: (v) => setState(() => _chronicHypertension = v),
          onFamilyHistory: (v) => setState(() => _familyHistory = v),
          onSmoking: (v) => setState(() => _smoking = v),
          onAlcohol: (v) => setState(() => _alcohol = v),
          onPhysicalActivity: (v) => setState(() => _physicalActivity = v),
          onEmploymentStatus: (v) => setState(() => _employmentStatus = v),
        );
      default:
        return _LabsAndNotesStep(
          phone: phone,
          hemoglobin: _hemoglobinController,
          platelet: _plateletController,
          creatinine: _creatinineController,
          protein: _protein,
          oedema: _oedema,
          dangerSigns: _dangerSigns,
          onProtein: (v) => setState(() => _protein = v),
          onOedema: (v) => setState(() => _oedema = v),
          onDangerSigns: (v) => setState(() => _dangerSigns = v),
        );
    }
  }

  Widget _footer(bool phone) {
    final primary = ElevatedButton(
      onPressed: _submitting ? null : _next,
      child: _submitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(_step == _steps.length - 2 ? 'Run prediction →' : 'Continue →'),
    );

    if (phone) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: primary),
          if (_step > 0) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _submitting ? null : _back, child: const Text('← Back'))),
          ],
        ],
      );
    }

    return Row(
      children: [
        if (_step > 0)
          OutlinedButton(onPressed: _submitting ? null : _back, child: const Text('← Back'))
        else
          const SizedBox(),
        const Spacer(),
        primary,
      ],
    );
  }
}

class _StepField extends StatelessWidget {
  final String label;
  final Widget child;
  const _StepField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(context)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _FieldGrid extends StatelessWidget {
  final bool phone;
  final List<Widget> children;
  const _FieldGrid({required this.phone, required this.children});

  @override
  Widget build(BuildContext context) {
    if (phone) {
      return Column(
        children: [
          for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final hasSecond = i + 1 < children.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 16),
              Expanded(child: hasSecond ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _PatientStep extends StatefulWidget {
  final String? patientId;
  final void Function(String id, String name) onChanged;
  const _PatientStep({required this.patientId, required this.onChanged});

  @override
  State<_PatientStep> createState() => _PatientStepState();
}

class _PatientStepState extends State<_PatientStep> {
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _future = PatientService().fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Patient>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return AlertStrip(
            icon: Icons.error_outline_rounded,
            tone: AlertTone.danger,
            text: 'Could not load patients: ${snapshot.error}',
          );
        }
        final patients = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepField(
              label: 'Patient',
              child: _Dropdown(
                hint: 'Select a patient',
                value: widget.patientId,
                items: patients.map((p) => (value: p.id, label: '${p.name} · wk ${p.gestationalWeek}')).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final patient = patients.firstWhere((p) => p.id == id);
                  widget.onChanged(patient.id, patient.name);
                },
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddPatientDialog(
                  onAdded: (patient) {
                    setState(() => _future = PatientService().fetchPatients());
                    widget.onChanged(patient.id, patient.name);
                  },
                ),
              ),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
              label: const Text('Add new patient'),
            ),
          ],
        );
      },
    );
  }
}

class _MeasurementsStep extends StatelessWidget {
  final bool phone;
  final TextEditingController maternalAge;
  final TextEditingController gestAge;
  final TextEditingController systolic;
  final TextEditingController diastolic;
  final TextEditingController weight;
  final TextEditingController height;
  final double bmi;

  const _MeasurementsStep({
    required this.phone,
    required this.maternalAge,
    required this.gestAge,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.height,
    required this.bmi,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldGrid(
      phone: phone,
      children: [
        _StepField(label: 'Maternal age (years)', child: _Input(controller: maternalAge)),
        _StepField(label: 'Gestational age (weeks)', child: _Input(controller: gestAge)),
        _StepField(label: 'Systolic BP (mmHg)', child: _Input(controller: systolic)),
        _StepField(label: 'Diastolic BP (mmHg)', child: _Input(controller: diastolic)),
        _StepField(label: 'Weight (kg)', child: _Input(controller: weight)),
        _StepField(label: 'Height (cm)', child: _Input(controller: height)),
        _StepField(label: 'BMI (auto-computed)', child: _Input(controller: TextEditingController(text: bmi.toStringAsFixed(1)), enabled: false)),
      ],
    );
  }
}

class _RiskFactorsStep extends StatelessWidget {
  final bool previousPreeclampsia;
  final bool gestationalDiabetes;
  final bool chronicHypertension;
  final bool familyHistory;
  final bool smoking;
  final bool alcohol;
  final bool physicalActivity;
  final bool employmentStatus;
  final ValueChanged<bool> onPreviousPreeclampsia;
  final ValueChanged<bool> onGestationalDiabetes;
  final ValueChanged<bool> onChronicHypertension;
  final ValueChanged<bool> onFamilyHistory;
  final ValueChanged<bool> onSmoking;
  final ValueChanged<bool> onAlcohol;
  final ValueChanged<bool> onPhysicalActivity;
  final ValueChanged<bool> onEmploymentStatus;

  const _RiskFactorsStep({
    required this.previousPreeclampsia,
    required this.gestationalDiabetes,
    required this.chronicHypertension,
    required this.familyHistory,
    required this.smoking,
    required this.alcohol,
    required this.physicalActivity,
    required this.employmentStatus,
    required this.onPreviousPreeclampsia,
    required this.onGestationalDiabetes,
    required this.onChronicHypertension,
    required this.onFamilyHistory,
    required this.onSmoking,
    required this.onAlcohol,
    required this.onPhysicalActivity,
    required this.onEmploymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History & lifestyle', style: AppTextStyles.label(context)),
        const SizedBox(height: 6),
        _CheckboxField(label: 'Previous preeclampsia', value: previousPreeclampsia, onChanged: onPreviousPreeclampsia),
        _CheckboxField(label: 'Gestational diabetes', value: gestationalDiabetes, onChanged: onGestationalDiabetes),
        _CheckboxField(label: 'Chronic hypertension', value: chronicHypertension, onChanged: onChronicHypertension),
        _CheckboxField(label: 'Family history', value: familyHistory, onChanged: onFamilyHistory),
        _CheckboxField(label: 'Smoking', value: smoking, onChanged: onSmoking),
        _CheckboxField(label: 'Alcohol', value: alcohol, onChanged: onAlcohol),
        _CheckboxField(label: 'Regular physical activity', value: physicalActivity, onChanged: onPhysicalActivity),
        _CheckboxField(label: 'Employed', value: employmentStatus, onChanged: onEmploymentStatus),
      ],
    );
  }
}

class _CheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CheckboxField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.of(context).tealPrimary,
            ),
            Expanded(child: Text(label, style: AppTextStyles.body(context))),
          ],
        ),
      ),
    );
  }
}

class _LabsAndNotesStep extends StatelessWidget {
  final bool phone;
  final TextEditingController hemoglobin;
  final TextEditingController platelet;
  final TextEditingController creatinine;
  final String protein;
  final String oedema;
  final String dangerSigns;
  final ValueChanged<String> onProtein;
  final ValueChanged<String> onOedema;
  final ValueChanged<String> onDangerSigns;

  const _LabsAndNotesStep({
    required this.phone,
    required this.hemoglobin,
    required this.platelet,
    required this.creatinine,
    required this.protein,
    required this.oedema,
    required this.dangerSigns,
    required this.onProtein,
    required this.onOedema,
    required this.onDangerSigns,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Laboratory results', style: AppTextStyles.label(context)),
        const SizedBox(height: 6),
        _FieldGrid(
          phone: phone,
          children: [
            _StepField(label: 'Hemoglobin (g/dL)', child: _Input(controller: hemoglobin)),
            _StepField(label: 'Platelet count (10³/µL)', child: _Input(controller: platelet)),
            _StepField(label: 'Creatinine (mg/dL)', child: _Input(controller: creatinine)),
          ],
        ),
        const SizedBox(height: 20),
        Text('Clinical notes', style: AppTextStyles.label(context)),
        const SizedBox(height: 6),
        _FieldGrid(
          phone: phone,
          children: [
            _StepField(
              label: 'Protein in urine',
              child: _Dropdown(
                value: protein,
                items: const [
                  (value: 'Negative', label: 'Negative'),
                  (value: 'Trace', label: 'Trace'),
                  (value: '1+', label: '1+'),
                  (value: '2+', label: '2+'),
                  (value: '3+', label: '3+'),
                ],
                onChanged: (v) => onProtein(v!),
              ),
            ),
            _StepField(
              label: 'Oedema',
              child: _Dropdown(
                value: oedema,
                items: const [
                  (value: 'None', label: 'None'),
                  (value: 'Mild (feet/ankles)', label: 'Mild (feet/ankles)'),
                  (value: 'Moderate (legs)', label: 'Moderate (legs)'),
                  (value: 'Severe (face/hands)', label: 'Severe (face/hands)'),
                ],
                onChanged: (v) => onOedema(v!),
              ),
            ),
            _StepField(
              label: 'Danger signs',
              child: _Dropdown(
                value: dangerSigns,
                items: const [
                  (value: 'None reported', label: 'None reported'),
                  (value: 'Headache', label: 'Headache'),
                  (value: 'Blurred vision', label: 'Blurred vision'),
                  (value: 'Epigastric pain', label: 'Epigastric pain'),
                ],
                onChanged: (v) => onDangerSigns(v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const AlertStrip(
          icon: Icons.info_outline_rounded,
          text: 'Protein, oedema, and danger signs are kept as clinical notes for the record. The prediction model does not use them as inputs.',
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  const _Input({required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      style: AppTextStyles.body(context, color: enabled ? AppColors.of(context).ink : AppColors.of(context).inkMute),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? AppColors.of(context).card : AppColors.of(context).paper,
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value;
  final String? hint;
  final List<({String value, String label})> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({this.value, this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.of(context).card,
          value: value,
          hint: hint != null ? Text(hint!, style: AppTextStyles.body(context, color: AppColors.of(context).inkMute)) : null,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.of(context).inkMute),
          style: AppTextStyles.body(context),
          items: items.map((o) => DropdownMenuItem(value: o.value, child: Text(o.label))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
