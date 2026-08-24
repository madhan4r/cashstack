import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_controller.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../core/home_widget/home_widget_screen.dart';
import '../features/accounts/screens/screens.dart';
import '../features/household/screens/household_screen.dart';
import '../features/household/screens/pending_invites_screen.dart';
import '../features/export/screens/export_screen.dart';
import '../features/notifications/screens/notification_preferences_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/budget/screens/category_budgets_screen.dart';
import '../features/categories/screens/screens.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/feedback/screens/feedback_screen.dart';
import '../features/transaction_detection/screens/detected_transactions_screen.dart';
import '../features/recurring/screens/screens.dart';
import '../features/reports/screens/screens.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/savings_goals/screens/savings_goal_form_screen.dart';
import '../features/savings_goals/screens/savings_goals_list_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/transactions/screens/transaction_form_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../shared/models/transaction_kind.dart';
import 'app_routes.dart';
import 'main_shell.dart';

const _publicPaths = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
};

final goRouterProvider = Provider<GoRouter>((ref) {
  // GoRouter's `refreshListenable` needs a Listenable; bridge Riverpod's
  // AuthState changes into a ValueNotifier so the router re-evaluates
  // `redirect` every time auth status changes.
  final authListenable = ValueNotifier<AuthState>(
    ref.read(authControllerProvider),
  );
  ref.listen<AuthState>(
    authControllerProvider,
    (_, next) => authListenable.value = next,
  );
  ref.onDispose(authListenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isPublicRoute = _publicPaths.contains(state.matchedLocation);

      switch (authState.status) {
        case AuthStatus.unknown:
          // Still checking for a stored session — stay put.
          return state.matchedLocation == AppRoutes.splash
              ? null
              : AppRoutes.splash;
        case AuthStatus.unauthenticated:
          // Unauthenticated users must always land on Login.
          return isPublicRoute && state.matchedLocation != AppRoutes.splash
              ? null
              : AppRoutes.login;
        case AuthStatus.authenticated:
          // Authenticated users shouldn't sit on splash/login/register.
          return isPublicRoute ? AppRoutes.home : null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordScreen(
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) {
          final typeParam = state.uri.queryParameters['type'];
          final initialType = typeParam == null
              ? null
              : TransactionKind.values
                  .cast<TransactionKind?>()
                  .firstWhere((kind) => kind!.toJson() == typeParam, orElse: () => null);
          final amountParam = state.uri.queryParameters['amount'];
          final initialAmount = amountParam == null ? null : double.tryParse(amountParam);
          return TransactionFormScreen(initialType: initialType, initialAmount: initialAmount);
        },
      ),
      GoRoute(
        path: AppRoutes.editTransactionPattern,
        builder: (context, state) => TransactionFormScreen(
          transactionId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.accounts,
        builder: (context, state) => const AccountsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAccount,
        builder: (context, state) => const AccountFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editAccountPattern,
        builder: (context, state) =>
            AccountFormScreen(accountId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.accountDetailsPattern,
        builder: (context, state) =>
            AccountDetailsScreen(accountId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCategory,
        builder: (context, state) => const CategoryFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editCategoryPattern,
        builder: (context, state) =>
            CategoryFormScreen(categoryId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.categoryDetailsPattern,
        builder: (context, state) =>
            CategoryDetailsScreen(categoryId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.exportData,
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: AppRoutes.detectedTransactions,
        builder: (context, state) => const DetectedTransactionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.homeScreenWidgets,
        builder: (context, state) => const HomeWidgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.household,
        builder: (context, state) => const HouseholdScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingInvites,
        builder: (context, state) => const PendingInvitesScreen(),
      ),
      GoRoute(
        path: AppRoutes.recurring,
        builder: (context, state) => const RecurringListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addRecurring,
        builder: (context, state) => const RecurringFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editRecurringPattern,
        builder: (context, state) =>
            RecurringFormScreen(recurringId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.categoryBudgets,
        builder: (context, state) => const CategoryBudgetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.savingsGoals,
        builder: (context, state) => const SavingsGoalsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addSavingsGoal,
        builder: (context, state) => const SavingsGoalFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.savingsGoalDetailsPattern,
        builder: (context, state) =>
            SavingsGoalFormScreen(goalId: state.pathParameters['id']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
