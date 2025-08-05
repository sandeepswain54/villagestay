import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_app/model/user_view_model.dart';
import 'package:service_app/model/user_view_model.dart' as userViewModel;
import 'package:service_app/views/provider.dart';
import 'package:service_app/views/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showRegistrationOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Register as",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => const ProviderSignupScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Village Host",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => const Signup(userType: "User"));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Tourist",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController _resetEmailController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: _resetEmailController,
          decoration: const InputDecoration(
            labelText: "Enter your registered email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _resetEmailController.text.trim();
              if (email.isEmpty || !email.contains("@")) {
                Get.snackbar("Invalid Email", "Please enter a valid email address.");
                return;
              }

              try {
                await userViewModel.UserViewModel().sendPasswordResetEmail(email);
                Navigator.pop(context);
                Get.snackbar("Success", "Reset link sent to $email",
                    backgroundColor: Colors.green,
                    colorText: Colors.white);
              } catch (e) {
                Navigator.pop(context);
                Get.snackbar("Error", "No account found or something went wrong",
                    backgroundColor: Colors.red,
                    colorText: Colors.white);
              }
            },
            child: const Text("Send Link"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFF967BB6)]  ,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ListView(
          children: [
            Image.asset(
              "assets/logo456.png",
              width: 230,
              height: 230,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 140),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                "Login to Village Stay",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || !value.contains("@")) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 21),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          UserViewModel userVM = UserViewModel();
                          await userVM.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: _showRegistrationOptions,
              child: const Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
