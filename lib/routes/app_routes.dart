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
}
