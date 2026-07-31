import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';

/// Modal form for creating a patient. Pops with the created [Patient] on
/// success so callers can e.g. auto-select it, or just refresh a list.
class AddPatientDialog extends StatefulWidget {
  final ValueChanged<Patient> onAdded;
  const AddPatientDialog({super.key, required this.onAdded});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weekController = TextEditingController();
  final _gravidaController = TextEditingController();
  final _paraController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weekController.dispose();
    _gravidaController.dispose();
    _paraController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final patient = await PatientService().createPatient(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        gestationalWeek: int.tryParse(_weekController.text),
        gravida: int.tryParse(_gravidaController.text),
        para: int.tryParse(_paraController.text),
      );
      widget.onAdded(patient);
      if (mounted) Navigator.of(context).pop();
    } on PatientApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add patient'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _weekController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gest. week'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _gravidaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Gravida',
                      helperText: 'Total pregnancies',
                      helperMaxLines: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _paraController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Para',
                      helperText: 'Births after 24 wks',
                      helperMaxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}
