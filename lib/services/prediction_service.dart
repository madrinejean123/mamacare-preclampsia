import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prediction_input.dart';
import '../models/prediction_result.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PredictionApiException implements Exception {
  final String message;
  PredictionApiException(this.message);

  @override
  String toString() => message;
}

/// Talks to the Flask/Postgres backend (preeclampsia_backend/api.py) wrapping
/// the pickled screening model. Requires the caller to be logged in — the
/// backend rejects /predict without a valid Bearer token.
class PredictionService {
  Future<PredictionResult> predict(
    PredictionInput input, {
    String? patientId,
    String? patientName,
    int? gestationalWeek,
    String? proteinUrine,
    String? oedema,
    String? dangerSigns,
  }) async {
    final payload = input.toJson();
    if (patientId != null) payload['patient_id'] = int.parse(patientId);
    if (gestationalWeek != null) payload['gestational_week'] = gestationalWeek;
    if (proteinUrine != null) payload['protein_urine'] = proteinUrine;
    if (oedema != null) payload['oedema'] = oedema;
    if (dangerSigns != null) payload['danger_signs'] = dangerSigns;

    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/predict'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.instance.token != null) 'Authorization': 'Bearer ${AuthService.instance.token}',
        },
        body: jsonEncode(payload),
      );
    } catch (_) {
      throw PredictionApiException(
        'Could not reach the prediction service at ${ApiConfig.baseUrl}. Is it running?',
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw PredictionApiException('Prediction service returned an invalid response.');
    }

    if (response.statusCode != 200) {
      throw PredictionApiException(body['error']?.toString() ?? 'Prediction failed.');
    }

    return PredictionResult.fromJson(
      body,
      input: input,
      patientId: patientId,
      patientName: patientName,
      gestationalWeek: gestationalWeek,
    );
  }
}
