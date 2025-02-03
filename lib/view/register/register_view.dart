import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/repo/auth_repository.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';
import 'package:worker_bee/view/login/login_view.dart';
import 'package:worker_bee/viewmodel/auth_controller.dart';
import 'package:worker_bee/viewmodel/services/register_services.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final placeController = TextEditingController();
  late final AuthController _authController;
  File selectedImage = File('');

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      AuthRepository(Supabase.instance.client),
    );
  }

  Future<void> _handleRegister() async {
    // Basic validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        placeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await _authController.registerWithEmail(
      email: emailController.text,
      password: passwordController.text,
      username: nameController.text,
      phone: phoneController.text,
      place: placeController.text,
      profileImage: selectedImage.path.isEmpty ? null : selectedImage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authController.error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create account",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Gap(20),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    const SizedBox(
                      width: 120,
                      height: 120,
                    ),
                    Positioned(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: selectedImage == File('') ||
                                selectedImage.path == ""
                            ? const NetworkImage(
                                "https://i.pinimg.com/736x/1b/2e/31/1b2e314e767a957a44ed8f992c6d9098.jpg",
                              )
                            : FileImage(selectedImage),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: IconButton(
                        onPressed: () async {
                          var val = await RegisterServices().pickImage(context);
                          setState(() {
                            selectedImage = val;
                          });
                        },
                        icon: Card(
                          child: Icon(
                            Icons.add_circle,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              CustomTextformField(
                controller: nameController,
                fieldText: "Username",
              ),
              const Gap(10),
              CustomTextformField(
                controller: emailController,
                fieldText: "Email address",
              ),
              const Gap(20),
              CustomTextformField(
                controller: passwordController,
                fieldText: "Password",
              ),
              const Gap(20),
              CustomTextformField(
                controller: phoneController,
                prefixText: "+91",
                fieldText: "Phone",
              ),
              const Gap(20),
              CustomTextformField(
                controller: placeController,
                fieldText: "Place",
              ),
              const Gap(20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomButton(
                  onPressed: _handleRegister,
                  btnText: "Register",
                ),
              ),
              const Gap(20),
              const Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                      child: Divider(
                    endIndent: 20,
                    indent: 80,
                  )),
                  Text(" OR "),
                  Expanded(
                      child: Divider(
                    endIndent: 80,
                    indent: 20,
                  )),
                ],
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: SignInButton(
                  Buttons.google,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  onPressed: () {},
                ),
              ),
              const Gap(20),
              Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                direction: Axis.horizontal,
                children: [
                  Text(
                    "Already have an account?",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ));
                    },
                    child: const Text("Login"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
