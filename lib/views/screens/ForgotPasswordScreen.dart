import 'dart:ui';
import '../../helpers/ExportImports.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  @override
  void initState() {
    super.initState();
    // Optional: Clear all errors on initial build
    controller.forgotPassEmailError.value = '';
    controller.otpError.value = '';
    controller.newPasswordError.value = '';
    controller.confirmPasswordError.value = '';
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.put(ForgotPasswordController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background image
          Image.asset('assets/images/login_bg.jpg', width: double.infinity, height: double.infinity, fit: BoxFit.cover),

          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),

          // Orange overlay
          Container(color: const Color(0xFFC3892F).withOpacity(0.85)),

          // Main content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: size.height,
              child: Column(
                children: [
                  // Top section (logo + title)
                  Expanded(
                    flex: 4,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              padding: const EdgeInsets.all(25),
                              child: Image.asset('assets/images/logo_without_text.png', fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Obx(
                            () => Text(
                              controller.isCodeSent.value ? 'Reset Password' : 'Forgot Password?',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => Text(
                              controller.isCodeSent.value ? 'Enter the OTP sent to your email.' : 'Enter your email to receive a reset code.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom white curved section
                  Expanded(
                    flex: 6,
                    child: ClipPath(
                      clipper: InvertedTopCurveClipper(),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(35, 60, 35, 20), // Reduced top padding slightly
                          child: Obx(() => controller.isCodeSent.value ? _buildResetPasswordForm(controller) : _buildSendCodeForm(controller)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form 1: Send Code (Email Only) ──
  Widget _buildSendCodeForm(ForgotPasswordController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        Obx(
          () => TextField(
            onChanged: (value) {
              controller.forgotPassEmail.value = value;
              if (controller.forgotPassEmailError.value.isNotEmpty) {
                controller.forgotPassEmailError.value = ''; // Clear error as soon as user types
              }
            },
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'example: johndoe@gmail.com',
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              errorText: controller.forgotPassEmailError.value.isNotEmpty ? controller.forgotPassEmailError.value : null,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Send Code Button
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: controller.forgotPassIsLoading.value ? null : controller.sendResetCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: grailGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              child: controller.forgotPassIsLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Send Code',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Back to Login
        GestureDetector(
          onTap: () => Get.back(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, color: grailBackgroundStart, size: 18),
              const SizedBox(width: 5),
              Text(
                'Back to Login',
                style: TextStyle(color: grailBackgroundStart, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Form 2: Reset Password (now scrollable to prevent overflow) ──
  Widget _buildResetPasswordForm(ForgotPasswordController controller) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(), // Smooth, no bounce overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          // Email (read-only, pre-filled)
          TextField(
            controller: TextEditingController(text: controller.forgotPassEmail.value),
            readOnly: true,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20), // Reduced spacing
          // OTP Code
          Obx(
            () => TextField(
              onChanged: (value) {
                controller.otp.value = value;
                if (controller.otpError.value.isNotEmpty) {
                  controller.otpError.value = ''; // Clear error as soon as user types
                }
              },
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'OTP Code',
                hintText: 'Enter OTP',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                errorText: controller.otpError.value.isNotEmpty ? controller.otpError.value : null,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 20),

          // New Password
          Obx(
            () => TextField(
              onChanged: (value) {
                controller.newPassword.value = value;
                if (controller.newPasswordError.value.isNotEmpty) {
                  controller.newPasswordError.value = ''; // Clear error as soon as user types
                }
              },
              obscureText: !controller.isNewPasswordVisible.value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'New Password',
                hintText: 'Min 8 characters',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: Icon(controller.isNewPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
                errorText: controller.newPasswordError.value.isNotEmpty ? controller.newPasswordError.value : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Password
          Obx(
            () => TextField(
              onChanged: (value) {
                controller.confirmPassword.value = value;
                if (controller.confirmPasswordError.value.isNotEmpty) {
                  controller.confirmPasswordError.value = ''; // Clear error as soon as user types
                }
              },
              obscureText: !controller.isConfirmPasswordVisible.value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm password',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: Icon(controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                errorText: controller.confirmPasswordError.value.isNotEmpty ? controller.confirmPasswordError.value : null,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Set New Password Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: controller.resetPassIsLoading.value ? null : controller.resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: grailGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: controller.resetPassIsLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Set New Password',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
