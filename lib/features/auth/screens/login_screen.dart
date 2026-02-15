import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import 'registration_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo / Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [AppColors.tealGlow],
                          color: AppColors.surface,
                        ),
                        child: const Icon(
                          Icons.track_changes,
                          size: 64,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Securely access your tasks and goals',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 48),
                      
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.teal),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline, color: AppColors.teal),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading 
                                  ? null 
                                  : () => authProvider.login(
                                      _emailController.text, 
                                      _passwordController.text
                                    ),
                                child: authProvider.isLoading
                                  ? const CircularProgressIndicator(color: AppColors.background)
                                  : const Text('LOGIN', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary),
                            children: [
                              TextSpan(text: 'Sign Up', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
