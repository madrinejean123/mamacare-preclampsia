import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/step_indicator.dart';

const _steps = ['Patient', 'Measurements', 'History', 'Result'];

class NewAssessmentScreen extends StatefulWidget {
  const NewAssessmentScreen({super.key});

  @override
  State<NewAssessmentScreen> createState() => _NewAssessmentScreenState();
}

class _NewAssessmentScreenState extends State<NewAssessmentScreen> {
  int _step = 0;

  String? _patientId;
  final _gestAgeController = TextEditingController(text: '28');
  final _systolicController = TextEditingController(text: '120');
  final _diastolicController = TextEditingController(text: '78');
  final _weightController = TextEditingController(text: '68');
  final _heightController = TextEditingController(text: '162');
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
  void dispose() {
    _gestAgeController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  void _next() {
    if (_step == _steps.length - 2) {
      context.go('/assess/result');
      return;
    }
    setState(() => _step += 1);
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
        return _PatientStep(patientId: _patientId, onChanged: (v) => setState(() => _patientId = v));
      case 1:
        return _MeasurementsStep(
          phone: phone,
          gestAge: _gestAgeController,
          systolic: _systolicController,
          diastolic: _diastolicController,
          weight: _weightController,
          height: _heightController,
          bmi: _bmi,
        );
      default:
        return _HistoryStep(
          phone: phone,
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
      onPressed: _next,
      child: Text(_step == _steps.length - 2 ? 'Run prediction →' : 'Continue →'),
    );

    if (phone) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: primary),
          if (_step > 0) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _back, child: const Text('← Back'))),
          ],
        ],
      );
    }

    return Row(
      children: [
        if (_step > 0)
          OutlinedButton(onPressed: _back, child: const Text('← Back'))
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

class _PatientStep extends StatelessWidget {
  final String? patientId;
  final ValueChanged<String?> onChanged;
  const _PatientStep({required this.patientId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepField(
      label: 'Patient',
      child: _Dropdown(
        hint: 'Select a patient',
        value: patientId,
        items: MockData.patients.map((p) => (value: p.id, label: '${p.name} · wk ${p.gestationalWeek}')).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _MeasurementsStep extends StatelessWidget {
  final bool phone;
  final TextEditingController gestAge;
  final TextEditingController systolic;
  final TextEditingController diastolic;
  final TextEditingController weight;
  final TextEditingController height;
  final double bmi;

  const _MeasurementsStep({
    required this.phone,
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

class _HistoryStep extends StatelessWidget {
  final bool phone;
  final String protein;
  final String oedema;
  final String dangerSigns;
  final ValueChanged<String> onProtein;
  final ValueChanged<String> onOedema;
  final ValueChanged<String> onDangerSigns;

  const _HistoryStep({
    required this.phone,
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
          text: 'These fields map directly to the prediction model\'s features. Missing values are imputed automatically and flagged in the result.',
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
