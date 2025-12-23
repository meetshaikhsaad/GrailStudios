import 'dart:ui';

import '../../helpers/ExportImports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    // // Clear validation errors every time the screen is rebuilt (including on return)
    // controller.emailError.value = '';
    // controller.passwordError.value = '';

    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Image.asset('assets/images/login_bg.jpg', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
          Container(color: const Color(0xFFC3892F).withOpacity(0.85)),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: size.height,
              child: Column(
                children: [
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
                          const Text(
                            'Login to your Account',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Welcome to Grail Studios Admin Portal',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: ClipPath(
                      clipper: InvertedTopCurveClipper(),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(35, 100, 35, 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(
                                () => TextField(
                                  onChanged: (value) {
                                    controller.email.value = value;
                                    print("email: " +controller.email.value);
                                    if (controller.emailError.value.isNotEmpty) {
                                      controller.emailError.value = ''; // Clear on type
                                    }
                                  },
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'example: johndoe@gmail.com',
                                    filled: true,
                                    fillColor: const Color(0xFFF8F8F8),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                    errorText: controller.emailError.value.isNotEmpty ? controller.emailError.value : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Obx(
                                () => TextField(
                                  onChanged: (value) {
                                    controller.password.value = value;
                                    if (controller.passwordError.value.isNotEmpty) {
                                      controller.passwordError.value = ''; // Clear on type
                                    }
                                  },
                                  controller: controller.passwordController,
                                  obscureText: !controller.isPasswordVisible.value,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'XXXXXXXX',
                                    filled: true,
                                    fillColor: const Color(0xFFF8F8F8),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                    suffixIcon: IconButton(
                                      icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                      onPressed: controller.togglePasswordVisibility,
                                    ),
                                    errorText: controller.passwordError.value.isNotEmpty ? controller.passwordError.value : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => const ForgotPasswordScreen());
                                    controller.resetForm();
                                  },

                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: grailGold, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : controller.login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: grailGold,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 5,
                                    ),
                                    child: controller.isLoading.value
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Login',
                                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}
