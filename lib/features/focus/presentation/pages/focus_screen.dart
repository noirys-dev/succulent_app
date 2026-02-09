import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

class FocusScreen extends StatefulWidget {
  final String taskTitle;
  final Duration plannedDuration;
  final int taskIndex;

  const FocusScreen({
    super.key,
    required this.taskTitle,
    required this.plannedDuration,
    required this.taskIndex,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  late final AudioPlayer _audioPlayer;
  late final Duration _originalDuration;
  late Duration _sessionTargetDuration;
  late Duration _remainingDuration;
  bool _isRunning = false;
  String _sound = 'Lofi';
  bool _isCompleted = false;
  static const List<String> _completionMessages = [
    "This is how strong roots form.",
    "Another growth ring.",
    "Time, well spent.",
    "Focus, sustained.",
  ];
  String? _completionMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _originalDuration = widget.plannedDuration;
    _sessionTargetDuration = _originalDuration;
    _remainingDuration = _sessionTargetDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playLofi() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.0);
    await _audioPlayer.play(AssetSource('audio/lofi_focus.mp3'));

    // Gentle fade-in for premium focus feel
    const int steps = 6;
    const Duration stepDuration = Duration(milliseconds: 120);
    double volume = 0.0;
    const double targetVolume = 0.55;

    for (int i = 0; i < steps; i++) {
      volume += targetVolume / steps;
      await _audioPlayer.setVolume(volume.clamp(0.0, targetVolume));
      await Future.delayed(stepDuration);
    }
  }

  Future<void> _fadeOutAndStopAudio() async {
    try {
      const int steps = 6;
      const Duration stepDuration = Duration(milliseconds: 100);
      double volume = 0.55;

      for (int i = 0; i < steps; i++) {
        volume -= 0.55 / steps;
        await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
        await Future.delayed(stepDuration);
      }

      await _audioPlayer.stop();
      await _audioPlayer.setVolume(0.55); // reset for next play
    } catch (_) {
      // Fail silently — audio should never crash focus flow
    }
  }

  Future<void> _playCompletionChime() async {
    try {
      final chimePlayer = AudioPlayer();
      await chimePlayer.setVolume(0.8);
      await chimePlayer.play(
        AssetSource('audio/focus_complete_chime.mp3'),
      );
    } catch (_) {
      // fail silently
    }
  }

  void _startTimer() {
    if (_isRunning) return;
    if (_sound == 'Lofi') {
      _playLofi();
    }
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingDuration.inSeconds <= 0) {
        await _stopTimer();
        await _playCompletionChime();
        setState(() {
          _isCompleted = true;
          _completionMessage = _pickCompletionMessage();
        });
        // Do NOT call _endFocus() automatically; user must press "End Focus"
        return;
      }
      setState(() {
        _remainingDuration = _remainingDuration - const Duration(seconds: 1);
      });
    });
  }

  String _pickCompletionMessage() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final idx =
        (seed + widget.taskTitle.hashCode).abs() % _completionMessages.length;
    return _completionMessages[idx];
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();
    _timer = null;
    await _fadeOutAndStopAudio();
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    await _fadeOutAndStopAudio();
    if (_isCompleted) {
      if (!mounted) return;
      Navigator.of(context).pop({
        'updatedDuration': _sessionTargetDuration,
        'completed': true,
        'taskIndex': widget.taskIndex,
      });
    }
  }

  // FocusScreen returns updated duration to the caller (HomeScreen) when focus ends.
  Future<void> _endFocus() async {
    await _stopTimer();
    debugPrint(
      'Focus ended: ${widget.taskTitle}, planned=$_originalDuration, remaining=$_remainingDuration, sound=$_sound',
    );
    if (!mounted) return;
    Navigator.of(context).pop({
      'completed': false,
    });
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 999999);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    // If the planned duration the user entered on HomeScreen is less than 1 hour,
    // show only mm:ss for a cleaner, simpler display.
    if (widget.plannedDuration < const Duration(hours: 1)) {
      final m = minutes.toString().padLeft(2, '0');
      final s = seconds.toString().padLeft(2, '0');
      return '$m:$s';
    }

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
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
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
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: AppColors.creme,
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
                label: 'Off',
                onTap: () async {
                  setState(() => _sound = 'Off');
                  if (_isRunning) {
                    await _fadeOutAndStopAudio();
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              _SoundOption(
                label: 'Lofi',
                onTap: () async {
                  setState(() => _sound = 'Lofi');
                  if (_isRunning) {
                    await _playLofi();
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              _SoundOption(
                label: 'White Noise',
                onTap: () async {
                  setState(() => _sound = 'White Noise');
                  if (_isRunning) {
                    await _fadeOutAndStopAudio();
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showPlatformDialog({
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required bool destructive,
    required VoidCallback onConfirm,
  }) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(cancelText),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onConfirm();
                },
                isDestructiveAction: destructive,
                isDefaultAction: !destructive,
                child: Text(confirmText),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _showEndSessionDialog() async {
    final wasRunning = _isRunning;
    await _stopTimer();
    // If already completed, offer to finish instead of end
    if (_isCompleted) {
      _showPlatformDialog(
        title: 'Focus session complete',
        content: 'Save this session to grow your progress?',
        confirmText: 'Save session',
        cancelText: 'Not now',
        destructive: false,
        onConfirm: _finishSession,
      );
      return;
    }

    _showPlatformDialog(
      title: 'End focus session?',
      content: wasRunning
          ? 'This session is paused and won’t be marked as completed.'
          : 'Leave focus session?',
      confirmText: 'End session',
      cancelText: 'Keep focusing',
      destructive: true,
      onConfirm: _endFocus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showEndSessionDialog();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            _showEndSessionDialog();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.darkGreen,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.chevron_left,
                            size: 40,
                            color: AppColors.creme.withValues(alpha: 0.9),
                          ),
                          onPressed: _showEndSessionDialog,
                          tooltip: 'Back',
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Deep Focus Session',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.creme.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Currently working on:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.creme.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.taskTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.creme.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.creme.withValues(alpha: 0.08),
                          ),
                        ),
                        if (_isCompleted && _completionMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _completionMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.creme.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _openDurationSheet,
                    child: Text(
                      _formatDuration(_remainingDuration),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        color: AppColors.creme,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Builder(
                      key: ValueKey<String>(
                        _isCompleted
                            ? 'completed'
                            : _isRunning
                                ? 'running'
                                : 'idle',
                      ),
                      builder: (context) {
                        if (_isCompleted) {
                          // Finish Session button
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _finishSession,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.creme,
                                foregroundColor: AppColors.darkGreen,
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
                                      foregroundColor: AppColors.creme
                                          .withValues(alpha: 0.9),
                                      side: BorderSide(
                                          color: AppColors.creme
                                              .withValues(alpha: 0.8),
                                          width: 1.6),
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
                                      backgroundColor: AppColors.creme,
                                      foregroundColor: AppColors.darkGreen,
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
                          // Start Focus or Continue button
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  (_sessionTargetDuration == Duration.zero)
                                      ? null
                                      : _startTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.creme,
                                foregroundColor: AppColors.darkGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _remainingDuration < _sessionTargetDuration
                                    ? 'Continue'
                                    : 'Start Focus',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _openSoundSheet,
                    child: Text(
                      '🎧 Sound: $_sound ▾',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.creme.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
