import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileSoundTab extends StatefulWidget {
  const ProfileSoundTab({super.key});

  @override
  State<ProfileSoundTab> createState() => _ProfileSoundTabState();
}

class _ProfileSoundTabState extends State<ProfileSoundTab>
    with AutomaticKeepAliveClientMixin {
  bool soundEnabled = false;
  double soundVolume = 50;

  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserSound();
  }

  Future<void> _loadUserSound() async {
    final res = await AuthService.getUser();

    if (!mounted) return;

    if (res['status'] == 'success') {
      final user = res['user'];

      soundEnabled = user['sound'] ?? false;
      soundVolume =
      soundEnabled ? (user['volume_sound'] ?? 50).toDouble() : 0;
    }

    setState(() => isLoading = false);
  }

  /// 🔊 SWITCH
  Future<void> _toggleSound(bool value) async {
    setState(() {
      soundEnabled = value;
      if (!value) {
        soundVolume = 0;
      } else if (soundVolume == 0) {
        soundVolume = 10;
      }
    });

    await AuthService.updateUser({
      'sound': soundEnabled,
      'volume_sound': soundVolume.toInt(),
    });
  }

  /// 🎚 SLIDER
  Future<void> _updateVolume(double value) async {
    setState(() {
      soundVolume = value;

      if (value == 0) {
        soundEnabled = false;
      } else if (!soundEnabled) {
        soundEnabled = true;
      }
    });

    await AuthService.updateUser({
      'sound': soundEnabled,
      'volume_sound': soundVolume.toInt(),
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// ---------- SOUND SWITCH ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sound',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: soundEnabled,
                onChanged: _toggleSound,
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// ---------- VOLUME ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lautstärke',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('${soundVolume.toInt()}%'),
            ],
          ),

          Slider(
            value: soundVolume,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: _updateVolume,
          ),
        ],
      ),
    );
  }
}
