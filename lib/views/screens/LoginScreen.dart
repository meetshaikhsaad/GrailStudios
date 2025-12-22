import 'dart:ui';
import '../../helpers/ExportImports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background image
          Image.asset(
            'assets/images/login_bg.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          // Blur effect on background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),

          // Strong orange/gold overlay on top section
          Container(
            color: const Color(0xFFC3892F).withOpacity(0.85), // Adjust opacity if needed to match your screenshot tone
          ),
          // Curved white bottom + content
          Column(
            children: [
              // Top section (logo + text)
              Expanded(
                flex: 4, // Larger top area to match screenshot proportion
                child: SafeArea(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo in white circle
                        Padding(
                          padding: const EdgeInsetsGeometry.only(top: 30.0),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(25),
                            child: Image.asset(
                              'assets/images/logo_without_text.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        const Text(
                          'Login to your Account',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Welcome to Grail Studios Admin Portal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom white curved section with form
              // Bottom white section with INVERTED (concave) top curve
              Expanded(
                flex: 6,
                child: ClipPath(
                  clipper: InvertedTopCurveClipper(),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(35, 80, 35, 40), // Increased top padding to clear the curve
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Email Field
                            Obx(() => TextField(
                              onChanged: (value) => controller.email.value = value,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'example: johndoe@gmail.com',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: controller.emailError.value.isNotEmpty
                                    ? controller.emailError.value
                                    : null,
                              ),
                            )),
                            const SizedBox(height: 25),

                            // Password Field
                            Obx(() => TextField(
                              onChanged: (value) => controller.password.value = value,
                              obscureText: !controller.isPasswordVisible.value,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'XXXXXXXX',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                                errorText: controller.passwordError.value.isNotEmpty
                                    ? controller.passwordError.value
                                    : null,
                              ),
                            )),
                            const SizedBox(height: 60),

                            // Login Button
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value ? null : controller.login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: grailGold, // Use your updated color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvertedTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double r = 50;

    final path = Path();

    // Start after top-left curve
    path.moveTo(r, r);

    // Straight top line
    path.lineTo(size.width - r, r);

    // 🔺 Top-right INVERTED corner (concave upward)
    path.arcToPoint(
      Offset(size.width, 0),
      radius: const Radius.circular(r),
      clockwise: false,
    );

    // Right side down
    path.lineTo(size.width, size.height);

    // Bottom
    path.lineTo(0, size.height);

    // Left side up
    path.lineTo(0, r * 2);

    // 🔻 Top-left NORMAL corner (convex downward)
    path.arcToPoint(
      Offset(r, r),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
