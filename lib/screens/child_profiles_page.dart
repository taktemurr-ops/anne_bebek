import 'daily_routine_journal_page.dart';
import '../services/daily_routine_repository.dart';
import 'official_vaccine_guide_page.dart';
import 'child_data_audit_page.dart';
import '../services/legacy_child_import.dart';
import 'child_overview_page.dart';
import 'child_care_plan_page.dart';
import 'child_growth_trends_page.dart';
import 'child_report_page.dart';
import 'package:flutter/material.dart';
import '../services/child_profiles.dart';
import '../services/child_journals.dart';
import '../services/child_care_plans.dart';
import '../services/secure_health_store.dart';
import '../utils/baby_age.dart';
import '../utils/child_profile_validator.dart';

class ChildProfilesPage extends StatefulWidget {
  const ChildProfilesPage({super.key});
  @override
  State<ChildProfilesPage> createState() => _ChildProfilesPageState();
}

class _ChildProfilesPageState extends State<ChildProfilesPage> {
  static const _key = 'child_profiles_directory_v58';
  List<ChildProfile> _profiles = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final value = await SecureHealthStore.read(_key);
      final result = decodeChildProfiles(value);
      if (mounted) setState(() { _profiles = result; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Profiller okunamadı. Veriler silinmedi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(List<ChildProfile> next) async {
    if (_saving || _error != null) return;
    setState(() => _saving = true);
    try {
      await SecureHealthStore.write(_key, encodeChildProfiles(next));
      if (mounted) setState(() => _profiles = next);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedilemedi; eski profiller korundu.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _add() async {
    final name = TextEditingController();
    DateTime birth = DateTime.now();
    String sex = 'unknown';
    ModalRoute<dynamic>? dialogRoute;
    final result = await showDialog<ChildProfile>(context: context, builder: (dialogContext) {
      dialogRoute = ModalRoute.of(dialogContext);
      return StatefulBuilder(builder: (dialogContext, refresh) => AlertDialog(
      title: const Text('Çocuk profili ekle'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, maxLength: 60, decoration: const InputDecoration(labelText: 'Adı')),
        DropdownButtonFormField<String>(initialValue: sex, decoration: const InputDecoration(labelText: 'Büyüme referansı için cinsiyet'), items: const [
          DropdownMenuItem(value: 'unknown', child: Text('Belirtilmedi')),
          DropdownMenuItem(value: 'female', child: Text('Kız')),
          DropdownMenuItem(value: 'male', child: Text('Erkek')),
        ], onChanged: (value) { if (value != null) refresh(() => sex = value); }),
        OutlinedButton.icon(onPressed: () async {
          final today = DateTime.now();
          final earliest = DateTime(today.year - 18, today.month, today.day);
          final chosen = await showDatePicker(context: dialogContext,
            initialDate: birth, firstDate: earliest, lastDate: today);
          if (chosen != null) refresh(() => birth = chosen);
        }, icon: const Icon(Icons.cake_outlined), label: Text('Doğum: ${birth.day}.${birth.month}.${birth.year}')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Vazgeç')),
        FilledButton(onPressed: () {
          final value = name.text.trim();
          final error = ChildProfileValidator.validateName(value) ??
              ChildProfileValidator.validateBirthDate(birth) ??
              ChildProfileValidator.validateSex(sex);
          if (error != null) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(error)));
            return;
          }
          Navigator.pop(dialogContext, ChildProfile(id: DateTime.now().microsecondsSinceEpoch.toString(), name: value, birthDate: birth, sex: sex));
        }, child: const Text('Kaydet'))],
    )); });
    await dialogRoute?.completed;
    name.dispose();
    if (result != null && mounted) await _save([..._profiles, result]);
  }

  Future<void> _rename(ChildProfile profile) async {
    final controller = TextEditingController(text: profile.name);
    ModalRoute<dynamic>? renameRoute;
    final newName = await showDialog<String>(context: context, builder: (ctx) {
      renameRoute = ModalRoute.of(ctx);
      return AlertDialog(
      title: const Text('Profil adını düzenle'),
      content: TextField(controller: controller, maxLength: 60, decoration: const InputDecoration(labelText: 'Ad')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () {
          final name = controller.text.trim();
          final error = ChildProfileValidator.validateName(name);
          if (error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
            return;
          }
          Navigator.pop(ctx, name);
        }, child: const Text('Kaydet'))],
    ); });
    await renameRoute?.completed;
    controller.dispose();
    if (newName != null && mounted && newName != profile.name) {
      await _save(_profiles.map((e) => e.id == profile.id
        ? ChildProfile(id: e.id, name: newName, birthDate: e.birthDate, sex: e.sex) : e).toList());
    }
  }


