import '../../helpers/ExportImports.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
print("email2: " + email.value);
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
    emailError.value = '';
    passwordError.value = '';

    isLoading.value = true;

    final user = await ApiService.login(
      email: email.value,
      password: password.value,
    );

    isLoading.value = false;

    if (user != null) {
      Get.snackbar(
        'Success',
        user.message,
        backgroundColor: grailGold,
        colorText: Colors.white,
      );
      resetForm();

      Get.offAll(() => const DashboardScreen());

      // Navigate based on role or onboarded status
      // if (user.user.role == 'admin') {
      //   Get.offAllNamed('/dashboard'); // or your admin home
      // } else {
      //   Get.offAllNamed('/home');
      // }
    }
  }


  void resetForm() {
    email.value = '';
    password.value = '';
    emailError.value = '';
    passwordError.value = '';
    isLoading.value = false;
    isPasswordVisible.value = false;

    // 🔥 THIS is what clears the UI
    emailController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

}