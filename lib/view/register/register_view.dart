import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';
import 'package:worker_bee/view/customNavigation/custom_navigation_view.dart';
import 'package:worker_bee/view/login/login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final placeController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      // Handle the case where the user cancels the image picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Register the user
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        // Upload image to Supabase Storage
        if (_image != null) {
          final fileExtension = _image!.path.split('.').last;
          final fileName = '${response.user!.id}.$fileExtension';
          final filePath = 'user_images/$fileName';

          await Supabase.instance.client.storage
              .from('user_images')
              .upload(filePath, _image!);

          // Get the public URL of the uploaded image
          final imageUrl = Supabase.instance.client.storage
              .from('user_images')
              .getPublicUrl(filePath);

          // Insert user details into the profiles table
          await Supabase.instance.client.from('users').upsert({
            'id': response.user!.id,
            'user_name': nameController.text,
            'email': emailController.text,
            'phone_no': phoneController.text,
            'place': placeController.text,
            'image_url': imageUrl,
          });
        } else {
          // Insert user details without an image
          await Supabase.instance.client.from('users').upsert({
            'id': response.user!.id,
            'user_name': nameController.text,
            'email': emailController.text,
            'phone_no': phoneController.text,
            'place': placeController.text,
          });
        }

        // Navigate to the home screen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomNavigationView(),
            ));
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
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
                        backgroundImage: _image != null &&
                                _image!.path.isNotEmpty
                            ? FileImage(_image!)
                            : const NetworkImage(
                                "https://i.pinimg.com/736x/1b/2e/31/1b2e314e767a957a44ed8f992c6d9098.jpg"),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: IconButton(
                        onPressed: _pickImage,
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
                controller: confirmPasswordController,
                fieldText: "Confirm password",
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
                  onPressed: _register,
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
