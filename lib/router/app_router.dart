import 'package:go_router/go_router.dart';

import '../models/prediction_result.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/assessment/new_assessment_screen.dart';
import '../screens/assessment/prediction_result_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/insights/reports_screen.dart';
import '../screens/insights/trends_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/patient/patient_home_screen.dart';
import '../screens/patients/patient_profile_screen.dart';
import '../screens/patients/patients_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/auth_service.dart';

const _alwaysPublic = {'/'};
const _authOnlyRoutes = {'/login', '/register'};

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AuthService.instance,
  redirect: (context, state) {
    final auth = AuthService.instance;
    final loc = state.matchedLocation;

    if (_alwaysPublic.contains(loc)) return null;

    // Always show the login/register form itself when asked for it,
    // even if an old session is still stored — never silently skip it.
    if (_authOnlyRoutes.contains(loc)) return null;

    if (!auth.isLoggedIn) {
      return '/login';
    }

    // Patients only ever see their own read-only view.
    if (auth.isPatient) {
      return loc == '/me' ? null : '/me';
    }

    // Staff (admin/clinician) from here on — /me isn't for them, /admin is admin-only.
    if (loc == '/me') return '/dashboard';
    if (loc == '/admin' && !auth.isAdmin) return '/dashboard';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/patients', builder: (context, state) => const PatientsListScreen()),
    GoRoute(
      path: '/patients/:id',
      builder: (context, state) => PatientProfileScreen(patientId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/assess', builder: (context, state) => const NewAssessmentScreen()),
    GoRoute(
      path: '/assess/result',
      builder: (context, state) => PredictionResultScreen(result: state.extra as PredictionResult?),
    ),
    GoRoute(
      path: '/trends',
      builder: (context, state) => TrendsScreen(initialPatientId: state.uri.queryParameters['patient']),
    ),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/me', builder: (context, state) => const PatientHomeScreen()),
  ],
);
