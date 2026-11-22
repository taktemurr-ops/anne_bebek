import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show I18n, t;
import '../i18n/text.dart';
import '../services/secure_health_store.dart';
import '../services/subscription_service.dart';
import '../services/text_share.dart';
import '../services/tracking_report_pdf.dart';
import '../services/tracking_report.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';
import 'membership_page.dart';

/// Takip ve raporlar: tüm takip edilen süreçler ve toplu rapor.
class TrackingReportPage extends StatefulWidget {
  final VoidCallback? onOpenDailyReport;
  final DateTime Function()? clock;
  const TrackingReportPage({super.key, this.onOpenDailyReport, this.clock});
  @override
  State<TrackingReportPage> createState() => _TrackingReportPageState();
}

class _TrackingReportPageState extends State<TrackingReportPage> {
  List<TrackerSummary> _list = const [];
  Map<String, int> _care = const {};
  bool _loading = true;
  String _filter = 'Tümü';

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final now = _now;
    final out = <TrackerSummary>[];
    Map<String, int> care = const {};
    for (final d in trackerDefs) {
      String? raw;
      try { raw = await SecureHealthStore.read(d.key); } catch (_) {}
      out.add(summarizeTracker(d, raw, now));
      if (d.key == 'olaylar') care = careEventTotals(raw, now);
    }
    if (mounted) setState(() { _list = out; _care = care; _loading = false; });
  }

  Future<void> _share() async {
    final text = buildTrackingReport(_list, _care, _now, t);
    try {
      await TextShare.share(text, subject: t('Anne & Bebek toplu takip raporu'));
    } catch (_) {
      if (mounted) kitSnack(context, t('Paylaşım açılamadı.'));
    }
  }

  Future<void> _pdf() async {
    var premium = false;
    if (SubscriptionService.configured) {
      try { premium = (await SubscriptionService.fetchStatus()).isPremium; } catch (_) {}
    }
    if (!mounted) return;
    if (!premium) {
      final go = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: Text('Premium özelliği'),
        content: Text('Toplu raporu PDF olarak indirme ve yazdırma Premium üyelikte. Metin raporu herkes için ücretsiz paylaşılabilir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Premium’u incele')),
        ],
      ));
      if (go == true && mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MembershipPage()));
      }
      return;
    }
    final lang = I18n.language.value;
    try {
      final ok = await TrackingReportPdf.share(t('Anne & Bebek toplu takip raporu'),
          buildTrackingReport(_list, _care, _now, t), rtl: lang == 'ar' || lang == 'fa');
      if (!ok && mounted) kitSnack(context, t('PDF için yazı tipi indirilemedi; internet bağlantını kontrol et.'));
    } catch (_) {
      if (mounted) kitSnack(context, t('PDF oluşturulamadı.'));
    }
  }

  String _line(TrackerSummary s) {
    final rec = t('kayıt'), last = t('son kayıt'), week = t('Son 7 gün');
    final lastPart = s.lastDate == null ? '' : ' · $last: ${_date(s.lastDate!)}';
    final weekPart = s.last7 > 0 ? ' · $week: ${s.last7}' : '';
    return '${s.records} $rec$lastPart$weekPart';
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Widget _stat(String value, String label) => Expanded(child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ]));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final tot = reportTotals(_list);
    final shown = _list.where((s) => _filter == 'Tümü' || s.def.section == _filter).toList()
      ..sort((a, b) {
        if (a.active != b.active) return a.active ? -1 : 1;
        final ad = a.lastDate, bd = b.lastDate;
        if (ad == null || bd == null) return ad == null ? (bd == null ? 0 : 1) : -1;
        return bd.compareTo(ad);
      });
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        PastelCard(child: Row(children: [
          _stat('${tot.activeTrackers}', t('Aktif takip')),
          _stat('${tot.totalRecords}', t('Toplam kayıt')),
          _stat('${tot.last7}', t('Son 7 gün')),
        ])),
        Row(children: [
          Expanded(child: FilledButton.icon(key: const Key('rapor_paylas'), onPressed: _share,
              icon: const Icon(Icons.ios_share), label: Text('Toplu raporu paylaş'))),
          if (widget.onOpenDailyReport != null) ...[
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: widget.onOpenDailyReport,
                icon: const Icon(Icons.insights), label: Text('Günlük analiz'))),
          ],
        ]),
        const SizedBox(height: 6),
        OutlinedButton.icon(key: const Key('rapor_pdf'), onPressed: _pdf,
            icon: const Icon(Icons.picture_as_pdf_outlined), label: Text('PDF olarak indir · Premium')),
        if (_care.isNotEmpty) ...[
          const KitHeader('Son 7 günde bebek bakımı', Icons.child_care_outlined),
          PastelCard(child: Wrap(spacing: 16, runSpacing: 8, children: [
            for (final e in _care.entries)
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${e.value}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kitMor)),
                Text(e.key, style: const TextStyle(fontSize: 12)),
              ]),
          ])),
        ],
        const KitHeader('Takip edilen süreçler', Icons.fact_check_outlined),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final f in ['Tümü', ...trackerSections])
            ChoiceChip(key: Key('rapor_filtre_$f'), label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f)),
        ]),
        const SizedBox(height: 8),
        for (final s in shown)
          PastelCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            color: s.active ? const Color(0xFFFFFFFF) : const Color(0xFFF7F3F7),
            child: Row(children: [
              Icon(s.active ? Icons.check_circle : Icons.radio_button_unchecked, color: s.active ? const Color(0xFF2E8B57) : const Color(0xFFB9AEB9)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.def.label, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
                Text(s.active ? _line(s) : t('Henüz kayıt yok; ilgili bölümden başlayabilirsin.'),
                    style: const TextStyle(fontSize: 12.5)),
              ])),
              Text(t(s.def.section), style: const TextStyle(fontSize: 11, color: Color(0xFF8A7A8A))),
            ]),
          ),
        const KitFootnote('Rapor yalnızca bu cihazdaki kayıtları okur; hiçbir veri gönderilmez. Paylaşmayı sen seçersen metin olarak paylaşılır.'),
      ]),
    );
  }
}