  Future<void> _editSex(ChildProfile profile) async {
    final selected = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('Büyüme referansı için cinsiyet'),
      children: [
        for (final item in const [('female', 'Kız'), ('male', 'Erkek'), ('unknown', 'Belirtilmedi')])
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, item.$1), child: Text(item.$2)),
      ],
    ));
    if (selected == null || !mounted || selected == profile.sex) return;
    if (ChildProfileValidator.validateSex(selected) != null) return;
    await _save(_profiles.map((e) => e.id == profile.id
      ? ChildProfile(id: e.id, name: e.name, birthDate: e.birthDate, sex: selected) : e).toList());
  }

  Future<void> _editBirth(ChildProfile profile) async {
    final today = DateTime.now();
    final earliest = DateTime(today.year - 18, today.month, today.day);
    final latest = DateTime(today.year, today.month, today.day);
    final initial = profile.birthDate.isBefore(earliest)
        ? earliest
        : profile.birthDate.isAfter(latest) ? latest : profile.birthDate;
    final chosen = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest, lastDate: latest,
    );
    if (chosen == null || !mounted) return;
    final birthError = ChildProfileValidator.validateBirthDate(chosen);
    if (birthError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(birthError)));
      return;
    }
    try {
      final entries = decodeChildJournal(
        await SecureHealthStore.read('child_journal_entries_v59'));
      final careItems = decodeChildCareItems(
        await SecureHealthStore.read('child_care_plan_v96'));
      final hasEarlierJournal = ChildProfileValidator.hasRecordsBeforeBirth(
        chosen, entries.where((e) => e.childId == profile.id).map((e) => e.at));
      final hasEarlierCare = ChildProfileValidator.hasRecordsBeforeBirth(
        chosen, careItems.where((item) => item.childId == profile.id)
            .map((item) => item.date));
      if (hasEarlierJournal || hasEarlierCare) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Yeni doğum tarihi, mevcut günlük veya sağlık kayıtlarından sonra olamaz. Önce kayıtları kontrol edin.')));
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Günlük veya sağlık kayıtları doğrulanamadı; doğum tarihi değiştirilmedi.')));
      }
      return;
    }
    if (!mounted) return;
    await _save(_profiles.map((e) => e.id == profile.id
      ? ChildProfile(id: e.id, name: e.name, birthDate: chosen, sex: e.sex) : e).toList());
  }

  Future<void> _importLegacy(ChildProfile profile) async {
    if (_saving || _error != null) return;
    try {
      final legacy = LegacyChildImport.parseLegacy(
        await SecureHealthStore.read('entries_v2'));
      final current = decodeChildJournal(
        await SecureHealthStore.read('child_journal_entries_v59'));
      final count = LegacyChildImport.newEntryCount(
        childId: profile.id, legacy: legacy, existing: current);
      if (!mounted) return;
      if (count == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Aktarılacak yeni eski kayıt bulunamadı.')));
        return;
      }
      final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Eski bebek kayıtlarını kopyala'),
        content: Text('Eski ana bebek günlüğündeki $count kayıt, ${profile.name} profiline KOPYALANACAK. '
          'Eski kayıtlar silinmeyecek. Lütfen doğru çocuğu seçtiğinizden emin olun. '
          'Aktarım sonrası kayıtları kontrol edin.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kopyala')),
        ],
      ));
      if (confirmed != true || !mounted) return;
      setState(() => _saving = true);
      // Re-read immediately before writing to avoid overwriting newer records.
      final latest = decodeChildJournal(
        await SecureHealthStore.read('child_journal_entries_v59'));
      final merged = LegacyChildImport.merge(
        childId: profile.id, legacy: legacy, existing: latest);
      await SecureHealthStore.write('child_journal_entries_v59',
        encodeChildJournal(merged));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
        Text('${merged.length - latest.length} kayıt kopyalandı. Eski kayıtlar korundu.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
        Text('Aktarım doğrulanamadı. Eski kayıtlar silinmedi.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove(ChildProfile profile) async {
    // Do not orphan sensitive records by removing their parent profile.
    // If the encrypted store cannot be read, refuse deletion rather than
    // guessing that there are no associated records.
    try {
      final journals = decodeChildJournal(
        await SecureHealthStore.read('child_journal_entries_v59'));
      final care = decodeChildCareItems(
        await SecureHealthStore.read('child_care_plan_v96'));
      final hasJournal = journals.any((entry) => entry.childId == profile.id);
      final hasCare = care.any((item) => item.childId == profile.id);
      final hasRoutine = (await DailyRoutineRepository.load())
          .any((entry) => entry.childId == profile.id);
      // Never remove a profile with health or routine data attached to its exact ID.
      if (hasJournal || hasCare || hasRoutine) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bu çocuğa ait sağlık kayıtları var. Veri kaybını önlemek için profil silinmedi.')));
        return;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kayıtlar doğrulanamadı. Güvenlik için profil silinmedi.')));
      return;
    }
    if (!mounted) return;
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Boş profil silinsin mi?'),
      content: Text('${profile.name} profilini kaldırmak istiyor musunuz? Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (confirm == true && mounted) await _save(_profiles.where((e) => e.id != profile.id).toList());
  }

  String _formattedDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  Widget _profileCard(ChildProfile profile) {
    final ageText = BabyAge.label(profile.birthDate, DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFE0EE),
            child: Icon(profile.sex == 'male' ? Icons.face :
                profile.sex == 'female' ? Icons.face_3 : Icons.child_care,
                color: const Color(0xFFCE438A), size: 30),
          ),
          title: Text(profile.name, style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text('$ageText  •  ${_formattedDate(profile.birthDate)}'),
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(
              builder: (_) => ChildOverviewPage(child: profile))),
          trailing: PopupMenuButton<String>(
            tooltip: 'Profil işlemleri',
            onSelected: (choice) {
              if (choice == 'rename') { _rename(profile); }
              else if (choice == 'birth') { _editBirth(profile); }
              else if (choice == 'sex') { _editSex(profile); }
              else if (choice == 'growth') { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChildGrowthTrendsPage(child: profile))); }
              else if (choice == 'vaccineGuide') { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => OfficialVaccineGuidePage(child: profile))); }
              else if (choice == 'care') { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChildCarePlanPage(child: profile))); }
              else if (choice == 'report') { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChildReportPage(child: profile))); }
              else if (choice == 'routines') { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => DailyRoutineJournalPage(childId: profile.id))); }
              else if (choice == 'import') { _importLegacy(profile); }
              else if (choice == 'delete') { _remove(profile); }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Adı düzenle')),
              PopupMenuItem(value: 'birth', child: Text('Doğum tarihini düzenle')),
              PopupMenuItem(value: 'sex', child: Text('Büyüme referansı cinsiyetini düzenle')),
              PopupMenuItem(value: 'growth', child: Text('Büyüme geçmişi')),
              PopupMenuItem(value: 'care', child: Text('Aşı ve sağlık planı')),
              PopupMenuItem(value: 'vaccineGuide', child: Text('Aşı rehberi')),
              PopupMenuItem(value: 'report', child: Text('Doktor özeti')),
              PopupMenuItem(value: 'routines', child: Text('Günlük yaşam kayıtları')),
              PopupMenuItem(value: 'import', child: Text('Eski kayıtları kopyala')),
              PopupMenuItem(value: 'delete', child: Text('Profili sil')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8FC),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFF8FC),
      title: const Text('Bebek profillerim'),
      actions: [IconButton(
        tooltip: 'Veri bütünlüğü kontrolü',
        icon: const Icon(Icons.fact_check_outlined),
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
            builder: (_) => const ChildDataAuditPage())),
      )],
    ),
    floatingActionButton: _loading || _saving || _error != null ? null :
        FloatingActionButton.extended(
          backgroundColor: const Color(0xFFE9569B),
          foregroundColor: Colors.white,
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: const Text('Bebek ekle'),
        ),
    body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 100), children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFD5E9), Color(0xFFEAE0FF)]),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.favorite_rounded, color: Color(0xFFD64B91), size: 30),
          SizedBox(height: 12),
          Text('Minik mucizelerim', style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF693A70))),
          SizedBox(height: 6),
          Text('Her bebeğin gelişimini ve günlük kayıtlarını ayrı ayrı takip et.',
              style: TextStyle(fontSize: 14, color: Color(0xFF735D7B))),
        ]),
      ),
      const SizedBox(height: 18),
      if (_error != null) Card(child: ListTile(
        title: Text(_error!),
        trailing: TextButton(onPressed: () {
          setState(() => _loading = true);
          _load();
        }, child: const Text('Tekrar dene')),
      )),
      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFFD64B91)),
          hintText: 'Bebeklerimde ara...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
        ),
        onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
      ),
      const SizedBox(height: 18),
      Text('Profillerim (${_profiles.length})', style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      if (_profiles.isEmpty && _error == null)
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const Icon(Icons.child_care, size: 48, color: Color(0xFFD64B91)),
          const SizedBox(height: 10),
          const Text('Henüz bebek profili eklenmedi.'),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _add,
              icon: const Icon(Icons.add), label: const Text('İlk bebeğimi ekle')),
        ]))),
      for (final profile in _profiles.where((p) => p.name.toLowerCase().contains(_search)))
        _profileCard(profile),
      if (_profiles.isNotEmpty &&
          !_profiles.any((p) => p.name.toLowerCase().contains(_search)))
        const Padding(padding: EdgeInsets.all(24),
            child: Center(child: Text('Aramanıza uygun bebek bulunamadı.'))),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: _loading || _saving || _error != null ? null : _add,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Yeni bebek profili oluştur'),
      ),
      const SizedBox(height: 12),
      const Text('Bir profile dokunarak beslenme, uyku, büyüme ve sağlık kayıtlarını açabilirsiniz.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF85798A))),
    ]),
  );
}
