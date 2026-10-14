import 'package:flutter/material.dart';

class WorkItem {
  final String id;
  final String number;
  final String venue;
  final String location;
  final DateTime date;
  final String reportingTime; // എ.ഡി: 07:00 AM
  final String eventType;     // Wedding, Reception, Birthday etc.
  final String paxCount;      // എണ്ണം / പ്ലേറ്റ് (eg: 500 Pax)
  final String note;          // ഫോൺ നമ്പർ അല്ലെങ്കിൽ പ്രത്യേക കുറിപ്പ്
  final double amount;
  final double balance;
  final bool isPaid;
  final String status;

  WorkItem({
    required this.id,
    required this.number,
    required this.venue,
    required this.location,
    required this.date,
    this.reportingTime = '07:00 AM',
    this.eventType = 'Wedding',
    this.paxCount = 'General',
    this.note = '',
    required this.amount,
    required this.balance,
    required this.isPaid,
    required this.status,
  });

  String get dateText => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  IconData get icon {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return Icons.favorite_border_rounded;
      case 'reception':
        return Icons.wine_bar_outlined;
      case 'birthday':
        return Icons.cake_outlined;
      case 'corporate':
        return Icons.business_center_outlined;
      default:
        return Icons.room_service_outlined;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'venue': venue,
      'location': location,
      'date': date.toIso8601String(),
      'reportingTime': reportingTime,
      'eventType': eventType,
      'paxCount': paxCount,
      'note': note,
      'amount': amount,
      'balance': balance,
      'isPaid': isPaid,
      'status': status,
    };
  }

  factory WorkItem.fromMap(Map<String, dynamic> map) {
    return WorkItem(
      id: map['id'] ?? '',
      number: map['number'] ?? '01',
      venue: map['venue'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      reportingTime: map['reportingTime'] ?? '07:00 AM',
      eventType: map['eventType'] ?? 'Wedding',
      paxCount: map['paxCount'] ?? 'General',
      note: map['note'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      isPaid: map['isPaid'] ?? false,
      status: map['status'] ?? 'Pending',
    );
  }

  WorkItem copyWith({
    String? id,
    String? number,
    String? venue,
    String? location,
    DateTime? date,
    String? reportingTime,
    String? eventType,
    String? paxCount,
    String? note,
    double? amount,
    double? balance,
    bool? isPaid,
    String? status,
  }) {
    return WorkItem(
      id: id ?? this.id,
      number: number ?? this.number,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      date: date ?? this.date,
      reportingTime: reportingTime ?? this.reportingTime,
      eventType: eventType ?? this.eventType,
      paxCount: paxCount ?? this.paxCount,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
    );
  }
}

class ExpenseItem {
  final String id;
  final String number;
  final String title;
  final String subNote;
  final String category;
  final DateTime date;
  final double amount;

  ExpenseItem({
    required this.id,
    required this.number,
    required this.title,
    required this.subNote,
    required this.category,
    required this.date,
    required this.amount,
  });

  String get dateText => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'travel':
        return Icons.directions_bus_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'uniform':
        return Icons.checkroom_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'subNote': subNote,
      'category': category,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] ?? '',
      number: map['number'] ?? '01',
      title: map['title'] ?? '',
      subNote: map['subNote'] ?? '',
      category: map['category'] ?? 'Other',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ExpenseItem copyWith({
    String? id,
    String? number,
    String? title,
    String? subNote,
    String? category,
    DateTime? date,
    double? amount,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      subNote: subNote ?? this.subNote,
      category: category ?? this.category,
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }
}