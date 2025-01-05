import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/core/widgets/text_form_fields.dart';
import 'package:ober_version_2/pages/sign_up/sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final size = MediaQuery.sizeOf(context);

    return GetBuilder(
      init: SignUpController(),
      builder: (signUpController) {
        return Scaffold(
          body: Form(
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
                  ElevatedButtons(
                    onPressed: () {
                      signUpController.signUp(
                        name: usernameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
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
