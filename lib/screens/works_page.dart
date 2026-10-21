import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../models/catering_models.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import 'calendar_page.dart';

class WorksPage extends StatefulWidget {
  const WorksPage({Key? key}) : super(key: key);

  @override
  State<WorksPage> createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  String selectedFilter = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // മാസത്തിന്റെ പേര് ചുരുക്കി 'Sep 2026' എന്നാക്കി ഓവർഫ്ലോ ഒഴിവാക്കുന്നു
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

    // പുതിയ വർക്കുകൾ ഏറ്റവും മുകളിൽ വരാൻ .reversed നൽകിയിരിക്കുന്നു
    final filteredWorks = provider.works.reversed.where((item) {
      final matchesSearch = item.venue.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.eventType.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (selectedFilter == 'Paid') return item.isPaid;
      if (selectedFilter == 'Pending') return !item.isPaid;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E1E1E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Work', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddWorkSheet(context),
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
                    child: const Icon(Icons.work_outline_rounded, size: 20, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Works',
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
                          'Manage schedule & payments',
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
                          hintText: 'Search by venue, place or event...',
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

              // 3. Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Paid', 'Pending'].map((filter) {
                    bool isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFilter = filter),
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
                            filter,
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
                    child: _buildStatCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Total Works',
                      value: '${provider.totalWorksCount}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.currency_rupee,
                      title: 'Total Income',
                      value: '₹ ${provider.totalIncome.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline,
                      title: 'Received',
                      value: '₹ ${provider.receivedAmount.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.access_time_rounded,
                      title: 'Pending',
                      value: '₹ ${provider.pendingAmount.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. Works Cards List
              if (filteredWorks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 50, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          'No catering works found.\nTap "Add Work" to add venue, time & amount.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredWorks.map((work) => _buildWorkCard(work, context)).toList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
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
                  style: TextStyle(fontSize: 8.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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

  Widget _buildWorkCard(WorkItem work, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  work.number,
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
                child: Icon(work.icon, size: 16, color: Colors.black87),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            work.venue,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            work.eventType,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                          ),
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
                            work.location,
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
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
                    '₹ ${work.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bal: ₹ ${work.balance.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(width: 6),

              GestureDetector(
                onTap: () => context.read<CateringProvider>().togglePaymentStatus(work.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: work.isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        work.isPaid ? Icons.check : Icons.access_time_rounded,
                        size: 10,
                        color: work.isPaid ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
                      ),
                      const SizedBox(width: 3),
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
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 17, color: Colors.black54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditWorkSheet(context, work);
                  } else if (val == 'pdf') {
                    PdfService.exportWorkInvoice(work);
                  } else if (val == 'delete') {
                    _showDeleteDialog(context, work.id);
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
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf_outlined, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Bill / Invoice', style: TextStyle(fontSize: 13)),
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

          const Divider(height: 14, thickness: 0.7),

          // Date, Reporting Time & Pax Badges (Wrap prevents overflow)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 10.5, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(work.dateText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 10.5, color: Color(0xFFF57F17)),
                    const SizedBox(width: 4),
                    Text('Report: ${work.reportingTime}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF57F17))),
                  ],
                ),
              ),
              if (work.paxCount.isNotEmpty && work.paxCount != 'General')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 10.5, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(work.paxCount, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
            ],
          ),

          if (work.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Note: ${work.note}',
              style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  // --- ADD WORK BOTTOM SHEET (With 8 PM Previous Night Auto-Reminder) ---
  void _showAddWorkSheet(BuildContext context) {
    final venueController = TextEditingController();
    final locationController = TextEditingController();
    final amountController = TextEditingController();
    final advanceController = TextEditingController();
    final paxController = TextEditingController();
    final noteController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);
    String selectedEventType = 'Wedding';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                    const Text('Book Catering Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue / Auditorium Name *',
                    hintText: 'eg: Grand Royal Auditorium',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Place / Location *',
                          hintText: 'eg: Kochi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedEventType,
                        decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                        items: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEventType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Event Date', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.black87),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Reporting Time', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 13, color: Colors.black87),
                                  const SizedBox(width: 5),
                                  Text(
                                    selectedTime.format(context),
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Amount (₹) *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: advanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Advance (₹)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: paxController,
                        decoration: const InputDecoration(
                          labelText: 'Plates / Pax Count',
                          hintText: 'eg: 800 Pax',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Phone / Note',
                          hintText: 'eg: 9876543210',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E)),
                    onPressed: () {
                      if (venueController.text.trim().isEmpty) return;

                      final total = double.tryParse(amountController.text) ?? 0.0;
                      final received = double.tryParse(advanceController.text) ?? 0.0;
                      final balance = (total - received).clamp(0.0, double.infinity);
                      final isPaid = received >= total && total > 0;

                      final newWork = WorkItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        number: '${context.read<CateringProvider>().works.length + 1}'.padLeft(2, '0'),
                        venue: venueController.text.trim(),
                        location: locationController.text.trim().isEmpty ? 'General' : locationController.text.trim(),
                        date: selectedDate,
                        reportingTime: selectedTime.format(context),
                        eventType: selectedEventType,
                        paxCount: paxController.text.trim().isEmpty ? 'General' : paxController.text.trim(),
                        note: noteController.text.trim(),
                        amount: total,
                        balance: balance,
                        isPaid: isPaid,
                        status: isPaid ? 'Paid' : 'Pending',
                      );

                      // വർക്ക് ലിസ്റ്റിലേക്ക് ആഡ് ചെയ്യുന്നു
                      context.read<CateringProvider>().addWork(newWork);

                      // തലേദിവസം രാത്രി 8 മണിക്ക് ഓട്ടോമാറ്റിക് അലാറം ഷെഡ്യൂൾ ചെയ്യുന്നു
                      NotificationService.scheduleWorkReminder(newWork);

                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Catering Work', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EDIT WORK BOTTOM SHEET ---
  void _showEditWorkSheet(BuildContext context, WorkItem work) {
    final venueController = TextEditingController(text: work.venue);
    final locationController = TextEditingController(text: work.location);
    final amountController = TextEditingController(text: work.amount.toStringAsFixed(0));
    final advanceController = TextEditingController(text: (work.amount - work.balance).toStringAsFixed(0));
    final paxController = TextEditingController(text: work.paxCount);
    final noteController = TextEditingController(text: work.note);

    DateTime selectedDate = work.date;
    String reportingTime = work.reportingTime;
    String selectedEventType = work.eventType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                    const Text('Edit Catering Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].contains(selectedEventType)
                            ? selectedEventType
                            : 'Other',
                        decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                        items: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEventType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Event Date', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 7, minute: 0),
                          );
                          if (picked != null) {
                            setModalState(() => reportingTime = picked.format(context));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Reporting Time', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                reportingTime,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Total (₹)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: advanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Received (₹)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: paxController,
                        decoration: const InputDecoration(labelText: 'Pax / Plates', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(labelText: 'Phone / Note', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E)),
                    onPressed: () {
                      final total = double.tryParse(amountController.text) ?? work.amount;
                      final received = double.tryParse(advanceController.text) ?? (work.amount - work.balance);
                      final isPaid = received >= total;

                      final updated = work.copyWith(
                        venue: venueController.text,
                        location: locationController.text,
                        date: selectedDate,
                        reportingTime: reportingTime,
                        eventType: selectedEventType,
                        paxCount: paxController.text,
                        note: noteController.text,
                        amount: total,
                        balance: (total - received).clamp(0, double.infinity),
                        isPaid: isPaid,
                        status: isPaid ? 'Paid' : 'Pending',
                      );

                      // വിവരങ്ങൾ അപ്‌ഡേറ്റ് ചെയ്യുന്നു
                      context.read<CateringProvider>().updateWork(updated);

                      // മാറ്റിയ തീയതിക്കനുസരിച്ച് നോട്ടിഫിക്കേഷൻ റീഷെഡ്യൂൾ ചെയ്യുന്നു
                      NotificationService.scheduleWorkReminder(updated);

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

  void _showDeleteDialog(BuildContext context, String workId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Work?'),
        content: const Text('Are you sure you want to remove this catering record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // വർക്ക് ഡിലീറ്റ് ചെയ്യുന്നു
              context.read<CateringProvider>().deleteWork(workId);

              // ഷെഡ്യൂൾ ചെയ്ത നോട്ടിഫിക്കേഷൻ റദ്ദാക്കുന്നു
              NotificationService.cancelWorkReminder(workId);

              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}