import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class CookingModeScreen extends StatefulWidget {
  final RecipeModel recipe;
  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  
  // Timer logic
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = minutes * 60;
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        _showTimerFinishedDialog();
      }
    });
  }

  void _showTimerFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Waktu Habis!'),
        content: const Text('Timer memasak Anda sudah selesai.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.recipe.steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: Icon(_isTimerRunning ? Icons.timer : Icons.timer_outlined, color: Colors.amber),
            onPressed: () => _showSetTimerDialog(),
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Langkah ${_currentStep + 1} dari ${widget.recipe.steps.length}',
                  style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        step.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _currentStep--),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                      )
                    else
                      const SizedBox(),
                    if (_currentStep < widget.recipe.steps.length - 1)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _currentStep++),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Lanjut'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Selesai'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_isTimerRunning)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Timer: ${_formatTime(_secondsRemaining)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSetTimerDialog() {
    int selectedMinutes = 5;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Timer Masak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berapa menit?'),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: 10'),
              onChanged: (v) => selectedMinutes = int.tryParse(v) ?? 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              _startTimer(selectedMinutes);
              Navigator.pop(context);
            },
            child: const Text('Mulai Timer'),
          ),
        ],
      ),
    );
  }
}
