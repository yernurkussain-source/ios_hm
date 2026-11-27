import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import 'root_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(email.text, password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          // Only while this screen is on top (not under Register).
          listenWhen: (_, _) => ModalRoute.of(context)?.isCurrent ?? true,
          // One-time side effects only: SnackBar and navigation.
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar();
            if (state is AuthError) {
              messenger.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  content: Text(state.message),
                ),
              );
            } else if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const RootScreen(initialTab: RootScreen.catalogTab),
                ),
              );
            }
          },
          // Widgets only.
          builder: (context, state) {
            final loading = state is AuthLoading;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome to MoodCart',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue shopping.',
                        style: TextStyle(color: context.palette.muted),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: email,
                        enabled: !loading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: password,
                        enabled: !loading,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => submit(),
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: submit,
                                child: const Text('Log in'),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Demo: ${AuthCubit.demoEmail} / '
                        '${AuthCubit.demoPassword}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.palette.muted),
                      ),
                      if (context.read<AuthCubit>().canRegister)
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                          child: const Text('No account? Create one'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
