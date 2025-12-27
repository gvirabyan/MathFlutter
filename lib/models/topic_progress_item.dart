class TopicProgressItem {
  final int categoryId;
  final String title;
  final int done;
  final int total;

  TopicProgressItem({
    required this.categoryId,
    required this.title,
    required this.done,
    required this.total,
  });

  factory TopicProgressItem.fromJson(Map<String, dynamic> json) {
    return TopicProgressItem(
      categoryId: json['category_id'],
      title: json['title'],
      done: json['done'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
