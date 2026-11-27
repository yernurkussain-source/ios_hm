import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';
import '../theme/app_theme.dart';
import 'root_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [name, email, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().register(
      name.text,
      email.text,
      password.text,
      confirm.text,
    );
  }

  Widget field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool secret = false,
    bool enabled = true,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: secret,
        keyboardType: keyboard,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: BlocConsumer<AuthCubit, AuthState>(
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
            // Drop register + login screens: Back must not return to them.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const RootScreen(initialTab: RootScreen.catalogTab),
              ),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                'Your account is saved on this device (SQLite).',
                style: TextStyle(color: context.palette.muted),
              ),
              const SizedBox(height: 20),
              field(name, 'Name', Icons.person_outline, enabled: !loading),
              field(
                email,
                'Email',
                Icons.mail_outline,
                enabled: !loading,
                keyboard: TextInputType.emailAddress,
              ),
              field(
                password,
                'Password (min 6)',
                Icons.lock_outline,
                secret: true,
                enabled: !loading,
              ),
              field(
                confirm,
                'Repeat password',
                Icons.lock_reset,
                secret: true,
                enabled: !loading,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        onPressed: submit,
                        child: const Text('Sign up'),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
