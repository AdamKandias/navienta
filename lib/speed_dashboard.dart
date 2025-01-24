import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SpeedDashboard extends StatefulWidget {
  const SpeedDashboard({super.key});

  @override
  State<SpeedDashboard> createState() => _SpeedDashboardState();
}

class _SpeedDashboardState extends State<SpeedDashboard> {
  double speedYou = 0;
  double speedFront = 0;
  double speedFrontRight = 0;
  String overtakingStatus = "Tidak";

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final random = Random();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Kecepatan"),
      ),
      body: Row(
        children: [
          Expanded(
            child: _buildGridItem(
                "Kecepatanmu", "${speedYou.toStringAsFixed(1)} km/h"),
          ),
          Expanded(
            child: _buildGridItem("Kecepatan Mobil Depan",
                "${speedFront.toStringAsFixed(1)} km/h"),
          ),
          Expanded(
            child: _buildGridItem("Kecepatan Mobil Depan Kanan",
                "${speedFrontRight.toStringAsFixed(1)} km/h"),
          ),
          Expanded(
            child: _buildGridItem(
              "Aman untuk Nyalip?",
              overtakingStatus,
              overtakingStatus == "Iya" ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
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
}
