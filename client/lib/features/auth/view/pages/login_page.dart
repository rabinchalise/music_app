import 'package:client/core/theme/app_color.dart';

import 'package:client/core/utils/extension.dart';
import 'package:client/core/widgets/custom_textfields.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';

import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/obsecure_password_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (_) => false,
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
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Sign In.',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    30.verticalSpacer,
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
                      buttonText: 'Sign in',
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(authViewModelProvider.notifier)
                              .loginUser(
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
                        text: 'Don\'t have an account? ',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(const SignupPage());
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
