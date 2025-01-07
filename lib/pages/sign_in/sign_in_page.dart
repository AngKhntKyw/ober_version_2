import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/core/widgets/text_form_fields.dart';
import 'package:ober_version_2/pages/home/home_page.dart';
import 'package:ober_version_2/pages/sign_in/sign_in_controller.dart';
import 'package:ober_version_2/pages/sign_up/sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GetBuilder(
      init: SignInController(),
      builder: (signInController) {
        return Scaffold(
          body: isLoading
              ? const LoadingIndicators()
              : Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView(
                      children: [
                        const Icon(Icons.local_taxi_sharp, size: 160),
                        const Text("Sign In"),
                        SizedBox(height: size.height / 40),
                        TextFormFields(
                          controller: emailController,
                          hintText: 'email',
                          isObscureText: false,
                        ),
                        SizedBox(height: size.height / 40),
                        TextFormFields(
                          controller: passwordController,
                          hintText: 'password',
                          isObscureText: false,
                        ),
                        SizedBox(height: size.height / 40),
                        ElevatedButtons(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              UserCredential? user =
                                  await signInController.signIn(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim());

                              setState(() {
                                isLoading = false;
                              });
                              if (user != null) {
                                Get.offAll(() => const HomePage());
                              }
                            }
                          },
                          buttonName: 'Sign in',
                        ),
                        SizedBox(height: size.height / 40),
                        TextButton(
                          onPressed: () => Get.to(const SignUpPage()),
                          child: const Text("Don't have an account? Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
