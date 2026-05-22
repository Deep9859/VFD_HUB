import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isListening = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = await _speech.initialize();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) await initialize();
    if (_isListening) return;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords.toLowerCase());
          _isListening = false;
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  VoiceCommand? parseCommand(String text) {
    text = text.toLowerCase().trim();

    if (text.contains('search') || text.contains('find')) {
      final query = text.replaceAll(RegExp(r'search|find|for'), '').trim();
      return VoiceCommand(type: CommandType.search, data: query);
    }

    if (text.contains('show') || text.contains('open')) {
      if (text.contains('fault') || text.contains('error')) {
        return VoiceCommand(type: CommandType.showFaults);
      }
      if (text.contains('manual')) {
        return VoiceCommand(type: CommandType.showManuals);
      }
      if (text.contains('calculator')) {
        return VoiceCommand(type: CommandType.showCalculator);
      }
    }

    final vendors = ['abb', 'siemens', 'delta', 'schneider', 'danfoss'];
    for (var vendor in vendors) {
      if (text.contains(vendor)) {
        return VoiceCommand(type: CommandType.selectVendor, data: vendor);
      }
    }

    if (text.contains('scan') && text.contains('qr')) {
      return VoiceCommand(type: CommandType.scanQR);
    }

    if (text.contains('compare')) {
      return VoiceCommand(type: CommandType.compare);
    }

    return null;
  }
}

enum CommandType {
  search,
  showFaults,
  showManuals,
  showCalculator,
  selectVendor,
  scanQR,
  compare,
}

class VoiceCommand {
  final CommandType type;
  final String? data;
  VoiceCommand({required this.type, this.data});
}

class VoiceCommandButton extends StatefulWidget {
  final Function(VoiceCommand?) onCommand;
  const VoiceCommandButton({super.key, required this.onCommand});

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  final _voiceService = VoiceCommandService();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _voiceService.initialize();
  }

  @override
  void dispose() {
    _animController.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  void _toggleListening() async {
    if (_voiceService.isListening) {
      await _voiceService.stopListening();
      _animController.stop();
      setState(() {});
    } else {
      await _voiceService.startListening((text) {
        final command = _voiceService.parseCommand(text);
        widget.onCommand(command);
        _animController.stop();
        setState(() {});
      });
      _animController.repeat();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _toggleListening,
      backgroundColor: _voiceService.isListening ? Colors.red : Colors.blue,
      child: _voiceService.isListening
          ? AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Icon(Icons.mic, size: 24 + (_animController.value * 8));
              },
            )
          : const Icon(Icons.mic_none),
    );
  }
}
