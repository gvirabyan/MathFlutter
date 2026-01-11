import 'api_service.dart';

class QuestionsService {
  static Future<Map<String, dynamic>> getQuestions({
    int? categoryId,
  }) async {
    final res = await ApiService.get(
      'questions'
          '?filters[category][id][\$eq]=$categoryId'
          '&pagination[limit]=100',
    );
    return res;
  }
  static Future<Map<String, dynamic>> getTopicQuestions({
    required int categoryId,
    int page = 1,
  }) async {
    final endpoint =
        'topic-questions'
        '?categoryId=$categoryId'
        '&pagination[page]=$page';

    final res = await ApiService.get(endpoint);
    return res;
  }



  /// Вопросы для админа
  static Future<Map<String, dynamic>> getQuestionsForAdmin({
    required int categoryId,
    required bool isAdmin,
    int page = 1,
  }) async {
    return await ApiService.get(
      'topic-questions-for-admin'
          '?categoryId=$categoryId'
          '&pagination[page]=$page'
          '&isAdmin=$isAdmin',
    );
  }

  /// Обновить упражнение (admin)
  static Future<dynamic> updateExercise({
    required Map<String, dynamic> data,
    required bool isAdmin,
  }) async {
    final res = await ApiService.put(
      'update-exercise',
      {
        'data': data,
        'isAdmin': isAdmin,
      },
    );

    return res;
  }

  /// Получить отвеченные вопросы пользователя по категории
  static Future<Map<String, dynamic>> getAnsweredQuestions({
    required int categoryId,
    required int userId,
  }) async {
    final res = await ApiService.get(
      'user-answers'
          '?populate[0]=question'
          '&filters[question][category][id][\$eq]=$categoryId'
          '&filters[users_permissions_user][id][\$eq][0]=$userId'
          '&filters[status][\$ne][1]=skipped'
          '&pagination[limit]=100',
    );

    return {
      'answers': res['data'] ?? [],
      'points': res['topic_points'] ?? 0,
    };
  }

  /// Количество всех отвеченных вопросов
  static Future<int> getAnsweredQuestionsCount() async {
    final res = await ApiService.get('answered-questions');
    return res['result'] ?? 0;
  }

  /// Получить решение вопроса
  static Future<dynamic> getSolution({
    required int questionId,
    required int categoryId,
  }) async {
    return await ApiService.get(
      'solution?questionID=$questionId&categoryID=$categoryId',
    );
  }

  /// Создать новые вопросы (admin)
  static Future<dynamic> createNewQuestions(
      Map<String, dynamic> data,
      ) async {
    final res = await ApiService.post(
      'create-new-questions',
      {'data': data},
    );

    return res;
  }
}
