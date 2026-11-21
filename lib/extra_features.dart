import 'utils/dialog_helpers.dart';
import 'i18n/i18n.dart' show t;
import 'i18n/text.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'tracking_journal.dart';
import 'package:flutter/material.dart' hide Text;
import 'services/secure_health_store.dart';
import 'services/growth_analysis.dart';
import 'services/monthly_growth.dart';
import 'services/pregnancy_timeline.dart';
import 'services/pregnancy_week_guide.dart';
import 'widgets/reference_widgets.dart';
import 'screens/mom_tools_page.dart';

const _mor = Color(0xFF764A72);
const _pembe = Color(0xFFF8DDEB);
const _lila = Color(0xFFE8DEFF);

Widget _header(String title, String subtitle) => Container(
  width: double.infinity, padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
    gradient: const LinearGradient(colors: [_pembe, _lila])),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 20, color: _mor, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), Text(subtitle, style: const TextStyle(color: _mor)),
  ]));
String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class PregnancyPage extends StatefulWidget {
  const PregnancyPage({super.key});
  @override
  State<PregnancyPage> createState() => _PregnancyPageState();
}
class _PregnancyPageState extends State<PregnancyPage> {
  final _checklistKey = GlobalKey();
  DateTime? period;
  final Set<String> done = {};
  final List<Map<String, String>> appointments = [];
  static const tasks = ['Doktor kontrolünü planla', 'Doğum çantasını hazırla',
    'Hastane ulaşım planı yap', 'Bebek kıyafetlerini hazırla', 'Aile destek planı oluştur'];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final savedPeriod = await SecureHealthStore.read('pregnancy_last_period_v3');
      final savedChecklist = await SecureHealthStore.read('pregnancy_checklist_v3');
      final savedAppointments = await SecureHealthStore.read('pregnancy_appointments_v3');
      final parsedAppointments = <Map<String, String>>[];
      if (savedAppointments != null) {
        final decoded = jsonDecode(savedAppointments);
        if (decoded is! List) throw const FormatException('Kontrol kayıtları geçersiz');
        for (final row in decoded) {
          if (row is! Map || row['title'] is! String || row['date'] is! String ||
              DateTime.tryParse(row['date'] as String) == null) {
            throw const FormatException('Kontrol kaydı geçersiz');
          }
          parsedAppointments.add({'title': row['title'] as String, 'date': row['date'] as String});
        }
      }
      final loaded = <String>[];
      if (savedChecklist != null) {
        final decoded = jsonDecode(savedChecklist);
        if (decoded is! List || !decoded.every((v) => v is String)) {
          throw const FormatException('Gebelik listesi geçersiz');
        }
        loaded.addAll(decoded.cast<String>());
      }
      if (!mounted) return;
      setState(() {
        period = DateTime.tryParse(savedPeriod ?? '');
        done.addAll(loaded);
        appointments.addAll(parsedAppointments);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gebelik kaydı okunamadı. Mevcut veriler silinmedi.'),
        ));
      }
    }
  }
  Future<void> _save() async {
    await SecureHealthStore.write('pregnancy_last_period_v3', period?.toIso8601String() ?? '');
    await SecureHealthStore.write('pregnancy_checklist_v3', jsonEncode(done.toList()));
  }
  Future<void> _saveAppointments() async {
    await SecureHealthStore.write('pregnancy_appointments_v3', jsonEncode(appointments));
  }
  Future<void> _addAppointment() async {
    final controller = TextEditingController();
    DateTime selected = DateTime.now();
    final result = await showDialogAndDispose<Map<String, String>>(disposables: [controller], context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
        title: const Text('Kontrol / randevu ekle'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, maxLength: 100,
            decoration: InputDecoration(labelText: t('Kontrol adı'))),
          OutlinedButton.icon(icon: const Icon(Icons.event), label: Text(_date(selected)),
            onPressed: () async {
              final date = await showDatePicker(context: ctx, initialDate: selected,
                firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (date != null) refresh(() => selected = date);
            }),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            final title = controller.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(ctx, {'title': title, 'date': selected.toIso8601String()});
          }, child: const Text('Kaydet')),
        ],
      )));
    if (result == null || !mounted) return;
    setState(() => appointments.add(result));
    try {
      await _saveAppointments();
    } catch (_) {
      if (!mounted) return;
      setState(() => appointments.remove(result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kontrol kaydedilemedi; değişiklik geri alındı.')));
    }
  }
  Future<void> _removeAppointment(Map<String, String> appointment) async {
    final index = appointments.indexOf(appointment);
    if (index < 0) return;
    setState(() => appointments.removeAt(index));
    try {
      await _saveAppointments();
    } catch (_) {
      if (!mounted) return;
      setState(() => appointments.insert(index.clamp(0, appointments.length), appointment));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kontrol silinemedi; kayıt korundu.')));
    }
  }
  Future<void> _choose() async {
    final date = await showDatePicker(context: context, initialDate: period ?? DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime.now());
    if (date != null && mounted) {
      final previous = period;
      setState(() => period = date);
      try {
        await _save();
      } catch (_) {
        if (!mounted) return;
        setState(() => period = previous);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tarih kaydedilemedi. Önceki tarih korundu.'),
        ));
      }
    }
  }
  void _openTools(int tab, String title) => Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: MomToolsPage(initialTab: tab))));
  @override
  Widget build(BuildContext context) {
    final timeline = period == null ? null : pregnancyTimeline(period!, DateTime.now());
    final valid = timeline != null;
    final week = timeline?.week;
    void openGuide() => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PregnancyWeekGuidePage(initialWeek: (week ?? 1).clamp(1, 40))));
    // Paket 39 referansı: hafta kartı, 40 haftalık ilerleme ve üç bağlantı kartı.
    return ListView(padding: const EdgeInsets.all(16), children: [
      PregnancyWeekCard(
        week: week,
        dueDate: period == null ? null : _date(period!.add(const Duration(days: 280))),
        progress: timeline?.progress ?? 0,
        onChangeDate: _choose,
      ),
      const SizedBox(height: 14),
      PastelLinkCard(icon: Icons.child_friendly_outlined, title: 'Bebeğin Gelişimi',
        subtitle: valid ? pregnancyWeekNote(timeline.week) : 'Tarih girildiğinde bu haftanın gelişimi gösterilir',
        onTap: openGuide),
      PastelLinkCard(icon: Icons.calendar_view_week_rounded, title: 'Hafta Hafta Gebelik',
        subtitle: valid ? '${timeline.week}. haftada seni neler bekliyor?' : '1–40 hafta gebelik rehberi',
        iconColor: _lila, onTap: openGuide),
      PastelLinkCard(icon: Icons.menu_book_rounded, title: 'Yapılacaklar Listem',
        subtitle: 'Kontroller, testler ve hazırlıklar', iconColor: const Color(0xFFFFEBD9),
        onTap: () {
          final ctx = _checklistKey.currentContext;
          if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350));
        }),
      PastelLinkCard(key: const Key('gebelik_kasilma'), icon: Icons.timer_outlined, title: 'Kasılma ve Tekme Sayacı',
        subtitle: 'Kasılma aralığı, 5-1-1 uyarısı ve 10 hareket takibi', iconColor: const Color(0xFFFFE0E0),
        onTap: () => _openTools(0, 'Kasılma ve Tekme Sayacı')),
      PastelLinkCard(key: const Key('gebelik_isimler'), icon: Icons.badge_outlined, title: 'Bebek İsimleri',
        subtitle: 'Anlamıyla isim önerileri ve favori listen', iconColor: _lila,
        onTap: () => _openTools(3, 'Bebek İsimleri')),
      if (timeline != null) ...[
        Card(child: ListTile(leading: const Icon(Icons.auto_awesome, color: _mor),
          title: Text('${timeline.trimester} • ${timeline.week} hafta ${timeline.dayOfWeek} gün (yaklaşık)'),
          subtitle: Text('Son adet başlangıcı: ${_date(period!)}'))),
        Card(child: ListTile(leading: const Icon(Icons.today, color: _mor),
          title: const Text('Tahmini doğuma kalan süre'),
          subtitle: Text(timeline.daysUntilEstimatedDueDate >= 0
            ? '${timeline.daysUntilEstimatedDueDate} gün (yaklaşık)'
            : 'Tahmini tarih ${-timeline.daysUntilEstimatedDueDate} gün önceydi; doktorunla görüş.'))),
      ],
      const SizedBox(height: 12),
      Card(child: ListTile(
        leading: const Icon(Icons.menu_book_outlined, color: _mor),
        title: const Text('1–40 hafta gebelik rehberi'),
        subtitle: const Text('Hafta hafta gelişim, anne adayındaki değişimler ve hazırlık önerileri'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => PregnancyWeekGuidePage(initialWeek: (timeline?.week ?? 1).clamp(1, 40)))),
      )),
      FilledButton.tonalIcon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(appBar: AppBar(title: const Text('Gebelik günlüğüm')),
          body: const TrackingJournalPage(pregnancy: true)))),
        icon: const Icon(Icons.edit_note), label: const Text('Kilo, belirti ve kontrol günlüğüm')),
      const SizedBox(height: 16),
      Row(key: _checklistKey, children: [
        const Expanded(child: Text('Kontrol ve randevularım',
          style: TextStyle(fontSize: 17, color: _mor, fontWeight: FontWeight.bold))),
        IconButton(tooltip: t('Kontrol ekle'), onPressed: _addAppointment,
          icon: const Icon(Icons.add_circle_outline, color: _mor)),
      ]),
      if (appointments.isEmpty) const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Henüz kontrol eklenmedi. Tarih ve açıklama ekleyebilirsin.')),
      ...([...appointments]..sort((a, b) => a['date']!.compareTo(b['date']!))).map((a) => Card(
        child: ListTile(leading: const Icon(Icons.medical_services_outlined, color: _mor),
          title: Text(a['title']!),
          subtitle: Text(_date(DateTime.parse(a['date']!))),
          trailing: IconButton(tooltip: t('Kontrolü sil'), icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeAppointment(a))))),
      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Doğuma hazırlık listesi',
        style: TextStyle(fontSize: 17, color: _mor, fontWeight: FontWeight.bold))),
      ...tasks.map((task) => Card(color: Colors.white, child: CheckboxListTile(
        title: Text(task), value: done.contains(task), activeColor: _mor,
        onChanged: (v) async {
          final previous = done.contains(task);
          setState(() { if (v == true) { done.add(task); } else { done.remove(task); } });
          try { await _save(); } catch (_) {
            if (!context.mounted) return;
            setState(() { if (previous) { done.add(task); } else { done.remove(task); } });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Liste kaydedilemedi; değişiklik geri alındı.')));
          }
        }))),
      const SizedBox(height: 16),
      const Text('Bu hesaplama yaklaşık bilgi sunar; doktorun belirlediği gebelik haftası ve doğum tarihi esas alınmalıdır.',
        style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }
}

