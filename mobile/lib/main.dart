
import 'package:flutter/material.dart';

void main() {
  runApp(const UniversalInventoryApp());
}

class UniversalInventoryApp extends StatelessWidget {
  const UniversalInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080B12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D8DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        28, 24, 28, 30,
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
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5798FF),
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
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
