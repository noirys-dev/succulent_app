import 'dart:async';

import 'package:flutter/material.dart';

// Brand color palette (mirrors HomeScreen)
const Color kDarkGreen = Color(0xFF76966B);
const Color kCreme = Color(0xFFF9EEDB);
const Color kCharcoal = Color(0xFF636262);

class FocusScreen extends StatefulWidget {
  final String taskTitle;
  final Duration plannedDuration;
  final String category;

  const FocusScreen({
    super.key,
    required this.taskTitle,
    required this.plannedDuration,
    this.category = 'Productivity',
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  late final Duration _originalDuration;
  late Duration _sessionTargetDuration;
  late Duration _remainingDuration;
  bool _isRunning = false;
  String _sound = 'Lofi';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _originalDuration = widget.plannedDuration;
    _sessionTargetDuration = _originalDuration;
    _remainingDuration = _sessionTargetDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds <= 0) {
        _stopTimer();
        setState(() {
          _isCompleted = true;
        });
        // Do NOT call _endFocus() automatically; user must press "End Focus"
        return;
      }
      setState(() {
        _remainingDuration = _remainingDuration - const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _finishSession() {
    Navigator.of(context).pop({
      'updatedDuration': _sessionTargetDuration,
      'completed': true,
    });
  }

  // FocusScreen returns updated duration to the caller (HomeScreen) when focus ends.
  void _endFocus() {
    _stopTimer();
    debugPrint(
      'Focus ended: ${widget.taskTitle}, planned=$_originalDuration, remaining=$_remainingDuration, sound=$_sound',
    );
    Navigator.of(context).pop({
      'completed': false,
    });
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 999999);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final h = hours.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _openDurationSheet() {
    if (_isRunning) return;
    int tempHours = _sessionTargetDuration.inHours;
    int tempMinutes = _sessionTargetDuration.inMinutes.remainder(60);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kCharcoal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NumberPicker(
                          value: tempHours,
                          max: 12,
                          label: 'h',
                          onChanged: (v) {
                            setModalState(() => tempHours = v);
                          },
                        ),
                        const SizedBox(width: 16),
                        _NumberPicker(
                          value: tempMinutes,
                          max: 59,
                          label: 'm',
                          onChanged: (v) {
                            setModalState(() => tempMinutes = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final newDuration = Duration(
                          hours: tempHours,
                          minutes: tempMinutes,
                        );
                        setState(() {
                          _sessionTargetDuration = newDuration;
                          _remainingDuration = newDuration;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: kCreme,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Set Duration'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSoundSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _SoundOption(
                label: 'None',
                onTap: () {
                  setState(() => _sound = 'None');
                  Navigator.of(context).pop();
                },
              ),
              _SoundOption(
                label: 'Lofi',
                onTap: () {
                  setState(() => _sound = 'Lofi');
                  Navigator.of(context).pop();
                },
              ),
              _SoundOption(
                label: 'White Noise',
                onTap: () {
                  setState(() => _sound = 'White Noise');
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                'Deep Focus Session',
                style: TextStyle(
                  fontSize: 16,
                  color: kCreme.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.taskTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: kCreme,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.category,
                style: TextStyle(
                  fontSize: 13,
                  color: kCreme.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _openDurationSheet,
                child: Text(
                  _formatDuration(_remainingDuration),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                    color: kCreme,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Session control buttons (Start/Stop/End/Finish)
              Builder(
                builder: (context) {
                  if (_isCompleted) {
                    // Finish Session button
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _finishSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCreme,
                          foregroundColor: kDarkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Finish Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  } else if (_isRunning) {
                    // Stop Session (outlined) + End Session (filled) buttons
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _stopTimer,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kCreme.withOpacity(0.9),
                                side: BorderSide(
                                    color: kCreme.withOpacity(0.8), width: 1.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Stop Session',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _endFocus,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kCreme,
                                foregroundColor: kDarkGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'End Session',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Start Focus button
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_sessionTargetDuration == Duration.zero)
                            ? null
                            : _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCreme,
                          foregroundColor: kDarkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Start Focus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _openSoundSheet,
                child: Text(
                  '🎧 Sound: $_sound ▾',
                  style: TextStyle(
                    fontSize: 13,
                    color: kCreme.withOpacity(0.75),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final int value;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;

  const _NumberPicker({
    required this.value,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
        Text(
          '$value$label',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
      ],
    );
  }
}

class _SoundOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SoundOption({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