class PregnancyWeekGuidePage extends StatefulWidget {
  final int initialWeek;
  const PregnancyWeekGuidePage({super.key, this.initialWeek = 1});
  @override
  State<PregnancyWeekGuidePage> createState() => _PregnancyWeekGuidePageState();
}

class _PregnancyWeekGuidePageState extends State<PregnancyWeekGuidePage> {
  late int week;
  @override
  void initState() { super.initState(); week = widget.initialWeek.clamp(1, 40); }
  @override
  Widget build(BuildContext context) {
    final guide = pregnancyGuideForWeek(week);
    return Scaffold(
      appBar: AppBar(title: const Text('Gebelik: 1–40 hafta')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _header('$week. hafta', 'Genel bilgilendirme • Doktorunun belirlediği gebelik haftası esas alınır.'),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: week,
          decoration: InputDecoration(labelText: t('Hafta seç'), border: OutlineInputBorder()),
          items: [for (var i = 1; i <= 40; i++) DropdownMenuItem(value: i, child: Text('$i. hafta'))],
          onChanged: (value) { if (value != null) setState(() => week = value); },
        ),
        const SizedBox(height: 12),
        Card(color: const Color(0xFFFFEEF6), elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Text(guide.sizeEmoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$week. hafta · ${guide.trimester}. trimester',
                style: const TextStyle(fontWeight: FontWeight.w800, color: _mor)),
              if (guide.sizeLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Bebeğin bir ${guide.sizeLabel} büyüklüğünde',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFE94791))),
              ],
              if (guide.measure.isNotEmpty) Text(guide.measure[0].toUpperCase() + guide.measure.substring(1),
                style: const TextStyle(color: Colors.black54)),
            ])),
          ]))),
        _guideCard('Bebeğin gelişimi', guide.development, Icons.child_care),
        _guideCard('Anne adayındaki değişimler', guide.maternalChanges, Icons.favorite_outline),
        _guideCard('Bu hafta yapılacaklar', guide.preparation, Icons.checklist),
        _guideCard('Ne zaman yardım alınmalı?', guide.safety, Icons.health_and_safety_outlined),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: week > 1 ? () => setState(() => week--) : null,
            icon: const Icon(Icons.chevron_left), label: const Text('Önceki hafta'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton.icon(
            onPressed: week < 40 ? () => setState(() => week++) : null,
            icon: const Icon(Icons.chevron_right), label: const Text('Sonraki hafta'))),
        ]),
        const SizedBox(height: 12),
        const Text('Bu rehber tıbbi tanı, kişisel risk değerlendirmesi veya doktor takibinin yerine geçmez.',
          style: TextStyle(color: Colors.black54)),
      ]),
    );
  }
  Widget _guideCard(String title, String body, IconData icon) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: _mor), const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 10), Text(body),
      ],
    )),
  );
}

