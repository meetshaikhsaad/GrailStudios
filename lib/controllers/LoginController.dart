import '../../helpers/ExportImports.dart';

class LoginController extends GetxController {
  // Form fields
  var email = ''.obs;
  var password = ''.obs;

  // Loading state
  var isLoading = false.obs;

  // Form validation
  var emailError = ''.obs;
  var passwordError = ''.obs;

  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool validate() {
    bool valid = true;

    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      emailError.value = 'Please enter a valid email';
      valid = false;
    } else {
      emailError.value = '';
    }

    if (password.value.isEmpty || password.value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      valid = false;
    } else {
      passwordError.value = '';
    }

    return valid;
  }

  Future<void> login() async {
    if (!validate()) return;

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // On success → navigate to dashboard (replace with your actual screen)
      Get.offAllNamed('/dashboard'); // or Get.to(() => DashboardScreen());

      Get.snackbar(
        'Success',
        'Welcome to Grail Studios!',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}