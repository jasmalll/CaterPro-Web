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
    const green = Color(0xFF147D59);
    const navy = Color(0xFF142A3A);
    final scheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: brightness,
      surface: dark ? const Color(0xFF151F28) : const Color(0xFFFFFFFF),
    );
    final border = dark ? const Color(0xFF2B3944) : const Color(0xFFE5EAF0);
    final surface = dark ? const Color(0xFF151D24) : Colors.white;
    final background = dark ? const Color(0xFF0B1218) : const Color(0xFFF4F7F8);
    final foreground = dark ? const Color(0xFFF2F6F8) : const Color(0xFF17232D);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme.copyWith(primary: green, secondary: const Color(0xFFE3A642), surface: surface),
      primaryColor: green,
      splashFactory: InkSparkle.splashFactory,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.standard,
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
        elevation: dark ? 0 : 1,
        shadowColor: Colors.black.withOpacity(dark ? 0.0 : 0.04),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    const destinations = <({IconData icon, IconData selected, String label})>[
      (icon: Icons.grid_view_rounded, selected: Icons.grid_view_rounded, label: 'Home'),
      (icon: Icons.event_note_outlined, selected: Icons.event_note_rounded, label: 'Works'),
      (icon: Icons.receipt_long_outlined, selected: Icons.receipt_long_rounded, label: 'Expenses'),
      (icon: Icons.query_stats_outlined, selected: Icons.query_stats_rounded, label: 'Reports'),
      (icon: Icons.calendar_month_outlined, selected: Icons.calendar_month_rounded, label: 'Calendar'),
    ];
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: theme.dividerColor.withOpacity(.85)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? .16 : .07), blurRadius: 28, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: List.generate(destinations.length, (index) {
              final item = destinations[index];
              final selected = index == _currentIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? theme.colorScheme.primary.withOpacity(dark ? .22 : .10) : Colors.transparent,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedScale(scale: selected ? 1.08 : 1, duration: const Duration(milliseconds: 220), child: Icon(selected ? item.selected : item.icon, size: 21, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(item.label, maxLines: 1, style: TextStyle(fontSize: 10, letterSpacing: -.1, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
                      ]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
