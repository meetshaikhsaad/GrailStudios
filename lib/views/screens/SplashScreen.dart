import '../../helpers/ExportImports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)], // Light to medium gray
          ),
        ),
        child: Stack(
          children: [
            // Faded network background
            Image.asset(
              'assets/images/bg_splash.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Top person (larger, positioned upper rightish)
                        Positioned(
                          top: size.height * 0.17,
                          right: size.width * 0.15,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 50,
                            backgroundImage: AssetImage('assets/images/splash_person1.png'),
                          ),
                        ),

                        // Bottom left person (smaller)
                        Positioned(
                          bottom: size.height * 0.18,
                          left: size.width * 0.12,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 40,
                            backgroundImage: AssetImage('assets/images/splash_person2.png'),
                          ),
                        ),

                        // Bottom right person (smaller)
                        Positioned(
                          bottom: size.height * 0.12,
                          right: size.width * 0.12,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 40,
                            backgroundImage: AssetImage('assets/images/splash_person3.png'),
                          ),
                        ),

                        // Central logo
                        Positioned(
                          top: size.height * 0.35,
                          child: Image.asset(
                            'assets/images/logo.png', // Your chalice + star logo
                            width: 180,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tagline at bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Text(
                      'Connect, manage and monitor your\nteam from a single platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}