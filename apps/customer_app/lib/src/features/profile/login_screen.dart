import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../customer/customer_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Aarav Sharma');
  final _email = TextEditingController(text: 'aarav@example.com');
  final _password = TextEditingController(text: 'bazaaro123');
  final _phone = TextEditingController(text: '+91 98765 43210');
  final _address = TextEditingController(
    text: '221B Demo Street, Bengaluru, Karnataka 560001',
  );

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login to Bazaaro')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                BazaaroBrand.tagline,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use any email and password for this dummy demo. Details are required before checkout.',
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _Field(
                      controller: _name,
                      label: 'Full name',
                      icon: Icons.person_outline,
                    ),
                    _Field(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      email: true,
                    ),
                    _Field(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      password: true,
                    ),
                    _Field(
                      controller: _phone,
                      label: 'Phone',
                      icon: Icons.call_outlined,
                    ),
                    _Field(
                      controller: _address,
                      label: 'Delivery address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          ref
                              .read(customerSessionProvider.notifier)
                              .login(
                                name: _name.text.trim(),
                                email: _email.text.trim(),
                                phone: _phone.text.trim(),
                                address: _address.text.trim(),
                              );
                          context.go('/checkout');
                        },
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Continue to checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.email = false,
    this.password = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool email;
  final bool password;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: password,
        maxLines: password ? 1 : maxLines,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return '$label is required';
          if (email && !text.contains('@')) return 'Enter a valid email';
          if (password && text.length < 6) return 'Use at least 6 characters';
          return null;
        },
      ),
    );
  }
}
