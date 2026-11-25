import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/cook_timer.dart';
import '../widgets/module_kit.dart';

/// Pişirme modu: tarifi mutfakta adım adım, büyük yazıyla izlemek için.
/// Adımdaki süre ("10 dakika", "12–15 dakika") otomatik bulunur ve tek
/// dokunuşla geri sayım başlatılır; malzemeler ayrı bir listede
/// işaretlenebilir. Tüm genel ve bebek tariflerinde çalışır.
class CookModePage extends StatefulWidget {
  const CookModePage({
    super.key,
    required this.title,
    required this.ingredients,
    required this.steps,
  });

  final String title;
  final List<String> ingredients;
  final List<String> steps;

  @override
  State<CookModePage> createState() => _CookModePageState();
}

class _CookModePageState extends State<CookModePage> {
  final _pages = PageController();
  int _step = 0;
  final _checked = <int>{};

  // Geri sayım (aynı anda tek zamanlayıcı).
  Timer? _ticker;
  int? _timerStep;
  int _remaining = 0;
  bool _paused = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _go(int index) {
    if (index < 0 || index >= widget.steps.length) return;
    _pages.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _startTimer(int step, int minutes) {
    _ticker?.cancel();
    setState(() {
      _timerStep = step;
      _remaining = minutes * 60;
      _paused = false;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted || _paused) return;
    setState(() => _remaining--);
    if (_remaining <= 0) {
      _ticker?.cancel();
      final done = _timerStep;
      setState(() => _timerStep = null);
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      final label = t('Adım {0}: süre doldu').replaceAll('{0}', '${(done ?? 0) + 1}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 8),
        action: done == null ? null : SnackBarAction(label: t('Adıma git'), onPressed: () => _go(done)),
      ));
    }
  }

  void _stopTimer() {
    _ticker?.cancel();
    setState(() => _timerStep = null);
  }

  void _showIngredients() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .7),
            child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
              const Text('Malzemeler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kitMor)),
              const SizedBox(height: 4),
              const Text('Hazırladıklarını işaretle.', style: TextStyle(color: Colors.black54)),
              for (var i = 0; i < widget.ingredients.length; i++)
                CheckboxListTile(
                  key: ValueKey('cook_ing_$i'),
                  value: _checked.contains(i),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(widget.ingredients[i],
                      style: TextStyle(
                          fontSize: 16,
                          decoration: _checked.contains(i) ? TextDecoration.lineThrough : null)),
                  onChanged: (v) {
                    setState(() => v == true ? _checked.add(i) : _checked.remove(i));
                    setSheet(() {});
                  },
                ),
            ]),
          ),
        );
      }),
    );
  }

  String _stepLabel() => t('Adım {0} / {1}')
      .replaceAll('{0}', '${_step + 1}')
      .replaceAll('{1}', '${widget.steps.length}');

  Widget _timerCard(int index) {
    final minutes = stepMinutes(widget.steps[index]);
    if (_timerStep == index) {
      return Card(
        color: const Color(0xFFFFEAF5),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.timer_outlined, color: kitMor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(formatCountdown(_remaining),
                  key: const ValueKey('cook_countdown'),
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: kitMor,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ),
            IconButton(
              tooltip: _paused ? t('Devam et') : t('Duraklat'),
              icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
              onPressed: () => setState(() => _paused = !_paused),
            ),
            IconButton(tooltip: t('Durdur'), icon: const Icon(Icons.stop_rounded), onPressed: _stopTimer),
          ]),
        ),
      );
    }
    if (minutes == null) return const SizedBox.shrink();
    final label = t('{0} dk zamanlayıcı başlat').replaceAll('{0}', '$minutes');
    return Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.tonalIcon(
        key: ValueKey('cook_timer_$index'),
        onPressed: () => _startTimer(index, minutes),
        icon: const Icon(Icons.timer_outlined),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final last = _step == steps.length - 1;
    final otherTimer = _timerStep != null && _timerStep != _step;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            key: const ValueKey('cook_ingredients'),
            tooltip: t('Malzemeler'),
            icon: const Icon(Icons.checklist_rounded),
            onPressed: _showIngredients,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(children: [
              LinearProgressIndicator(value: steps.isEmpty ? 0 : (_step + 1) / steps.length, color: kitMor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  Expanded(child: Text(_stepLabel(),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: kitMor))),
                  if (otherTimer)
                    ActionChip(
                      avatar: const Icon(Icons.timer_outlined, size: 18),
                      label: Text(formatCountdown(_remaining)),
                      onPressed: () => _go(_timerStep!),
                    ),
                ]),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: steps.length,
                  onPageChanged: (i) => setState(() => _step = i),
                  itemBuilder: (ctx, i) => ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(steps[i], key: ValueKey('cook_step_$i'),
                          style: const TextStyle(fontSize: 22, height: 1.45)),
                      const SizedBox(height: 20),
                      _timerCard(i),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('cook_prev'),
                      onPressed: _step == 0 ? null : () => _go(_step - 1),
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('cook_next'),
                      style: FilledButton.styleFrom(backgroundColor: kitMor),
                      onPressed: last
                          ? () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(t('Afiyet olsun!'))));
                              Navigator.of(context).maybePop();
                            }
                          : () => _go(_step + 1),
                      icon: Icon(last ? Icons.check_rounded : Icons.chevron_right_rounded),
                      label: Text(last ? 'Bitti' : 'İleri'),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Tarif sayfalarında pişirme modunu açan düğme.
class CookModeButton extends StatelessWidget {
  const CookModeButton({
    super.key,
    required this.title,
    required this.ingredients,
    required this.steps,
  });

  final String title;
  final List<String> ingredients;
  final List<String> steps;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: FilledButton.icon(
          key: const ValueKey('cook_mode'),
          style: FilledButton.styleFrom(
            backgroundColor: kitMor,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => CookModePage(title: title, ingredients: ingredients, steps: steps),
          )),
          icon: const Icon(Icons.soup_kitchen_rounded),
          label: const Text('Pişirme modu: adım adım ve zamanlayıcılı'),
        ),
      );
}
