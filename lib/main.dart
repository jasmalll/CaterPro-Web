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
  await Hive.initFlutter();
  await Hive.openBox('works_box');
  await Hive.openBox('expenses_box');
  await Hive.openBox('settings_box');
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CateringProvider()..loadDataFromStorage()),
      ChangeNotifierProvider(create: (_) => CaterProThemeController()..load()),
    ],
    child: const CaterProApp(),
  ));
}

class CaterProApp extends StatelessWidget {
  const CaterProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaterProThemeController>(
      builder: (context, controller, _) => MaterialApp(
        title: 'CaterPro',
        debugShowCheckedModeBanner: false,
        themeMode: controller.themeMode,
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
      surface: dark ? const Color(0xFF151D24) : Colors.white,
    );
    final border = dark ? const Color(0xFF2B3741) : const Color(0xFFE7ECF0);
    final surface = dark ? const Color(0xFF151D24) : Colors.white;
    final background = dark ? const Color(0xFF0D141A) : const Color(0xFFF7F9FB);
    final foreground = dark ? const Color(0xFFF2F6F8) : const Color(0xFF17232D);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme.copyWith(primary: green, secondary: const Color(0xFFD99A35)),
      primaryColor: green,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      fontFamily: 'Inter',
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
        fontFamily: 'Inter',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: foreground, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1B2630) : const Color(0xFFF7F9FB),
        hintStyle: TextStyle(color: dark ? const Color(0xFF8C9AA5) : const Color(0xFF87939D), fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: green, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: green, foregroundColor: Colors.white, elevation: 3),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: dark ? const Color(0xFF214A3A) : const Color(0xFFE1F4EA),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? green : (dark ? const Color(0xFF9CAAB4) : const Color(0xFF7B8790)),
        )),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      )),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note_rounded), label: 'Works'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
        ],
      ),
    );
  }
}
