import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/core/widgets/text_form_fields.dart';
import 'package:ober_version_2/pages/home/home_page.dart';
import 'package:ober_version_2/pages/sign_up/sign_up_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GetBuilder(
      init: SignUpController(),
      builder: (signUpController) {
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
                        const Text("Sign Up"),
                        SizedBox(height: size.height / 40),
                        TextFormFields(
                          controller: usernameController,
                          hintText: 'username',
                          isObscureText: false,
                        ),
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
                        DropdownButtonFormField(
                          isDense: true,
                          isExpanded: true,
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'driver',
                              child: Text('driver'),
                            ),
                            DropdownMenuItem(
                              value: 'passenger',
                              child: Text('passenger'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          hint: const Text("Select your role"),
                          autofocus: true,
                          alignment: Alignment.center,
                          dropdownColor: AppPallete.white,
                          elevation: 0,
                          enableFeedback: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select your role';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height / 40),
                        ElevatedButtons(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              UserCredential? user =
                                  await signUpController.signUp(
                                name: usernameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                role: selectedRole ?? 'passenger',
                              );
                              setState(() {
                                isLoading = false;
                              });
                              if (user != null) {
                                Get.offAll(() => const HomePage());
                              }
                            }
                          },
                          buttonName: 'Sign up',
                        ),
                        SizedBox(height: size.height / 40),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Already have an account? Sign In"),
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