class FamilyCalendarPage extends StatefulWidget {
  const FamilyCalendarPage({super.key});
  @override
  State<FamilyCalendarPage> createState() => _FamilyCalendarPageState();
}
class _FamilyCalendarPageState extends State<FamilyCalendarPage> {
  final List<Map<String, String>> events = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { events.addAll((jsonDecode(await SecureHealthStore.read('family_calendar_v3') ?? '[]') as List)
      .map((e) => Map<String, String>.from(e as Map))); } catch (_) { /* Ignore invalid optional records. */ }
    if (mounted) setState(() {});
  }
  Future<void> _save() async {
    await SecureHealthStore.write('family_calendar_v3', jsonEncode(events));
  }
  Future<void> _add() async {
    final input = TextEditingController();
    DateTime selected = DateTime.now();
    final result = await showDialog<Map<String, String>>(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
        title: const Text('Etkinlik ekle'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: input, decoration: InputDecoration(labelText: t('Etkinlik adı'))),
          OutlinedButton.icon(icon: const Icon(Icons.event), label: Text(_date(selected)), onPressed: () async {
            final d = await showDatePicker(context: ctx, initialDate: selected,
              firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (d != null) refresh(() => selected = d);
          }),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            if (input.text.trim().isEmpty) return;
            Navigator.pop(ctx, {'title': input.text.trim(), 'date': selected.toIso8601String()});
          }, child: const Text('Kaydet'))],
      )));
    if (result != null && mounted) { setState(() { events.add(result);
      events.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? '')); }); await _save(); }
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    _header('Aile takvimi 📅', 'Randevu, doğum günü ve aile planlarını kaydet.'),
    const SizedBox(height: 16),
    FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Etkinlik ekle')),
    if (events.isEmpty) const ListTile(title: Text('Henüz etkinlik eklenmedi.')),
    ...events.map((e) => Card(color: Colors.white, child: ListTile(
      leading: const Icon(Icons.calendar_month, color: _mor),
      title: Text(e['title'] ?? ''),
      subtitle: Text(_date(DateTime.tryParse(e['date'] ?? '') ?? DateTime.now())),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
        setState(() => events.remove(e)); _save();
      }),
    ))),
    const SizedBox(height: 16),
    const Text('Etkinlikler cihazda saklanır; otomatik bildirim ve sistem takvimi eşitlemesi henüz yoktur.',
      style: TextStyle(fontSize: 12, color: Colors.black54)),
  ]);
}

