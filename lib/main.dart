// lib/main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lekkerly/category_detail_screen.dart';
import 'package:lekkerly/my_sets_screen.dart';
import 'package:lekkerly/services/user_content_service.dart';
import 'package:lekkerly/app_theme.dart';
import 'package:lekkerly/theme_provider.dart';
import 'package:lekkerly/onboarding_screen.dart';
import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/achievements_screen.dart';
import 'package:lekkerly/settings_screen.dart'; // Import settings screen
import 'package:lekkerly/services/favorites_service.dart';
import 'package:lekkerly/services/progress_service.dart';
import 'package:lekkerly/search_screen.dart';

// The main entry point of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: LekkerlyApp(onboardingComplete: onboardingComplete),
    ),
  );
}

class LekkerlyApp extends StatelessWidget {
  final bool onboardingComplete;

  const LekkerlyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lekkerly',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: onboardingComplete
          ? const CategoryListScreen()
          : const OnboardingScreen(),
    );
  }
}

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final ProgressService _progressService = ProgressService();
  final UserContentService _userContentService = UserContentService();

  List<Category> _displayCategories = [];
  List<VocabularyItem> _allItems = [];
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _progressService.getStreak(),
      rootBundle.loadString('assets/vocabulary.json'),
      _userContentService.loadUserCategories(),
      _favoritesService.getFavoriteIds(),
    ]);

    final streak = results[0] as int;
    final jsonString = results[1] as String;
    final userCategories = results[2] as List<Category>;
    final favoriteIds = results[3] as List<int>;

    final Map<String, dynamic> data = json.decode(jsonString);
    final List<Category> builtInCategories = data.entries.map((entry) {
      return Category.fromJson(entry.key, entry.value);
    }).toList();
    builtInCategories.sort((a, b) => a.name.compareTo(b.name));

    _allItems = [
      ...builtInCategories.expand((c) => c.items),
      ...userCategories.expand((c) => c.items)
    ];

    List<Category> newDisplayCategories = [];

    if (favoriteIds.isNotEmpty) {
      final favoriteItems =
          _allItems.where((item) => favoriteIds.contains(item.id)).toList();
      if (favoriteItems.isNotEmpty) {
        newDisplayCategories
            .add(Category(name: "Favorites", items: favoriteItems));
      }
    }

    newDisplayCategories.addAll(userCategories);
    newDisplayCategories.addAll(builtInCategories);

    setState(() {
      _displayCategories = newDisplayCategories;
      _currentStreak = streak;
      _isLoading = false;
    });
  }

  IconData _getIconForCategory(String categoryName,
      {bool isUserCategory = false}) {
    if (isUserCategory) return Icons.edit_note_outlined;
    switch (categoryName.toLowerCase()) {
      case 'greetings':
        return Icons.waving_hand_outlined;
      case 'food':
        return Icons.restaurant_menu_outlined;
      case 'travel':
        return Icons.flight_takeoff_outlined;
      case 'daily life':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      case 'emotions':
        return Icons.sentiment_satisfied_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      case 'time':
        return Icons.access_time_rounded;
      case 'favorites':
        return Icons.star_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  void _navigateToDetail(Category category, {bool isUserCategory = false}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              category: category,
              icon: _getIconForCategory(category.name,
                  isUserCategory: isUserCategory),
            ),
          ),
        )
        .then((_) => _loadData());
  }

  void _navigateToSearch() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
              builder: (context) => SearchScreen(allItems: _allItems)),
        )
        .then((_) => _loadData());
  }

  void _navigateToAchievements() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => const AchievementsScreen()),
        )
        .then((_) => _loadData());
  }

  void _navigateToMySets() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => const MySetsScreen()),
        )
        .then((_) => _loadData());
  }

  // NEW: Navigation for Settings Screen
  void _navigateToSettings() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        )
        .then((_) =>
            _loadData()); // Reload data in case the user resets something
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToMySets,
        label: const Text('My Sets'),
        icon: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120.0,
                    floating: true,
                    pinned: true,
                    snap: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text('Lekkerly',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                      centerTitle: true,
                    ),
                    actions: [
                      if (_currentStreak > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(children: [
                            Text('$_currentStreak',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 2),
                            Icon(Icons.local_fire_department_rounded,
                                color: Colors.deepOrange.shade400),
                          ]),
                        ),
                      IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _navigateToSearch,
                          tooltip: 'Search'),
                      IconButton(
                          icon: const Icon(Icons.emoji_events_outlined),
                          onPressed: _navigateToAchievements,
                          tooltip: 'Achievements'),
                      IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: _navigateToSettings,
                          tooltip: 'Settings'), // NEW: Settings Button
                    ],
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text("Let's get learning!",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(12.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = _displayCategories[index];
                          final bool isUserCategory =
                              category.name != 'Favorites' &&
                                  !DefaultCategories.list
                                      .contains(category.name.toLowerCase());
                          final icon = _getIconForCategory(category.name,
                              isUserCategory: isUserCategory);
                          return CategoryCard(
                            category: category,
                            icon: icon,
                            isUserCategory: isUserCategory,
                            onTap: () => _navigateToDetail(category,
                                isUserCategory: isUserCategory),
                          );
                        },
                        childCount: _displayCategories.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final IconData icon;
  final VoidCallback onTap;
  final bool isUserCategory;

  const CategoryCard({
    super.key,
    required this.category,
    required this.icon,
    required this.onTap,
    this.isUserCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = category.name == 'Favorites';
    Color primaryColor = isFavorite
        ? Colors.amber.shade700
        : Theme.of(context).colorScheme.primary;
    Color backgroundColor =
        isFavorite ? Colors.amber.shade100 : primaryColor.withOpacity(0.1);

    if (isUserCategory) {
      primaryColor = Colors.green.shade700;
      backgroundColor = Colors.green.shade100;
    }

    return Card(
      elevation: 2.0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: primaryColor),
              const Spacer(),
              Text(
                category.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${category.items.length} words',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DefaultCategories {
  static final List<String> list = [
    'greetings',
    'food',
    'travel',
    'daily life',
    'work',
    'emotions',
    'shopping',
    'health',
    'time'
  ];
}
