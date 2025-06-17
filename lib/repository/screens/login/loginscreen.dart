import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:houzy/repository/widgets/uihelper.dart';
import 'package:houzy/screens/userauth/firebaseauthservices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  bool isLoginMode = true; // true = sign in, false = sign up

  Future<void> _handleGoogleAuth() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _showMessage("Google Sign-In failed");
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (isLoginMode) {
        // 🔸 Login Mode
        if (docSnapshot.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavScreen()),
          );
        } else {
          _showMessage("You are not registered, please sign up first.");
        }
      } else {
        // 🔸 Sign Up Mode
        if (docSnapshot.exists) {
          _showMessage("You are already registered, please log in.");
        } else {
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'timestamp': Timestamp.now(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavScreen()),
          );
        }
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    height: 80,
                    child: UiHelper.CustomImage(img: "houzylogoimage.png"),
                  ),
                  const Positioned(
                    top: -2,
                    left: 12,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 18),
                  ),
                  const Positioned(
                    top: -3,
                    right: 20,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 20),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 16),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 10,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              UiHelper.CustomText(
                text: "Professional House Cleaning Service",
                color: const Color(0xFFFE600E),
                fontweight: FontWeight.bold,
                fontsize: 10,
                fontfamily: "bold",
              ),
              const SizedBox(height: 20),

              // 🔸 Toggle Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isLoginMode = true),
                    child: const Text("Sign In"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoginMode ? const Color(0xFFFE600E) : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => isLoginMode = false),
                    child: const Text("Sign Up"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isLoginMode ? const Color(0xFFFE600E) : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.only(left: 48), // Shifts image slightly to the right
  child: SizedBox(
    width: 450,  // Set desired width
    height: 350, // Set desired height
    child: UiHelper.CustomImage(img: "loginsvg.png"),
  ),
),

const SizedBox(height: 10),


              // 🔸 Google Auth Button
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleAuth,
                  icon: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset('assets/images/googleicon.png'),
                  ),
                  label: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          isLoginMode ? "Login with Google" : "Register with Google",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔸 Footer
              Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'T&C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: ' policy.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
