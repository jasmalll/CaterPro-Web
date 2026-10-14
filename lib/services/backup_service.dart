import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/catering_provider.dart';

class BackupService {
  // 1. ബാക്കപ്പ് ഫയൽ ഉണ്ടാക്കി ഷെയർ ചെയ്യാൻ
  static Future<void> exportBackup(BuildContext context) async {
    try {
      final worksBox = Hive.box('works_box');
      final expensesBox = Hive.box('expenses_box');

      final Map<String, dynamic> backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'works': worksBox.toMap(),
        'expenses': expensesBox.toMap(),
      };

      final jsonString = jsonEncode(backupData);

      final dateStr = DateTime.now().toString().split(' ')[0];
      final fileName = 'caterpro_backup_$dateStr.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'application/json')],
        subject: 'CaterPro Data Backup - $dateStr',
        text: 'CaterPro backup file. Keep this safe to restore your data.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 2. പഴയ ഫയൽ തെരഞ്ഞെടുത്ത് ഡാറ്റ തിരികെ കൊണ്ടുവരാൻ (Restore)
  static Future<void> restoreBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null) {
        final pickedFile = result.files.single;
        if (!pickedFile.name.toLowerCase().endsWith('.json')) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a valid .json backup file!'), backgroundColor: Colors.orange),
            );
          }
          return;
        }

        final bytes = pickedFile.bytes;
        if (bytes == null) {
          throw 'Unable to read the selected backup file. Please select it again.';
        }
        final content = utf8.decode(bytes);
        final dynamic decoded = jsonDecode(content);
        if (decoded is! Map) {
          throw const FormatException('Invalid backup file format.');
        }
        final Map<String, dynamic> decodedData = Map<String, dynamic>.from(decoded);

        final worksBox = Hive.box('works_box');
        final expensesBox = Hive.box('expenses_box');

        // പഴയ ഡാറ്റ ക്ലിയർ ചെയ്ത് ബാക്കപ്പിലുള്ളവ കയറ്റുന്നു
        await worksBox.clear();
        await expensesBox.clear();

        Map<String, dynamic> normalizeEntries(dynamic raw) {
          if (raw is Map) return Map<String, dynamic>.from(raw);
          if (raw is List) {
            final normalized = <String, dynamic>{};
            for (final item in raw) {
              if (item is Map) {
                final map = Map<String, dynamic>.from(item);
                final id = (map['id'] ?? DateTime.now().microsecondsSinceEpoch).toString();
                map['id'] = id;
                normalized[id] = map;
              }
            }
            return normalized;
          }
          return <String, dynamic>{};
        }

        final works = normalizeEntries(decodedData['works']);
        final expenses = normalizeEntries(decodedData['expenses']);

        for (final entry in works.entries) {
          await worksBox.put(entry.key, entry.value);
        }
        for (final entry in expenses.entries) {
          await expensesBox.put(entry.key, entry.value);
        }

        if (context.mounted) {
          context.read<CateringProvider>().loadDataFromStorage();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data restored successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}