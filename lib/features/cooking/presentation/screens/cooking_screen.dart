import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../../recipes/models/recipe.dart';
import '../providers/cooking_provider.dart';
class CookingArguments {
  const CookingArguments(this.recipe, this.servings);
  final Recipe recipe;
  final int servings;
}
class CookingScreen extends StatefulWidget {
  const CookingScreen({super.key});
  @override
  State<CookingScreen> createState() => _CookingScreenState();
}
class _CookingScreenState extends State<CookingScreen> with WidgetsBindingObserver {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) context.read<CookingProvider>().notify();
  }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  Future<void> _move(bool forward) async {
    final cooking = context.read<CookingProvider>();
    if ((cooking.timer.running || cooking.timer.paused) && !await confirmAction(context,
      title: 'Leave this step?', message: 'Moving to another step clears the current step timer.', confirmLabel: 'Move on')) return;
    if (!mounted) return;
    final ok = forward ? await cooking.next() : await cooking.previous();
    if (mounted && !ok) showMessage(context, cooking.errorMessage ?? 'Progress could not be saved.');
  }
  @override
  Widget build(BuildContext context) {
    final cooking = context.watch<CookingProvider>();
    return Scaffold(appBar: AppBar(title: const Text('Cooking mode'), actions: [
      IconButton(tooltip: 'Restart this recipe', onPressed: cooking.busy ? null : () async {
        if (!await confirmAction(context, title: 'Start from step one?', message: 'Your step progress and timer will be reset.', confirmLabel: 'Restart')) return;
        await cooking.restart();
      }, icon: const Icon(Icons.restart_alt_rounded)), const SizedBox(width: 8),
    ]), body: SafeArea(child: FeaturePage(title: cooking.recipe.title,
      subtitle: '${cooking.servings} servings / Progress is saved on this device', eyebrow: 'One step at a time',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ErrorNotice(cooking.errorMessage),
        if (cooking.completed) EmptyStateView(icon: Icons.check_circle_outline_rounded, title: 'Made by you. Enjoy every bite.',
          message: 'Your cooking session is complete. You can restart the recipe whenever you are ready.',
          action: AppButton(label: 'Back to recipe', icon: Icons.restaurant_rounded, onPressed: () => Navigator.pop(context)))
        else ...[
          Row(children: [Expanded(child: Text('Step ${cooking.index + 1} of ${cooking.recipe.steps.length}',
            style: Theme.of(context).textTheme.titleMedium)), Text('${(cooking.progress * 100).round()}%')]),
          const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: cooking.progress, minHeight: 8)),
          const SizedBox(height: 26), SurfaceCard(padding: const EdgeInsets.all(26), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cooking.step.title, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 20),
              Text(cooking.step.instruction, style: const TextStyle(fontSize: 21, height: 1.65)),
            ])),
          if (cooking.step.timerSeconds > 0) ...[const SizedBox(height: 24), const _TimerControls()],
          const SizedBox(height: 28), Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: cooking.index == 0 || cooking.busy ? null : () => _move(false),
              icon: const Icon(Icons.arrow_back_rounded), label: const Text('Previous'))),
            const SizedBox(width: 14), Expanded(child: AppButton(
              label: cooking.index + 1 == cooking.recipe.steps.length ? 'Finish cooking' : 'Next step',
              loading: cooking.busy, onPressed: () => _move(true))),
          ]),
          const SizedBox(height: 22), const InfoBanner('Timers keep a saved deadline when you leave the app, but no background alarm is scheduled. '
            'Use a separate alarm when you need an audible reminder.', icon: Icons.timer_outlined),
        ],
      ]))));
  }
}
class _TimerControls extends StatelessWidget {
  const _TimerControls();
  @override
  Widget build(BuildContext context) {
    final cooking = context.watch<CookingProvider>();
    final timer = cooking.timer;
    return SurfaceCard(child: Center(child: Column(children: [
      Eyebrow(timer.finished ? 'Timer finished' : 'Your step timer'), const SizedBox(height: 12),
      Text(timer.hasStarted ? cooking.clock : '${(cooking.step.timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(cooking.step.timerSeconds % 60).toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 54, fontWeight: FontWeight.w700, letterSpacing: -2, color: Theme.of(context).colorScheme.primary)),
      if (timer.finished) Semantics(liveRegion: true, child: const Text('Time to check your food.')),
      const SizedBox(height: 16), Wrap(spacing: 12, runSpacing: 10, alignment: WrapAlignment.center, children: [
        if (!timer.hasStarted || timer.finished) AppButton(label: timer.finished ? 'Start again' : 'Start timer',
          icon: Icons.play_arrow_rounded, loading: cooking.busy, onPressed: cooking.startTimer)
        else if (timer.paused) AppButton(label: 'Resume timer', icon: Icons.play_arrow_rounded, loading: cooking.busy, onPressed: cooking.resumeTimer)
        else AppButton(label: 'Pause timer', icon: Icons.pause_rounded, loading: cooking.busy, onPressed: cooking.pauseTimer),
        if (timer.hasStarted) OutlinedButton(onPressed: cooking.busy ? null : cooking.resetTimer, child: const Text('Reset')),
      ]),
    ])));
  }
}
