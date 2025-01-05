import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/core/widgets/text_form_fields.dart';
import 'package:ober_version_2/pages/sign_up/sign_up_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Form(
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
                onPressed: () {},
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
  }
}
