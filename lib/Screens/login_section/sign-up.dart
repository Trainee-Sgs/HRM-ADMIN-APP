import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isAgreed = false;
  bool _sameAsMobile = false;
  bool isLoading = false;

  /// Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController whatsappCtrl = TextEditingController();

  /// API URL
  final String apiUrl = "https://erpsmart.in/total/api/m_api/";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    const Color brandColor = Color(0xFF2BAE9E); // Teal color from screenshot

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.05),

                /// LOGO
                Image.asset(
                  'assets/logo.png',
                  width: size.width * 0.55,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                /// SUBTITLE
                const Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                /// TITLE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Signup",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w600, // Matching the weight in screenshot
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// NAME
                _inputField("Enter Your Name", nameCtrl, brandColor),
                const SizedBox(height: 16),

                /// EMAIL
                _inputField("Enter Business Email", emailCtrl, brandColor),
                const SizedBox(height: 16),

                /// MOBILE
                _inputField(
                  "Enter Mobile Number",
                  mobileCtrl,
                  brandColor,
                  type: TextInputType.phone,
                  onChanged: (val) {
                    if (_sameAsMobile) {
                      whatsappCtrl.text = val;
                    }
                  },
                ),
                const SizedBox(height: 16),

                /// WHATSAPP
                _inputField(
                  "Enter Whatsapp Number",
                  whatsappCtrl,
                  brandColor,
                  type: TextInputType.phone,
                  readOnly: _sameAsMobile,
                ),

                /// SAME AS MOBILE CHECKBOX
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _sameAsMobile,
                        activeColor: brandColor,
                        side: const BorderSide(color: brandColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _sameAsMobile = value!;
                            if (_sameAsMobile) {
                              whatsappCtrl.text = mobileCtrl.text;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Same as Mobile Number",
                      style: TextStyle(fontSize: 14, color: brandColor),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// TERMS CHECKBOX
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        activeColor: brandColor,
                        side: const BorderSide(color: brandColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() => _isAgreed = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            const TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(color: brandColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Add navigation if needed
                                },
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(color: brandColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Add navigation if needed
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signupApiCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "GET STARTED",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                /// SOCIAL SIGNUP
                const Text(
                  "or  signup with",
                  style: TextStyle(
                    fontSize: 14,
                    color: brandColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton('assets/google.png'),
                    const SizedBox(width: 30),
                    _socialButton('assets/apple.png'),
                  ],
                ),

                const SizedBox(height: 30),

                /// LOGIN REDIRECT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an Account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Signin",
                        style: TextStyle(
                          fontSize: 14,
                          color: brandColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField(
    String hint,
    TextEditingController controller,
    Color brandColor, {
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2BAE9E), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2BAE9E), width: 2),
        ),
      ),
    );
  }

  /// SOCIAL BUTTON
  Widget _socialButton(String assetPath) {
    return InkWell(
      onTap: () {
        // Social login logic
      },
      child: Image.asset(assetPath, width: 44, height: 44),
    );
  }


  /// ✅ MOCK SIGNUP (API BINDING REMOVED)
  Future<void> _signupApiCall() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final mobile = mobileCtrl.text.trim();
    final whatsapp = whatsappCtrl.text.trim();

    if (name.isEmpty) {
      _showSnack("Please enter your name", false);
      return;
    }

    if (email.isEmpty ||
        !RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        ).hasMatch(email)) {
      _showSnack("Please enter a valid email", false);
      return;
    }

    if (mobile.isEmpty ||
        mobile.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      _showSnack("Please enter a valid 10-digit mobile number", false);
      return;
    }

    if (whatsapp.isEmpty ||
        whatsapp.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(whatsapp)) {
      _showSnack("Please enter a valid 10-digit WhatsApp number", false);
      return;
    }

    if (!_isAgreed) {
      _showSnack("Please accept terms", false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mocked local Storage
      await prefs.setString('name', name);
      await prefs.setBool('isRegistered', true);

      _showSnack("Account created successfully (Mock)", true);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint("MOCK SIGNUP ERROR => $e");
      _showSnack("Error during local storage", false);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  /// SNACKBAR
  void _showSnack(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
