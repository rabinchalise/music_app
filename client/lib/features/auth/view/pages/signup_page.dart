import 'package:client/core/providers/obsecure_password_provider.dart';
import 'package:client/core/theme/app_color.dart';
import 'package:client/core/utils/extension.dart';
import 'package:client/core/widgets/custom_textfields.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(authViewModelProvider.select((val) => val?.isLoading == true));
    final isObsecure = ref.watch(obsecurePasswordProvider);
    ref.listen(
      authViewModelProvider,
      (_, next) {
        next?.when(
          data: (data) {
            context.showSnackBar(
              message: 'Account created successfully! Please  login.',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          error: (error, st) {
            context.showSnackBar(message: error.toString());
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up.',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    30.verticalSpacer,
                    CustomTextfields(
                      hintText: 'Name',
                      controller: _nameController,
                    ),
                    15.verticalSpacer,
                    CustomTextfields(
                      hintText: 'Email',
                      controller: _emailController,
                    ),
                    15.verticalSpacer,
                    CustomTextfields(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: isObsecure,
                      suffix: GestureDetector(
                        onTap:
                            ref.read(obsecurePasswordProvider.notifier).toggle,
                        child: isObsecure == true
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                    ),
                    20.verticalSpacer,
                    AuthGradientButton(
                      buttonText: 'Sign up',
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          await ref
                              .read(authViewModelProvider.notifier)
                              .signUpUser(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                        } else {
                          context.showSnackBar(message: 'Missing fields!');
                        }
                      },
                    ),
                    20.verticalSpacer,
                    RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(const LoginPage());
                              },
                            style: const TextStyle(
                              color: AppColor.gradient2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
