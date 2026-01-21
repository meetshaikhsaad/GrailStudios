import '../../helpers/ExportImports.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String usersRoles = '/users-roles';
  static const String tasksAssigner = '/tasks-assigner';
  static const String tasksSubmission = '/tasks-submission';
  static const String contentVault = '/content-vault';
  static const String compliance = '/compliance';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String addUser = '/addUser';
  static const String userDetail = '/userDetail';
  static const String resetPassword = '/resetPassword';
  static const String createTask = '/createTask';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen()),
    GetPage(name: AppRoutes.usersRoles, page: () => const UsersRolesScreen()),
    GetPage(name: AppRoutes.addUser, page: () => const AddUserScreen()),
    GetPage(name: AppRoutes.userDetail, page: () => const UserDetailScreen()),
    GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: AppRoutes.tasksAssigner, page: () => TaskAssignerScreen()),
    GetPage(name: AppRoutes.tasksSubmission, page: () => TaskSubmissionScreen()),
    GetPage(name: AppRoutes.createTask, page: () => const CreateTaskScreen()),
    // GetPage(name: AppRoutes.tasks, page: () => const TasksScreen()),
    // GetPage(name: AppRoutes.contentVault, page: () => const ContentVaultScreen()),
    // GetPage(name: AppRoutes.compliance, page: () => const ComplianceScreen()),
    // GetPage(name: AppRoutes.reports, page: () => const ReportsScreen()),
    // GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
  ];
}