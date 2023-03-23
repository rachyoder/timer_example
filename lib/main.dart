import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: Builder(
        builder: (context) => CupertinoPageScaffold(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Custom Form Widget and Timer Demo'),
          ),
          child: ListView(
            children: [
              CupertinoFormSection.insetGrouped(
                header: const Text('FORM TEMPLATE'),
                children: [
                  StepperFormField(
                    context: context,
                    prefix: 'Sample Field',
                    min: 0,
                    max: 10,
                    hasTimer: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class Home extends StatelessWidget {
//   const Home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoApp(
//       home: CupertinoPageScaffold(
//         backgroundColor: const Color.fromARGB(255, 245, 245, 245),
//         navigationBar: const CupertinoNavigationBar(
//           middle: Text('Custom Form Widget and Timer Demo'),
//         ),
//         child: ListView(
//           children: [
//             CupertinoFormSection.insetGrouped(
//               header: const Text('FORM TEMPLATE'),
//               children: [
//                 StepperFormField(
//                   context: context,
//                   prefix: 'Sample Field',
//                   min: 0,
//                   max: 10,
//                   hasTimer: true,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class BalanceModuleTimerWidget extends HookConsumerWidget {
  const BalanceModuleTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TimerCount display = ref.watch(balanceTimerProvider);
    final isTimerActive = useState<bool>(false);

    return Column(
      children: [
        // Optional row for showing the progress indicator for the timer
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.zero,
                child: LinearProgressIndicator(
                  color: const Color.fromARGB(255, 102, 45, 145),
                  backgroundColor:
                      const Color.fromARGB(255, 102, 45, 145).withOpacity(0.30),
                  value: display.timerPosition / 20,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoButton(
              child: display.displayTimer,
              onPressed: () {
                isTimerActive.value
                    ? {
                        Future.microtask(() => ref
                            .watch(balanceTimerProvider.notifier)
                            .stopTimer()),
                        // _controller.stop()
                      }
                    : {
                        Future.microtask(() => ref
                            .watch(balanceTimerProvider.notifier)
                            .startTimer()),
                        // _controller.reverse()
                      };
                isTimerActive.value = !isTimerActive.value;
              },
            ),
          ],
        ),
      ],
    );
  }
}

class StepperFormField extends FormField<int?> {
  StepperFormField({
    Key? key,
    ValueChanged<int?>? onChanged,
    FormFieldSetter<int>? onSaved,
    FormFieldValidator<int>? validator,
    int? initialValue,
    String? prefix,
    int? min,
    int? max,
    bool hasTimer = false,
    required BuildContext context,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<int?> state) {
            void onChangedHandler(int? value) {
              Future.microtask(() => state.didChange(value));
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                state.value == null ? onChangedHandler(0) : null;
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Container(
                          height:
                              MediaQuery.of(context).copyWith().size.height *
                                  0.25,
                          color: CupertinoColors.white,
                          child: Column(
                            mainAxisAlignment: hasTimer
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            crossAxisAlignment: hasTimer
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              if (hasTimer) ...{
                                const BalanceModuleTimerWidget(),
                              },
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: CupertinoButton(
                                      child: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 50,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        if (min != null) {
                                          if (state.value! > min) {
                                            onChangedHandler(state.value! - 1);
                                          }
                                        } else {
                                          onChangedHandler(state.value! - 1);
                                        }
                                        Future.microtask(
                                            () => setState((() {})));
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      state.value.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 50,
                                        color:
                                            Color.fromARGB(255, 102, 45, 145),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: CupertinoButton(
                                      child: const Icon(
                                        Icons.add_circle_outline,
                                        size: 50,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        if (max != null) {
                                          if (state.value! < max) {
                                            onChangedHandler(state.value! + 1);
                                          }
                                        } else {
                                          onChangedHandler(state.value! + 1);
                                        }
                                        Future.microtask(
                                            () => setState((() {})));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: CupertinoFormRow(
                prefix: Text(prefix ?? ''),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(state.value != null ? state.value.toString() : ''),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 20,
                        color: Color.fromARGB(255, 186, 186, 186),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
}

@immutable
class TimerCount {
  const TimerCount({required this.displayTimer, required this.timerPosition});

  final Widget displayTimer;
  final int timerPosition;

  TimerCount copyWith({Widget? displayTimer, int? timerPosition}) {
    return TimerCount(
        displayTimer: displayTimer ?? this.displayTimer,
        timerPosition: timerPosition ?? this.timerPosition);
  }
}

final balanceTimerProvider =
    StateNotifierProvider.autoDispose<BalanceTimerNotifier, TimerCount>(
        (ref) => BalanceTimerNotifier());

// ignore: prefer_const_constructors
final _timerCount = TimerCount(
    displayTimer: const Icon(Icons.timer_outlined), timerPosition: 20);

class BalanceTimerNotifier extends StateNotifier<TimerCount> {
  BalanceTimerNotifier() : super(_timerCount);

  late Timer _timer;
  int _timerDuration = 20;
  bool isInitialized = false;
  final _player = AudioPlayer();

  void startTimer() {
    isInitialized = true;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _timerDuration > 0
            ? {
                state = TimerCount(
                    displayTimer: Text('$_timerDuration'),
                    timerPosition: _timerDuration),
                _timerDuration--
              }
            : {
                state = TimerCount(
                    displayTimer: Text('$_timerDuration'),
                    timerPosition: _timerDuration),
                resetTimer(),
                playTimer(),
              };
      },
    );
  }

  void stopTimer() {
    if (isInitialized) {
      _timer.cancel();
    }
  }

  void resetTimer() {
    stopTimer();
    _timerDuration = 20;
    if (mounted) {
      Timer(
          const Duration(seconds: 3),
          () => state = TimerCount(
              displayTimer: const Icon(Icons.timer_outlined),
              timerPosition: _timerDuration));
    }
  }

  void playAudio() async {
    await _player.setAsset('assets/audio/bess-timer.mp3');
    _player.play();
  }

  void playTimer() {
    playAudio();
    HapticFeedback.vibrate();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    if (isInitialized) {
      _timer.cancel();
    }
  }
}
