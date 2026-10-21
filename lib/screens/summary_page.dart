import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../services/pdf_service.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

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
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();

    // തിരഞ്ഞെടുത്ത മാസത്തെ വർക്കുകൾ
    final monthlyWorks = provider.works.where((w) {
      return w.date.year == selectedMonth.year && w.date.month == selectedMonth.month;
    }).toList();

    // തിരഞ്ഞെടുത്ത മാസത്തെ ചെലവുകൾ
    final monthlyExpenses = provider.expenses.where((e) {
      return e.date.year == selectedMonth.year && e.date.month == selectedMonth.month;
    }).toList();

    final totalIncome = monthlyWorks.fold(0.0, (sum, w) => sum + w.amount);
    final totalReceived = monthlyWorks.fold(0.0, (sum, w) => sum + (w.amount - w.balance));
    final totalPending = monthlyWorks.fold(0.0, (sum, w) => sum + w.balance);
    final totalExpenses = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // കൃത്യമായ കണക്ക്: കയ്യിൽ കിട്ടിയ തുകയിൽ നിന്ന് മാത്രം ചെലവ് കുറയ്ക്കുന്നു (Cash In Hand)
    final netSavings = totalReceived - totalExpenses;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Monthly Financial Report',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Month Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8EAEE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    monthLabel,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Monthly Financial Cards (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Income',
                    amount: '₹ ${totalIncome.toStringAsFixed(0)}',
                    color: const Color(0xFF2E7D32),
                    bg: const Color(0xFFE8F5E9),
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Expenses',
                    amount: '₹ ${totalExpenses.toStringAsFixed(0)}',
                    color: const Color(0xFFE53935),
                    bg: const Color(0xFFFFEBEE),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Cash in Hand',
                    amount: netSavings >= 0
                        ? '₹ ${netSavings.toStringAsFixed(0)}'
                        : '- ₹ ${netSavings.abs().toStringAsFixed(0)}',
                    color: netSavings >= 0 ? const Color(0xFF1976D2) : Colors.red,
                    bg: const Color(0xFFE3F2FD),
                    icon: Icons.savings_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Works',
                    amount: '${monthlyWorks.length} Booked',
                    color: Colors.black87,
                    bg: Colors.grey.shade100,
                    icon: Icons.assignment_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Received Cash & Pending Balance Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8EAEE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Received Cash', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                '₹ ${totalReceived.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Color(0xFFF57C00), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pending Balance', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                '₹ ${totalPending.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF57C00)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Export PDF Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                label: Text(
                  'Export $monthLabel PDF Report',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  PdfService.exportMonthlyReport(
                    monthLabel: monthLabel,
                    totalIncome: totalIncome,
                    totalExpenses: totalExpenses,
                    netSavings: netSavings,
                    works: monthlyWorks,
                    expenses: monthlyExpenses,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 5. Quick Overview of Works
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$monthLabel Works (${monthlyWorks.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ₹ ${totalIncome.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (monthlyWorks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No works booked in $monthLabel',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
              )
            else
              ...monthlyWorks.map((w) => Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      dense: true,
                      title: Text(w.venue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${w.dateText} • ${w.eventType} • Bal: ₹ ${w.balance.toStringAsFixed(0)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹ ${w.amount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                          Text(
                            w.status,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: w.isPaid ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String amount,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}