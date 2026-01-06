import '../../helpers/ExportImports.dart';

class AuthController extends GetxController {
  var currentUser = Rxn<ActiveUser>(); // Reactive nullable user

  @override
  void onInit() {
    super.onInit();
    loadSavedUser();
  }

  Future<void> loadSavedUser() async {
    final user = await ApiService.getSavedUser();
    currentUser.value = user; // Now safe to assign
  }
}