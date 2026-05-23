import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class TikuLoader {
  static Future<TikuData> load() async {
    final raw = await rootBundle.loadString('assets/tiku.json');
    final parsed = json.decode(raw) as Map<String, dynamic>;
    return TikuData.fromJson(parsed);
  }
}
