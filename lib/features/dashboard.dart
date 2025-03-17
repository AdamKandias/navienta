import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/assets.dart';
import '../widgets/animated_speedometer_without_gradient.dart';
import '../widgets/reusable_text.dart';
import '../constants/global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../constants/app_colors.dart';
import '../widgets/animated_speedometer.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
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
  String overtakingStatus = "Be Careful";
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

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Global.globalKey,
      endDrawer: NavientaDrawer(),
      backgroundColor: AppColors.backgroundPrimary,
      appBar: navientaAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 35.h,
              top: 10.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Row(
              spacing: 7.w,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 5.w,
                            left: 5.w,
                            right: 5.w,
                            bottom: 2.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12.r),
                              topLeft: Radius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 9.h),
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 4.w,
                                          height: 4.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundPrimary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors
                                                    .backgroundPrimary
                                                    .withAlpha(100),
                                                spreadRadius: 5,
                                                offset: Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15.h,
                                        ),
                                        Flexible(
                                          child: ReusableText(
                                            text:
                                                'Apakah aman untuk menyalip ?',
                                            textAlign: TextAlign.left,
                                            textColor: AppColors.textLight,
                                            fontSize: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.r),
                                    ),
                                  ),
                                  child: _renderOvertakingStatus(
                                    overtakingStatus: overtakingStatus,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: 5.w,
                            left: 5.w,
                            right: 5.w,
                            top: 2.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 9.h),
                                  Flexible(
                                    child: ReusableText(
                                      text: 'Voice Asisstant',
                                      textAlign: TextAlign.left,
                                      textColor: AppColors.textLight,
                                      fontSize: 6,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ReusableText(
                                        text:
                                            'Listening Status: ${!_isMicrophoneOn ? "No, Please Wait" : _isListening ? "Yes" : "No, Please Activate Microphone Permission"}',
                                        textColor: AppColors.textDark,
                                        fontSize: 6,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      ReusableText(
                                        text: 'Detected Text : $_detectedText',
                                        fontSize: 6,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(
                                        height: 50.h,
                                      ),
                                      Container(
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withAlpha(100),
                                              spreadRadius: 10,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Container(
                                            margin: EdgeInsets.all(5.h),
                                            child: Image.asset(
                                              Assets.narrator,
                                              width: 45.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 5.w,
                            left: 5.w,
                            right: 5.w,
                            bottom: 2.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12.r),
                              topLeft: Radius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 9.h),
                                        Flexible(
                                          child: ReusableText(
                                            text: 'Status kendaraan anda',
                                            textAlign: TextAlign.left,
                                            textColor: AppColors.textLight,
                                            fontSize: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 40.h,
                                                  left: 3.w,
                                                ),
                                                child: AnimatedSpeedometer(
                                                  value: 70,
                                                  height: 15.w,
                                                  width: 19.w,
                                                ),
                                              ),
                                              Positioned(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 3.w,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: 80.h,
                                                      ),
                                                      ReusableText(
                                                        text: speedYou
                                                            .toStringAsFixed(1),
                                                        fontSize: 15,
                                                      ),
                                                      ReusableText(
                                                        text: 'KM/JAM',
                                                        fontSize: 5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      ReusableText(
                                                        text:
                                                            'Kecepatan saat ini',
                                                        fontSize: 4,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Expanded(
                                          child: Column(
                                            spacing: 4.h,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ReusableText(
                                                text: 'Batas Kecepatan',
                                                fontSize: 6,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              _speedLimitGuide(
                                                icon: Icons.add_road,
                                                text:
                                                    'Jalan Tol: 60-100 km/jam',
                                              ),
                                              _speedLimitGuide(
                                                icon:
                                                    Icons.emoji_transportation,
                                                text:
                                                    'Jalan Antarkota: Maks 80 km/jam',
                                              ),
                                              _speedLimitGuide(
                                                icon: Icons.apartment_outlined,
                                                text:
                                                    'Perkotaan: Maks 50 km/jam',
                                              ),
                                              _speedLimitGuide(
                                                icon: Icons.cottage,
                                                text:
                                                    'Pemukiman: Maks 30 km/jam',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: 5.w,
                            left: 5.w,
                            right: 5.w,
                            top: 2.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 9.h),
                                  Flexible(
                                    child: ReusableText(
                                      text: 'Status Kendaraan Depan',
                                      textAlign: TextAlign.left,
                                      textColor: AppColors.textLight,
                                      fontSize: 6,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Expanded(
                                child: Row(
                                  spacing: 5.w,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.r),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 40.h,
                                                    ),
                                                    child:
                                                        AnimatedSpeedometerWithoutGradient(
                                                      value: 20,
                                                      height: 15.w,
                                                      width: 19.w,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 50.h,
                                                        ),
                                                        ReusableText(
                                                          text: speedFront
                                                              .toStringAsFixed(
                                                                  1),
                                                          fontSize: 15,
                                                        ),
                                                        ReusableText(
                                                          text: 'KM/JAM',
                                                          fontSize: 5,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        ReusableText(
                                                          text:
                                                              'Kecepatan saat ini',
                                                          fontSize: 4,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.r),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        ReusableText(
                                                          text: '100',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        Column(
                                                          children: [
                                                            ReusableText(
                                                              text: 'M',
                                                              fontSize: 5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                            SizedBox(
                                                              height: 10.h,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    ReusableText(
                                                      textAlign: TextAlign.left,
                                                      text:
                                                          'Jarak kendaraan\ndi depan',
                                                      fontSize: 3.8,
                                                      textColor: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/car.png",
                                                      fit: BoxFit.fill,
                                                      height: 70.h,
                                                    ),
                                                    Image.asset(
                                                      "assets/images/up-down-arrow.png",
                                                      fit: BoxFit.fill,
                                                      height: 32.h,
                                                    ),
                                                    Image.asset(
                                                      "assets/images/car.png",
                                                      fit: BoxFit.fill,
                                                      height: 70.h,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              bottom: 5,
                                              left: 5,
                                              child: InkWell(
                                                onTap: () {},
                                                child: Row(
                                                  spacing: 1.w,
                                                  children: [
                                                    Icon(
                                                      Icons.info,
                                                      size: 6.w,
                                                      color: AppColors.primary,
                                                    ),
                                                    ReusableText(
                                                      text: 'Aturan Jarak',
                                                      fontSize: 3.5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              switch (overtakingStatus) {
                case "Safe":
                  overtakingMessage = "It is safe to overtake.";
                  break;
                case "Be Careful":
                  overtakingMessage = "It is okey but aware and be careful!";
                  break;
                default:
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

        // Logic for overtaking safety (only considering speedFront)
        if (speedYou > speedFront + 10) {
          overtakingStatus = "Safe";
        } else if (speedYou > speedFront) {
          overtakingStatus = "Be Careful";
        } else {
          overtakingStatus = "Not Safe";
        }
      });
    });
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

Widget _speedLimitGuide({
  required IconData icon,
  required String text,
}) =>
    Row(
      spacing: 2.w,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 8.w,
          color: AppColors.primary,
        ),
        Flexible(
          child: ReusableText(
            text: text,
            fontSize: 4,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

Widget _renderOvertakingStatus({required String overtakingStatus}) {
  if (overtakingStatus == "Safe") {
    return Column(
      spacing: 5.h,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 100.h,
          color: AppColors.success,
          shadows: [
            BoxShadow(
              color: AppColors.success.withAlpha(
                150,
              ),
              spreadRadius: 0,
              blurRadius: 100,
            ),
          ],
        ),
        ReusableText(
          text: 'Aman',
          fontSize: 7,
        ),
        Flexible(
          child: ReusableText(
            text:
                'Kecepatan kendaraan didepan tidak memungkinkan untuk menyalip\ndengan aman. Pastikan ada ruang yang cukup sebelum mencoba',
            fontSize: 4,
            textColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  } else if (overtakingStatus == "Not Safe") {
    return Column(
      spacing: 5.h,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.dangerous,
          size: 100.h,
          color: AppColors.danger,
          shadows: [
            BoxShadow(
              color: AppColors.danger.withAlpha(
                150,
              ),
              spreadRadius: 0,
              blurRadius: 100,
            ),
          ],
        ),
        ReusableText(
          text: 'Bahaya!',
          fontSize: 7,
        ),
        Flexible(
          child: ReusableText(
            text:
                'Kecepatan kendaraan didepan tidak memungkinkan untuk menyalip\ndengan aman. Pastikan ada ruang yang cukup sebelum mencoba',
            fontSize: 4,
            textColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  return Column(
    spacing: 5.h,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(
        Icons.warning,
        size: 100.h,
        color: AppColors.warning,
        shadows: [
          BoxShadow(
            color: AppColors.warning.withAlpha(
              150,
            ),
            spreadRadius: 0,
            blurRadius: 100,
          ),
        ],
      ),
      ReusableText(
        text: 'Hati - hati',
        fontSize: 7,
      ),
      Flexible(
        child: ReusableText(
          text:
              'Kecepatan kendaraan didepan tidak memungkinkan untuk menyalip\ndengan aman. Pastikan ada ruang yang cukup sebelum mencoba',
          fontSize: 4,
          textColor: AppColors.textSecondary,
        ),
      ),
    ],
  );
}
