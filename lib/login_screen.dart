import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nidle_qty/models/user_model.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/text_from_field.dart';
import 'package:provider/provider.dart';

import 'buyer_list.dart';
import 'home_screen.dart';
import 'line_dropdown_settings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _passCon = TextEditingController();

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    _emailCon.dispose();
    _passCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.deepPurple.shade800, Color(0xff161a49)])),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Title
                  Image.asset('images/logo.png', height: 140, width: 140),
                  const SizedBox(height: 20),
                  Text("Welcome Back", style: AppConstants.customTextStyle(18, Colors.white, FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Sign in to continue", style: AppConstants.customTextStyle(18, Colors.white.withOpacity(0.8), FontWeight.w600)),
                  const SizedBox(height: 40),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        CustomTextFormField(
                          controller: _emailCon,
                          labelText: "Email",
                          prefixIcon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        TextFormField(
                          obscureText: _obscurePassword,
                          controller: _passCon,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white54)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () {}, child: Text("Forgot Password?", style: AppConstants.customTextStyle(12, Colors.white.withOpacity(.7), FontWeight.w400))),
                        ),
                        const SizedBox(height: 30),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);

                                        try {

                                          var bp = context.read<BuyerProvider>();
                                          bool loginSuccess = await bp.userLogin(_emailCon.text.trim(), _passCon.text.trim());

                                          if (loginSuccess) {
                                            await DashboardHelpers.setString('email', _emailCon.text);
                                            await DashboardHelpers.setString('pass', _passCon.text);
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchDropdownScreen()));
                                          }
                                        } catch (e) {
                                          // Handle error if needed
                                          debugPrint('Login error: $e');
                                        } finally {
                                          if (mounted) {
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 5,
                              minimumSize: const Size(double.infinity, 50), // Full width button
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.deepPurple, strokeWidth: 2))
                                    : Text("LOGIN", style: AppConstants.customTextStyle(16, myColors.primaryColor, FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Link
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Don't have an account?", style: AppConstants.customTextStyle(12, Colors.white.withOpacity(.7), FontWeight.w400))]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getUserInfo() async {
    String email = await DashboardHelpers.getString('email');
    String pass = await DashboardHelpers.getString('pass');
    if (email != '' && pass != '') {
      setState(() {
        _emailCon.text = email;
        _passCon.text = pass;
      });
    }
  }
}
