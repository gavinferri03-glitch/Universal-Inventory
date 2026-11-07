
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_data.dart';
import 'app_settings.dart';
import 'dashboard_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    const ProviderScope(
      child: UniversalInventoryApp(),
    ),
  );
}

// MAIN APPLICATION

class UniversalInventoryApp extends ConsumerWidget {
  const UniversalInventoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    if (!settings.isLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF080B12),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5798FF),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Universal Inventory',
      debugShowCheckedModeBanner: false,

      // APP LANGUAGE
      locale: settings.locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // APP THEME
      themeMode: settings.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D8DFF),
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080B12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D8DFF),
          brightness: Brightness.dark,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}

// SPLASH SCREEN

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -150,
            right: -130,
            child: _GlowOrb(
              size: 340,
              color: Color(0x334D8DFF),
            ),
          ),
          const Positioned(
            bottom: -180,
            left: -150,
            child: _GlowOrb(
              size: 360,
              color: Color(0x221E5B9A),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        28,
                        24,
                        28,
                        30,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF68A5FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'SMART INVENTORY PLATFORM',
                                style: TextStyle(
                                  color: Color(0xFF9BA9BD),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 54),
                          Column(
                            children: [
                              Container(
                                width: 250,
                                height: 250,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111824),
                                  borderRadius:
                                      BorderRadius.circular(36),
                                  border: Border.all(
                                    color: const Color(0xFF9ABEFF)
                                        .withValues(alpha: 0.18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF397DDB)
                                          .withValues(alpha: 0.13),
                                      blurRadius: 45,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'file_000000002550820b98dbddbb87b2bb92.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 38),
                              const Text(
                                'UNIVERSAL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFF5F7FB),
                                  fontSize: 31,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'INVENTORY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF79AFFF),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 7,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 46,
                                height: 2,
                                color: const Color(0xFF5798FF),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Everything in its place.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFB3BECE),
                                  fontSize: 15,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 54),
                          Column(
                            children: [
                              const Text(
                                'STOCK  •  OPERATIONS  •  CONTROL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'A clearer view of your business.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF718096)
                                      .withValues(alpha: 0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// LOGIN SCREEN

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -140,
            right: -130,
            child: _GlowOrb(
              size: 340,
              color: Color(0x334D8DFF),
            ),
          ),
          const Positioned(
            bottom: -180,
            left: -150,
            child: _GlowOrb(
              size: 360,
              color: Color(0x221E5B9A),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // LOGO AND BRAND

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14243B),
                              borderRadius:
                                  BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFF344C70),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF397DDB)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'file_000000002550820b98dbddbb87b2bb92.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'UNIVERSAL',
                            style: TextStyle(
                              color: Color(0xFFF5F7FB),
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'INVENTORY',
                            style: TextStyle(
                              color: Color(0xFF79AFFF),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Everything in its place.',
                            style: TextStyle(
                              color: Color(0xFF91A4BE),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // WELCOME

                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Color(0xFFF5F7FB),
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue to your workspace.',
                      style: TextStyle(
                        color: Color(0xFF9AAAC0),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // EMAIL FIELD

                    const Text(
                      'Email or Username',
                      style: TextStyle(
                        color: Color(0xFFC8D5E7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email or username',
                        hintStyle: const TextStyle(
                          color: Color(0xFF71849E),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF829BB9),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF121D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF344761),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF344761),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF5798FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // PASSWORD FIELD

                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFFC8D5E7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF71849E),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF829BB9),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF829BB9),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF121D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF344761),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF344761),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF5798FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // REMEMBER AND FORGOT PASSWORD

                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          activeColor: const Color(0xFF347FE2),
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: Color(0xFFA8B8CD),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            showMessage(
                              'Password recovery will be available soon.',
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF78AEFF),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SIGN IN BUTTON

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (emailController.text.trim().isEmpty ||
                              passwordController.text.isEmpty) {
                            showMessage(
                              'Please enter your email and password.',
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DashboardScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF347FE2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'SIGN IN  →',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CREATE ACCOUNT

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'New to Universal Inventory? ',
                            style: TextStyle(
                              color: Color(0xFFA1B0C4),
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showMessage(
                                'Account registration will be available soon.',
                              );
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Color(0xFF78AEFF),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    const Center(
                      child: Text(
                        'SECURE ACCESS  •  YOUR BUSINESS  •  YOUR CONTROL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF71849E),
                          fontSize: 9,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BACKGROUND GLOW

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}
