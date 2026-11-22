// Her kullanıcı ekranı boş açılmamalı: hatasız çizilmeli, yeterli içerik
// göstermeli ve en az bir etkileşim (kayıt girme, arama, açma) sunmalıdır.
import 'package:anne_bebek/cycle_tracker.dart';
import 'package:anne_bebek/extra_features.dart';
import 'package:anne_bebek/life_hub.dart';
import 'package:anne_bebek/screens/activity_planner_page.dart';
import 'package:anne_bebek/screens/age_guides_page.dart';
import 'package:anne_bebek/screens/ai_assistant_page.dart';
import 'package:anne_bebek/screens/baby_activity_catalog_page.dart';
import 'package:anne_bebek/screens/baby_health_page.dart';
import 'package:anne_bebek/screens/baby_nutrition_page.dart';
import 'package:anne_bebek/screens/baby_recipes_page.dart';
import 'package:anne_bebek/screens/backup_page.dart';
import 'package:anne_bebek/screens/child_profiles_page.dart';
import 'package:anne_bebek/screens/daily_meal_suggestions_page.dart';
import 'package:anne_bebek/screens/encyclopedia_page.dart';
import 'package:anne_bebek/screens/family_recipe_notebook_page.dart';
import 'package:anne_bebek/screens/fever_log_page.dart';
import 'package:anne_bebek/screens/module_hub_page.dart';
import 'package:anne_bebek/screens/mom_tools_page.dart';
import 'package:anne_bebek/screens/monthly_baby_guide_page.dart';
import 'package:anne_bebek/screens/mother_profile_page.dart';
import 'package:anne_bebek/screens/my_health_page.dart';
import 'package:anne_bebek/screens/notification_preferences_page.dart';
import 'package:anne_bebek/screens/pantry_recipe_page.dart';
import 'package:anne_bebek/screens/postpartum_care_page.dart';
import 'package:anne_bebek/screens/product_catalog_page.dart';
import 'package:anne_bebek/screens/questions_page.dart';
import 'package:anne_bebek/screens/recipe_explorer_page.dart';
import 'package:anne_bebek/screens/reminders_page.dart';
import 'package:anne_bebek/screens/reproductive_calendar_page.dart';
import 'package:anne_bebek/screens/shopping_checklist_page.dart';
import 'package:anne_bebek/screens/smart_discovery_page.dart';
import 'package:anne_bebek/screens/smart_shopping_page.dart';
import 'package:anne_bebek/screens/weekly_meal_planner_page.dart';
import 'package:anne_bebek/screens/women_lifestyle_page.dart';
import 'package:anne_bebek/screens/womens_health_journal_page.dart';
import 'package:anne_bebek/screens/birth_plan_page.dart';
import 'package:anne_bebek/screens/care_guides_pages.dart';
import 'package:anne_bebek/screens/more_guides_pages.dart';
import 'package:anne_bebek/screens/tracking_report_page.dart';
import 'package:anne_bebek/screens/life_guides_pages.dart';
import 'package:anne_bebek/screens/family_more_pages.dart';
import 'package:anne_bebek/screens/extra_guides_pages.dart';
import 'package:anne_bebek/screens/family_tools_pages.dart';
import 'package:anne_bebek/screens/first_aid_page.dart';
import 'package:anne_bebek/screens/food_intro_page.dart';
import 'package:anne_bebek/screens/memories_page.dart';
import 'package:anne_bebek/screens/milestones_page.dart';
import 'package:anne_bebek/screens/milk_stash_page.dart';
import 'package:anne_bebek/screens/mood_check_page.dart';
import 'package:anne_bebek/screens/mother_exercise_page.dart';
import 'package:anne_bebek/screens/teeth_page.dart';
import 'package:anne_bebek/screens/ttc_page.dart';
import 'package:anne_bebek/sleep_journal.dart';
import 'package:anne_bebek/tracking_journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pages = <(String, Widget Function())>[
    ('ActivityPlannerPage', () => const ActivityPlannerPage()),
    ('AiAssistantPage', () => const AiAssistantPage()),
    ('BabyActivityCatalogPage', () => const BabyActivityCatalogPage()),
    ('BabyHealthPage', () => const BabyHealthPage()),
    ('BabyRecipesPage', () => const BabyRecipesPage()),
    ('BackupPage', () => const BackupPage()),
    ('ChildProfilesPage', () => const ChildProfilesPage()),
    ('CycleTrackerPage', () => const CycleTrackerPage()),
    ('DailyMealSuggestionsPage', () => const DailyMealSuggestionsPage()),
    ('EncyclopediaPage', () => const EncyclopediaPage()),
    ('FamilyCalendarPage', () => const FamilyCalendarPage()),
    ('FamilyRecipeNotebookPage', () => const FamilyRecipeNotebookPage()),
    ('FeverLogPage', () => const FeverLogPage()),
    ('LifeHubPage', () => const LifeHubPage()),
    ('ModuleHubPage', () => const ModuleHubPage()),
    ('MomToolsPage', () => const MomToolsPage()),
    ('NotificationPreferencesPage', () => const NotificationPreferencesPage()),
    ('PantryRecipePage', () => const PantryRecipePage()),
    ('PostpartumCarePage', () => const PostpartumCarePage()),
    ('PregnancyPage', () => const PregnancyPage()),
    ('PregnancyWeekGuidePage', () => const PregnancyWeekGuidePage()),
    ('ProductCatalogPage', () => const ProductCatalogPage()),
    ('RecipeExplorerPage', () => const RecipeExplorerPage()),
    ('RemindersPage', () => const RemindersPage()),
    ('ReproductiveCalendarPage', () => const ReproductiveCalendarPage()),
    ('ShoppingChecklistPage', () => const ShoppingChecklistPage()),
    ('SleepJournalPage', () => const SleepJournalPage()),
    ('SmartDiscoveryPage', () => const SmartDiscoveryPage()),
    ('SmartShoppingPage', () => const SmartShoppingPage()),
    ('TrackingJournalPage', () => const TrackingJournalPage()),
    ('TrackingJournalPage(gebelik)', () => const TrackingJournalPage(pregnancy: true)),
    ('WeeklyMealPlannerPage', () => const WeeklyMealPlannerPage()),
    ('WomenLifestylePage', () => const WomenLifestylePage()),
    ('WomensHealthJournalPage', () => const WomensHealthJournalPage()),
    ('MyHealthPage', () => const MyHealthPage(scheduleNotifications: false)),
    ('MotherProfilePage', () => const MotherProfilePage()),
    ('QuestionsPage', () => const QuestionsPage()),
    ('BabyNutritionPage', () => const BabyNutritionPage(initialMonth: 6)),
    ('MonthlyBabyGuidePage', () => const MonthlyBabyGuidePage(initialMonth: 3)),
    ('AgeGuidesPage', () => const AgeGuidesPage()),
    ('MilestonesPage', () => MilestonesPage(birth: DateTime.now().subtract(const Duration(days: 300)))),
    ('TeethPage', () => TeethPage(birth: DateTime.now().subtract(const Duration(days: 300)))),
    ('FoodIntroPage', () => FoodIntroPage(birth: DateTime.now().subtract(const Duration(days: 200)))),
    ('MemoriesPage', () => const MemoriesPage()),
    ('MoodCheckPage', () => const MoodCheckPage()),
    ('TtcPage', () => TtcPage(periodStarts: [DateTime.now().subtract(const Duration(days: 10))])),
    ('MotherExercisePage', () => const MotherExercisePage()),
    ('MilkStashPage', () => const MilkStashPage()),
    ('BirthPlanPage', () => const BirthPlanPage()),
    ('FirstAidPage', () => const FirstAidPage()),
    ('NewbornChecklistPage', () => const NewbornChecklistPage()),
    ('PottyTrainingPage', () => const PottyTrainingPage()),
    ('CaregiverCardPage', () => const CaregiverCardPage(childName: 'Ada')),
    ('FoodSafetyPage', () => const FoodSafetyPage()),
    ('PregnancyWeightPage', () => const PregnancyWeightPage()),
    ('CryingBabyPage', () => const CryingBabyPage()),
    ('SleepGuidePage', () => SleepGuidePage(birth: DateTime.now().subtract(const Duration(days: 200)))),
    ('SickBabyGuidePage', () => const SickBabyGuidePage()),
    ('BreastfeedingHelpPage', () => const BreastfeedingHelpPage()),
    ('StoolGuidePage', () => const StoolGuidePage()),
    ('PregnancyWarningSignsPage', () => const PregnancyWarningSignsPage()),
    ('FormulaPrepPage', () => const FormulaPrepPage()),
    ('BabyCareHowToPage', () => const BabyCareHowToPage()),
    ('SpeechDevelopmentPage', () => SpeechDevelopmentPage(birth: DateTime.now().subtract(const Duration(days: 400)))),
    ('PostpartumContraceptionPage', () => const PostpartumContraceptionPage()),
    ('TrackingReportPage', () => const TrackingReportPage()),
    ('MotherRightsPage', () => const MotherRightsPage()),
    ('TravelWithBabyPage', () => const TravelWithBabyPage()),
    ('BreastSelfExamPage', () => const BreastSelfExamPage()),
    ('TantrumHelperPage', () => const TantrumHelperPage()),
    ('ScreenTimePage', () => ScreenTimePage(birth: DateTime.now().subtract(const Duration(days: 1000)))),
    ('PartnerGuidePage', () => const PartnerGuidePage()),
    ('SiblingPrepPage', () => const SiblingPrepPage()),
    ('MenopauseTrackerPage', () => const MenopauseTrackerPage()),
    ('HomeSafetyPage', () => HomeSafetyPage(birth: DateTime.now().subtract(const Duration(days: 200)))),
  ];
  for (final (name, build) in pages) {
    testWidgets('$name boş değil ve etkileşimli', (tester) async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': 1});
      installSecureStorageMock();
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: build())));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final error = tester.takeException();
      expect(error, isNull, reason: '$name: ${error is FlutterError ? error.diagnostics.map((d) => d.toString()).join('\n') : error}');
      final texts = find.byType(Text).evaluate().length;
      expect(texts, greaterThanOrEqualTo(3), reason: '$name: ekran neredeyse boş ($texts metin)');
      final interactive = find.byWidgetPredicate((w) =>
          (w is ButtonStyleButton && w.onPressed != null) ||
          (w is IconButton && w.onPressed != null) ||
          (w is FloatingActionButton && w.onPressed != null) ||
          w is TextField || w is EditableText ||
          (w is ListTile && w.onTap != null) ||
          (w is InkWell && w.onTap != null) ||
          w is Checkbox || w is Switch || w is ChoiceChip || w is FilterChip || w is Tab ||
          w is DropdownButton || w is Slider || w is PopupMenuButton ||
          (w is GestureDetector && w.onTap != null));
      // Etkileşimli öğe ekranın altında olabilir; tembel listeyi aşağı kaydırarak ara.
      final scrollables = find.byType(Scrollable);
      for (var i = 0; i < 8 && interactive.evaluate().isEmpty && scrollables.evaluate().isNotEmpty; i++) {
        await tester.drag(scrollables.first, const Offset(0, -500), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(interactive, findsWidgets, reason: '$name: dokunulacak ya da kayıt girilecek bir öğe yok');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
