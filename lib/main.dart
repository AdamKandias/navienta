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
      debugShowCheckedModeBanner: false,
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
  String _selectedLocaleId = "en-US"; // Default language
  List<LocaleName> _locales = [];
  double speedYou = 0;
  double speedFront = 0;
  double speedFrontRight = 0;
  String overtakingStatus = "Tidak";
  late AnimationController _animationController;
  bool isTTSProcessing = false;
  bool _isVisualEffectTriggered = false;
  late Timer _timer;
  String _currentLanguageName = "English";
  bool _isMicrophoneOn = false;

  @override
  void initState() {
    super.initState();
    _initializePermissions().then((granted) {
      if (granted) {
        _speechToText = SpeechToText();
        _initializeTTS();
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
          setState(() {
            _isMicrophoneOn = false;
          });
          // Tambahkan timeout atau jeda kecil
          Future.delayed(const Duration(milliseconds: 500), () {
            _restartListening();
          });
        }
      },
    );

    if (available) {
      _locales = await _speechToText.locales();
      setState(() {
        _isMicrophoneOn = true;
      });
      _startListening(); // Start listening automatically
    } else {
      setState(() {
        _isMicrophoneOn = false;
      });
      debugPrint("Speech recognition not available");
    }
  }

  void _initializeTTS() async {
    _flutterTts = FlutterTts();
    _locales = await _speechToText.locales();
    // for (var locale in _locales) {
    //   print('ID: ${locale.localeId}, Name: ${locale.name}');
    // }

    // Cek apakah ada locale bahasa Inggris
    var englishLocale = _locales.firstWhere(
      (locale) => locale.localeId == 'en_US', // Prioritaskan en_US
      orElse: () => _locales.firstWhere(
        (locale) => locale.localeId
            .startsWith('en_GB'), // Jika tidak ada en_US, cari en_GB
        orElse: () => _locales.firstWhere(
          (locale) => locale.localeId.startsWith('en'), //
          orElse: () =>
              _locales.first, // Jika tidak ditemukan, gunakan default pertama
        ),
      ),
    );

    // List<dynamic> languages = await _flutterTts.getLanguages;
    // print(languages);
    // // Gunakan locale bahasa Inggris jika tersedia, jika tidak gunakan default
    _selectedLocaleId = englishLocale.localeId;
    _currentLanguageName = englishLocale.name;
    _flutterTts.setLanguage('en-US'); // Set default language for TTS
    _flutterTts.setSpeechRate(0.5); // Adjust speech rate
    _flutterTts.setPitch(1.0); // Adjust pitch
  }

  void _startListening() async {
    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) async {
          if (!isTTSProcessing) {
            dev.log(_detectedText);
            setState(() {
              _detectedText = result.recognizedWords.toLowerCase();
            });
            // navi effect
            if ((_detectedText.startsWith("hi") ||
                        _detectedText.startsWith("hey")) &&
                    (_detectedText.contains(" naf") ||
                        _detectedText.contains(" nephe") ||
                        _detectedText.contains(" not") ||
                        _detectedText.contains(" enough")) ||
                _detectedText.contains("i love") ||
                _detectedText == "hi") {
              _triggerVisualEffect();
              return;
            }
            // my car speed
            if (_detectedText.contains("my car speed")) {
              double currentYourSpeed = speedYou;
              setState(() {
                _detectedText = '';
              });
              await _respondWithTTS(
                      "${currentYourSpeed.toStringAsFixed(1)} kilo per hour is the speed of your car.")
                  .then((_) {});
            }
            // front car speed
            if (_detectedText.contains("front car speed")) {
              double currentFrontSpeed = speedFront;
              setState(() {
                _detectedText = '';
              });
              await _respondWithTTS(
                      "${currentFrontSpeed.toStringAsFixed(1)} kilo per hour is the speed of front car.")
                  .then((_) {});
            }
            // safe to overtake
            if (_detectedText.contains("safe to overtake")) {
              double currentFrontSpeed = speedFront;
              String overtakingMessage;
              // Check if overtaking is safe
              if (overtakingStatus == "Yes") {
                overtakingMessage = "It is safe to overtake.";
              } else {
                overtakingMessage = "It is not safe to overtake.";
              }
              setState(() {
                _detectedText = '';
              });
              await _respondWithTTS(
                      "$overtakingMessage, $overtakingMessage, The front car speed is ${currentFrontSpeed.toStringAsFixed(1)} kilo per hour.")
                  .then((_) {});
            }
          }
        },
        localeId: _selectedLocaleId,
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.deviceDefault,
        ),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _restartListening() async {
    await _speechToText.stop();
    setState(() {
      _isMicrophoneOn = true;
    });
    _startListening();
  }

  Future<void> _respondWithTTS(String answer) async {
    if (isTTSProcessing) {
      // Jika TTS sedang diproses, tolak panggilan baru
      return;
    }
    setState(() {
      isTTSProcessing = true; // Tandai TTS sedang diproses
    });
    dev.log(isTTSProcessing.toString());
    await _flutterTts.speak(answer);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(answer.replaceAll('kilo per hour', 'km/h')),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    _flutterTts.setCompletionHandler(() {
      _restartListening();
      setState(() {
        isTTSProcessing = false;
      });
      dev.log(isTTSProcessing.toString());
    });
  }

  void _triggerVisualEffect() {
    if (_isVisualEffectTriggered) {
      return;
    }
    _isVisualEffectTriggered = true;
    // Start the animation
    _animationController.reset();
    _animationController.forward();

    // Automatically stop the animation and hide the effect after ....time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _isVisualEffectTriggered = false;
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
            ? "Yes"
            : "No";
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
        actions: [
          Icon(
            Icons.language,
            size: 20,
            color: Colors.grey[700],
          ),
          Text(
            _currentLanguageName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
        ],
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blueAccent[100],
        title: const Text(
          'Navienta',
        ),
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
                        child: _buildGridItem("Your Speed",
                            "${speedYou.toStringAsFixed(1)} km/h")),
                    Expanded(
                        child: _buildGridItem("Front Car Speed",
                            "${speedFront.toStringAsFixed(1)} km/h")),
                    Expanded(
                        child: _buildGridItem("Front Right Car Speed",
                            "${speedFrontRight.toStringAsFixed(1)} km/h")),
                    Expanded(
                        child: _buildGridItemWhiteText(
                      "Safe to Overtake?",
                      overtakingStatus,
                      overtakingStatus == "Yes" ? Colors.green : Colors.red,
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
                      'Listening: ${!_isMicrophoneOn ? "No, Please Wait" : _isListening ? "Yes" : "No, Please Activate Microphone Permission"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      _isVisualEffectTriggered
                          ? 'Detected Text: Hi Navi!'
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
                    width: 500 * _animationController.value,
                    height: 500 * _animationController.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withValues(alpha: 0.7),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: _animationController
                            .value, // Fade-in effect for the text
                        child: const Text(
                          "Hi Driver!\nNeed Something?",
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
