import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../services/user_session.dart';

class TopicProgressItemWidget extends StatefulWidget {
  final String title;
  final int done;
  final int total;
  final int? count;
  final VoidCallback? onTap;
  final VoidCallback? onGenerate;
  final VoidCallback? onReview;

  const TopicProgressItemWidget({
    super.key,
    required this.title,
    required this.done,
    required this.total,
    this.count,
    this.onTap,
    this.onGenerate,
    this.onReview,
  });

  @override
  State<TopicProgressItemWidget> createState() => _TopicProgressItemWidgetState();
}

class _TopicProgressItemWidgetState extends State<TopicProgressItemWidget> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final isAdmin = await UserSession.instance.isAdmin;
    if (mounted) {
      setState(() => _isAdmin = isAdmin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${widget.done}/${widget.total}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),

            if (_isAdmin) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AdminButton(
                    label: 'Generate',
                    count: widget.count,
                    onPressed: () => widget.onGenerate?.call(),
                  ),
                  _AdminButton(
                    label: 'Review',
                    count: widget.count,
                    onPressed: () => widget.onReview?.call(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Вспомогательный мини-виджет для кнопок, чтобы не дублировать код
class _AdminButton extends StatelessWidget {
  final String label;
  final int? count;
  final VoidCallback onPressed;

  const _AdminButton({
    required this.label,
    required this.onPressed,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final bool showCount = label == 'Review' && (count ?? 0) > 0;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: showCount ? Colors.white : AppColors.primaryPurple,
        backgroundColor: showCount ? Colors.red : null,
        side: BorderSide(color: showCount ? Colors.red : AppColors.primaryPurple),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(showCount ? '$label $count' : label),
    );
  }
}
