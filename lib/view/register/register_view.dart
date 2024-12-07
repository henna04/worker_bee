import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset("assets/images/login_image.png"),
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
              controller: emailController,
              fieldText: "Password",
            ),
           
            
            const Gap(20),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: CustomButton(
                onPressed: () {},
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
                  onPressed: () {},
                  child: const Text("Register"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
 