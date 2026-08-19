import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_role.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/admin/presentation/screens/admin_calendar_screen.dart';
import '../../features/admin/presentation/screens/client_list_screen.dart';
import '../../features/admin/presentation/screens/manage_availability_screen.dart';
import '../../features/appointments/presentation/screens/my_appointments_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/booking/presentation/screens/book_appointment_screen.dart';
import '../../features/contact/presentation/screens/contact_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/shell/presentation/access_denied_screen.dart';
import '../../features/shell/presentation/admin_shell.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/shell/presentation/splash_screen.dart';
import 'route_paths.dart';

const _guardedClientRoutes = {
  RoutePaths.book,
  RoutePaths.myAppointments,
  RoutePaths.profile,
};

const _authRoutes = {
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
};

String _roleHome(UserRole role) =>
    role == UserRole.admin ? RoutePaths.adminCalendar : RoutePaths.home;

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// [Listenable]-based `refreshListenable`, so the router re-evaluates
/// [GoRouter.redirect] whenever auth state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final _authListenableProvider = Provider<_AuthListenable>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});

Page<void> _fadeSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = ref.watch(_authListenableProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (location == RoutePaths.splash) {
        if (authState.isLoading) return null;
        final user = authState.valueOrNull;
        return user == null ? RoutePaths.login : _roleHome(user.role);
      }

      final user = authState.valueOrNull;

      if (user == null) {
        final needsAuth =
            _guardedClientRoutes.contains(location) || location.startsWith('/admin');
        return needsAuth ? '${RoutePaths.login}?redirect=$location' : null;
      }

      if (_authRoutes.contains(location)) {
        final redirectTo = state.uri.queryParameters['redirect'];
        final isRedirectAppropriateForRole = redirectTo != null &&
            (user.role == UserRole.admin
                ? redirectTo.startsWith('/admin')
                : !redirectTo.startsWith('/admin'));
        return isRedirectAppropriateForRole ? redirectTo : _roleHome(user.role);
      }

      if (user.role == UserRole.client && location.startsWith('/admin')) {
        return RoutePaths.accessDenied;
      }

      if (user.role == UserRole.admin &&
          (location == RoutePaths.book ||
              location == RoutePaths.myAppointments ||
              location == RoutePaths.profile)) {
        return RoutePaths.adminCalendar;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) => _fadeSlidePage(const SplashScreen(), state),
      ),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) => _fadeSlidePage(
          LoginScreen(redirectTo: state.uri.queryParameters['redirect']),
          state,
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        pageBuilder: (context, state) => _fadeSlidePage(const RegisterScreen(), state),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        pageBuilder: (context, state) => _fadeSlidePage(const ForgotPasswordScreen(), state),
      ),
      GoRoute(
        path: RoutePaths.accessDenied,
        pageBuilder: (context, state) => _fadeSlidePage(const AccessDeniedScreen(), state),
      ),
      GoRoute(
        path: RoutePaths.book,
        pageBuilder: (context, state) => _fadeSlidePage(
          BookAppointmentScreen(preselectedServiceId: state.extra as String?),
          state,
        ),
      ),
      GoRoute(
        path: RoutePaths.myAppointments,
        pageBuilder: (context, state) => _fadeSlidePage(const MyAppointmentsScreen(), state),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.home,
              pageBuilder: (c, s) => _fadeSlidePage(const HomeScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.services,
              pageBuilder: (c, s) => _fadeSlidePage(const ServicesScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.about,
              pageBuilder: (c, s) => _fadeSlidePage(const AboutScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.contact,
              pageBuilder: (c, s) => _fadeSlidePage(const ContactScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.profile,
              pageBuilder: (c, s) => _fadeSlidePage(const ProfileScreen(), s),
            ),
          ]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.adminCalendar,
              pageBuilder: (c, s) => _fadeSlidePage(const AdminCalendarScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.adminClients,
              pageBuilder: (c, s) => _fadeSlidePage(const ClientListScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.adminAvailability,
              pageBuilder: (c, s) => _fadeSlidePage(const ManageAvailabilityScreen(), s),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.adminProfile,
              pageBuilder: (c, s) => _fadeSlidePage(const ProfileScreen(), s),
            ),
          ]),
        ],
      ),
    ],
  );
});
