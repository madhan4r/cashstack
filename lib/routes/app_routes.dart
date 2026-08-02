/// Centralized route paths/names. Screens navigate via these constants
/// instead of hardcoded strings.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String changePassword = '/profile/change-password';
  static const String feedback = '/feedback';

  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/new';

  static String editTransaction(String transactionId) =>
      '/transactions/$transactionId/edit';
  static const String editTransactionPattern = '/transactions/:id/edit';

  static const String accounts = '/accounts';
  static const String addAccount = '/accounts/new';

  static String accountDetails(String accountId) => '/accounts/$accountId';
  static const String accountDetailsPattern = '/accounts/:id';

  static String editAccount(String accountId) => '/accounts/$accountId/edit';
  static const String editAccountPattern = '/accounts/:id/edit';

  static const String categories = '/categories';
  static const String addCategory = '/categories/new';

  static String categoryDetails(String categoryId) => '/categories/$categoryId';
  static const String categoryDetailsPattern = '/categories/:id';

  static String editCategory(String categoryId) => '/categories/$categoryId/edit';
  static const String editCategoryPattern = '/categories/:id/edit';

  static const String reports = '/reports';

  static const String recurring = '/recurring';
  static const String addRecurring = '/recurring/new';

  static String editRecurring(String recurringId) => '/recurring/$recurringId/edit';
  static const String editRecurringPattern = '/recurring/:id/edit';

  static const String detectedTransactions = '/detected-transactions';
  static const String homeScreenWidgets = '/home-screen-widgets';

  static const String household = '/household';
  static const String pendingInvites = '/household/invites';

  static const String categoryBudgets = '/budget/categories';

  static const String savingsGoals = '/savings-goals';
  static const String addSavingsGoal = '/savings-goals/new';

  /// Also doubles as the edit screen — [SavingsGoalFormScreen] handles
  /// both detail-viewing and editing in one screen, same as this app's
  /// other Add/Edit forms.
  static String savingsGoalDetails(String goalId) => '/savings-goals/$goalId';
  static const String savingsGoalDetailsPattern = '/savings-goals/:id';
}
