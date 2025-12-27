import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:untitled2/services/questions_service.dart';

import '../models/topic_progress_item.dart';
import 'api_service.dart';
import 'category_service.dart';

class CategoryAnswerService {
  /// Главный метод — получить ответы для UI
  static List<String>? buildAnswers({
    required List<dynamic> categoryAnswers,
    required List<dynamic>? wrongAnswers,
    required String answer,
    int randomLimit = 3,
  }) {
    if (wrongAnswers != null && wrongAnswers.isNotEmpty) {
      final list = wrongAnswers.map((e) => e.toString()).toList();
      list.add(answer);
      return _shuffle(list);
    }

    if (categoryAnswers.isNotEmpty) {
      return _createRandomData(
        categoryAnswers,
        answer,
        randomLimit,
      );
    }

    return null;
  }

  /// Создание случайного набора ответов
  static List<String> _createRandomData(
      List<dynamic> data,
      String answer,
      int limit,
      ) {
    final strData = data.map((e) => e.toString()).toSet().toList();
    strData.shuffle();

    final randomData =
    strData.take(min(limit, strData.length)).toList();

    if (!randomData.contains(answer)) {
      randomData.add(answer);
    }

    return _shuffle(randomData);
  }

  /// Перемешивание
  static List<String> _shuffle(List<String> list) {
    final random = Random();
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }

  /// Отправка ответа пользователя
  static Future<Map<String, dynamic>> updateUserAnsweredQuestion({
    required Map<String, dynamic> answerData,
    String mode = 'topic',
  }) async {
    try {
      final res = await ApiService.post(
        'user-answers',
        {'data': answerData},
      );

      if (res['error'] == null) {
        return {'status': 'success'};
      }

      return {
        'status': 'error',
        'message': res['error']?['message'],
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}
