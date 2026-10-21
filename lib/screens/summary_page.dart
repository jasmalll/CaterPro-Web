import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../services/pdf_service.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month, 1);
  }

  String get monthLabel {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }

  String money(double value) => '₹${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final monthlyWorks = provider.works.where((w) => w.date.year == selectedMonth.year && w.date.month == selectedMonth.month).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthlyExpenses = provider.expenses.where((e) => e.date.year == selectedMonth.year && e.date.month == selectedMonth.month).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final totalIncome = monthlyWorks.fold<double>(0, (sum, w) => sum + w.amount);
    final totalReceived = monthlyWorks.fold<double>(0, (sum, w) => sum + (w.amount - w.balance));
    final totalPending = monthlyWorks.fold<double>(0, (sum, w) => sum + w.balance);
    final totalExpenses = monthlyExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netSavings = totalReceived - totalExpenses;
    final progress = totalIncome > 0 ? (totalReceived / totalIncome).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Financial reports'),
          SizedBox(height: 2),
          Text('Track income, collections and expenses', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: theme.dividerColor)),
              child: Row(children: [
                IconButton(tooltip: 'Previous month', onPressed: () => setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1)), icon: const Icon(Icons.chevron_left_rounded)),
                Expanded(child: Column(children: [Text(monthLabel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), Text('${monthlyWorks.length} works · ${monthlyExpenses.length} expenses', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant))])),
                IconButton(tooltip: 'Next month', onPressed: () => setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1)), icon: const Icon(Icons.chevron_right_rounded)),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF12382D), const Color(0xFF176A4A)]),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CASH IN HAND', style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(money(netSavings), style: const TextStyle(color: Colors.white, fontSize: 34, letterSpacing: -1, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Received collections minus recorded expenses', style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 12)),
                const SizedBox(height: 20),
                Container(height: 1, color: Colors.white.withOpacity(.18)),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(child: _HeroValue(label: 'Received', value: money(totalReceived), icon: Icons.south_west_rounded, tint: const Color(0xFF83E0B4))),
                  const SizedBox(width: 10),
                  Expanded(child: _HeroValue(label: 'Pending', value: money(totalPending), icon: Icons.schedule_rounded, tint: const Color(0xFFFFD18A))),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
            Text('Monthly overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.3)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.48,
              children: [
                _MetricCard(title: 'Total income', value: money(totalIncome), icon: Icons.account_balance_wallet_rounded, tint: const Color(0xFF16865B)),
                _MetricCard(title: 'Expenses', value: money(totalExpenses), icon: Icons.receipt_long_rounded, tint: const Color(0xFFD65D52)),
                _MetricCard(title: 'Cash in hand', value: money(netSavings), icon: Icons.savings_rounded, tint: netSavings >= 0 ? const Color(0xFF16865B) : const Color(0xFFD65D52)),
                _MetricCard(title: 'Booked works', value: '${monthlyWorks.length}', icon: Icons.event_available_rounded, tint: const Color(0xFF5579D6)),
              ],
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'Collection progress', subtitle: totalIncome > 0 ? '${(progress * 100).round()}% of income collected' : 'No income recorded this month'),
            const SizedBox(height: 12),
            _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: theme.dividerColor, valueColor: const AlwaysStoppedAnimation(Color(0xFF16865B)))),
              const SizedBox(height: 15),
              Row(children: [Expanded(child: _Legend(label: 'Received', amount: money(totalReceived), color: const Color(0xFF16865B))), const SizedBox(width: 10), Expanded(child: _Legend(label: 'Pending', amount: money(totalPending), color: const Color(0xFFD99A35)))]),
            ])),
            const SizedBox(height: 22),
            SizedBox(height: 52, child: ElevatedButton.icon(
              onPressed: () => PdfService.exportMonthlyReport(monthLabel: monthLabel, totalIncome: totalIncome, totalExpenses: totalExpenses, netSavings: netSavings, works: monthlyWorks, expenses: monthlyExpenses),
              icon: const Icon(Icons.picture_as_pdf_rounded), label: Text('Export $monthLabel PDF report'),
            )),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Works this month', subtitle: '${monthlyWorks.length} bookings · ${money(totalIncome)} total value'),
            const SizedBox(height: 12),
            if (monthlyWorks.isEmpty)
              const _EmptyPanel(icon: Icons.event_busy_rounded, title: 'No works this month', message: 'Bookings for this month will appear here.')
            else ...monthlyWorks.map((work) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: colors.primary.withOpacity(.09), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.event_note_rounded, color: colors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(work.venue, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${work.dateText} · ${work.eventType}', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)), const SizedBox(height: 5), Text('Balance ${money(work.balance)}', style: theme.textTheme.labelSmall?.copyWith(color: work.balance > 0 ? const Color(0xFFB7791F) : const Color(0xFF16865B), fontWeight: FontWeight.w700))])),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(money(work.amount), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 5), _StatusPill(label: work.status, paid: work.isPaid)]),
              ])),
            )),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Expenses this month', subtitle: '${monthlyExpenses.length} records · ${money(totalExpenses)} total'),
            const SizedBox(height: 12),
            if (monthlyExpenses.isEmpty)
              const _EmptyPanel(icon: Icons.receipt_long_rounded, title: 'No expenses this month', message: 'Recorded expenses will appear here.')
            else ...monthlyExpenses.map((expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(child: Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFD65D52).withOpacity(.10), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFD65D52))),
                const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${expense.date.day}/${expense.date.month}/${expense.date.year} · ${expense.category}', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant))])),
                const SizedBox(width: 8), Text('-${money(expense.amount)}', style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFFD65D52), fontWeight: FontWeight.w900)),
              ])),
            )),
          ],
        ),
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  const _HeroValue({required this.label, required this.value, required this.icon, required this.tint});
  final String label, value; final IconData icon; final Color tint;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: tint.withOpacity(.15), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: tint, size: 17)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.white.withOpacity(.68), fontSize: 11)), const SizedBox(height: 3), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))]))]);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon, required this.tint});
  final String title, value; final IconData icon; final Color tint;
  @override
  Widget build(BuildContext context) { final theme = Theme.of(context); return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: tint.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: tint, size: 19)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)), const SizedBox(height: 5), FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.5)))])], mainAxisSize: MainAxisSize.max)); }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child}); final Widget child;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor)), child: child);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle}); final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.3)), const SizedBox(height: 3), Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]);
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.amount, required this.color}); final String label, amount; final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 3), Text(amount, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900))]))]);
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.paid}); final String label; final bool paid;
  @override
  Widget build(BuildContext context) { final color = paid ? const Color(0xFF16865B) : const Color(0xFFB7791F); return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800))); }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.title, required this.message}); final IconData icon; final String title, message;
  @override
  Widget build(BuildContext context) => _Panel(child: Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [Icon(icon, size: 30, color: Theme.of(context).colorScheme.onSurfaceVariant), const SizedBox(height: 9), Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]))));
}
