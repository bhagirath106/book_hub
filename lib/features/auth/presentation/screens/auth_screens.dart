import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/bookhub_theme.dart';

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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Welcome back',
    subtitle: 'Your next chapter is waiting.',
    child: Column(
      children: [
        const TextField(decoration: InputDecoration(labelText: 'Email')),
        const SizedBox(height: 14),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
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
            onPressed: () => context.go('/'),
            child: const Text('Log in'),
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

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Create your world',
    subtitle: 'Join readers discovering more together.',
    child: Column(
      children: [
        const TextField(decoration: InputDecoration(labelText: 'Display name')),
        const SizedBox(height: 14),
        const TextField(decoration: InputDecoration(labelText: 'Email')),
        const SizedBox(height: 14),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.go('/'),
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
