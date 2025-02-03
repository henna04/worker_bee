import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/repo/auth_repository.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';
import 'package:worker_bee/view/register/register_view.dart';
import 'package:worker_bee/viewmodel/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      AuthRepository(Supabase.instance.client),
    );
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await _authController.signInWithEmail(
      emailController.text,
      passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authController.error ?? 'Login failed')),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _authController.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_authController.error ?? 'Google sign in failed')),
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
                  onPressed: _handleLogin,
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
                  onPressed: _handleGoogleSignIn,
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
