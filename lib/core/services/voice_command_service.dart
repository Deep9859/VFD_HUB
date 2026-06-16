import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'permissions_service.dart';

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _initAttempted = false;
  bool _isListening = false;

  Future<void> initialize() async {
    if (_initAttempted) return;
    _initAttempted = true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    } on PlatformException {
      _isInitialized = false;
    } on Object {
      _isInitialized = false;
    }
  }

  Future<bool> startListening(Function(String) onResult) async {
    if (!_isInitialized) await initialize();
    if (_isListening) return false;
    if (!await PermissionsService.ensureMicrophone()) return false;

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
    return true;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  VoiceCommand? parseCommand(String text) {
    text = text.toLowerCase().trim();

    if (text.contains('search') || text.contains('find')) {
      return VoiceCommand(type: CommandType.openSearch);
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

    const vendors = ['abb', 'siemens', 'delta', 'schneider', 'danfoss'];
    for (final vendor in vendors) {
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
  openSearch,
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
  final Object? heroTag;

  const VoiceCommandButton({
    super.key,
    required this.onCommand,
    this.heroTag = 'voice-command-fab',
  });

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  final _voiceService = VoiceCommandService();
  late AnimationController _animController;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _voiceService.initialize();
    if (mounted) setState(() => _ready = true);
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
      final started = await _voiceService.startListening((text) {
        final command = _voiceService.parseCommand(text);
        widget.onCommand(command);
        _animController.stop();
        setState(() {});
      });
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice commands'),
          ),
        );
        return;
      }
      _animController.repeat();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || !_voiceService.isAvailable) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      heroTag: widget.heroTag,
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
