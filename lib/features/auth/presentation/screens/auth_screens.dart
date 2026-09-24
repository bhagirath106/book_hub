import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/bookhub_theme.dart';
import '../providers/auth_provider.dart';

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 36),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: BookHubColors.violet,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 28),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 32),
          child,
        ],
      ),
    ),
  );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final success = await ref
        .read(authNotifierProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      context.go('/');
    } else {
      setState(() {
        _errorMessage = 'Invalid email/username or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Welcome back',
    subtitle: 'Your next chapter is waiting.',
    child: Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email or Username'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/auth/forgot-password'),
            child: const Text('Forgot password?'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Log in'),
          ),
        ),
        TextButton(
          onPressed: () => context.push('/auth/register'),
          child: const Text('Create an account'),
        ),
      ],
    ),
  );
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final success = await ref
        .read(authNotifierProvider.notifier)
        .login(_emailController.text, _passwordController.text);
    if (mounted && success) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Create your world',
    subtitle: 'Join readers discovering more together.',
    child: Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _handleRegister,
            child: const Text('Create account'),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Already have an account? Log in'),
        ),
      ],
    ),
  );
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Reset password',
    subtitle: 'We will send a secure reset link to your email.',
    child: Column(
      children: [
        const TextField(decoration: InputDecoration(labelText: 'Email')),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Send reset link'),
          ),
        ),
      ],
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BookHubColors.darkCanvas,
    body: Center(
      child: Image.asset(
        'assets/branding/bookhub_logo.png',
        width: 280,
        semanticLabel: 'BookHub',
      ),
    ),
  );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories,
              size: 100,
              color: BookHubColors.violet,
            ),
            const SizedBox(height: 32),
            Text(
              'Pick your worlds',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Discover books, meet readers, and make every chapter yours.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Start exploring'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
