// lib/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lekkerly/main.dart';
import 'package:lekkerly/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: const [
              OnboardingPage(
                icon: Icons.school_outlined,
                title: 'Welcome to Lekkerly!',
                subtitle:
                    'Your fun and modern partner for learning the Dutch language.',
              ),
              OnboardingPage(
                icon: Icons.checklist_rtl_outlined,
                title: 'Learn Your Way',
                subtitle:
                    'Master vocabulary with flashcards, multiple-choice quizzes, and typing tests.',
              ),
              OnboardingPage(
                icon: Icons.palette_outlined,
                title: 'Choose Your Look',
                subtitle:
                    'Select your preferred theme to get started. You can always change it later in settings.',
                isLastPage: true,
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    dotHeight: 12,
                    dotWidth: 12,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLastPage;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 64),
          if (isLastPage)
            Column(
              children: [
                ToggleButtons(
                  isSelected: [
                    themeProvider.themeMode == ThemeMode.light,
                    themeProvider.themeMode == ThemeMode.dark,
                  ],
                  onPressed: (index) {
                    final mode = index == 0 ? ThemeMode.light : ThemeMode.dark;
                    themeProvider.setThemeMode(mode);
                  },
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: themeProvider.themeMode == ThemeMode.light
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimary,
                  color: Theme.of(context).colorScheme.primary,
                  fillColor: Theme.of(context).colorScheme.primary,
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(children: [
                          Icon(Icons.light_mode),
                          SizedBox(width: 8),
                          Text('Light')
                        ])),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(children: [
                          Icon(Icons.dark_mode),
                          SizedBox(width: 8),
                          Text('Dark')
                        ])),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboarding_complete', true);

                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const CategoryListScreen()),
                      );
                    }
                  },
                  child: const Text('Get Started'),
                ),
              ],
            )
        ],
      ),
    );
  }
}
