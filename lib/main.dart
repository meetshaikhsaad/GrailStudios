import '../../helpers/ExportImports.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // ← Changed from MaterialApp
      title: 'Grail Studios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: grailPrimaryOrange,
        scaffoldBackgroundColor: grailLoginBackground,
        fontFamily: 'Roboto',

        colorScheme: ColorScheme.light(
          primary: grailPrimaryOrange,
          secondary: grailGold,
          background: grailLoginBackground,
          onPrimary: Colors.white,
          onBackground: grailTextDark,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: grailPrimaryOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: grailInputFill,
          labelStyle: const TextStyle(color: grailTextDark),
          hintStyle: TextStyle(color: grailTextDark.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: grailInputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: grailInputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: grailPrimaryOrange, width: 2),
          ),
        ),

        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}