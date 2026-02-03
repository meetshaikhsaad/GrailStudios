import '../../helpers/ExportImports.dart';

class DashboardController extends GetxController {
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Replace with your actual API call
      // final response1 = await ApiService.get('/api/dashboard/stats');
      final response = await ApiService().callApiWithMap(
        'dashboard/stats',
        'Get',
        mapData: {},
      );

      stats.value = DashboardStats.fromJson(response);

    } catch (e) {
      errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardStats();
  }
}