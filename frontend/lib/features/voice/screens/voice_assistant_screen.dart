import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/utils/constants.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isProcessing = false;
  String _transcript = '';
  String _status = 'Tap the mic to start speaking';
  String _aiResponse = '';
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (_isListening) {
              setState(() {
                _isListening = false;
              });
              if (_transcript.isNotEmpty) {
                _processVoiceQuery(_transcript);
              }
            }
          }
        },
        onError: (val) => debugPrint('STT Error: $val'),
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  void _toggleListening() async {
    if (_isProcessing) return;

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _status = 'Processing your question...';
      });
      if (_transcript.isNotEmpty) {
        _processVoiceQuery(_transcript);
      }
    } else {
      setState(() {
        _transcript = '';
        _aiResponse = '';
      });

      if (_speechAvailable) {
        setState(() {
          _isListening = true;
          _status = 'Listening... Speak your question';
        });
        await _speech.listen(
          onResult: (val) {
            setState(() {
              _transcript = val.recognizedWords;
            });
          },
          localeId: _getLocaleId(_selectedLanguage),
        );
      } else {
        // Fallback for emulator or devices without active speech engine
        _simulateDemoQuery();
      }
    }
  }

  String _getLocaleId(String lang) {
    switch (lang) {
      case 'hi':
        return 'hi_IN';
      case 'te':
        return 'te_IN';
      case 'ta':
        return 'ta_IN';
      case 'mr':
        return 'mr_IN';
      default:
        return 'en_IN';
    }
  }

  Future<void> _simulateDemoQuery() async {
    setState(() {
      _isListening = true;
      _status = 'Listening...';
      _transcript = 'How to treat yellow leaf spots in paddy crop?';
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isListening = false;
    });
    await _processVoiceQuery(_transcript);
  }

  Future<void> _processVoiceQuery(String queryText) async {
    setState(() {
      _isProcessing = true;
      _status = 'Gemini AI is generating voice response...';
    });

    final api = ref.read(dioProvider);
    final audioService = ref.read(audioServiceProvider);

    try {
      final res = await api.post<Map<String, dynamic>>(
        ApiEndpoints.aiQuery,
        data: {
          'query_text': queryText,
          'target_language': _selectedLanguage,
          'crop_type': 'Rice',
        },
        parser: (d) => Map<String, dynamic>.from(d),
      );

      if (res.success && res.data != null) {
        final responseText = res.data!['response_text'] ?? '';
        final audioBase64 = res.data!['audio_response_base64'];

        setState(() {
          _isProcessing = false;
          _status = 'Response received';
          _aiResponse = responseText;
        });

        if (audioBase64 != null && audioBase64.toString().isNotEmpty) {
          await audioService.playBase64Audio(audioBase64.toString());
        }
      } else {
        setState(() {
          _isProcessing = false;
          _status = 'Failed to get response. Tap mic to try again.';
          _aiResponse = 'Sorry, could not process your query.';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error connecting to service.';
        _aiResponse = 'Network error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Language Selector Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.record_voice_over, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Voice Advisory',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: const Color(0xFF2E7D32),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: AppConstants.supportedLanguages.map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(AppConstants.languageNames[code] ?? code),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedLanguage = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Transcript Display
                      Text(
                        _transcript.isEmpty
                            ? 'Speak your question in ${AppConstants.languageNames[_selectedLanguage]}\ne.g. "How to treat yellow leaves in paddy?"'
                            : '"$_transcript"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ).animate().fade(duration: 400.ms),
                      const SizedBox(height: 24),

                      // AI Response Card
                      if (_aiResponse.isNotEmpty)
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.psychology, color: Color(0xFF2E7D32)),
                                    SizedBox(width: 8),
                                    Text('Agrolith Answer',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32),
                                            fontSize: 15)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _aiResponse,
                                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),

                      const Spacer(),

                      // Status Text
                      Text(
                        _status,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // Microphone Button
                      GestureDetector(
                        onTap: _toggleListening,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? Colors.redAccent
                                : (_isProcessing ? Colors.amber : Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.mic
                                : (_isProcessing ? Icons.hourglass_top : Icons.mic_none),
                            size: 48,
                            color: _isListening || _isProcessing
                                ? Colors.white
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
