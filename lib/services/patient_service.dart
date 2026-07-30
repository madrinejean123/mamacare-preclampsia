import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/patient.dart';
import '../models/stats.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PatientApiException implements Exception {
  final String message;
  PatientApiException(this.message);

  @override
  String toString() => message;
}

class PatientService {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthService.instance.token != null) 'Authorization': 'Bearer ${AuthService.instance.token}',
      };

  Future<dynamic> _get(String path) async {
    final http.Response response;
    try {
      response = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers);
    } catch (_) {
      throw PatientApiException('Could not reach the server at ${ApiConfig.baseUrl}. Is it running?');
    }
    return _decode(response);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final http.Response response;
    try {
      response = await http.post(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers, body: jsonEncode(body));
    } catch (_) {
      throw PatientApiException('Could not reach the server at ${ApiConfig.baseUrl}. Is it running?');
    }
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw PatientApiException('Server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map<String, dynamic> ? data['error']?.toString() : null;
      throw PatientApiException(message ?? 'Request failed (${response.statusCode}).');
    }
    return data;
  }

  Future<List<Patient>> fetchPatients() async {
    final data = await _get('/patients') as List;
    return data.map((p) => Patient.fromListJson(p as Map<String, dynamic>)).toList();
  }

  Future<Patient> fetchPatient(String id) async {
    final data = await _get('/patients/$id') as Map<String, dynamic>;
    return Patient.fromDetailJson(data);
  }

  Future<Patient> createPatient({
    required String name,
    int? age,
    int? gestationalWeek,
    int? gravida,
    int? para,
  }) async {
    final data = await _post('/patients', {
      'name': name,
      if (age != null) 'age': age,
      if (gestationalWeek != null) 'gestational_week': gestationalWeek,
      if (gravida != null) 'gravida': gravida,
      if (para != null) 'para': para,
    }) as Map<String, dynamic>;
    return Patient.fromListJson(data);
  }

  Future<void> addNote(String patientId, {required String author, required String text}) async {
    await _post('/patients/$patientId/notes', {'author': author, 'text': text});
  }

  Future<ClinicStats> fetchStats() async {
    final data = await _get('/stats') as Map<String, dynamic>;
    return ClinicStats.fromJson(data);
  }
}
