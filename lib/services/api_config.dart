/// Shared base URL for the backend (preeclampsia_backend/api.py).
///
/// Android emulators can't reach the host via localhost; swap in 10.0.2.2
/// there, or point at a deployed URL for real devices.
class ApiConfig {
  static const String baseUrl = 'http://localhost:5001';
}
