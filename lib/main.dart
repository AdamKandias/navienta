import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _detectedText = "";
  final String _selectedLocaleId = "id_ID"; // Default language
  List<LocaleName> _locales = [];
  double speedYou = 0;
  double speedFront = 0;
  double speedFrontRight = 0;
  String overtakingStatus = "Tidak";
  late AnimationController _animationController;
  bool isCanTriggerAgain = true;
  bool isTTSProcessing = false;

  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _initializePermissions().then((granted) {
      if (granted) {
        _speechToText = SpeechToText();
        _initializeSpeechRecognition();
        _startUpdatingSpeedValues();
      } else {
        debugPrint("Microphone permission not granted");
      }
    });

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<bool> _initializePermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    return status.isGranted;
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          _restartListening();
        }
      },
      onError: (error) {
        debugPrint("Speech error: $error");
        if (_isListening && !isTTSProcessing) {
          // Tambahkan timeout atau jeda kecil
          Future.delayed(const Duration(milliseconds: 500), () {
            _restartListening();
          });
        }
      },
    );

    if (available) {
      _locales = await _speechToText.locales();
      setState(() {});
      _startListening(); // Start listening automatically
    } else {
      debugPrint("Speech recognition not available");
    }
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("id-ID"); // Set default language for TTS
    _flutterTts.setSpeechRate(0.9); // Adjust speech rate
    _flutterTts.setPitch(1.0); // Adjust pitch
  }

  void _startListening() async {
    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            if (isCanTriggerAgain && !isTTSProcessing) {
              dev.log(_detectedText);
              _detectedText = result.recognizedWords.toLowerCase();

              if (_detectedText.contains("hai nav") ||
                  _detectedText.contains("hai naf") ||
                  _detectedText.contains("hai novi")) {
                _triggerVisualEffect();
              }

              if (_detectedText.contains("kecepatan mobil") &&
                  !isTTSProcessing) {
                double currentSpeedYou = speedYou;
                _detectedText = '';

                // Log ketika TTS dipanggil
                dev.log("sedang dipanggil nich!!!");

                // Panggil TTS

                _respondWithTTS(
                        "Kecepatan mobilmu saat ini adalah ${currentSpeedYou.toStringAsFixed(1)} km/jam.")
                    .then((_) {
                  // Setelah TTS selesai, izinkan trigger lagi
                });
              }
            }
          });
        },
        localeId: _selectedLocaleId,
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _restartListening() async {
    await _speechToText.stop();
    _startListening();
  }

  Future<void> _respondWithTTS(String answer) async {
    if (isTTSProcessing) {
      // Jika TTS sedang diproses, tolak panggilan baru
      dev.log("gakbisa lagi bre");
      return;
    }
    isTTSProcessing = true; // Tandai TTS sedang diproses
    await _flutterTts.speak(answer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(answer),
        duration: const Duration(seconds: 3),
      ),
    );
    _flutterTts.setCompletionHandler(() {
      _restartListening();
      isTTSProcessing = false;
      isCanTriggerAgain = true;
    });
  }

  void _triggerVisualEffect() {
    // Start the animation
    _animationController.reset();
    _animationController.forward();

    // Automatically stop the animation and hide the effect after ....time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          _detectedText = ""; // Clear detected text after the effect
        });
      }
    });
  }

  void _startUpdatingSpeedValues() {
    final random = Random();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        speedYou = random.nextDouble() * 100;
        speedFront = random.nextDouble() * 100;
        speedFrontRight = random.nextDouble() * 100;

        // Logic to determine overtaking safety
        overtakingStatus = (speedYou > speedFront && speedYou > speedFrontRight)
            ? "Iya"
            : "Tidak";
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navienta'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Dashboard Kecepatan
              Expanded(
                flex: 8,
                child: Row(
                  children: [
                    Expanded(
                        child: _buildGridItem("Kecepatanmu",
                            "${speedYou.toStringAsFixed(1)} km/h")),
                    Expanded(
                        child: _buildGridItem("Kecepatan Mobil Depan",
                            "${speedFront.toStringAsFixed(1)} km/h")),
                    Expanded(
                        child: _buildGridItem("Kecepatan Mobil Depan Kanan",
                            "${speedFrontRight.toStringAsFixed(1)} km/h")),
                    Expanded(
                        child: _buildGridItemWhiteText(
                      "Aman untuk Nyalip?",
                      overtakingStatus,
                      overtakingStatus == "Iya" ? Colors.green : Colors.red,
                    )),
                  ],
                ),
              ),
              // Info Voice Recognition
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Listening: ${_isListening ? "Yes" : "No"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      _detectedText.contains('hai nav') ||
                              _detectedText.contains('hai nov') ||
                              _detectedText.contains('hai nafi')
                          ? 'Detected Text: Hai Navi!'
                          : 'Detected Text: $_detectedText',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Visual Effect Overlay with Message
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value,
                  child: Container(
                    width: 200 * _animationController.value,
                    height: 200 * _animationController.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: _animationController
                            .value, // Fade-in effect for the text
                        child: const Text(
                          "Hai Driver!\nMau apa?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGridItem(String title, String value, [Color? color]) {
  return Container(
    color: color ?? Colors.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildGridItemWhiteText(String title, String value, [Color? color]) {
  return Container(
    color: color ?? Colors.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          value,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