class GrowthChartsPage extends StatelessWidget {
  final List<Map<String, String>> measurements;
  const GrowthChartsPage({super.key, required this.measurements});
  @override
  Widget build(BuildContext context) {
    final rows = [...measurements]..sort((a, b) => (a['tarih'] ?? '').compareTo(b['tarih'] ?? ''));
    return ListView(padding: const EdgeInsets.all(16), children: [
      _header('Büyüme grafikleri 📈', 'Boy, kilo ve baş çevresi kayıtlarının tarih sırasıyla takibi.'),
      const SizedBox(height: 20),
      _chart(rows, 'kilo', 'Kilo (kg)'),
      const SizedBox(height: 20),
      _chart(rows, 'boy', 'Boy (cm)'),
      const SizedBox(height: 20),
      _chart(rows, 'basCevresi', 'Baş çevresi (cm)'),
      const SizedBox(height: 20),
      const Text('Bu grafikler persentil veya tıbbi değerlendirme değildir.',
        style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }
  Widget _chart(List<Map<String, String>> rows, String field, String label) {
    final points = growthSeries(rows, field);
    final values = points.map((p) => p.value).toList();
    final unit = field == 'kilo' ? 'kg' : 'cm';
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _mor, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        if (values.isEmpty) const Text('Henüz ölçüm yok. Bebeğim bölümünden ölçüm ekle.'),
        if (values.isNotEmpty) ...[
          SizedBox(height: 170, child: CustomPaint(painter: _GraphPainter(values), child: const SizedBox.expand())),
          const SizedBox(height: 10),
          Text('${values.length} kayıt • İlk: ${values.first.toStringAsFixed(1)} $unit • Son: ${values.last.toStringAsFixed(1)} $unit',
            style: const TextStyle(color: _mor, fontSize: 12)),
          Text(growthChange(points, unit), style: const TextStyle(color: _mor, fontSize: 12)),
          if (growthStats(points) case final stats?) ...[
            Text('En düşük: ${stats.minimum.toStringAsFixed(1)} $unit • En yüksek: ${stats.maximum.toStringAsFixed(1)} $unit',
              style: const TextStyle(color: _mor, fontSize: 12)),
            Text('Ölçüm aralığı: ${stats.elapsedDays} gün',
              style: const TextStyle(color: _mor, fontSize: 12)),
          ],
          const SizedBox(height: 10),
          const Text('Aylık ölçüm özeti', style: TextStyle(fontWeight: FontWeight.w600)),
          ...monthlyGrowth(points).reversed.take(6).map((month) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('${month.label}: ${month.count} ölçüm • Son: ${month.last.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12)))),
          if (lastMonthDifference(monthlyGrowth(points)) case final difference?)
            Text('Ardışık son iki ayın son ölçüm farkı: ${difference >= 0 ? "+" : ""}${difference.toStringAsFixed(1)} $unit',
              style: const TextStyle(color: _mor, fontSize: 12)),
          const Text('Kayıt olmayan aylar karşılaştırmaya katılmaz.',
            style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Ölçüm geçmişi', style: TextStyle(fontWeight: FontWeight.w600)),
          ...points.reversed.take(8).map((point) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('${point.date.day}.${point.date.month}.${point.date.year}  •  ${point.value.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12)))),

        ],
      ]));
  }
}
class _GraphPainter extends CustomPainter {
  final List<double> values;
  _GraphPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = _pembe..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = i * size.height / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final span = math.max(1.0, high - low);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : i * size.width / (values.length - 1);
      final y = size.height - 10 - ((values[i] - low) / span) * (size.height - 20);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = _mor);
    }
    canvas.drawPath(path, Paint()..color = _mor..strokeWidth = 3..style = PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) => oldDelegate.values != values;
}
