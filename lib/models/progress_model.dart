// lib/models/progress_model.dart

class Progress {
  final String categoryName;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;

  Progress({
    required this.categoryName,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
  });

  // Convert a Progress object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a Progress object from a Map object
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      categoryName: json['categoryName'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
