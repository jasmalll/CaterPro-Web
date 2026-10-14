import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../models/catering_models.dart';
import 'calendar_page.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({Key? key}) : super(key: key);

  String get currentMonthText {
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${shortMonths[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();
    final income = provider.totalIncome;
    final received = provider.receivedAmount;
    final expense = provider.totalExpenses;
    final pending = provider.pendingAmount;

    // കൃത്യമായ കണക്ക്: കയ്യിൽ കിട്ടിയ തുകയിൽ നിന്ന് മാത്രം ചെലവ് കുറയ്ക്കുന്നു
    final savings = received - expense;

    // ശതമാനം കണക്കാക്കുന്നു (Total Income-മായി താരതമ്യം ചെയ്ത്)
    final double expenseRatio = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;
    final double savingsRatio = income > 0 ? (savings > 0 ? (savings / income).clamp(0.0, 1.0) : 0.0) : 0.0;

    final int expensePercent = (expenseRatio * 100).round();
    final int savingsPercent = (savingsRatio * 100).round();

    // ഏറ്റവും പുതിയ 3 വർക്കുകൾ മുകളിൽ കാണിക്കാൻ
    final recentWorks = provider.works.reversed.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CaterPro',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Catering & Event Manager',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Calendar Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            currentMonthText,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Backup & Restore Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black87, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'export') {
                        provider.exportBackup(context);
                      } else if (val == 'restore') {
                        provider.restoreBackup(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.upload_file_outlined, size: 18, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Export Backup', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.settings_backup_restore_outlined, size: 18, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Restore Backup', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Financial Overview Cards (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Income',
                      value: '₹ ${income.toStringAsFixed(0)}',
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF2E7D32),
                      bgColor: const Color(0xFFE8F5E9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Expenses',
                      value: '₹ ${expense.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFFE53935),
                      bgColor: const Color(0xFFFFEBEE),
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
                      value: savings >= 0
                          ? '₹ ${savings.toStringAsFixed(0)}'
                          : '- ₹ ${savings.abs().toStringAsFixed(0)}',
                      icon: Icons.savings_outlined,
                      color: savings >= 0 ? const Color(0xFF1976D2) : Colors.red,
                      bgColor: const Color(0xFFE3F2FD),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Works',
                      value: '${provider.totalWorksCount} Booked',
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFF424242),
                      bgColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Received & Pending Mini Summary
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                                  '₹ ${received.toStringAsFixed(0)}',
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
                                  '₹ ${pending.toStringAsFixed(0)}',
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
              const SizedBox(height: 16),

              // 4. INCOME VS EXPENSES VS SAVINGS CHART CARD
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8EAEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 18, color: Colors.black87),
                            SizedBox(width: 6),
                            Text(
                              'Money Breakdown',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        Text(
                          savings >= 0 ? '$savingsPercent% In Hand' : 'Loss',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: savings >= 0 ? const Color(0xFF1976D2) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Total Income Bar
                    _buildChartRow(
                      label: 'Income (Total)',
                      amount: '₹ ${income.toStringAsFixed(0)}',
                      ratio: income > 0 ? 1.0 : 0.0,
                      percentageText: '100%',
                      barColor: const Color(0xFF2E7D32),
                      bgColor: const Color(0xFFE8F5E9),
                    ),
                    const SizedBox(height: 10),

                    // Expenses Bar
                    _buildChartRow(
                      label: 'Expenses',
                      amount: '₹ ${expense.toStringAsFixed(0)}',
                      ratio: expenseRatio,
                      percentageText: '$expensePercent%',
                      barColor: const Color(0xFFE53935),
                      bgColor: const Color(0xFFFFEBEE),
                    ),
                    const SizedBox(height: 10),

                    // Savings Bar (Calculated from Received - Expense)
                    _buildChartRow(
                      label: 'Cash in Hand',
                      amount: savings >= 0 ? '₹ ${savings.toStringAsFixed(0)}' : '- ₹ ${savings.abs().toStringAsFixed(0)}',
                      ratio: savingsRatio,
                      percentageText: '$savingsPercent%',
                      barColor: const Color(0xFF1976D2),
                      bgColor: const Color(0xFFE3F2FD),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 5. Recent Works Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Works',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    '${provider.works.length} Total',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 6. Recent Works List
              if (recentWorks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      'No catering works added yet.\nGo to Works tab to book events.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...recentWorks.map((work) => _buildRecentWorkTile(work)).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartRow({
    required String label,
    required String amount,
    required double ratio,
    required String percentageText,
    required Color barColor,
    required Color bgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  amount,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: barColor),
                ),
                const SizedBox(width: 4),
                Text(
                  '($percentageText)',
                  style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 7,
                width: double.infinity,
                color: bgColor,
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkTile(WorkItem work) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(work.icon, size: 16, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        work.venue,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        work.eventType,
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${work.dateText} • Report: ${work.reportingTime}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹ ${work.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                work.status,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: work.isPaid ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}