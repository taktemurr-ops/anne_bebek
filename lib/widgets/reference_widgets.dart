import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/cycle_estimate.dart';
import 'pastel_design.dart';

/// Paket 39 referans tasarımındaki ortak bileşenler.
///
/// Bu dosyadaki bileşenler yalnızca görünümdür; veriyi çağıran ekran verir.

/// Pembe hap biçimli sekme çubuğu (Gelişim/Sağlık/Aşılar/Notlar gibi).
class PastelSegmentTabs extends StatelessWidget {
  const PastelSegmentTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7ECF6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: i == selected ? PastelPalette.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: i == selected ? Colors.white : PastelPalette.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );
}

/// Beyaz, yumuşak gölgeli kart (referanstaki tüm bölümlerin zemini).
class PastelCard extends StatelessWidget {
  const PastelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = PastelPalette.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(22),
          elevation: 1.2,
          shadowColor: const Color(0x22E94791),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

/// Kart başlığı: pembe simge + kalın başlık + isteğe bağlı sağ eylem.
class PastelSectionHeader extends StatelessWidget {
  const PastelSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: PastelPalette.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: PastelPalette.text)),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
        if (action != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18, color: PastelPalette.primary),
            label: Text(action!,
                style: const TextStyle(
                    color: PastelPalette.primary, fontWeight: FontWeight.w700)),
          ),
      ]);
}

/// Çocuk kartı: yuvarlak avatar, ad, yaş ve seçici oku.
class ChildHeaderCard extends StatelessWidget {
  const ChildHeaderCard({
    super.key,
    required this.name,
    required this.age,
    required this.onTap,
    this.trailingIcon = Icons.keyboard_arrow_down_rounded,
  });

  final String name;
  final String age;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) => PastelCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: PastelPalette.softPink,
            child: Icon(Icons.child_care_rounded, color: PastelPalette.primary, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900, color: PastelPalette.text)),
              const SizedBox(height: 2),
              Text(age, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          Icon(trailingIcon, color: PastelPalette.text),
        ]),
      );
}

/// Büyüme kartı: çizgi grafik + kilo, boy, baş çevresi kutuları.
class GrowthSummaryCard extends StatelessWidget {
  const GrowthSummaryCard({
    super.key,
    required this.weights,
    required this.weight,
    required this.height,
    required this.head,
    required this.onOpen,
    required this.onAdd,
  });

  /// Tarih sırasıyla kilo değerleri (grafik için).
  final List<double> weights;
  final String weight, height, head;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => PastelCard(
        onTap: onOpen,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PastelSectionHeader(
            icon: Icons.bar_chart_rounded,
            title: 'Büyüme Takibi',
            subtitle: 'Boy • Kilo • Baş Çevresi',
            action: 'Ölçüm',
            onAction: onAdd,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: weights.length < 2
                ? Center(
                    child: Text(
                      weights.isEmpty
                          ? 'Grafik için ölçüm ekleyin.'
                          : 'Grafik için en az iki kilo ölçümü gerekir.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  )
                : CustomPaint(
                    painter: SoftLinePainter(weights),
                    child: const SizedBox.expand(),
                  ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _MetricTile(icon: Icons.monitor_weight_outlined, label: 'Kilo', value: weight)),
            const SizedBox(width: 8),
            Expanded(child: _MetricTile(icon: Icons.straighten_rounded, label: 'Boy', value: height)),
            const SizedBox(width: 8),
            Expanded(child: _MetricTile(icon: Icons.face_retouching_natural, label: 'Baş Çevresi', value: head)),
          ]),
        ]),
      );
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: PastelPalette.divider),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, color: PastelPalette.primary, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Colors.black54)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: PastelPalette.text, fontSize: 15)),
              ),
            ]),
          ),
        ]),
      );
}

/// Yumuşak dolgulu mor çizgi grafik.
class SoftLinePainter extends CustomPainter {
  SoftLinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final grid = Paint()
      ..color = PastelPalette.divider
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final span = math.max(0.0001, high - low);
    Offset point(int i) => Offset(
          i * size.width / (values.length - 1),
          size.height - 8 - (values[i] - low) / span * (size.height - 16),
        );
    final line = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(point(i).dx, point(i).dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x55B18CFF), Color(0x08B18CFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xFF8F6BE8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final dot = Paint()..color = const Color(0xFF8F6BE8);
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), 4, dot);
    }
  }

  @override
  bool shouldRepaint(SoftLinePainter oldDelegate) => oldDelegate.values != values;
}

