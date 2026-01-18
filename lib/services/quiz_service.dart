import 'api_service.dart';

class QuizService {
  /// Получить quiz вопросы
  static Future<Map<String, dynamic>> getQuizQuestions({
    required int limit,
    String rival = 'machine',
  }) async {
    final res = await ApiService.get(
      'quiz-questions?limit=$limit&rival=$rival',
    );

    return {
      'questions': res['questions'] ?? [],
      'categoriesAnswers': res['categories_answers'] ?? [],
      'rival_user': res['rival_user'],
    };
  }

  /// Проверка ответа пользователя
  static bool isCorrectAnswer({
    required String userAnswer,
    required String correctAnswer,
  }) {
    return userAnswer == correctAnswer;
  }

  /// Подсчёт очков
  static int calculateScore({
    required int currentScore,
    required bool correct,
  }) {
    return correct ? currentScore + 1 : currentScore;
  }

  /// Сохранить результат quiz
  static Future<Map<String, dynamic>> saveQuizResult({
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await ApiService.post(
        'practice-results',
        {'data': data},
      );

      if (res['error'] != null) {
        return {
          'status': 'error',
          'message': res['error']?['message'],
        };
      }

      return {
        'status': 'success',
        'data': res['data'],
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}
