import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:houzy/repository/screens/booking/bookingscreen.dart';

import 'firebase_options.dart';
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:houzy/repository/screens/login/loginscreen.dart';
import 'package:houzy/repository/screens/account/accountscreen.dart';
import 'package:houzy/repository/splash/splashscreen.dart';
import 'package:houzy/repository/screens/checkout/checkout.dart'; // Checkout screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set your Stripe publishable key here
  Stripe.publishableKey =
      'pk_test_51NqqEUSFQ0a1pnIOTAPpjx2C4mkmFSjaadsL9lD5mffA3p3rmSUbLHwKUVjZT9l5Yns2JQKUxmmnOKycQIValENm00QK1eDgLp';

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Houzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color(0xFFF54A00),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange,
        ).copyWith(
          secondary: Colors.deepOrangeAccent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => BottomNavScreen(),
        '/account': (context) => const AccountScreen(),
        '/booking': (context) => BookingScreen(),

        // ⚠️ Checkout route should only be used with Navigator.push() and real data
        // This is just a fallback example with dummy data for dev testing
        '/checkout': (context) => Checkout(
              selectedDate: DateTime.now(),
              selectedTimeSlot: '10:00 AM - 12:00 PM',
              sizeLabel: '2 BHK',
              price: 299,
            ),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