/// Küçük kare kısayol (Beslenme, Uyku, Bez, İlaç/Vitamin...).
class CareShortcut extends StatelessWidget {
  const CareShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: PastelPalette.divider),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: PastelPalette.primary, size: 22),
              ),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

/// Günlük Takip satırı: simge, başlık, son kayıt ve pembe + butonu.
class TrackingRow extends StatelessWidget {
  const TrackingRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onAdd,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PastelCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: PastelPalette.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15, color: PastelPalette.text)),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
          IconButton(
            tooltip: '$title kaydı ekle',
            onPressed: onAdd,
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: PastelPalette.primary,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ]),
      );
}

/// Tarih gezinme çubuğu: ‹  Bugün, 15 Ocak Çarşamba  ›
class DateNavigator extends StatelessWidget {
  const DateNavigator({
    super.key,
    required this.date,
    required this.onChanged,
    required this.today,
  });

  final DateTime date;
  final DateTime today;
  final ValueChanged<DateTime> onChanged;

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _days = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
  ];

  static String label(DateTime date, DateTime today) {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    final diff = d.difference(t).inDays;
    final prefix = diff == 0 ? 'Bugün, ' : diff == -1 ? 'Dün, ' : '';
    return '$prefix${d.day} ${_months[d.month - 1]} ${_days[d.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, today);
    return PastelCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(children: [
        IconButton(
          tooltip: 'Önceki gün',
          onPressed: () => onChanged(date.subtract(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2010),
                lastDate: today,
              );
              if (picked != null) onChanged(picked);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: PastelPalette.text),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(label(date, today),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: PastelPalette.text)),
                ),
              ]),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Sonraki gün',
          onPressed: isToday ? null : () => onChanged(date.add(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ]),
    );
  }
}

/// Lavanta zeminli özet kartı (Bugünkü Özet).
class SummaryStatsCard extends StatelessWidget {
  const SummaryStatsCard({super.key, required this.title, required this.items});

  final String title;

  /// (simge, metin) çiftleri.
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) => PastelCard(
        color: const Color(0xFFF1E9FF),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PastelSectionHeader(icon: Icons.insights_rounded, title: title),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    Icon(items[i].$1, color: PastelPalette.primary),
                    const SizedBox(height: 6),
                    Text(items[i].$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ]),
        ]),
      );
}

/// Aylık takvim: adet, tahmini yumurtlama ve verimli dönem günleri işaretlenir.
class CycleMonthCalendar extends StatelessWidget {
  const CycleMonthCalendar({
    super.key,
    required this.month,
    required this.kindOf,
    required this.today,
    required this.onMonthChanged,
    this.onDayTap,
  });

  /// Gösterilen ayın herhangi bir günü.
  final DateTime month;
  final DateTime today;
  final CycleDayKind Function(DateTime day) kindOf;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime>? onDayTap;

  static const _months = DateNavigator._months;
  static const _weekdays = ['Pzt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leading = first.weekday - 1; // Pazartesi = 0
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= daysInMonth; d++) DateTime(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return PastelCard(
      child: Column(children: [
        Row(children: [
          IconButton(
            tooltip: 'Önceki ay',
            onPressed: () => onMonthChanged(DateTime(month.year, month.month - 1, 1)),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text('${_months[month.month - 1]} ${month.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 16, color: PastelPalette.text)),
          ),
          IconButton(
            tooltip: 'Sonraki ay',
            onPressed: () => onMonthChanged(DateTime(month.year, month.month + 1, 1)),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          for (final w in _weekdays)
            Expanded(
              child: Text(w,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
        ]),
        const SizedBox(height: 6),
        for (var row = 0; row < cells.length ~/ 7; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              for (var col = 0; col < 7; col++) Expanded(child: _dayCell(cells[row * 7 + col])),
            ]),
          ),
        const SizedBox(height: 10),
        const Wrap(spacing: 14, runSpacing: 6, alignment: WrapAlignment.center, children: [
          _Legend(color: Color(0xFFF7A8C8), label: 'Adet Dönemi'),
          _Legend(color: Color(0xFFB18CFF), label: 'Tahmini Yumurtlama'),
          _Legend(color: Color(0xFFE3D6FF), label: 'Verimli Dönem'),
        ]),
      ]),
    );
  }

  Widget _dayCell(DateTime? day) {
    if (day == null) return const SizedBox(height: 36);
    final kind = kindOf(day);
    final isToday = DateUtils.isSameDay(day, today);
    final (Color? bg, Color fg) = switch (kind) {
      CycleDayKind.period => (const Color(0xFFF7A8C8), PastelPalette.text),
      CycleDayKind.ovulation => (const Color(0xFFB18CFF), Colors.white),
      CycleDayKind.fertile => (const Color(0xFFE3D6FF), PastelPalette.text),
      CycleDayKind.none => (null, PastelPalette.text),
    };
    final label = switch (kind) {
      CycleDayKind.period => ', adet dönemi',
      CycleDayKind.ovulation => ', tahmini yumurtlama',
      CycleDayKind.fertile => ', verimli dönem',
      CycleDayKind.none => '',
    };
    return Semantics(
      label: '${day.day} ${_months[day.month - 1]}$label',
      button: onDayTap != null,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onDayTap == null ? null : () => onDayTap!(day),
        child: Container(
          height: 36,
          margin: const EdgeInsets.all(1.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: PastelPalette.primary, width: 2) : null,
          ),
          child: Text('${day.day}',
              style: TextStyle(
                  color: fg,
                  fontWeight: kind == CycleDayKind.none ? FontWeight.w500 : FontWeight.w800)),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11.5)),
      ]);
}

