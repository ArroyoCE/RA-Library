import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true; // Default to true for remember me checkbox

  @override
  void dispose() {
    _usernameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  // Navigate to register screen using url_launcher
  Future<void> _navigateToRegister() async {
    final url = Uri.parse('https://retroachievements.org/createaccount.php');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  // Handle login
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Get username and API key
      final username = _usernameController.text.trim();
      final apiKey = _apiKeyController.text.trim();

      // Attempt login using provider
      await ref
          .read(authStateProvider.notifier)
          .login(username, apiKey, _rememberMe);

      // Check if login was successful
      if (mounted) {
        final userState = ref.read(authStateProvider);

        if (userState.isAuthenticated) {
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.loginSuccessful),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to home screen
          context.go('/');
        } else if (userState.errorMessage != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userState.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the user state to react to changes
    final userState = ref.watch(authStateProvider);

    // Populate username field if available
    if (userState.username != null && _usernameController.text.isEmpty) {
      _usernameController.text = userState.username!;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const RAAppBar(title: AppStrings.appName),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/ra-icon.png',
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'LIBRARY',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Username field
                  RATextField(
                    controller: _usernameController,
                    labelText: AppStrings.username,
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // API Key field
                  RATextField(
                    controller: _apiKeyController,
                    labelText: AppStrings.apiKey,
                    obscureText: true,
                    prefixIcon: Icons.vpn_key,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your API key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Remember me checkbox and forgot password link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.primary;
                              }
                              return Colors.grey;
                            }),
                            checkColor: AppColors.darkBackground,
                          ),
                          const Text(
                            AppStrings.rememberMe,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  RAPrimaryButton(
                    text: AppStrings.login,
                    onPressed: _handleLogin,
                    isLoading: userState.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.dontHaveAccount,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text(
                          AppStrings.register,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Updated disclaimer text
                  const Text(
                    AppStrings.apiKeyDisclaimer,
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
