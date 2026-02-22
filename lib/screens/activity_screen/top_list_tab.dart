import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_colors.dart';
import '../../app_start.dart';
import '../../services/auth_service.dart';
import '../../services/top_list_service.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/open_circle_gauge.dart';

class TopListTab extends StatefulWidget {
  const TopListTab({super.key});

  @override
  State<TopListTab> createState() => _TopListTabState();
}

class _TopListTabState extends State<TopListTab> {
  final TopListService _service = TopListService();

  bool isLoading = true;

  Map<String, dynamic> user = {};
  Map<String, dynamic> rankings = {};

  TopListCategory? selectedCategory;

  final List<TopListCategory> categories = [
    TopListCategory(
      title: 'In deiner Klasse',
      fieldName: 'Klasse',
      key: 'course',
    ),
    TopListCategory(
      title: 'In deiner Schule',
      fieldName: 'Schule',
      key: 'institution',
    ),
    TopListCategory(title: 'In deiner Stadt', fieldName: 'Stadt', key: 'city'),
    TopListCategory(title: 'In deniem Land', fieldName: 'Land', key: 'country'),
    TopListCategory(title: 'In der Welt', fieldName: 'Welt', key: 'world'),
  ];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => isLoading = true);

    try {
      // 1) user
      final resUser = await AuthService.getUser();
      if (resUser['status'] == 'success') {
        user = (resUser['user'] as Map).cast<String, dynamic>();
      }

      // fallback: иногда points может храниться где-то ещё
      if (user.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final points = prefs.getInt('points');
        if (points != null) user['points'] = points;
      }

      // 2) rankings
      rankings = await TopListService.getRankings();

      // 3) заполнить UI как в Vue watch(rankings)
      for (final c in categories) {
        final r = rankings[c.key];
        if (r is Map) {
          final rm = r.cast<String, dynamic>();
          c.place = rm['my_place']?.toString();
          final usersAmount = rm['users_amount']?.toString();
          if (usersAmount != null) {
            c.fromText = 'aus $usersAmount Spielern';
          }
          c.points = rm['points']?.toString();
        } else {
          c.place = null;
          c.fromText = null;
          c.points = null;
        }
      }
    } catch (e, s) {
      debugPrint('❌ TopList load error: $e');
      debugPrintStack(stackTrace: s);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool _canOpenCategory(TopListCategory c) {
    if (c.key == 'world') return true;
    final v = user[c.key];
    return v != null && v.toString().trim().isNotEmpty;
  }

  void _chooseCategory(TopListCategory c) {
    if (_canOpenCategory(c)) {
      setState(() => selectedCategory = c);
    } else {
      MainScreen.of(context)?.setMainIndex(3);
    }
  }

  void _backToMenu() {
    setState(() => selectedCategory = null);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: LoadingOverlay()),
      );
    }

    // 2-й экран: TopListSingle
    if (selectedCategory != null) {
      return TopListSingle(
        category: selectedCategory!,
        onBack: _backToMenu,
        service: _service,
      );
    }

    // 1-й экран: меню как в Vue
    final points =
        (user['points'] is num)
            ? (user['points'] as num).toInt()
            : int.tryParse(user['points']?.toString() ?? '') ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _CirclePoints(points: points),
          const SizedBox(height: 16),
          ...categories.map(
            (c) => _TopListMenuCard(
              category: c,
              enabled: _canOpenCategory(c),
              onTap: () => _chooseCategory(c),
            ),
          ),
        ],
      ),
    );
  }
}

class TopListCategory {
  final String title; // UI
  final String fieldName; // UI
  final String key; // backend key

  String? place;
  String? fromText;
  String? points;

  TopListCategory({
    required this.title,
    required this.fieldName,
    required this.key,
    this.place,
    this.fromText,
    this.points,
  });
}

class _CirclePoints extends StatelessWidget {
  final int points;

  const _CirclePoints({required this.points});

  @override
  Widget build(BuildContext context) {
    return OpenCircleGauge(
      percent: 100,
      // полный круг
      size: 180,
      strokeWidth: 8,
      color: const Color(0xFFEDE7FF),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$points',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text('Punkte'),
        ],
      ),
    );
  }
}

class _TopListMenuCard extends StatelessWidget {
  final TopListCategory category;
  final bool enabled;
  final VoidCallback onTap;

  const _TopListMenuCard({
    required this.category,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final place = category.place;
    final points = category.points ?? '0';

    return Opacity(
      opacity: enabled ? 1 : 1, //changeddd!!
      child: InkWell(
        onTap: enabled ? onTap : onTap, // Vue тоже даёт тап, но внутри решает
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color(0xf535353),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (place != null)
                    Text(
                      '$place Platz',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child:
                        place != null
                            ? Text(
                              category.fromText ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            )
                            : Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Bitte Update: '),
                                  TextSpan(
                                    text: category.fieldName,
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(color: Colors.black54),
                            ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopListSingle extends StatefulWidget {
  final TopListCategory category;
  final VoidCallback onBack;
  final TopListService service;

  const TopListSingle({
    super.key,
    required this.category,
    required this.onBack,
    required this.service,
  });

  @override
  State<TopListSingle> createState() => _TopListSingleState();
}

class _TopListSingleState extends State<TopListSingle> {
  bool isLoading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      items = await TopListService.getTopListByCategory(widget.category.key);
    } catch (e, s) {
      debugPrint('❌ TopListSingle error: $e');
      debugPrintStack(stackTrace: s);
      items = [];
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ← Zurück zur Top-List
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: GestureDetector(
            onTap: widget.onBack,
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Text(
                  'Zurück zur Top-List',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // ФИОЛЕТОВАЯ КАРТОЧКА (как на скрине)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4ECFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // LEFT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.category.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.category.fromText ?? '',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const Spacer(),

                // RIGHT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.category.place != null)
                      Text(
                        '${widget.category.place} Platz',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (widget.category.points != null)
                      Text(
                        '${widget.category.points} Punkte',
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // СПИСОК
        Expanded(
          child:
              isLoading
                  ? const Center(child: LoadingOverlay())
                  : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final u = items[index];
                      final username = u['username']?.toString() ?? '—';
                      final points = _toInt(u['points']);
                      final currentItemPlace = index + 1;
                      final bool isMe = currentItemPlace == int.tryParse(widget.category.place ?? '');
                      return Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isMe ? AppColors.primaryPurple : Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            '$points',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
