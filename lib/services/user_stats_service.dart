import '../services/api_service.dart';

/// FULL analogue of Pinia store: useUserStats
class UserStatsService {
  /// === STATE ===

  Map<String, dynamic> userStatus = {
    "last_quiz": null,
    "last_update": null,
    "points": null,
    "time_in_app": null,
    "past_categories_count": null,
    "categories_count": null,
    "past_categories_percent": null,
    "daily_statics": null,
  };

  static Map<String, dynamic> defaultAnswersStats() => {
    "questions_count": null,
    "questions_left_count": null,
    "answers_count": null,
    "answers_percent": null,
    "correct_answers": <String, dynamic>{
      "count": null,
      "percent": null,
    },
    "wrong_answers": <String, dynamic>{
      "count": null,
      "percent": null,
    },
    "skipped_answers": <String, dynamic>{
      "count": null,
      "percent": null,
    },
    "last_update": null,
  };

  Map<String, dynamic> answersStats = {
    "questions_count": null,
    "questions_left_count": null,
    "answers_count": null,
    "answers_percent": null,
    "correct_answers": <String, dynamic>{
      "count": null,
      "percent": null,
    },
    "wrong_answers": <String, dynamic>{
      "count": null,
      "percent": null,
    },
    "skipped_answers": <String, dynamic>{
      "count": null,
      "percent": null,
    },
    "last_update": null,
  };

  Map<String, dynamic> userProgress = {};

  /// === ACTIONS ===

  /// GET get-user-status
  Future<Map<String, dynamic>> getUserStatus() async {
    final data = await ApiService.get('get-user-status');

    if (data['time_in_app'] != null) {
      userStatus["last_quiz"] = data["last_quiz"];
      userStatus["last_update"] = data["last_update"];
      userStatus["points"] = data["points"];
      userStatus["time_in_app"] = data["time_in_app"];
      userStatus["past_categories_count"] =
      data["past_categories_count"];
      userStatus["categories_count"] = data["categories_count"];
      userStatus["past_categories_percent"] =
      data["past_categories_percent"];
      userStatus["daily_statics"] = data["daily_statics"];
    }

    return userStatus;
  }

  /// GET user-daily-activities
  Future<Map<String, dynamic>> getProgressByDays(
      String start, String end) async {
    final data = await ApiService.get(
      'user-daily-activities?start=$start&end=$end',
    );

    userProgress = data['data'] ?? {};
    return userProgress;
  }

  /// GET get-answers-stats
  Future<Map<String, dynamic>> getAnswersStats() async {
    final data = await ApiService.get('get-answers-stats');

    answersStats["questions_count"] = data["questions_count"];
    answersStats["questions_left_count"] =
    data["questions_left_count"];
    answersStats["answers_count"] = data["answers_count"];
    answersStats["answers_percent"] = data["answers_percent"];

    final correct = answersStats["correct_answers"]
    as Map<String, dynamic>;
    correct["count"] = data["correct_answers"]?["count"];
    correct["percent"] = data["correct_answers"]?["percent"];

    final wrong =
    answersStats["wrong_answers"] as Map<String, dynamic>;
    wrong["count"] = data["wrong_answers"]?["count"];
    wrong["percent"] = data["wrong_answers"]?["percent"];

    final skipped =
    answersStats["skipped_answers"] as Map<String, dynamic>;
    skipped["count"] = data["skipped_answers"]?["count"];
    skipped["percent"] = data["skipped_answers"]?["percent"];

    answersStats["last_update"] = data["last_update"];

    return answersStats;
  }
}
