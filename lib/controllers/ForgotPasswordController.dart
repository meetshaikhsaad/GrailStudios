import '../../helpers/ExportImports.dart';

class ForgotPasswordController extends GetxController {

  var forgotPassEmail = ''.obs;
  var forgotPassEmailError = ''.obs;
  var forgotPassIsLoading = false.obs;

  var isCodeSent = false.obs; // Controls which form to show

  var otp = ''.obs;
  var otpError = ''.obs;

  var newPassword = ''.obs;
  var newPasswordError = ''.obs;
  var isNewPasswordVisible = false.obs;

  var confirmPassword = ''.obs;
  var confirmPasswordError = ''.obs;
  var isConfirmPasswordVisible = false.obs;

  var resetPassIsLoading = false.obs;

  bool validate() {
    if (forgotPassEmail.value.isEmpty || !GetUtils.isEmail(forgotPassEmail.value)) {
      forgotPassEmailError.value = 'Please enter a valid email';
      return false;
    }
    forgotPassEmailError.value = '';
    return true;
  }

  Future<void> sendResetCode() async {
    forgotPassEmailError.value = '';
    if (forgotPassEmail.value.isEmpty || !forgotPassEmail.value.isEmail) {
      forgotPassEmailError.value = 'Please enter a valid email';
      return;
    }

    forgotPassIsLoading.value = true;

    final success = await ApiService.sendOtpForReset(email: forgotPassEmail.value);

    forgotPassIsLoading.value = false;

    if (success) {
      isCodeSent.value = true; // Show reset form
    }
  }

  // Future<void> resetPassword() async {
  //   otpError.value = '';
  //   newPasswordError.value = '';
  //   confirmPasswordError.value = '';
  //
  //   if (otp.value.length != 6) {
  //     otpError.value = 'Enter a valid 6-digit OTP';
  //     return;
  //   }
  //   if (newPassword.value.length < 8) {
  //     newPasswordError.value = 'Password must be at least 8 characters';
  //     return;
  //   }
  //   if (newPassword.value != confirmPassword.value) {
  //     confirmPasswordError.value = 'Passwords do not match';
  //     return;
  //   }
  //
  //   resetPassIsLoading.value = true;
  //
  //   // TODO: Call your reset password API
  //   // e.g., await ApiService.resetPassword(otp: otp.value, newPassword: newPassword.value)
  //
  //   await Future.delayed(const Duration(seconds: 2)); // Simulate API call
  //   resetPassIsLoading.value = false;
  //
  //   Get.snackbar('Success', 'Password reset successful!', backgroundColor: Colors.green, colorText: Colors.white);
  //   Get.offAll(() => const LoginScreen());
  // }

  Future<void> resetPassword() async {
    otpError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';

    if (otp.value.length != 6 || !GetUtils.isNumericOnly(otp.value)) {
      otpError.value = 'Enter a valid 6-digit OTP';
      return;
    }
    if (newPassword.value.length < 8) {
      newPasswordError.value = 'Password must be at least 8 characters';
      return;
    }
    if (newPassword.value != confirmPassword.value) {
      confirmPasswordError.value = 'Passwords do not match';
      return;
    }

    resetPassIsLoading.value = true;

    final success = await ApiService.resetPassword(
      email: forgotPassEmail.value.trim(),
      otp: otp.value.trim(),
      newPassword: newPassword.value,
    );

    resetPassIsLoading.value = false;

    if (success) {
      Get.offAll(() => const LoginScreen());
    }
  }

  void toggleNewPasswordVisibility() => isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
}