/// Gebelik hafta kartı: "Gebeliğin 26. Haftası" + tahmini doğum + ilerleme.
class PregnancyWeekCard extends StatelessWidget {
  const PregnancyWeekCard({
    super.key,
    required this.week,
    required this.dueDate,
    required this.progress,
    required this.onChangeDate,
  });

  /// null ise henüz tarih girilmemiştir.
  final int? week;
  final String? dueDate;
  final double progress;
  final VoidCallback onChangeDate;

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE3F0), Color(0xFFF3E6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(week == null ? 'Gebelik Takibi' : 'Gebeliğin\n$week. Haftası 💗',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF8E2A5E))),
                const SizedBox(height: 10),
                if (dueDate != null) ...[
                  const Text('Tahmini Doğum Tarihi', style: TextStyle(fontSize: 12.5)),
                  Text(dueDate!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: PastelPalette.text)),
                ] else
                  const Text('Son adet başlangıç tarihini girerek haftalık takibe başla.',
                      style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onChangeDate,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(week == null ? 'Tarih seç' : 'Tarihi değiştir'),
                ),
              ]),
            ),
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(color: Color(0xFFFFD0E6), shape: BoxShape.circle),
              child: const Icon(Icons.pregnant_woman_rounded,
                  size: 58, color: PastelPalette.primary),
            ),
          ]),
        ),
        if (week != null) ...[
          const SizedBox(height: 14),
          Row(children: [
            Text('${week!.clamp(0, 40)} / 40 Hafta',
                style: const TextStyle(fontWeight: FontWeight.w800, color: PastelPalette.text)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              color: PastelPalette.primary,
              backgroundColor: PastelPalette.softPink,
            ),
          ),
        ],
      ]);
}

/// Sağa ok içeren liste kartı (Bebeğin Gelişimi, Hafta Hafta Gebelik...).
class PastelLinkCard extends StatelessWidget {
  const PastelLinkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = PastelPalette.softPink,
  });

  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => PastelCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: PastelPalette.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: PastelPalette.text, fontSize: 14.5)),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: PastelPalette.text),
        ]),
      );
}

/// − 1 + adet seçici.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int value, min, max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: PastelPalette.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _btn(Icons.remove_rounded, 'Azalt', value > min ? () => onChanged(value - 1) : null),
          SizedBox(
            width: 28,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          _btn(Icons.add_rounded, 'Artır', value < max ? () => onChanged(value + 1) : null),
        ]),
      );

  Widget _btn(IconData icon, String tip, VoidCallback? onTap) => Semantics(
        button: true,
        label: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: onTap == null ? Colors.black26 : PastelPalette.text),
          ),
        ),
      );
}

/// Simge + etiket kategori kutusu (Bez, Beslenme, Giyim, Banyo, Gezi).
class CategoryIconTile extends StatelessWidget {
  const CategoryIconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? PastelPalette.softPink : PastelPalette.surface,
              border: Border.all(
                  color: selected ? PastelPalette.primary : PastelPalette.divider),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: PastelPalette.primary, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}
