import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Singleton экземпляр
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  // Один плеер на всё приложение
  final AudioPlayer _player = AudioPlayer();

  // Внутренние флаги состояния
  bool _isSoundEnabled = true;

  // Карта соответствия имен файлов путям в assets
  final Map<String, String> _audioMap = {
    'lose': 'audios/lose.mp3',
    'skipped': 'audios/skipped.mp3',
    'notification': 'audios/notification.mp3',
    'achtung_short': 'audios/achtung_short.mp3',
    'correct': 'audios/correct.wav',
    'draw': 'audios/draw.wav',
    'win': 'audios/win.wav',
    'wrong': 'audios/wrong.wav',
    'tabChange': 'audios/tabChange.wav',
    'formSubmit': 'audios/formSubmit.wav',
    'goalUpdate': 'audios/goalUpdate.mp3',
    'notificationOpen': 'audios/notificationOpen.mp3',
    'redirect': 'audios/redirect.mp3',
  };

  AudioService._internal();

  /// Вызывайте этот метод при инициализации приложения
  /// и каждый раз, когда пользователь меняет громкость или включает/выключает звук.
  void updateSettings({required bool enabled, required double volumePercent}) {
    _isSoundEnabled = enabled;

    // Устанавливаем громкость плееру ОДИН раз здесь
    // Значение должно быть от 0.0 до 1.0
    double vol = volumePercent / 100;
    _player.setVolume(vol);

    print("AudioSettings updated: Enabled: $enabled, Volume: $vol");
  }

  void enableSound({required bool enabled}) {
    _isSoundEnabled = enabled;
  }

  /// Основной метод для проигрывания. Принимает только имя.
  Future<void> play(String name) async {
    // Если звук выключен в настройках, просто выходим
    if (!_isSoundEnabled) return;

    final path = _audioMap[name];
    if (path == null) {
      print("Ошибка: Звук с именем '$name' не зарегистрирован.");
      return;
    }

    try {
      // Сбрасываем плеер на начало, если звук уже играет (чтобы можно было "спамить" звуком)
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (e) {
      print("Ошибка воспроизведения $name: $e");
    }
  }
}
