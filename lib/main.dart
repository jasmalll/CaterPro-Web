import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/catering_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_dashboard_page.dart';
import 'screens/works_page.dart';
import 'screens/expenses_page.dart';
import 'screens/summary_page.dart';
import 'screens/calendar_page.dart';
import 'theme/caterpro_theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Hive ഡാറ്റാബേസ് ആരംഭിക്കുന്നു
  await Hive.initFlutter();
  await Hive.openBox('works_box');
  await Hive.openBox('expenses_box');
  await Hive.openBox('settings_box');

  // 2. നോട്ടിഫിക്കേഷൻ സർവീസ് സുരക്ഷിതമായി ആരംഭിക്കുന്നു
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CateringProvider()..loadDataFromStorage()),
        ChangeNotifierProvider(create: (_) => CaterProThemeController()..load()),
      ],
      child: const CaterProApp(),
    ),
  );
}

class CaterProApp extends StatelessWidget {
  const CaterProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CaterProThemeController>(
      builder: (context, themeController, _) => MaterialApp(
        title: 'CaterPro',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const MainNavigationScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    const green = Color(0xFF16865B);
    final scheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: brightness,
      surface: dark ? const Color(0xFF171B20) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: green,
      scaffoldBackgroundColor: dark ? const Color(0xFF0D1117) : const Color(0xFFF5F7FA),
      cardColor: dark ? const Color(0xFF171B20) : Colors.white,
      dividerColor: dark ? const Color(0xFF30363D) : const Color(0xFFE5E9EF),
      fontFamily: 'sans-serif',
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF0D1117) : const Color(0xFFF5F7FA),
        foregroundColor: dark ? const Color(0xFFF0F3F6) : const Color(0xFF17202A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF171B20) : Colors.white,
        elevation: dark ? 0 : 1,
        shadowColor: Colors.black.withOpacity(dark ? 0.0 : 0.04),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: dark ? const Color(0xFF30363D) : const Color(0xFFE8ECF1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF20262D) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: dark ? const Color(0xFF39414A) : const Color(0xFFE1E7EE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: dark ? const Color(0xFF30363D) : const Color(0xFFE1E7EE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: green, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: green, foregroundColor: Colors.white),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF171B20) : Colors.white,
        indicatorColor: dark ? const Color(0xFF204C3B) : const Color(0xFFE3F4EC),
        labelTextStyle: MaterialStateProperty.resolveWith((states) => TextStyle(fontSize: 11, fontWeight: states.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }

}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeDashboardPage(),
    WorksPage(),
    ExpensesPage(),
    SummaryPage(),
    CalendarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline_rounded), selectedIcon: Icon(Icons.work_rounded), label: 'Works'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Summary'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
        ],
      ),
    );
  }
}
