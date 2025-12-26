import '../../helpers/ExportImports.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String usersRoles = '/users-roles';
  static const String tasks = '/tasks';
  static const String contentVault = '/content-vault';
  static const String compliance = '/compliance';
  static const String reports = '/reports';
  static const String settings = '/settings';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen()),
    GetPage(name: AppRoutes.usersRoles, page: () => const UsersRolesScreen()),
    // GetPage(name: AppRoutes.tasks, page: () => const TasksScreen()),
    // GetPage(name: AppRoutes.contentVault, page: () => const ContentVaultScreen()),
    // GetPage(name: AppRoutes.compliance, page: () => const ComplianceScreen()),
    // GetPage(name: AppRoutes.reports, page: () => const ReportsScreen()),
    // GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
  ];
}