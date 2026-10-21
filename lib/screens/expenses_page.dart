import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../models/catering_models.dart';
import 'calendar_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String selectedFilter = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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

    // Dynamic categories list (Puthiya custom category add cheythalum filter chips-il auto vannukollum)
    final Set<String> categoriesSet = {'All', 'Travel', 'Food', 'Uniform', 'Other'};
    for (var exp in provider.expenses) {
      if (exp.category.trim().isNotEmpty) {
        categoriesSet.add(exp.category.trim());
      }
    }
    final allCategoryFilters = categoriesSet.toList();

    // Puthiya expenses mukalil varaan .reversed upayogikkunnu
    final filteredExpenses = provider.expenses.reversed.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.subNote.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (selectedFilter == 'All') return true;
      return item.category.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E1E1E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddExpenseSheet(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                children: [
                  const Icon(Icons.menu, size: 26, color: Colors.black87),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Expenses',
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
                          'Track daily & catering expenses',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
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
                          const Icon(Icons.keyboard_arrow_down, size: 15, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE8EAEE)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search expenses...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8EAEE)),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.black87, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Category Filter Chips (Dynamic List)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allCategoryFilters.map((category) {
                    bool isSelected = selectedFilter.toLowerCase() == category.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFilter = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Metric Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Expenses',
                      value: '₹ ${provider.totalExpenses.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.currency_rupee,
                      title: 'Records',
                      value: '${provider.expenses.length}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.airport_shuttle_outlined,
                      title: 'Travel',
                      value: '${provider.travelCount}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.coffee_outlined,
                      title: 'Food',
                      value: '${provider.foodCount}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. Expense Items List
              if (filteredExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          'No expenses recorded yet.\nClick "Add Expense" to track your spending.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredExpenses.map((expense) => _buildExpenseCard(expense, context)).toList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
              Icon(icon, size: 12, color: Colors.black54),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem expense, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              expense.number,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(expense.icon, size: 16, color: Colors.black87),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 10, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      expense.dateText,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 10, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        expense.subNote,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹ ${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense.category,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 17, color: Colors.black54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onSelected: (val) {
              if (val == 'edit') {
                _showEditExpenseSheet(context, expense);
              } else if (val == 'delete') {
                _showDeleteDialog(context, expense.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ADD EXPENSE SHEET (With Manual Date Picker & Custom Category Support) ---
  void _showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    final customCatController = TextEditingController();

    DateTime selectedExpenseDate = DateTime.now();
    String selectedCat = 'Travel';
    bool isCustom = false;

    final standardCategories = [
      'Travel',
      'Food',
      'Uniform',
      'Provisions / Grocery',
      'Gas & Fuel',
      'Staff Wage',
      'Other / Custom'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Expense Description *', hintText: 'eg: Chicken 20kg', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                // Manual Date Picker Row
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedExpenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModalState(() => selectedExpenseDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expense Date', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                                Text(
                                  '${selectedExpenseDate.day}/${selectedExpenseDate.month}/${selectedExpenseDate.year}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹) *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: standardCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedCat = val;
                        isCustom = (val == 'Other / Custom');
                      });
                    }
                  },
                ),

                // Puthiya category type cheyyan ulla extra field
                if (isCustom) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: customCatController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Custom Category Name *',
                      hintText: 'eg: Ice block, Plastic items etc.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Sub Note / Shop Name', hintText: 'eg: Daily bazaar Kochi', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E)),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;

                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      final finalCat = (isCustom && customCatController.text.trim().isNotEmpty)
                          ? customCatController.text.trim()
                          : (isCustom ? 'Other' : selectedCat);

                      final newExpense = ExpenseItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        number: '${context.read<CateringProvider>().expenses.length + 1}'.padLeft(2, '0'),
                        title: titleController.text.trim(),
                        subNote: noteController.text.trim().isEmpty ? 'General' : noteController.text.trim(),
                        category: finalCat,
                        date: selectedExpenseDate,
                        amount: amount,
                      );

                      context.read<CateringProvider>().addExpense(newExpense);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EDIT EXPENSE SHEET ---
  void _showEditExpenseSheet(BuildContext context, ExpenseItem expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toStringAsFixed(0));
    final noteController = TextEditingController(text: expense.subNote);
    final customCatController = TextEditingController();

    DateTime selectedExpenseDate = expense.date;
    final standardCategories = [
      'Travel',
      'Food',
      'Uniform',
      'Provisions / Grocery',
      'Gas & Fuel',
      'Staff Wage',
      'Other / Custom'
    ];

    bool isCustom = !['Travel', 'Food', 'Uniform', 'Provisions / Grocery', 'Gas & Fuel', 'Staff Wage'].contains(expense.category);
    String selectedCat = isCustom ? 'Other / Custom' : expense.category;
    if (isCustom) {
      customCatController.text = expense.category;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Expense Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                // Manual Date Selection in Edit
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedExpenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModalState(() => selectedExpenseDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expense Date', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                                Text(
                                  '${selectedExpenseDate.day}/${selectedExpenseDate.month}/${selectedExpenseDate.year}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: standardCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedCat = val;
                        isCustom = (val == 'Other / Custom');
                      });
                    }
                  },
                ),

                if (isCustom) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: customCatController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note / Location', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E)),
                    onPressed: () {
                      final amount = double.tryParse(amountController.text) ?? expense.amount;
                      final finalCat = (isCustom && customCatController.text.trim().isNotEmpty)
                          ? customCatController.text.trim()
                          : (isCustom ? 'Other' : selectedCat);

                      final updated = expense.copyWith(
                        title: titleController.text,
                        subNote: noteController.text,
                        amount: amount,
                        category: finalCat,
                        date: selectedExpenseDate,
                      );

                      context.read<CateringProvider>().updateExpense(updated);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DELETE CONFIRMATION DIALOG ---
  void _showDeleteDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to remove this expense record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CateringProvider>().deleteExpense(expenseId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense record deleted!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}