// lib/services/progress_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lekkerly/models/progress_model.dart';

class ProgressService {
  static const String _progressKey = 'user_progress';
  static const String _lastSessionDateKey = 'last_session_date';
  static const String _streakCountKey = 'streak_count';

  // Save a new quiz score
  Future<void> saveProgress(Progress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Progress> allProgress = await loadProgress();
    allProgress.add(progress);

    final List<String> progressJsonList =
        allProgress.map((p) => json.encode(p.toJson())).toList();

    await prefs.setStringList(_progressKey, progressJsonList);
    await updateStreak(); // Update the streak after saving progress
  }

  // Load all saved scores
  Future<List<Progress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? progressJsonList = prefs.getStringList(_progressKey);

    if (progressJsonList == null) {
      return [];
    }

    final List<Progress> progressList = progressJsonList
        .map((jsonString) => Progress.fromJson(json.decode(jsonString)))
        .toList();

    progressList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return progressList;
  }

  // Clear all saved scores
  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_lastSessionDateKey);
    await prefs.remove(_streakCountKey);
  }

  // --- STREAK LOGIC ---

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if the streak should be reset before returning
    final lastSessionString = prefs.getString(_lastSessionDateKey);
    if (lastSessionString == null) return 0;

    final lastSessionDate = DateTime.parse(lastSessionString);
    final today = DateTime.now();
    final difference = today.difference(lastSessionDate).inDays;

    if (difference > 1) {
      await prefs.setInt(_streakCountKey, 0);
      return 0;
    }

    return prefs.getInt(_streakCountKey) ?? 0;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final lastSessionString = prefs.getString(_lastSessionDateKey);
    int currentStreak = prefs.getInt(_streakCountKey) ?? 0;

    if (lastSessionString == null) {
      // First session ever
      currentStreak = 1;
    } else {
      final lastSessionDate = DateTime.parse(lastSessionString);
      final difference = todayDateOnly.difference(lastSessionDate).inDays;

      if (difference == 1) {
        // Consecutive day
        currentStreak++;
      } else if (difference > 1) {
        // Missed a day or more
        currentStreak = 1;
      }
      // If difference is 0, do nothing (same day session)
    }

    await prefs.setInt(_streakCountKey, currentStreak);
    await prefs.setString(_lastSessionDateKey, todayDateOnly.toIso8601String());
  }
}
