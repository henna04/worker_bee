import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';
import 'package:worker_bee/view/customNavigation/custom_navigation_view.dart';
import 'package:worker_bee/view/register/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (response.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CustomNavigationView(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
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
            children: [
              Image.asset("assets/images/login_bg.png"),
              const Gap(20),
              Text(
                "Welcome back!",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forget Password?",
                  ),
                ),
              ),
              const Gap(20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomButton(
                  onPressed: _login,
                  btnText: "Login",
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
                    "Don't have an account?",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterView(),
                          ));
                    },
                    child: const Text("Register"),
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
