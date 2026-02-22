import '../models/topic_progress_item.dart';
import 'category_service.dart';

class TopicsCacheService {
  static final TopicsCacheService _instance = TopicsCacheService._internal();

  factory TopicsCacheService() => _instance;

  TopicsCacheService._internal();

  final Map<int, List<TopicProgressItem>> _cache = {};

  final Map<int, bool> _hasLoadedOnce = {};

  Future<List<TopicProgressItem>> getCategoriesForClass({
    required int categoryClassId,
    required Function(List<TopicProgressItem>) onUpdate,
  }) async {
    if (_cache.containsKey(categoryClassId) &&
        _hasLoadedOnce[categoryClassId] == true) {
      final cachedData = _cache[categoryClassId]!;

      _updateInBackground(categoryClassId, onUpdate);

      return cachedData;
    }

    final categories = await CategoryService.getCategoriesByClass(
      categoryClassId: categoryClassId,
      isAdmin: false,
    );

    final items =
        categories.map<TopicProgressItem>((cat) {
          return TopicProgressItem(
            categoryId: cat['id'],
            title: cat['attributes']['name'],
            done: cat['answers'] ?? 0,
            total: cat['questions'] ?? 0,
          );
        }).toList();

    _cache[categoryClassId] = items;
    _hasLoadedOnce[categoryClassId] = true;

    return items;
  }

  Future<void> _updateInBackground(
    int categoryClassId,
    Function(List<TopicProgressItem>) onUpdate,
  ) async {
    try {
      final categories = await CategoryService.getCategoriesByClass(
        categoryClassId: categoryClassId,
        isAdmin: false,
      );

      final items =
          categories.map<TopicProgressItem>((cat) {
            return TopicProgressItem(
              categoryId: cat['id'],
              title: cat['attributes']['name'],
              done: cat['answers'] ?? 0,
              total: cat['questions'] ?? 0,
            );
          }).toList();

      _cache[categoryClassId] = items;

      onUpdate(items);
    } catch (e) {
      print('Background update failed for class $categoryClassId: $e');
    }
  }

  void clearCache() {
    _cache.clear();
    _hasLoadedOnce.clear();
  }

  void clearCacheForClass(int categoryClassId) {
    _cache.remove(categoryClassId);
    _hasLoadedOnce.remove(categoryClassId);
  }
}
