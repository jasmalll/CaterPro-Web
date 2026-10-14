import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/catering_models.dart';

class CateringProvider extends ChangeNotifier {
  List<WorkItem> _works = [];
  List<ExpenseItem> _expenses = [];

  List<WorkItem> get works => _works;
  List<ExpenseItem> get expenses => _expenses;

  final Box _worksBox = Hive.box('works_box');
  final Box _expensesBox = Hive.box('expenses_box');

  void loadDataFromStorage() {
    final rawWorks = _worksBox.values;
    _works = rawWorks
        .map((e) => WorkItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final rawExpenses = _expensesBox.values;
    _expenses = rawExpenses
        .map((e) => ExpenseItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  // --- WORKS CRUD ---
  Future<void> addWork(WorkItem work) async {
    _works.insert(0, work);
    await _worksBox.put(work.id, work.toMap());
    notifyListeners();
  }

  Future<void> updateWork(WorkItem updatedWork) async {
    final index = _works.indexWhere((w) => w.id == updatedWork.id);
    if (index != -1) {
      _works[index] = updatedWork;
      await _worksBox.put(updatedWork.id, updatedWork.toMap());
      notifyListeners();
    }
  }

  Future<void> deleteWork(String id) async {
    _works.removeWhere((w) => w.id == id);
    await _worksBox.delete(id);
    notifyListeners();
  }

  // Status Toggle (Paid <-> Pending)
  Future<void> togglePaymentStatus(String id) async {
    final index = _works.indexWhere((w) => w.id == id);
    if (index != -1) {
      final current = _works[index];
      final newStatus = !current.isPaid;
      _works[index] = current.copyWith(
        isPaid: newStatus,
        status: newStatus ? 'Paid' : 'Pending',
        balance: newStatus ? 0.0 : current.amount,
      );
      await _worksBox.put(id, _works[index].toMap());
      notifyListeners();
    }
  }

  // --- EXPENSES CRUD ---
  Future<void> addExpense(ExpenseItem expense) async {
    _expenses.insert(0, expense);
    await _expensesBox.put(expense.id, expense.toMap());
    notifyListeners();
  }

  Future<void> updateExpense(ExpenseItem updatedExpense) async {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      await _expensesBox.put(updatedExpense.id, updatedExpense.toMap());
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _expensesBox.delete(id);
    notifyListeners();
  }

  // --- BACKUP & RESTORE METHODS ---
  Future<void> exportBackup(BuildContext context) async {
    try {
      final backupData = {
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'works': _works.map((w) => w.toMap()).toList(),
        'expenses': _expenses.map((e) => e.toMap()).toList(),
      };

      final jsonString = jsonEncode(backupData);
      final now = DateTime.now();
      final fileName = 'caterpro_backup_${now.year}_${now.month}_${now.day}.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'application/json')],
        subject: 'CaterPro Backup Data',
        text: 'CaterPro Data Backup File ($fileName)',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> restoreBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null) {
        final pickedFile = result.files.single;
        final bytes = pickedFile.bytes;
        if (bytes == null) {
          throw 'Unable to read the selected backup file. Please try selecting it again.';
        }
        final content = utf8.decode(bytes);
        final dynamic decoded = jsonDecode(content);

        if (decoded is! Map) {
          throw 'Invalid JSON structure: Root must be a Map/Object';
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

        // List അല്ലെങ്കിൽ Map ആയാലും ശരിയായ രീതിയിൽ മാറ്റിയെടുക്കുന്നു
        List<Map<String, dynamic>> parseList(dynamic raw) {
          if (raw == null) return [];
          if (raw is List) {
            return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          } else if (raw is Map) {
            return raw.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
          return [];
        }

        final worksList = parseList(data['works']);
        final expensesList = parseList(data['expenses']);

        if (worksList.isNotEmpty || expensesList.isNotEmpty || data.containsKey('works')) {
          await _worksBox.clear();
          await _expensesBox.clear();

          for (var item in worksList) {
            final id = (item['id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
            item['id'] = id;
            await _worksBox.put(id, item);
          }

          for (var item in expensesList) {
            final id = (item['id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
            item['id'] = id;
            await _expensesBox.put(id, item);
          }

          loadDataFromStorage();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Backup restored successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw 'No valid works or expenses found in the selected backup file';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- AUTOMATIC CALCULATIONS & GETTERS ---
  int get totalWorksCount => _works.length;
  double get totalIncome => _works.fold(0.0, (sum, w) => sum + w.amount);
  double get pendingAmount => _works.fold(0.0, (sum, w) => sum + (w.isPaid ? 0.0 : w.balance));
  double get receivedAmount => totalIncome - pendingAmount;

  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get currentSavings => receivedAmount - totalExpenses;

  double get receivedPct => totalIncome > 0 ? (receivedAmount / totalIncome) * 100 : 0.0;
  double get pendingPct => totalIncome > 0 ? (pendingAmount / totalIncome) * 100 : 0.0;
  double get savingsPct => totalIncome > 0 ? (currentSavings / totalIncome) * 100 : 0.0;

  int get travelCount => _expenses.where((e) => e.category.toLowerCase() == 'travel').length;
  int get foodCount => _expenses.where((e) => e.category.toLowerCase() == 'food').length;

  Map<String, double> get expenseByCategory {
    final map = {'Travel': 0.0, 'Food': 0.0, 'Uniform': 0.0, 'Other': 0.0};
    for (var e in _expenses) {
      if (map.containsKey(e.category)) {
        map[e.category] = (map[e.category] ?? 0.0) + e.amount;
      } else {
        map['Other'] = (map['Other'] ?? 0.0) + e.amount;
      }
    }
    return map;
  }

  List<WorkItem> get topVenues {
    final sorted = List<WorkItem>.from(_works)..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(5).toList();
  }
}