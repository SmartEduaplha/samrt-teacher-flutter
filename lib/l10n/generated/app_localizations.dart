import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'مساعد المعلم'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get navGroups;

  /// No description provided for @navStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get navStudents;

  /// No description provided for @navAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get navAttendance;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @themeAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر والشكل'**
  String get themeAppearance;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب النظام)'**
  String get themeSystem;

  /// No description provided for @newGroup.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة جديدة'**
  String get newGroup;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get searchHint;

  /// No description provided for @noGroupsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات'**
  String get noGroupsFound;

  /// No description provided for @noGroupsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات حتى الآن'**
  String get noGroupsYet;

  /// No description provided for @addGroup.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مجموعة'**
  String get addGroup;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @center.
  ///
  /// In ar, this message translates to:
  /// **'سنتر'**
  String get center;

  /// No description provided for @privateGroup.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة خاصة'**
  String get privateGroup;

  /// No description provided for @privateLesson.
  ///
  /// In ar, this message translates to:
  /// **'درس خاص'**
  String get privateLesson;

  /// No description provided for @online.
  ///
  /// In ar, this message translates to:
  /// **'أونلاين'**
  String get online;

  /// No description provided for @groupsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مجموعة'**
  String groupsCount(int count);

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String errorOccurred(String error);

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @security.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get security;

  /// No description provided for @appLock.
  ///
  /// In ar, this message translates to:
  /// **'قفل التطبيق (PIN)'**
  String get appLock;

  /// No description provided for @appLockSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب رمز الدخول عند فتح التطبيق'**
  String get appLockSubtitle;

  /// No description provided for @backupData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات والنسخ الاحتياطي'**
  String get backupData;

  /// No description provided for @backupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة النسخ الاحتياطي اليدوي'**
  String get backupSubtitle;

  /// No description provided for @exportImport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير/استيراد البيانات'**
  String get exportImport;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تفعيل هذه الميزة قريباً'**
  String get comingSoon;

  /// No description provided for @setPin.
  ///
  /// In ar, this message translates to:
  /// **'إعداد رمز PIN'**
  String get setPin;

  /// No description provided for @enterFourDigits.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز مكون من 4 أرقام'**
  String get enterFourDigits;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @saving.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get saving;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get notes;

  /// No description provided for @viewTasks.
  ///
  /// In ar, this message translates to:
  /// **'عرض المهام'**
  String get viewTasks;

  /// No description provided for @moreMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة الإضافية'**
  String get moreMenu;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @profileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة بياناتك وصورتك الشخصية'**
  String get profileSubtitle;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات والتحميل'**
  String get notificationsSubtitle;

  /// No description provided for @groupsAndLevel.
  ///
  /// In ar, this message translates to:
  /// **'المراحل والمجموعات'**
  String get groupsAndLevel;

  /// No description provided for @groupsAndLevelSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التصنيفات الدراسية'**
  String get groupsAndLevelSubtitle;

  /// No description provided for @appSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التطبيق'**
  String get appSettings;

  /// No description provided for @appSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اللغة، الثيم، والأمان'**
  String get appSettingsSubtitle;

  /// No description provided for @helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupport;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة وتواصل معنا'**
  String get helpSupportSubtitle;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @teacherPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة المعلم'**
  String get teacherPortal;

  /// No description provided for @studentPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الطالب'**
  String get studentPortal;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ سجل الآن'**
  String get noAccount;

  /// No description provided for @orViaGoogle.
  ///
  /// In ar, this message translates to:
  /// **'أو عبر جوجل'**
  String get orViaGoogle;

  /// No description provided for @googleLogin.
  ///
  /// In ar, this message translates to:
  /// **'الدخول بواسطة جوجل'**
  String get googleLogin;

  /// No description provided for @teacherLogin.
  ///
  /// In ar, this message translates to:
  /// **'دخول المعلم'**
  String get teacherLogin;

  /// No description provided for @studentLogin.
  ///
  /// In ar, this message translates to:
  /// **'دخول الطالب'**
  String get studentLogin;

  /// No description provided for @studentWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك يا بطل! ادخل كود البوابة الخاص بك للمتابعة'**
  String get studentWelcome;

  /// No description provided for @studentCode.
  ///
  /// In ar, this message translates to:
  /// **'كود الطالب'**
  String get studentCode;

  /// No description provided for @studentCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الحصول على الكود من المعلم الخاص بك'**
  String get studentCodeHint;

  /// No description provided for @errorEmptyFields.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء جميع الحقول'**
  String get errorEmptyFields;

  /// No description provided for @errorEmptyStudentCode.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كود الطالب'**
  String get errorEmptyStudentCode;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @statsGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get statsGroups;

  /// No description provided for @groupsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get groupsTitle;

  /// No description provided for @statsStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get statsStudents;

  /// No description provided for @studentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get studentsTitle;

  /// No description provided for @statsTodayCollection.
  ///
  /// In ar, this message translates to:
  /// **'حصيلة اليوم'**
  String get statsTodayCollection;

  /// No description provided for @todayRevenue.
  ///
  /// In ar, this message translates to:
  /// **'حصيلة اليوم'**
  String get todayRevenue;

  /// No description provided for @statsOutstanding.
  ///
  /// In ar, this message translates to:
  /// **'المتأخرات'**
  String get statsOutstanding;

  /// No description provided for @debtsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المديونيات'**
  String get debtsTitle;

  /// No description provided for @currentlyActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة حالياً'**
  String get currentlyActive;

  /// No description provided for @activeNow.
  ///
  /// In ar, this message translates to:
  /// **'نشطة حالياً'**
  String get activeNow;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي'**
  String get total;

  /// No description provided for @operations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات'**
  String get operations;

  /// No description provided for @studentsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب'**
  String studentsCount(int count);

  /// No description provided for @totalCount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي {count} طالب'**
  String totalCount(int count);

  /// No description provided for @operationsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عمليات'**
  String operationsCount(int count);

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currency;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك،'**
  String get welcomeBack;

  /// No description provided for @teacher.
  ///
  /// In ar, this message translates to:
  /// **'المعلم'**
  String get teacher;

  /// No description provided for @todayAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور اليوم'**
  String get todayAttendance;

  /// No description provided for @present.
  ///
  /// In ar, this message translates to:
  /// **'حضور'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In ar, this message translates to:
  /// **'غياب'**
  String get absent;

  /// No description provided for @todaySessions.
  ///
  /// In ar, this message translates to:
  /// **'حصص اليوم'**
  String get todaySessions;

  /// No description provided for @noSessionsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حصص اليوم'**
  String get noSessionsToday;

  /// No description provided for @studentsPresent.
  ///
  /// In ar, this message translates to:
  /// **'طلاب حاضرون'**
  String get studentsPresent;

  /// No description provided for @outstandingAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المتأخرات'**
  String get outstandingAlerts;

  /// No description provided for @noOutstandingPayments.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز! لا توجد متأخرات'**
  String get noOutstandingPayments;

  /// No description provided for @totalOutstandingThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المتأخرات هذا الشهر'**
  String get totalOutstandingThisMonth;

  /// No description provided for @recentFinancialActivity.
  ///
  /// In ar, this message translates to:
  /// **'آخر النشاطات المادية'**
  String get recentFinancialActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات مؤخراً'**
  String get noRecentActivity;

  /// No description provided for @communicationManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التواصل'**
  String get communicationManagement;

  /// No description provided for @generalAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات العامة'**
  String get generalAnnouncements;

  /// No description provided for @generalAnnouncementsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رسائل تظهر فورياً للطلاب'**
  String get generalAnnouncementsSubtitle;

  /// No description provided for @smartSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'مقترحات ذكية 💡'**
  String get smartSuggestions;

  /// No description provided for @takeAction.
  ///
  /// In ar, this message translates to:
  /// **'اتخاذ إجراء'**
  String get takeAction;

  /// No description provided for @convertToTask.
  ///
  /// In ar, this message translates to:
  /// **'تحويل لمهمة'**
  String get convertToTask;

  /// No description provided for @suggestionConvertedToTask.
  ///
  /// In ar, this message translates to:
  /// **'تم تحويل المقترح إلى مهمة: {title}'**
  String suggestionConvertedToTask(String title);

  /// No description provided for @schedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول الحصص'**
  String get schedule;

  /// No description provided for @recordAttendance.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل حضور'**
  String get recordAttendance;

  /// No description provided for @addPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get addPayment;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @showMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد ({count})'**
  String showMore(int count);

  /// No description provided for @showLess.
  ///
  /// In ar, this message translates to:
  /// **'عرض أقل'**
  String get showLess;

  /// No description provided for @saturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get friday;

  /// No description provided for @am_suffix.
  ///
  /// In ar, this message translates to:
  /// **'ص'**
  String get am_suffix;

  /// No description provided for @pm_suffix.
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get pm_suffix;

  /// No description provided for @sessions_count_label.
  ///
  /// In ar, this message translates to:
  /// **'{count} حصة'**
  String sessions_count_label(Object count);

  /// No description provided for @no_sessions_on_this_day.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حصص في هذا اليوم'**
  String get no_sessions_on_this_day;

  /// No description provided for @student_label_count.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب'**
  String student_label_count(int count);

  /// No description provided for @attendance_title.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الحضور'**
  String get attendance_title;

  /// No description provided for @attendance_edit_registered.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مسجّل'**
  String get attendance_edit_registered;

  /// No description provided for @attendance_select_group_hint.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة...'**
  String get attendance_select_group_hint;

  /// No description provided for @attendance_session_date_label.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الحصة'**
  String get attendance_session_date_label;

  /// No description provided for @attendance_stat_present.
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get attendance_stat_present;

  /// No description provided for @attendance_stat_absent.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get attendance_stat_absent;

  /// No description provided for @attendance_stat_total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي'**
  String get attendance_stat_total;

  /// No description provided for @attendance_quick_all_present.
  ///
  /// In ar, this message translates to:
  /// **'✅ الكل حاضر'**
  String get attendance_quick_all_present;

  /// No description provided for @attendance_quick_all_absent.
  ///
  /// In ar, this message translates to:
  /// **'❌ الكل غائب'**
  String get attendance_quick_all_absent;

  /// No description provided for @attendance_no_students_in_group.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب في هذه المجموعة'**
  String get attendance_no_students_in_group;

  /// No description provided for @attendance_free_badge.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get attendance_free_badge;

  /// No description provided for @attendance_saving_state.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get attendance_saving_state;

  /// No description provided for @attendance_save_success_state.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ ✓'**
  String get attendance_save_success_state;

  /// No description provided for @attendance_save_button_label.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الحضور'**
  String get attendance_save_button_label;

  /// No description provided for @attendance_whatsapp_bulk_toggle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات جماعية عبر واتساب'**
  String get attendance_whatsapp_bulk_toggle;

  /// No description provided for @whatsappBulkConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد حضور المجموعة: {groupName}'**
  String whatsappBulkConfirmTitle(String groupName);

  /// No description provided for @whatsappBulkDesc.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه سيتم إرساله للطلاب المحددين فقط.'**
  String get whatsappBulkDesc;

  /// No description provided for @whatsappBetaNote.
  ///
  /// In ar, this message translates to:
  /// **'إصدار تجريبي: تأكد من مراجعة الرسائل قبل الإرسال.'**
  String get whatsappBetaNote;

  /// No description provided for @teacherNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعلم (اختياري)'**
  String get teacherNameLabel;

  /// No description provided for @teacherNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعلم...'**
  String get teacherNameHint;

  /// No description provided for @messageTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الرسالة'**
  String get messageTypeLabel;

  /// No description provided for @absentNotification.
  ///
  /// In ar, this message translates to:
  /// **'❌ إشعار غياب'**
  String get absentNotification;

  /// No description provided for @presentConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'✅ تأكيد حضور'**
  String get presentConfirmation;

  /// No description provided for @lateNotification.
  ///
  /// In ar, this message translates to:
  /// **'⏰ إشعار تأخير'**
  String get lateNotification;

  /// No description provided for @sessionReminder.
  ///
  /// In ar, this message translates to:
  /// **'📢 تذكير بالحصة'**
  String get sessionReminder;

  /// No description provided for @sendToLabel.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إلى'**
  String get sendToLabel;

  /// No description provided for @absentCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'الغائبين ({count})'**
  String absentCountLabel(int count);

  /// No description provided for @presentCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحاضرين ({count})'**
  String presentCountLabel(int count);

  /// No description provided for @allStudentsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكل ({count})'**
  String allStudentsLabel(int count);

  /// No description provided for @messagePreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الرسالة:'**
  String get messagePreviewTitle;

  /// No description provided for @sendViaWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'إرسال عبر واتساب'**
  String get sendViaWhatsapp;

  /// No description provided for @noStudentsOfType.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد {type} في هذه المجموعة.'**
  String noStudentsOfType(String type);

  /// No description provided for @suggestionAttendanceMissed.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل حضور مجموعة {name} حتى الآن، مرور ساعة على بدء الحصة.'**
  String suggestionAttendanceMissed(String name);

  /// No description provided for @paymentOf.
  ///
  /// In ar, this message translates to:
  /// **'دفعة بقيمة'**
  String get paymentOf;

  /// No description provided for @suggestionAttendanceTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحضير مجموعة {name}'**
  String suggestionAttendanceTaskTitle(Object name);

  /// No description provided for @suggestionAttendanceTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تسجيل حضور اليوم لمجموعة {name}'**
  String suggestionAttendanceTaskDesc(Object name);

  /// No description provided for @suggestionPerformanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تراجع مستوى'**
  String get suggestionPerformanceTitle;

  /// No description provided for @suggestionPerformanceMessage.
  ///
  /// In ar, this message translates to:
  /// **'درجة الطالب {name} في آخر اختبار ({score}%) أقل بكثير من متوسطه.'**
  String suggestionPerformanceMessage(String name, String score);

  /// No description provided for @suggestionPerformanceTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة مستوى {name}'**
  String suggestionPerformanceTaskTitle(Object name);

  /// No description provided for @suggestionPerformanceTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة أداء الطالب {name} بعد تراجع درجاته في الاختبار الأخير'**
  String suggestionPerformanceTaskDesc(Object name);

  /// No description provided for @suggestionAbsenceTitle.
  ///
  /// In ar, this message translates to:
  /// **'غياب متكرر'**
  String get suggestionAbsenceTitle;

  /// No description provided for @suggestionAbsenceMessage.
  ///
  /// In ar, this message translates to:
  /// **'الطالب {name} غاب {count} حصص من آخر 5. يفضل متابعته.'**
  String suggestionAbsenceMessage(String name, int count);

  /// No description provided for @suggestionAbsenceWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'بخصوص غياب الطالب {name} المتكرر...'**
  String suggestionAbsenceWhatsApp(Object name);

  /// No description provided for @suggestionAbsenceTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بولي أمر {name}'**
  String suggestionAbsenceTaskTitle(Object name);

  /// No description provided for @suggestionAbsenceTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'التحدث مع ولي أمر الطالب {name} بخصوص تكرار الغياب ({count}/5)'**
  String suggestionAbsenceTaskDesc(Object count, Object name);

  /// No description provided for @suggestionDebtorTitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة تحصيل'**
  String get suggestionDebtorTitle;

  /// No description provided for @suggestionDebtorMessage.
  ///
  /// In ar, this message translates to:
  /// **'الطالب {name} منتظم في الحضور لكن لم يسدد مصروفات هذا الشهر.'**
  String suggestionDebtorMessage(Object name);

  /// No description provided for @suggestionDebtorTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل مصروفات {name}'**
  String suggestionDebtorTaskTitle(Object name);

  /// No description provided for @suggestionDebtorTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'مطالبة الطالب {name} بمصروفات شهر {month}'**
  String suggestionDebtorTaskDesc(Object month, Object name);

  /// No description provided for @suggestionInactiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة غير نشطة'**
  String get suggestionInactiveTitle;

  /// No description provided for @suggestionInactiveMessage.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة {name} لم يسجل لها حضور منذ أسبوع. هل توقفت؟'**
  String suggestionInactiveMessage(Object name);

  /// No description provided for @suggestionInactiveTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة حالة مجموعة {name}'**
  String suggestionInactiveTaskTitle(Object name);

  /// No description provided for @suggestionInactiveTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'التحقق مما إذا كانت مجموعة {name} لا تزال قائمة أو تحتاج للإغلاق'**
  String suggestionInactiveTaskDesc(Object name);

  /// No description provided for @suggestionHonorTitle.
  ///
  /// In ar, this message translates to:
  /// **'ترشيح تكريم'**
  String get suggestionHonorTitle;

  /// No description provided for @suggestionHonorMessage.
  ///
  /// In ar, this message translates to:
  /// **'الطالب {name} حصل على درجات ممتازة مؤخراً. يستحق التواجد في لوحة الشرف.'**
  String suggestionHonorMessage(Object name);

  /// No description provided for @suggestionHonorTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'تكريم الطالب {name}'**
  String suggestionHonorTaskTitle(Object name);

  /// No description provided for @suggestionHonorTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الطالب {name} للوحة الشرف وتجهيز شهادة تقدير'**
  String suggestionHonorTaskDesc(Object name);

  /// No description provided for @suggestionPortalTitle.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الطلاب'**
  String get suggestionPortalTitle;

  /// No description provided for @suggestionPortalMessage.
  ///
  /// In ar, this message translates to:
  /// **'الطالب الجديد {name} ليس لديه كود بوابة بعد.'**
  String suggestionPortalMessage(Object name);

  /// No description provided for @suggestionPortalTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء كود بوابة لـ {name}'**
  String suggestionPortalTaskTitle(Object name);

  /// No description provided for @suggestionPortalTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'توليد وإرسال كود بوابة الطالب {name}'**
  String suggestionPortalTaskDesc(Object name);

  /// No description provided for @suggestionGradingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح الاختبارات'**
  String get suggestionGradingTitle;

  /// No description provided for @suggestionGradingMessage.
  ///
  /// In ar, this message translates to:
  /// **'اختبار {title} يحتاج لتصحيح {count} طلاب.'**
  String suggestionGradingMessage(String title, int count);

  /// No description provided for @suggestionGradingTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح {title}'**
  String suggestionGradingTaskTitle(Object title);

  /// No description provided for @suggestionGradingTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'إكمال رصد درجات {count} طلاب لـ {title}'**
  String suggestionGradingTaskDesc(Object count, Object title);

  /// No description provided for @suggestionWelcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك!'**
  String get suggestionWelcomeTitle;

  /// No description provided for @suggestionWelcomeMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count} طالب نشط الآن. تمنياتنا بيوم دراسي موفق!'**
  String suggestionWelcomeMessage(int count);

  /// No description provided for @suggestion_action_take.
  ///
  /// In ar, this message translates to:
  /// **'اتخاذ إجراء'**
  String get suggestion_action_take;

  /// No description provided for @suggestion_action_dismiss.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get suggestion_action_dismiss;

  /// No description provided for @suggestion_action_whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get suggestion_action_whatsapp;

  /// No description provided for @suggestion_action_tasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get suggestion_action_tasks;

  /// No description provided for @attendance_wa_teacher_name_label.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعلم (اختياري)'**
  String get attendance_wa_teacher_name_label;

  /// No description provided for @attendance_wa_teacher_name_hint.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعلم...'**
  String get attendance_wa_teacher_name_hint;

  /// No description provided for @attendance_wa_msg_type_label.
  ///
  /// In ar, this message translates to:
  /// **'نوع الرسالة'**
  String get attendance_wa_msg_type_label;

  /// No description provided for @attendance_wa_type_absent.
  ///
  /// In ar, this message translates to:
  /// **'❌ إشعار غياب'**
  String get attendance_wa_type_absent;

  /// No description provided for @attendance_wa_type_present.
  ///
  /// In ar, this message translates to:
  /// **'✅ تأكيد حضور'**
  String get attendance_wa_type_present;

  /// No description provided for @attendance_wa_type_late.
  ///
  /// In ar, this message translates to:
  /// **'⏰ إشعار تأخير'**
  String get attendance_wa_type_late;

  /// No description provided for @attendance_wa_type_reminder.
  ///
  /// In ar, this message translates to:
  /// **'📢 تذكير بالحصة'**
  String get attendance_wa_type_reminder;

  /// No description provided for @attendance_wa_send_to_label.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إلى'**
  String get attendance_wa_send_to_label;

  /// No description provided for @attendance_wa_target_absent.
  ///
  /// In ar, this message translates to:
  /// **'الغائبين ({count})'**
  String attendance_wa_target_absent(int count);

  /// No description provided for @attendance_wa_target_present.
  ///
  /// In ar, this message translates to:
  /// **'الحاضرين ({count})'**
  String attendance_wa_target_present(int count);

  /// No description provided for @attendance_wa_target_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل ({count})'**
  String attendance_wa_target_all(int count);

  /// No description provided for @attendance_wa_preview_label.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الرسالة:'**
  String get attendance_wa_preview_label;

  /// No description provided for @attendance_wa_preview_name_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطالب'**
  String get attendance_wa_preview_name_placeholder;

  /// No description provided for @attendance_wa_no_phone_warning.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب بدون رقم هاتف — لن يتم إرسال رسائلهم'**
  String attendance_wa_no_phone_warning(int count);

  /// No description provided for @attendance_wa_send_button_label.
  ///
  /// In ar, this message translates to:
  /// **'إرسال لـ {count} طالب'**
  String attendance_wa_send_button_label(int count);

  /// No description provided for @attendance_wa_msg_present_template.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم ورحمة الله 🌟\nنود إعلامكم بأن الطالب/ة *{name}* قد حضر/ت حصة اليوم.\n📚 المجموعة: {group}\n📅 التاريخ: {date}\n\nشكراً على المتابعة 🙏\n{teacher}'**
  String attendance_wa_msg_present_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  );

  /// No description provided for @attendance_wa_msg_absent_template.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم ورحمة الله ⚠️\nنود إعلامكم بأن الطالب/ة *{name}* تغيب/ت عن حصة اليوم.\n📚 المجموعة: {group}\n📅 التاريخ: {date}\n\nنرجو المتابعة والاهتمام 🤍\n{teacher}'**
  String attendance_wa_msg_absent_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  );

  /// No description provided for @attendance_wa_msg_late_template.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم ورحمة الله ⏰\nنود إعلامكم بأن الطالب/ة *{name}* تأخر/ت عن موعد حصة اليوم.\n📚 المجموعة: {group}\n📅 التاريخ: {date}\n\nنرجو الالتزام بالمواعيد 🙏\n{teacher}'**
  String attendance_wa_msg_late_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  );

  /// No description provided for @attendance_wa_msg_reminder_template.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم ورحمة الله 📢\nتذكير للطالب/ة *{name}* بموعد الحصة.\n📚 المجموعة: {group}\n📅 التاريخ: {date}\n\nفي انتظاركم 💪\n{teacher}'**
  String attendance_wa_msg_reminder_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  );

  /// No description provided for @revenue.
  ///
  /// In ar, this message translates to:
  /// **'حصيلة'**
  String get revenue;

  /// No description provided for @studentsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلاب'**
  String studentsCountLabel(Object count);

  /// No description provided for @takeAttendanceFor.
  ///
  /// In ar, this message translates to:
  /// **'تحويل تحضير {name} لمهمة'**
  String takeAttendanceFor(Object name);

  /// No description provided for @followUpPerformance.
  ///
  /// In ar, this message translates to:
  /// **'متابعة مستوى {name}'**
  String followUpPerformance(Object name);

  /// No description provided for @callParent.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بولي أمر {name}'**
  String callParent(Object name);

  /// No description provided for @collectFees.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل من {name}'**
  String collectFees(Object name);

  /// No description provided for @reviewGroup.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة مجموعة {name}'**
  String reviewGroup(Object name);

  /// No description provided for @honorStudent.
  ///
  /// In ar, this message translates to:
  /// **'تكريم الطالب {name}'**
  String honorStudent(Object name);

  /// No description provided for @generatePortalCode.
  ///
  /// In ar, this message translates to:
  /// **'كود بوابة لـ {name}'**
  String generatePortalCode(Object name);

  /// No description provided for @gradeQuiz.
  ///
  /// In ar, this message translates to:
  /// **'رصد درجات {title}'**
  String gradeQuiz(Object title);

  /// No description provided for @activityAdded.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get activityAdded;

  /// No description provided for @activityUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get activityUpdated;

  /// No description provided for @activityDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get activityDeleted;

  /// No description provided for @activityAttendance.
  ///
  /// In ar, this message translates to:
  /// **'تحضير'**
  String get activityAttendance;

  /// No description provided for @activityPayment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get activityPayment;

  /// No description provided for @weeklyScheduleTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجدول الأسبوعي'**
  String get weeklyScheduleTitle;

  /// No description provided for @noRevenueToday.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تحصيل اليوم'**
  String get noRevenueToday;

  /// No description provided for @recentActivity.
  ///
  /// In ar, this message translates to:
  /// **'آخر التحركات'**
  String get recentActivity;

  /// No description provided for @totalStudents.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلاب'**
  String get totalStudents;

  /// No description provided for @paidThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'دفعوا هذا الشهر'**
  String get paidThisMonth;

  /// No description provided for @notPaidThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'لم يدفعوا'**
  String get notPaidThisMonth;

  /// No description provided for @groupData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المجموعة'**
  String get groupData;

  /// No description provided for @academicYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة الدراسية'**
  String get academicYear;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'المكان'**
  String get location;

  /// No description provided for @sessionLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط الحصة'**
  String get sessionLink;

  /// No description provided for @weeklySchedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول الأسبوعي'**
  String get weeklySchedule;

  /// No description provided for @noScheduleSet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد جدول محدد'**
  String get noScheduleSet;

  /// No description provided for @deleteGroup.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجموعة'**
  String get deleteGroup;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه المجموعة؟ جميع بيانات الطلاب والغياب والمدفوعات سيتم حذفها نهائياً.'**
  String get deleteGroupConfirm;

  /// No description provided for @editGroup.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المجموعة'**
  String get editGroup;

  /// No description provided for @newGroupTitle.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة جديدة'**
  String get newGroupTitle;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @createGroup.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المجموعة'**
  String get createGroup;

  /// No description provided for @basicInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية'**
  String get basicInfo;

  /// No description provided for @groupName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجموعة'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: سنتر الفيزياء'**
  String get groupNameHint;

  /// No description provided for @groupType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المجموعة'**
  String get groupType;

  /// No description provided for @subject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get subject;

  /// No description provided for @subjectHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الفيزياء'**
  String get subjectHint;

  /// No description provided for @defaultPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الشهري الافتراضي (ج)'**
  String get defaultPrice;

  /// No description provided for @groupDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم المجموعة الشهري (ج)'**
  String get groupDiscount;

  /// No description provided for @actualPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الفعلي: {price} ج'**
  String actualPrice(String price);

  /// No description provided for @locationHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان السنتر أو المكان'**
  String get locationHint;

  /// No description provided for @notesHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات...'**
  String get notesHint;

  /// No description provided for @addTime.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موعد'**
  String get addTime;

  /// No description provided for @to.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get to;

  /// No description provided for @groupCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المجموعة'**
  String get groupCreated;

  /// No description provided for @changesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعديلات'**
  String get changesSaved;

  /// No description provided for @errorPrefix.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorPrefix(String error);

  /// No description provided for @students.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get students;

  /// No description provided for @searchStudentHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن طالب...'**
  String get searchStudentHint;

  /// No description provided for @noStudentsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب'**
  String get noStudentsFound;

  /// No description provided for @addStudent.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب'**
  String get addStudent;

  /// No description provided for @editStudent.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الطالب'**
  String get editStudent;

  /// No description provided for @newStudentTitle.
  ///
  /// In ar, this message translates to:
  /// **'طالب جديد'**
  String get newStudentTitle;

  /// No description provided for @studentName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطالب'**
  String get studentName;

  /// No description provided for @studentNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الثلاثي أو الرباعي'**
  String get studentNameHint;

  /// No description provided for @gender.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @parentPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم ولي الأمر'**
  String get parentPhone;

  /// No description provided for @isFreeStudent.
  ///
  /// In ar, this message translates to:
  /// **'طالب مجاني (بدون مصاريف)'**
  String get isFreeStudent;

  /// No description provided for @barcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get barcode;

  /// No description provided for @barcodeHint.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغاً للتوليد التلقائي'**
  String get barcodeHint;

  /// No description provided for @studentCreated.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الطالب بنجاح'**
  String get studentCreated;

  /// No description provided for @studentUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات الطالب'**
  String get studentUpdated;

  /// No description provided for @studentProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملف'**
  String get studentProfile;

  /// No description provided for @attendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور'**
  String get attendance;

  /// No description provided for @payments.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get payments;

  /// No description provided for @results.
  ///
  /// In ar, this message translates to:
  /// **'النتائج'**
  String get results;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInfo;

  /// No description provided for @financialStatus.
  ///
  /// In ar, this message translates to:
  /// **'الموقف المالي'**
  String get financialStatus;

  /// No description provided for @attendanceRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الحضور'**
  String get attendanceRate;

  /// No description provided for @averageScore.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الدرجات'**
  String get averageScore;

  /// No description provided for @lastQuiz.
  ///
  /// In ar, this message translates to:
  /// **'آخر امتحان'**
  String get lastQuiz;

  /// No description provided for @free.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get free;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactive;

  /// No description provided for @whatsappGenericGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، بخصوص الطالب {name}...'**
  String whatsappGenericGreeting(String name);

  /// No description provided for @year_1_sec.
  ///
  /// In ar, this message translates to:
  /// **'الأول الثانوي'**
  String get year_1_sec;

  /// No description provided for @year_2_sec.
  ///
  /// In ar, this message translates to:
  /// **'الثاني الثانوي'**
  String get year_2_sec;

  /// No description provided for @year_3_sec.
  ///
  /// In ar, this message translates to:
  /// **'الثالث الثانوي'**
  String get year_3_sec;

  /// No description provided for @year_6_primary.
  ///
  /// In ar, this message translates to:
  /// **'الصف السادس الابتدائي'**
  String get year_6_primary;

  /// No description provided for @year_5_primary.
  ///
  /// In ar, this message translates to:
  /// **'الصف الخامس الابتدائي'**
  String get year_5_primary;

  /// No description provided for @year_4_primary.
  ///
  /// In ar, this message translates to:
  /// **'الصف الرابع الابتدائي'**
  String get year_4_primary;

  /// No description provided for @year_3_primary.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثالث الابتدائي'**
  String get year_3_primary;

  /// No description provided for @year_2_primary.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثاني الابتدائي'**
  String get year_2_primary;

  /// No description provided for @year_1_primary.
  ///
  /// In ar, this message translates to:
  /// **'الصف الأول الابتدائي'**
  String get year_1_primary;

  /// No description provided for @year_3_prep.
  ///
  /// In ar, this message translates to:
  /// **'الثالث الإعدادي'**
  String get year_3_prep;

  /// No description provided for @year_2_prep.
  ///
  /// In ar, this message translates to:
  /// **'الثاني الإعدادي'**
  String get year_2_prep;

  /// No description provided for @year_1_prep.
  ///
  /// In ar, this message translates to:
  /// **'الأول الإعدادي'**
  String get year_1_prep;

  /// No description provided for @year_university.
  ///
  /// In ar, this message translates to:
  /// **'طالب جامعي'**
  String get year_university;

  /// No description provided for @year_other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get year_other;

  /// No description provided for @exportStudentListSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تفعيل استخراج كشف الطلاب قريباً'**
  String get exportStudentListSoon;

  /// No description provided for @searchByNameOrPhone.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الرقم...'**
  String get searchByNameOrPhone;

  /// No description provided for @allGroupsFilter.
  ///
  /// In ar, this message translates to:
  /// **'كل المجموعات'**
  String get allGroupsFilter;

  /// No description provided for @addFirstStudent.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول طالب'**
  String get addFirstStudent;

  /// No description provided for @studentsRegisteredCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب مسجل'**
  String studentsRegisteredCount(int count);

  /// No description provided for @deleteStudentTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الطالب'**
  String get deleteStudentTitle;

  /// No description provided for @deleteStudentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف الطالب وجميع بياناته ونتائجه نهائياً.'**
  String get deleteStudentConfirm;

  /// No description provided for @deletePermanently.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائياً'**
  String get deletePermanently;

  /// No description provided for @personalData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get personalData;

  /// No description provided for @studentFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الثلاثي *'**
  String get studentFullName;

  /// No description provided for @studentNameHintExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أحمد محمد محمود'**
  String get studentNameHintExample;

  /// No description provided for @studentNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب إدخال الاسم'**
  String get studentNameRequired;

  /// No description provided for @studentPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف الطالب'**
  String get studentPhone;

  /// No description provided for @parentPhone1.
  ///
  /// In ar, this message translates to:
  /// **'رقم ولي الأمر 1 *'**
  String get parentPhone1;

  /// No description provided for @parentPhoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب للتواصل'**
  String get parentPhoneRequired;

  /// No description provided for @parentPhone2.
  ///
  /// In ar, this message translates to:
  /// **'رقم ولي الأمر 2'**
  String get parentPhone2;

  /// No description provided for @emergencyPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم إضافي للطوارئ'**
  String get emergencyPhoneHint;

  /// No description provided for @landline.
  ///
  /// In ar, this message translates to:
  /// **'تليفون أرضي'**
  String get landline;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In ar, this message translates to:
  /// **'منطقة السكن / الشارع'**
  String get addressHint;

  /// No description provided for @academicData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الدراسية'**
  String get academicData;

  /// No description provided for @targetGroup.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة المستهدفة *'**
  String get targetGroup;

  /// No description provided for @selectGroupHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة...'**
  String get selectGroupHint;

  /// No description provided for @groupRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب اختيار مجموعة'**
  String get groupRequired;

  /// No description provided for @errorLoadingGroups.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل المجموعات'**
  String get errorLoadingGroups;

  /// No description provided for @noGroupsForYear.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات نشطة لهذه السنة الدراسية'**
  String get noGroupsForYear;

  /// No description provided for @discountsAndExemptions.
  ///
  /// In ar, this message translates to:
  /// **'الخصومات والإعفاءات'**
  String get discountsAndExemptions;

  /// No description provided for @freeStudentToggle.
  ///
  /// In ar, this message translates to:
  /// **'طالب مجاني / حالة خاصة'**
  String get freeStudentToggle;

  /// No description provided for @fullExemption.
  ///
  /// In ar, this message translates to:
  /// **'إعفاء كامل من المصروفات'**
  String get fullExemption;

  /// No description provided for @hasIndividualDiscount.
  ///
  /// In ar, this message translates to:
  /// **'هل لدى الطالب خصم فردي؟'**
  String get hasIndividualDiscount;

  /// No description provided for @plusGroupDiscount.
  ///
  /// In ar, this message translates to:
  /// **'بالإضافة لخصم المجموعة إن وجد'**
  String get plusGroupDiscount;

  /// No description provided for @discountValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الخصم بالجنيه. مثال: 50'**
  String get discountValue;

  /// No description provided for @studentNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات عن الطالب'**
  String get studentNotes;

  /// No description provided for @studentNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات للمنصة السكرتارية أو المدرس فقط...'**
  String get studentNotesHint;

  /// No description provided for @studentNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الطالب غير موجود'**
  String get studentNotFound;

  /// No description provided for @noPhoneFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف'**
  String get noPhoneFound;

  /// No description provided for @portalCodeGenerated.
  ///
  /// In ar, this message translates to:
  /// **'تم توليد كود البوابة بنجاح'**
  String get portalCodeGenerated;

  /// No description provided for @groupNotSet.
  ///
  /// In ar, this message translates to:
  /// **'بدون مجموعة'**
  String get groupNotSet;

  /// No description provided for @outstanding.
  ///
  /// In ar, this message translates to:
  /// **'متأخرات'**
  String get outstanding;

  /// No description provided for @creditBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد دائن'**
  String get creditBalance;

  /// No description provided for @totalPaid.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المدفوع'**
  String get totalPaid;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @requiredAmount.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب'**
  String get requiredAmount;

  /// No description provided for @paidAmount.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get paidAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remainingAmount;

  /// No description provided for @portalCode.
  ///
  /// In ar, this message translates to:
  /// **'كود بوابة الطالب'**
  String get portalCode;

  /// No description provided for @inactivePortalCode.
  ///
  /// In ar, this message translates to:
  /// **'غير مفعل'**
  String get inactivePortalCode;

  /// No description provided for @activateCode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الكود'**
  String get activateCode;

  /// No description provided for @codeCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الكود إلى الحافظة'**
  String get codeCopied;

  /// No description provided for @performance.
  ///
  /// In ar, this message translates to:
  /// **'الأداء'**
  String get performance;

  /// No description provided for @attendanceTab.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get attendanceTab;

  /// No description provided for @paymentsTab.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات'**
  String get paymentsTab;

  /// No description provided for @gradesTab.
  ///
  /// In ar, this message translates to:
  /// **'الدرجات'**
  String get gradesTab;

  /// No description provided for @quizzesTab.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get quizzesTab;

  /// No description provided for @reportsTab.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reportsTab;

  /// No description provided for @overallPerformanceSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الأداء العام'**
  String get overallPerformanceSummary;

  /// No description provided for @attendanceRateLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الحضور'**
  String get attendanceRateLabel;

  /// No description provided for @excellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get excellent;

  /// No description provided for @needsImprovement.
  ///
  /// In ar, this message translates to:
  /// **'مستواك يحتاج لعناية واهتمام أكبر. لا تستسلم! 💪'**
  String get needsImprovement;

  /// No description provided for @low.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get low;

  /// No description provided for @acceptable.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get acceptable;

  /// No description provided for @needsFollowUp.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج متابعة'**
  String get needsFollowUp;

  /// No description provided for @higherThanGroup.
  ///
  /// In ar, this message translates to:
  /// **'أعلى من المجموعة بـ'**
  String get higherThanGroup;

  /// No description provided for @lowerThanGroup.
  ///
  /// In ar, this message translates to:
  /// **'أقل من المجموعة بـ'**
  String get lowerThanGroup;

  /// No description provided for @overallComparison.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة شاملة بالمجموعة'**
  String get overallComparison;

  /// No description provided for @noAttendanceRecords.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجلات حضور'**
  String get noAttendanceRecords;

  /// No description provided for @noPaymentRecords.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجلات دفع'**
  String get noPaymentRecords;

  /// No description provided for @noGradesFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد درجات مسجلة بعد'**
  String get noGradesFound;

  /// No description provided for @noQuizzesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على اختبارات'**
  String get noQuizzesFound;

  /// No description provided for @notEnoughQuizzesForChart.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اختبارات كافية لرسم المنحنى'**
  String get notEnoughQuizzesForChart;

  /// No description provided for @studentProgressChart.
  ///
  /// In ar, this message translates to:
  /// **'تطور مستوى الطالب (الاختبارات)'**
  String get studentProgressChart;

  /// No description provided for @deleteFromGroupConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف الطالب من هذه المجموعة. هل أنت متأكد؟'**
  String get deleteFromGroupConfirm;

  /// No description provided for @newStudentLabel.
  ///
  /// In ar, this message translates to:
  /// **'طالب جديد'**
  String get newStudentLabel;

  /// No description provided for @registerStudent.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الطالب'**
  String get registerStudent;

  /// No description provided for @selectGroup.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار المجموعة'**
  String get selectGroup;

  /// No description provided for @studentRegisteredSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الطالب بنجاح'**
  String get studentRegisteredSuccess;

  /// No description provided for @academicYearLabel.
  ///
  /// In ar, this message translates to:
  /// **'السنة الدراسية'**
  String get academicYearLabel;

  /// No description provided for @extra.
  ///
  /// In ar, this message translates to:
  /// **'إضافي'**
  String get extra;

  /// No description provided for @genderLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الطالب'**
  String get genderLabel;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get payment;

  /// No description provided for @complete.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get complete;

  /// No description provided for @averageGrade.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الدرجات'**
  String get averageGrade;

  /// No description provided for @monthlyPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الشهري'**
  String get monthlyPrice;

  /// No description provided for @higherThanGroupWithVal.
  ///
  /// In ar, this message translates to:
  /// **'أعلى من المجموعة بـ {value}%'**
  String higherThanGroupWithVal(String value);

  /// No description provided for @lowerThanGroupWithVal.
  ///
  /// In ar, this message translates to:
  /// **'أقل من المجموعة بـ {value}%'**
  String lowerThanGroupWithVal(String value);

  /// No description provided for @incomplete.
  ///
  /// In ar, this message translates to:
  /// **'غير مكتمل'**
  String get incomplete;

  /// No description provided for @comparisonToGroup.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بالمجموعة'**
  String get comparisonToGroup;

  /// No description provided for @student.
  ///
  /// In ar, this message translates to:
  /// **'الطالب'**
  String get student;

  /// No description provided for @group.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get group;

  /// No description provided for @groupDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المجموعة'**
  String get groupDetailsTitle;

  /// No description provided for @editGroupTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المجموعة'**
  String get editGroupTooltip;

  /// No description provided for @statMonthlyRequired.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب الشهري'**
  String get statMonthlyRequired;

  /// No description provided for @statOutstandingAmt.
  ///
  /// In ar, this message translates to:
  /// **'المتأخرات'**
  String get statOutstandingAmt;

  /// No description provided for @studentsWithCount.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب ({count})'**
  String studentsWithCount(int count);

  /// No description provided for @searchStudentsHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن طالب...'**
  String get searchStudentsHint;

  /// No description provided for @noStudentsInGroup.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب في هذه المجموعة'**
  String get noStudentsInGroup;

  /// No description provided for @noResultsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResultsFound;

  /// No description provided for @discountAmount.
  ///
  /// In ar, this message translates to:
  /// **'خصم {amount}'**
  String discountAmount(String amount);

  /// No description provided for @pricePerMonthLabel.
  ///
  /// In ar, this message translates to:
  /// **'{price} ج/شهر'**
  String pricePerMonthLabel(String price);

  /// No description provided for @overdueAmtWithLabel.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ج متأخر'**
  String overdueAmtWithLabel(String amount);

  /// No description provided for @creditAmtWithLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد {amount} ج'**
  String creditAmtWithLabel(String amount);

  /// No description provided for @completeLabel.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completeLabel;

  /// No description provided for @studentFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف'**
  String get studentFile;

  /// No description provided for @deleteAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteAction;

  /// No description provided for @teacherFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get teacherFullName;

  /// No description provided for @teacherSubject.
  ///
  /// In ar, this message translates to:
  /// **'المادة / التخصص'**
  String get teacherSubject;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profileUpdateSuccess;

  /// No description provided for @invalidName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم صحيح'**
  String get invalidName;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح'**
  String get invalidPhone;

  /// No description provided for @invalidSubject.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال المادة الدراسية'**
  String get invalidSubject;

  /// No description provided for @selectImageSource.
  ///
  /// In ar, this message translates to:
  /// **'اختر مصدر الصورة'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// No description provided for @quizzes.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get quizzes;

  /// No description provided for @honorBoard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الشرف'**
  String get honorBoard;

  /// No description provided for @expenses.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف'**
  String get expenses;

  /// No description provided for @financials.
  ///
  /// In ar, this message translates to:
  /// **'الشؤون المالية'**
  String get financials;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @userNotConnected.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم غير متصل'**
  String get userNotConnected;

  /// No description provided for @updateError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في التحديث: {error}'**
  String updateError(String error);

  /// No description provided for @attendanceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة حضور الطلاب والحصص'**
  String get attendanceSubtitle;

  /// No description provided for @financialsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المدفوعات والتحصيل والإحصائيات'**
  String get financialsSubtitle;

  /// No description provided for @expensesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المصروفات اليومية والتكاليف'**
  String get expensesSubtitle;

  /// No description provided for @quizzesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الامتحانات والنتائج والإحصائيات'**
  String get quizzesSubtitle;

  /// No description provided for @honorBoardSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض وإدارة حصالة الطلاب المتفوقين'**
  String get honorBoardSubtitle;

  /// No description provided for @academicManagement.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة الأكاديمية'**
  String get academicManagement;

  /// No description provided for @financialManagement.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة المالية'**
  String get financialManagement;

  /// No description provided for @studentExcellence.
  ///
  /// In ar, this message translates to:
  /// **'تميز الطلاب'**
  String get studentExcellence;

  /// No description provided for @freeStudent.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get freeStudent;

  /// No description provided for @addStudentLabel.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب'**
  String get addStudentLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الثلاثي *'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أحمد محمد محمود'**
  String get fullNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب إدخال الاسم'**
  String get nameRequired;

  /// No description provided for @phoneFormatHint.
  ///
  /// In ar, this message translates to:
  /// **'01xxxxxxxxxx'**
  String get phoneFormatHint;

  /// No description provided for @invalidPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر غير صالح'**
  String get invalidPrice;

  /// No description provided for @discountGreaterPrice.
  ///
  /// In ar, this message translates to:
  /// **'الخصم لا يمكن أن يكون أكبر من السعر'**
  String get discountGreaterPrice;

  /// No description provided for @paymentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات'**
  String get paymentsTitle;

  /// No description provided for @recordNewPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة جديدة'**
  String get recordNewPayment;

  /// No description provided for @recordPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدفعة'**
  String get recordPayment;

  /// No description provided for @pleaseSelectStudent.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار الطالب'**
  String get pleaseSelectStudent;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يجب أن يكون أكبر من صفر'**
  String get amountGreaterThanZero;

  /// No description provided for @pleaseSelectMonth.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد الشهر'**
  String get pleaseSelectMonth;

  /// No description provided for @freeStudentTitle.
  ///
  /// In ar, this message translates to:
  /// **'طالب مجاني'**
  String get freeStudentTitle;

  /// No description provided for @freeStudentConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا الطالب مجاني، هل تريد تسجيل دفعة استثنائية؟'**
  String get freeStudentConfirmMessage;

  /// No description provided for @paymentRecordedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة بنجاح ✓'**
  String get paymentRecordedSuccessfully;

  /// No description provided for @groupOptionalFilter.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة (اختياري للفلترة)'**
  String get groupOptionalFilter;

  /// No description provided for @selectGroupFilter.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة للفلترة...'**
  String get selectGroupFilter;

  /// No description provided for @allStudents.
  ///
  /// In ar, this message translates to:
  /// **'كل الطلاب'**
  String get allStudents;

  /// No description provided for @studentRequired.
  ///
  /// In ar, this message translates to:
  /// **'الطالب *'**
  String get studentRequired;

  /// No description provided for @selectStudent.
  ///
  /// In ar, this message translates to:
  /// **'اختر طالب...'**
  String get selectStudent;

  /// No description provided for @freeLabelSuffix.
  ///
  /// In ar, this message translates to:
  /// **' (مجاني)'**
  String get freeLabelSuffix;

  /// No description provided for @freeStudentSuffix.
  ///
  /// In ar, this message translates to:
  /// **'طالب مجاني'**
  String get freeStudentSuffix;

  /// No description provided for @requiredAmountSuffix.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب: {amount} {currency}/شهر'**
  String requiredAmountSuffix(Object amount, Object currency);

  /// No description provided for @amountCurrencyRequired.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ ({currency}) *'**
  String amountCurrencyRequired(Object currency);

  /// No description provided for @partialPaymentLabel.
  ///
  /// In ar, this message translates to:
  /// **'⚠️ دفع جزئي (متبقي {amount} {currency})'**
  String partialPaymentLabel(Object amount, Object currency);

  /// No description provided for @excessPaymentLabel.
  ///
  /// In ar, this message translates to:
  /// **'✅ رصيد دائن {amount} {currency}'**
  String excessPaymentLabel(Object amount, Object currency);

  /// No description provided for @paymentCompletedLabel.
  ///
  /// In ar, this message translates to:
  /// **'✅ مكتمل'**
  String get paymentCompletedLabel;

  /// No description provided for @monthRequired.
  ///
  /// In ar, this message translates to:
  /// **'الشهر *'**
  String get monthRequired;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @paymentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الدفع'**
  String get paymentDate;

  /// No description provided for @autoReceiptNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإيصال التلقائي: #{number}'**
  String autoReceiptNumber(Object number);

  /// No description provided for @deletePaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الدفعة'**
  String get deletePaymentTitle;

  /// No description provided for @deletePaymentConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه الدفعة نهائياً؟'**
  String get deletePaymentConfirmMessage;

  /// No description provided for @paymentDeletedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الدفعة'**
  String get paymentDeletedMessage;

  /// No description provided for @outstandingPaymentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المتأخرات'**
  String get outstandingPaymentsTitle;

  /// No description provided for @searchPaymentHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث باسم الطالب أو رقم الإيصال...'**
  String get searchPaymentHint;

  /// No description provided for @allGroups.
  ///
  /// In ar, this message translates to:
  /// **'جميع المجموعات'**
  String get allGroups;

  /// No description provided for @noPaymentsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مدفوعات'**
  String get noPaymentsFound;

  /// No description provided for @totalPaymentsSummary.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: {amount} {currency} ({count} سجل)'**
  String totalPaymentsSummary(Object amount, Object count, Object currency);

  /// No description provided for @receiptNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإيصال: #{number}'**
  String receiptNumberLabel(Object number);

  /// No description provided for @addPaymentTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دفعة'**
  String get addPaymentTooltip;

  /// No description provided for @noPhoneNumberRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف مسجل'**
  String get noPhoneNumberRegistered;

  /// No description provided for @outstandingStudentsCount.
  ///
  /// In ar, this message translates to:
  /// **'طلاب متأخرين'**
  String get outstandingStudentsCount;

  /// No description provided for @totalOutstandingAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المتأخرات'**
  String get totalOutstandingAmount;

  /// No description provided for @filterByGroup.
  ///
  /// In ar, this message translates to:
  /// **'فلترة حسب المجموعة'**
  String get filterByGroup;

  /// No description provided for @noOutstandingPaymentsSuccess.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد متأخرات لهذا الشهر!'**
  String get noOutstandingPaymentsSuccess;

  /// No description provided for @allStudentsPaidMessage.
  ///
  /// In ar, this message translates to:
  /// **'جميع الطلاب سددوا مستحقاتهم بالكامل'**
  String get allStudentsPaidMessage;

  /// No description provided for @paidAmountSuffix.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع: {amount}'**
  String paidAmountSuffix(Object amount);

  /// No description provided for @remind.
  ///
  /// In ar, this message translates to:
  /// **'تذكير'**
  String get remind;

  /// No description provided for @receive.
  ///
  /// In ar, this message translates to:
  /// **'استلام'**
  String get receive;

  /// No description provided for @manageExpensesTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المصروفات'**
  String get manageExpensesTitle;

  /// No description provided for @expenseRecordedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المصروف بنجاح ✓'**
  String get expenseRecordedSuccessfully;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المصروف'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا المصروف؟'**
  String get deleteExpenseConfirmMessage;

  /// No description provided for @totalExpensesAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات'**
  String get totalExpensesAmount;

  /// No description provided for @transactionsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحركات'**
  String get transactionsCount;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'كل التصنيفات'**
  String get allCategories;

  /// No description provided for @noExpensesRecorded.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصروفات مسجلة'**
  String get noExpensesRecorded;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get addExpense;

  /// No description provided for @recordNewExpense.
  ///
  /// In ar, this message translates to:
  /// **'سجل مصروف جديد'**
  String get recordNewExpense;

  /// No description provided for @titleRequired.
  ///
  /// In ar, this message translates to:
  /// **'العنوان *'**
  String get titleRequired;

  /// No description provided for @forMonth.
  ///
  /// In ar, this message translates to:
  /// **'عن شهر'**
  String get forMonth;

  /// No description provided for @recurringMonthlyExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف متكرر شهرياً'**
  String get recurringMonthlyExpense;

  /// No description provided for @saveExpenseButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المصروف'**
  String get saveExpenseButton;

  /// No description provided for @method_cash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get method_cash;

  /// No description provided for @method_bankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get method_bankTransfer;

  /// No description provided for @method_vodafoneCash.
  ///
  /// In ar, this message translates to:
  /// **'فودافون كاش'**
  String get method_vodafoneCash;

  /// No description provided for @category_rent.
  ///
  /// In ar, this message translates to:
  /// **'إيجار'**
  String get category_rent;

  /// No description provided for @category_salaries.
  ///
  /// In ar, this message translates to:
  /// **'رواتب'**
  String get category_salaries;

  /// No description provided for @category_supplies.
  ///
  /// In ar, this message translates to:
  /// **'مستلزمات'**
  String get category_supplies;

  /// No description provided for @category_utilities.
  ///
  /// In ar, this message translates to:
  /// **'مرافق'**
  String get category_utilities;

  /// No description provided for @category_maintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة'**
  String get category_maintenance;

  /// No description provided for @category_marketing.
  ///
  /// In ar, this message translates to:
  /// **'تسويق'**
  String get category_marketing;

  /// No description provided for @currency_egp.
  ///
  /// In ar, this message translates to:
  /// **'ج'**
  String get currency_egp;

  /// No description provided for @monthLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get monthLabel;

  /// No description provided for @outstandingPaymentWhatsappTemplate.
  ///
  /// In ar, this message translates to:
  /// **'عزيزي ولي أمر {name}،\nيرجى سداد المتأخرات بمبلغ {balance} {currency} عن شهر {month}.\nشكراً لتعاونكم.'**
  String outstandingPaymentWhatsappTemplate(
    Object balance,
    Object currency,
    Object month,
    Object name,
  );

  /// No description provided for @outstandingEntrySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'{group} · المطلوب: {required} · مدفوع: {paid}'**
  String outstandingEntrySubtitle(Object group, Object paid, Object required);

  /// No description provided for @saveExpense.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المصروف'**
  String get saveExpense;

  /// No description provided for @questionsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سؤال'**
  String questionsCount(num count);

  /// No description provided for @resultsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نتيجة'**
  String resultsCount(num count);

  /// No description provided for @publish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get publish;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @quizzesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get quizzesTitle;

  /// No description provided for @newQuiz.
  ///
  /// In ar, this message translates to:
  /// **'اختبار جديد'**
  String get newQuiz;

  /// No description provided for @averageResults.
  ///
  /// In ar, this message translates to:
  /// **'متوسط النتائج'**
  String get averageResults;

  /// No description provided for @totalQuizzes.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الاختبارات'**
  String get totalQuizzes;

  /// No description provided for @createFirstQuizMessage.
  ///
  /// In ar, this message translates to:
  /// **'قم بإنشاء أول اختبار لك لبدء تتبع تقدم الطلاب.'**
  String get createFirstQuizMessage;

  /// No description provided for @activeStatus.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeStatus;

  /// No description provided for @draftStatus.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get draftStatus;

  /// No description provided for @closedStatus.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get closedStatus;

  /// No description provided for @deleteQuizTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الاختبار'**
  String get deleteQuizTitle;

  /// No description provided for @deleteQuizConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الاختبار؟ سيتم فقدان جميع النتائج المتعلقة به.'**
  String get deleteQuizConfirm;

  /// No description provided for @honorBoardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الشرف'**
  String get honorBoardTitle;

  /// No description provided for @createQuiz.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء اختبار'**
  String get createQuiz;

  /// No description provided for @quizTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الاختبار *'**
  String get quizTitle;

  /// No description provided for @targetGroupLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة المستهدفة *'**
  String get targetGroupLabel;

  /// No description provided for @examDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاختبار'**
  String get examDateLabel;

  /// No description provided for @durationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة (دقيقة)'**
  String get durationLabel;

  /// No description provided for @questionsCountHeader.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة ({count})'**
  String questionsCountHeader(int count);

  /// No description provided for @mcqQuestion.
  ///
  /// In ar, this message translates to:
  /// **'سؤال اختيار متعدد'**
  String get mcqQuestion;

  /// No description provided for @trueFalseQuestion.
  ///
  /// In ar, this message translates to:
  /// **'سؤال صح/خطأ'**
  String get trueFalseQuestion;

  /// No description provided for @marksLabel.
  ///
  /// In ar, this message translates to:
  /// **'درجة'**
  String get marksLabel;

  /// No description provided for @questionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب نص السؤال هنا...'**
  String get questionHint;

  /// No description provided for @optionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الخيارات (حدد الإجابة الصحيحة ✓)'**
  String get optionsLabel;

  /// No description provided for @optionHint.
  ///
  /// In ar, this message translates to:
  /// **'الخيار {number}'**
  String optionHint(int number);

  /// No description provided for @tooltipMcq.
  ///
  /// In ar, this message translates to:
  /// **'سؤال اختياري'**
  String get tooltipMcq;

  /// No description provided for @tooltipTrueFalse.
  ///
  /// In ar, this message translates to:
  /// **'صح أو خطأ'**
  String get tooltipTrueFalse;

  /// No description provided for @completeBasicInfo.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إكمال البيانات الأساسية'**
  String get completeBasicInfo;

  /// No description provided for @completeAllQuestions.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إكمال جميع الأسئلة والإجابات الصحيحة'**
  String get completeAllQuestions;

  /// No description provided for @quizSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الاختبار بنجاح ✓'**
  String get quizSavedSuccess;

  /// No description provided for @saveError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ أثناء الحفظ: {error}'**
  String saveError(String error);

  /// No description provided for @quizResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج الاختبار'**
  String get quizResults;

  /// No description provided for @noResultsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نتائج لهذا الاختبار بعد'**
  String get noResultsYet;

  /// No description provided for @resultsWillShowHere.
  ///
  /// In ar, this message translates to:
  /// **'سيتم عرض النتائج هنا فور تسليم الطلاب للحلول'**
  String get resultsWillShowHere;

  /// No description provided for @searchByStudent.
  ///
  /// In ar, this message translates to:
  /// **'بحث باسم الطالب...'**
  String get searchByStudent;

  /// No description provided for @submittedInfo.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get submittedInfo;

  /// No description provided for @avgScore.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الدرجات'**
  String get avgScore;

  /// No description provided for @highestScore.
  ///
  /// In ar, this message translates to:
  /// **'أعلى درجة'**
  String get highestScore;

  /// No description provided for @submissionDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم: {date}'**
  String submissionDate(String date);

  /// No description provided for @shareWithParent.
  ///
  /// In ar, this message translates to:
  /// **'إرسال لولي الأمر'**
  String get shareWithParent;

  /// No description provided for @noPhoneRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف مسجل'**
  String get noPhoneRegistered;

  /// No description provided for @whatsappQuizResultMessage.
  ///
  /// In ar, this message translates to:
  /// **'نشيد بعلمكم بنتيجة الطالب {studentName} في اختبار \"{quizTitle}\":\nالدرجة: {score} من {totalMarks}\nالنسبة: {percentage}%\nشكراً لمتابعتكم.'**
  String whatsappQuizResultMessage(
    String studentName,
    String quizTitle,
    String score,
    int totalMarks,
    String percentage,
  );

  /// No description provided for @groupLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get groupLabel;

  /// No description provided for @noSufficientData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية'**
  String get noSufficientData;

  /// No description provided for @pointsLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get pointsLabel;

  /// No description provided for @loadingData.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loadingData;

  /// No description provided for @errorLoadingData.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل البيانات: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @myAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضوري'**
  String get myAttendance;

  /// No description provided for @attendanceHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل حضوري'**
  String get attendanceHistory;

  /// No description provided for @noAttendanceFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل حضور حتى الآن'**
  String get noAttendanceFound;

  /// No description provided for @attendanceWillShowHere.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر سجل حضورك هنا بمجرد تسجيل المعلم له.'**
  String get attendanceWillShowHere;

  /// No description provided for @myGrades.
  ///
  /// In ar, this message translates to:
  /// **'درجاتي'**
  String get myGrades;

  /// No description provided for @myGradesAndResults.
  ///
  /// In ar, this message translates to:
  /// **'درجاتي ونتائجي'**
  String get myGradesAndResults;

  /// No description provided for @scoreOutOf.
  ///
  /// In ar, this message translates to:
  /// **'الدرجة: {score} من {max}'**
  String scoreOutOf(String score, int max);

  /// No description provided for @gradesWillShowHere.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر نتائج اختباراتك هنا فور رصدها.'**
  String get gradesWillShowHere;

  /// No description provided for @lastScore.
  ///
  /// In ar, this message translates to:
  /// **'آخر درجة'**
  String get lastScore;

  /// No description provided for @overallPerformance.
  ///
  /// In ar, this message translates to:
  /// **'الأداء الأكاديمي العام'**
  String get overallPerformance;

  /// No description provided for @exceptionalPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء استثنائي! أنت من المتفوقين. 🌟'**
  String get exceptionalPerformance;

  /// No description provided for @veryGoodPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء جيد جداً، استمر في التقدم. 👍'**
  String get veryGoodPerformance;

  /// No description provided for @goodPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء مقبول، تحتاج لمزيد من الجهد. 📚'**
  String get goodPerformance;

  /// No description provided for @notebooksStore.
  ///
  /// In ar, this message translates to:
  /// **'متجر المذكرات'**
  String get notebooksStore;

  /// No description provided for @store.
  ///
  /// In ar, this message translates to:
  /// **'المتجر'**
  String get store;

  /// No description provided for @whatsappOpenError.
  ///
  /// In ar, this message translates to:
  /// **'فشل فتح الواتساب. يرجى التأكد من تثبيت التطبيق.'**
  String get whatsappOpenError;

  /// No description provided for @storeIsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'المتجر فارغ حالياً'**
  String get storeIsEmpty;

  /// No description provided for @noItemsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مذكرات أو كتب متاحة للطلب في الوقت الحالي. يرجى مراجعة المعلم.'**
  String get noItemsAvailable;

  /// No description provided for @teacherPhoneUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، رقم هاتف المعلم غير متوفر حالياً لإتمام الطلب.'**
  String get teacherPhoneUnavailable;

  /// No description provided for @whatsappStoreOrderMessage.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، أود طلب: {itemTitle}\nالتصنيف: {itemCategory}\nالسعر: {itemPrice} ج.م\nالاسم: {studentName}'**
  String whatsappStoreOrderMessage(
    String itemTitle,
    String itemCategory,
    double itemPrice,
    String studentName,
  );

  /// No description provided for @currencyEgp.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currencyEgp;

  /// No description provided for @orderNow.
  ///
  /// In ar, this message translates to:
  /// **'اطلب الآن'**
  String get orderNow;

  /// No description provided for @currentGroup.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة الحالية'**
  String get currentGroup;

  /// No description provided for @keepGoing.
  ///
  /// In ar, this message translates to:
  /// **'استمر في الاجتهاد يا {name}! 🚀'**
  String keepGoing(String name);

  /// No description provided for @announcementsAndAlerts.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات والتنبيهات'**
  String get announcementsAndAlerts;

  /// No description provided for @privateMessage.
  ///
  /// In ar, this message translates to:
  /// **'رسالة خاصة'**
  String get privateMessage;

  /// No description provided for @noNewNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات جديدة حالياً. يومك سعيد!'**
  String get noNewNotifications;

  /// No description provided for @errorLoadingAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل التنبيهات: {error}'**
  String errorLoadingAnnouncements(String error);

  /// No description provided for @dayLabel.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get dayLabel;

  /// No description provided for @latestAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الإعلانات'**
  String get latestAnnouncements;

  /// No description provided for @noAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات حالياً.'**
  String get noAnnouncements;

  /// No description provided for @performanceFeedback.
  ///
  /// In ar, this message translates to:
  /// **'{status}'**
  String performanceFeedback(String status);

  /// No description provided for @performanceExceptional.
  ///
  /// In ar, this message translates to:
  /// **'أداء استثنائي! أنت من المتفوقين. 🌟'**
  String get performanceExceptional;

  /// No description provided for @performanceDoingGreat.
  ///
  /// In ar, this message translates to:
  /// **'أداء جيد جداً، استمر في التقدم. 👍'**
  String get performanceDoingGreat;

  /// No description provided for @performanceAcceptable.
  ///
  /// In ar, this message translates to:
  /// **'أداء مقبول، تحتاج لمزيد من الجهد. 📚'**
  String get performanceAcceptable;

  /// No description provided for @performanceNeedsAttention.
  ///
  /// In ar, this message translates to:
  /// **'مستواك يحتاج لعناية واهتمام أكبر. لا تستسلم! 💪'**
  String get performanceNeedsAttention;

  /// No description provided for @method_other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get method_other;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المصروف؟'**
  String get deleteExpenseConfirm;

  /// No description provided for @totalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصاريف'**
  String get totalExpenses;

  /// No description provided for @titleLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get titleLabel;

  /// No description provided for @amountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amountLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get categoryLabel;

  /// No description provided for @notesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesLabel;

  /// No description provided for @recurringExpenseLabel.
  ///
  /// In ar, this message translates to:
  /// **'مصروف متكرر'**
  String get recurringExpenseLabel;

  /// No description provided for @freeBadge.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get freeBadge;

  /// No description provided for @paymentStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم دفع المبلغ بالكامل'**
  String get paymentStatusCompleted;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @confirmLogout.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسجيل الخروج'**
  String get confirmLogout;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج من بوابة الطالب؟'**
  String get logoutConfirmationMessage;

  /// No description provided for @expenseRecordedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المصروف بنجاح'**
  String get expenseRecordedSuccess;

  /// No description provided for @category_other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get category_other;

  /// No description provided for @suggestionAttendanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه غياب'**
  String get suggestionAttendanceTitle;

  /// No description provided for @suggestionAttendanceMessage.
  ///
  /// In ar, this message translates to:
  /// **'هناك {count} غيابات اليوم. هل تريد إرسال تنبيهات واتساب؟'**
  String suggestionAttendanceMessage(int count);

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك!'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count} طالب نشط في مجموعاتك حالياً.'**
  String welcomeMessage(int count);

  /// No description provided for @sendInstantMessages.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رسائل فورية'**
  String get sendInstantMessages;

  /// No description provided for @qrScanner.
  ///
  /// In ar, this message translates to:
  /// **'ماسح QR'**
  String get qrScanner;

  /// No description provided for @attendanceMode.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل حضور'**
  String get attendanceMode;

  /// No description provided for @paymentMode.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get paymentMode;

  /// No description provided for @scanStudentQrHint.
  ///
  /// In ar, this message translates to:
  /// **'قم بمسح كود الطالب لتسجيل حضوره أو دفعته'**
  String get scanStudentQrHint;

  /// No description provided for @scanHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المسح'**
  String get scanHistory;

  /// No description provided for @exams.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get exams;

  /// No description provided for @pendingExams.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pendingExams;

  /// No description provided for @completedExams.
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get completedExams;

  /// No description provided for @smartTools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات ذكية'**
  String get smartTools;

  /// No description provided for @studentQrCode.
  ///
  /// In ar, this message translates to:
  /// **'كود QR'**
  String get studentQrCode;

  /// No description provided for @submitExam.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الاختبار'**
  String get submitExam;

  /// No description provided for @examResult.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الاختبار'**
  String get examResult;

  /// No description provided for @timeLeft.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي'**
  String get timeLeft;

  /// No description provided for @manualGradingNote.
  ///
  /// In ar, this message translates to:
  /// **'{count} سؤال يحتاج تصحيح يدوي من المعلم'**
  String manualGradingNote(int count);

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @submitting.
  ///
  /// In ar, this message translates to:
  /// **'جاري التسليم...'**
  String get submitting;

  /// No description provided for @exitExam.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة الاختبار؟'**
  String get exitExam;

  /// No description provided for @exitExamWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم فقدان جميع إجاباتك إذا غادرت الآن. هل أنت متأكد؟'**
  String get exitExamWarning;

  /// No description provided for @backToExams.
  ///
  /// In ar, this message translates to:
  /// **'العودة للاختبارات'**
  String get backToExams;

  /// No description provided for @startQuiz.
  ///
  /// In ar, this message translates to:
  /// **'بدء الاختبار'**
  String get startQuiz;

  /// No description provided for @notLoggedIn.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل الدخول'**
  String get notLoggedIn;

  /// No description provided for @showQrHint.
  ///
  /// In ar, this message translates to:
  /// **'أظهر هذا الكود للمعلم لتسجيل الحضور أو الدفع'**
  String get showQrHint;

  /// No description provided for @screenshotHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك أخذ لقطة شاشة للاحتفاظ بالكود'**
  String get screenshotHint;

  /// No description provided for @noScansYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجلات مسح بعد'**
  String get noScansYet;

  /// No description provided for @noScansYetHint.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر سجلات المسح هنا بعد استخدام ماسح QR.'**
  String get noScansYetHint;

  /// No description provided for @quickActionAttendance.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل حضور'**
  String get quickActionAttendance;

  /// No description provided for @quickActionPayment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دفعة'**
  String get quickActionPayment;

  /// No description provided for @quickActionAddStudent.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب'**
  String get quickActionAddStudent;

  /// No description provided for @quickActionPortalCode.
  ///
  /// In ar, this message translates to:
  /// **'كود البوابة'**
  String get quickActionPortalCode;

  /// No description provided for @customizeQuickActions.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص الإجراءات السريعة'**
  String get customizeQuickActions;

  /// No description provided for @quickActionsHint.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الإجراءات التي تريدها واسحب لإعادة الترتيب'**
  String get quickActionsHint;

  /// No description provided for @selectStudentForPortalCode.
  ///
  /// In ar, this message translates to:
  /// **'اختر طالباً لتوليد كود البوابة'**
  String get selectStudentForPortalCode;

  /// No description provided for @searchStudents.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن طالب...'**
  String get searchStudents;

  /// No description provided for @copiedToClipboard.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ إلى الحافظة'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
