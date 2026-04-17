// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مساعد المعلم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navGroups => 'المجموعات';

  @override
  String get navStudents => 'الطلاب';

  @override
  String get navMore => 'المزيد';

  @override
  String get settings => 'الإعدادات';

  @override
  String get themeAppearance => 'المظهر والشكل';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get searchHint => 'بحث...';

  @override
  String get noGroupsFound => 'لا توجد مجموعات';

  @override
  String get addGroup => 'إضافة مجموعة';

  @override
  String get all => 'الكل';

  @override
  String get center => 'سنتر';

  @override
  String get privateGroup => 'مجموعة خاصة';

  @override
  String get privateLesson => 'درس خاص';

  @override
  String get online => 'أونلاين';

  @override
  String groupsCount(int count) {
    return '$count مجموعة';
  }

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ ما';
  }

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get security => 'الأمان';

  @override
  String get appLock => 'قفل التطبيق (PIN)';

  @override
  String get appLockSubtitle => 'طلب رمز الدخول عند فتح التطبيق';

  @override
  String get backupData => 'البيانات والنسخ الاحتياطي';

  @override
  String get backupSubtitle => 'إدارة النسخ الاحتياطي اليدوي';

  @override
  String get exportImport => 'تصدير/استيراد البيانات';

  @override
  String get comingSoon => 'سيتم تفعيل هذه الميزة قريباً';

  @override
  String get setPin => 'إعداد رمز PIN';

  @override
  String get enterFourDigits => 'أدخل رمز مكون من 4 أرقام';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String get notes => 'الملاحظات';

  @override
  String get viewTasks => 'عرض المهام';

  @override
  String get moreMenu => 'القائمة الإضافية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profileSubtitle => 'إدارة بياناتك وصورتك الشخصية';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get notificationsSubtitle => 'إعدادات الإشعارات والتحميل';

  @override
  String get groupsAndLevel => 'المراحل والمجموعات';

  @override
  String get groupsAndLevelSubtitle => 'إدارة التصنيفات الدراسية';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get appSettingsSubtitle => 'اللغة، الثيم، والأمان';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get helpSupportSubtitle => 'الأسئلة الشائعة وتواصل معنا';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get teacherPortal => 'بوابة المعلم';

  @override
  String get studentPortal => 'بوابة الطالب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get noAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get orViaGoogle => 'أو عبر جوجل';

  @override
  String get googleLogin => 'الدخول بواسطة جوجل';

  @override
  String get teacherLogin => 'دخول المعلم';

  @override
  String get studentLogin => 'دخول الطالب';

  @override
  String get studentWelcome =>
      'أهلاً بك يا بطل! ادخل كود البوابة الخاص بك للمتابعة';

  @override
  String get studentCode => 'كود الطالب';

  @override
  String get studentCodeHint => 'يمكنك الحصول على الكود من المعلم الخاص بك';

  @override
  String get errorEmptyFields => 'يرجى ملء جميع الحقول';

  @override
  String get errorEmptyStudentCode => 'يرجى إدخال كود الطالب';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get statsGroups => 'المجموعات';

  @override
  String get groupsTitle => 'المجموعات';

  @override
  String get statsStudents => 'الطلاب';

  @override
  String get studentsTitle => 'الطلاب';

  @override
  String get statsTodayCollection => 'حصيلة اليوم';

  @override
  String get todayRevenue => 'حصيلة اليوم';

  @override
  String get statsOutstanding => 'المتأخرات';

  @override
  String get debtsTitle => 'المديونيات';

  @override
  String get currentlyActive => 'نشطة حالياً';

  @override
  String get activeNow => 'نشطة حالياً';

  @override
  String get total => 'إجمالي';

  @override
  String get operations => 'عمليات';

  @override
  String studentsCount(int count) {
    return '$count طالب';
  }

  @override
  String totalCount(int count) {
    return 'إجمالي $count طالب';
  }

  @override
  String operationsCount(int count) {
    return '$count عمليات';
  }

  @override
  String get currency => 'ج.م';

  @override
  String get welcomeBack => 'أهلاً بك،';

  @override
  String get teacher => 'المعلم';

  @override
  String get todayAttendance => 'حضور اليوم';

  @override
  String get present => 'حضور';

  @override
  String get absent => 'غياب';

  @override
  String get todaySessions => 'حصص اليوم';

  @override
  String get noSessionsToday => 'لا توجد حصص اليوم';

  @override
  String get studentsPresent => 'طلاب حاضرون';

  @override
  String get outstandingAlerts => 'تنبيهات المتأخرات';

  @override
  String get noOutstandingPayments => 'ممتاز! لا توجد متأخرات';

  @override
  String get totalOutstandingThisMonth => 'إجمالي المتأخرات هذا الشهر';

  @override
  String get recentFinancialActivity => 'آخر النشاطات المادية';

  @override
  String get noRecentActivity => 'لا توجد عمليات مؤخراً';

  @override
  String get communicationManagement => 'إدارة التواصل';

  @override
  String get generalAnnouncements => 'التنبيهات العامة';

  @override
  String get generalAnnouncementsSubtitle => 'إرسال رسائل تظهر فورياً للطلاب';

  @override
  String get smartSuggestions => 'مقترحات ذكية 💡';

  @override
  String get takeAction => 'اتخاذ إجراء';

  @override
  String get convertToTask => 'تحويل لمهمة';

  @override
  String suggestionConvertedToTask(String title) {
    return 'تم تحويل المقترح إلى مهمة: $title';
  }

  @override
  String get schedule => 'جدول الحصص';

  @override
  String get recordAttendance => 'تسجيل حضور';

  @override
  String get addPayment => 'تسجيل دفعة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String showMore(int count) {
    return 'عرض المزيد ($count)';
  }

  @override
  String get showLess => 'عرض أقل';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get am_suffix => 'ص';

  @override
  String get pm_suffix => 'م';

  @override
  String sessions_count_label(Object count) {
    return '$count حصة';
  }

  @override
  String get no_sessions_on_this_day => 'لا توجد حصص في هذا اليوم';

  @override
  String student_label_count(int count) {
    return '$count طالب';
  }

  @override
  String get attendance_title => 'تسجيل الحضور';

  @override
  String get attendance_edit_registered => 'تعديل مسجّل';

  @override
  String get attendance_select_group_hint => 'اختر مجموعة...';

  @override
  String get attendance_session_date_label => 'تاريخ الحصة';

  @override
  String get attendance_stat_present => 'حاضر';

  @override
  String get attendance_stat_absent => 'غائب';

  @override
  String get attendance_stat_total => 'إجمالي';

  @override
  String get attendance_quick_all_present => '✅ الكل حاضر';

  @override
  String get attendance_quick_all_absent => '❌ الكل غائب';

  @override
  String get attendance_no_students_in_group => 'لا يوجد طلاب في هذه المجموعة';

  @override
  String get attendance_free_badge => 'مجاني';

  @override
  String get attendance_saving_state => 'جاري الحفظ...';

  @override
  String get attendance_save_success_state => 'تم الحفظ ✓';

  @override
  String get attendance_save_button_label => 'حفظ الحضور';

  @override
  String get attendance_whatsapp_bulk_toggle => 'تنبيهات جماعية عبر واتساب';

  @override
  String whatsappBulkConfirmTitle(String groupName) {
    return 'تأكيد حضور المجموعة: $groupName';
  }

  @override
  String get whatsappBulkDesc => 'التنبيه سيتم إرساله للطلاب المحددين فقط.';

  @override
  String get whatsappBetaNote =>
      'إصدار تجريبي: تأكد من مراجعة الرسائل قبل الإرسال.';

  @override
  String get teacherNameLabel => 'اسم المعلم (اختياري)';

  @override
  String get teacherNameHint => 'اسم المعلم...';

  @override
  String get messageTypeLabel => 'نوع الرسالة';

  @override
  String get absentNotification => '❌ إشعار غياب';

  @override
  String get presentConfirmation => '✅ تأكيد حضور';

  @override
  String get lateNotification => '⏰ إشعار تأخير';

  @override
  String get sessionReminder => '📢 تذكير بالحصة';

  @override
  String get sendToLabel => 'إرسال إلى';

  @override
  String absentCountLabel(int count) {
    return 'الغائبين ($count)';
  }

  @override
  String presentCountLabel(int count) {
    return 'الحاضرين ($count)';
  }

  @override
  String allStudentsLabel(int count) {
    return 'الكل ($count)';
  }

  @override
  String get messagePreviewTitle => 'معاينة الرسالة:';

  @override
  String get sendViaWhatsapp => 'إرسال عبر واتساب';

  @override
  String noStudentsOfType(String type) {
    return 'لا توجد $type في هذه المجموعة.';
  }

  @override
  String suggestionAttendanceMissed(String name) {
    return 'لم يتم تسجيل حضور مجموعة $name حتى الآن، مرور ساعة على بدء الحصة.';
  }

  @override
  String get paymentOf => 'دفعة بقيمة';

  @override
  String suggestionAttendanceTaskTitle(Object name) {
    return 'تحضير مجموعة $name';
  }

  @override
  String suggestionAttendanceTaskDesc(Object name) {
    return 'يرجى تسجيل حضور اليوم لمجموعة $name';
  }

  @override
  String get suggestionPerformanceTitle => 'تراجع مستوى';

  @override
  String suggestionPerformanceMessage(String name, String score) {
    return 'درجة الطالب $name في آخر اختبار ($score%) أقل بكثير من متوسطه.';
  }

  @override
  String suggestionPerformanceTaskTitle(Object name) {
    return 'متابعة مستوى $name';
  }

  @override
  String suggestionPerformanceTaskDesc(Object name) {
    return 'مراجعة أداء الطالب $name بعد تراجع درجاته في الاختبار الأخير';
  }

  @override
  String get suggestionAbsenceTitle => 'غياب متكرر';

  @override
  String suggestionAbsenceMessage(String name, int count) {
    return 'الطالب $name غاب $count حصص من آخر 5. يفضل متابعته.';
  }

  @override
  String suggestionAbsenceWhatsApp(Object name) {
    return 'بخصوص غياب الطالب $name المتكرر...';
  }

  @override
  String suggestionAbsenceTaskTitle(Object name) {
    return 'اتصال بولي أمر $name';
  }

  @override
  String suggestionAbsenceTaskDesc(Object count, Object name) {
    return 'التحدث مع ولي أمر الطالب $name بخصوص تكرار الغياب ($count/5)';
  }

  @override
  String get suggestionDebtorTitle => 'متابعة تحصيل';

  @override
  String suggestionDebtorMessage(Object name) {
    return 'الطالب $name منتظم في الحضور لكن لم يسدد مصروفات هذا الشهر.';
  }

  @override
  String suggestionDebtorTaskTitle(Object name) {
    return 'تحصيل مصروفات $name';
  }

  @override
  String suggestionDebtorTaskDesc(Object month, Object name) {
    return 'مطالبة الطالب $name بمصروفات شهر $month';
  }

  @override
  String get suggestionInactiveTitle => 'مجموعة غير نشطة';

  @override
  String suggestionInactiveMessage(Object name) {
    return 'مجموعة $name لم يسجل لها حضور منذ أسبوع. هل توقفت؟';
  }

  @override
  String suggestionInactiveTaskTitle(Object name) {
    return 'مراجعة حالة مجموعة $name';
  }

  @override
  String suggestionInactiveTaskDesc(Object name) {
    return 'التحقق مما إذا كانت مجموعة $name لا تزال قائمة أو تحتاج للإغلاق';
  }

  @override
  String get suggestionHonorTitle => 'ترشيح تكريم';

  @override
  String suggestionHonorMessage(Object name) {
    return 'الطالب $name حصل على درجات ممتازة مؤخراً. يستحق التواجد في لوحة الشرف.';
  }

  @override
  String suggestionHonorTaskTitle(Object name) {
    return 'تكريم الطالب $name';
  }

  @override
  String suggestionHonorTaskDesc(Object name) {
    return 'إضافة الطالب $name للوحة الشرف وتجهيز شهادة تقدير';
  }

  @override
  String get suggestionPortalTitle => 'بوابة الطلاب';

  @override
  String suggestionPortalMessage(Object name) {
    return 'الطالب الجديد $name ليس لديه كود بوابة بعد.';
  }

  @override
  String suggestionPortalTaskTitle(Object name) {
    return 'إنشاء كود بوابة لـ $name';
  }

  @override
  String suggestionPortalTaskDesc(Object name) {
    return 'توليد وإرسال كود بوابة الطالب $name';
  }

  @override
  String get suggestionGradingTitle => 'تصحيح الاختبارات';

  @override
  String suggestionGradingMessage(String title, int count) {
    return 'اختبار $title يحتاج لتصحيح $count طلاب.';
  }

  @override
  String suggestionGradingTaskTitle(Object title) {
    return 'تصحيح $title';
  }

  @override
  String suggestionGradingTaskDesc(Object count, Object title) {
    return 'إكمال رصد درجات $count طلاب لـ $title';
  }

  @override
  String get suggestionWelcomeTitle => 'مرحباً بك!';

  @override
  String suggestionWelcomeMessage(int count) {
    return 'لديك $count طالب نشط الآن. تمنياتنا بيوم دراسي موفق!';
  }

  @override
  String get suggestion_action_take => 'اتخاذ إجراء';

  @override
  String get suggestion_action_dismiss => 'تجاهل';

  @override
  String get suggestion_action_whatsapp => 'واتساب';

  @override
  String get suggestion_action_tasks => 'المهام';

  @override
  String get attendance_wa_teacher_name_label => 'اسم المعلم (اختياري)';

  @override
  String get attendance_wa_teacher_name_hint => 'اسم المعلم...';

  @override
  String get attendance_wa_msg_type_label => 'نوع الرسالة';

  @override
  String get attendance_wa_type_absent => '❌ إشعار غياب';

  @override
  String get attendance_wa_type_present => '✅ تأكيد حضور';

  @override
  String get attendance_wa_type_late => '⏰ إشعار تأخير';

  @override
  String get attendance_wa_type_reminder => '📢 تذكير بالحصة';

  @override
  String get attendance_wa_send_to_label => 'إرسال إلى';

  @override
  String attendance_wa_target_absent(int count) {
    return 'الغائبين ($count)';
  }

  @override
  String attendance_wa_target_present(int count) {
    return 'الحاضرين ($count)';
  }

  @override
  String attendance_wa_target_all(int count) {
    return 'الكل ($count)';
  }

  @override
  String get attendance_wa_preview_label => 'معاينة الرسالة:';

  @override
  String get attendance_wa_preview_name_placeholder => 'اسم الطالب';

  @override
  String attendance_wa_no_phone_warning(int count) {
    return '$count طالب بدون رقم هاتف — لن يتم إرسال رسائلهم';
  }

  @override
  String attendance_wa_send_button_label(int count) {
    return 'إرسال لـ $count طالب';
  }

  @override
  String attendance_wa_msg_present_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'السلام عليكم ورحمة الله 🌟\nنود إعلامكم بأن الطالب/ة *$name* قد حضر/ت حصة اليوم.\n📚 المجموعة: $group\n📅 التاريخ: $date\n\nشكراً على المتابعة 🙏\n$teacher';
  }

  @override
  String attendance_wa_msg_absent_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'السلام عليكم ورحمة الله ⚠️\nنود إعلامكم بأن الطالب/ة *$name* تغيب/ت عن حصة اليوم.\n📚 المجموعة: $group\n📅 التاريخ: $date\n\nنرجو المتابعة والاهتمام 🤍\n$teacher';
  }

  @override
  String attendance_wa_msg_late_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'السلام عليكم ورحمة الله ⏰\nنود إعلامكم بأن الطالب/ة *$name* تأخر/ت عن موعد حصة اليوم.\n📚 المجموعة: $group\n📅 التاريخ: $date\n\nنرجو الالتزام بالمواعيد 🙏\n$teacher';
  }

  @override
  String attendance_wa_msg_reminder_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'السلام عليكم ورحمة الله 📢\nتذكير للطالب/ة *$name* بموعد الحصة.\n📚 المجموعة: $group\n📅 التاريخ: $date\n\nفي انتظاركم 💪\n$teacher';
  }

  @override
  String get revenue => 'حصيلة';

  @override
  String studentsCountLabel(Object count) {
    return '$count طلاب';
  }

  @override
  String takeAttendanceFor(Object name) {
    return 'تحويل تحضير $name لمهمة';
  }

  @override
  String followUpPerformance(Object name) {
    return 'متابعة مستوى $name';
  }

  @override
  String callParent(Object name) {
    return 'اتصال بولي أمر $name';
  }

  @override
  String collectFees(Object name) {
    return 'تحصيل من $name';
  }

  @override
  String reviewGroup(Object name) {
    return 'مراجعة مجموعة $name';
  }

  @override
  String honorStudent(Object name) {
    return 'تكريم الطالب $name';
  }

  @override
  String generatePortalCode(Object name) {
    return 'كود بوابة لـ $name';
  }

  @override
  String gradeQuiz(Object title) {
    return 'رصد درجات $title';
  }

  @override
  String get activityAdded => 'إضافة';

  @override
  String get activityUpdated => 'تعديل';

  @override
  String get activityDeleted => 'حذف';

  @override
  String get activityAttendance => 'تحضير';

  @override
  String get activityPayment => 'دفعة';

  @override
  String get weeklyScheduleTitle => 'الجدول الأسبوعي';

  @override
  String get noRevenueToday => 'لا يوجد تحصيل اليوم';

  @override
  String get recentActivity => 'آخر التحركات';

  @override
  String get totalStudents => 'إجمالي الطلاب';

  @override
  String get paidThisMonth => 'دفعوا هذا الشهر';

  @override
  String get notPaidThisMonth => 'لم يدفعوا';

  @override
  String get groupData => 'بيانات المجموعة';

  @override
  String get academicYear => 'السنة الدراسية';

  @override
  String get location => 'المكان';

  @override
  String get sessionLink => 'رابط الحصة';

  @override
  String get weeklySchedule => 'الجدول الأسبوعي';

  @override
  String get noScheduleSet => 'لا يوجد جدول محدد';

  @override
  String get deleteGroup => 'حذف المجموعة';

  @override
  String get deleteGroupConfirm =>
      'هل أنت متأكد من حذف هذه المجموعة؟ جميع بيانات الطلاب والغياب والمدفوعات سيتم حذفها نهائياً.';

  @override
  String get editGroup => 'تعديل المجموعة';

  @override
  String get newGroupTitle => 'مجموعة جديدة';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get createGroup => 'إنشاء المجموعة';

  @override
  String get basicInfo => 'المعلومات الأساسية';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get groupNameHint => 'مثال: سنتر الفيزياء';

  @override
  String get groupType => 'نوع المجموعة';

  @override
  String get subject => 'المادة';

  @override
  String get subjectHint => 'مثال: الفيزياء';

  @override
  String get defaultPrice => 'السعر الشهري الافتراضي (ج)';

  @override
  String get groupDiscount => 'خصم المجموعة الشهري (ج)';

  @override
  String actualPrice(String price) {
    return 'السعر الفعلي: $price ج';
  }

  @override
  String get locationHint => 'عنوان السنتر أو المكان';

  @override
  String get notesHint => 'ملاحظات...';

  @override
  String get addTime => 'إضافة موعد';

  @override
  String get to => 'إلى';

  @override
  String get groupCreated => 'تم إنشاء المجموعة';

  @override
  String get changesSaved => 'تم حفظ التعديلات';

  @override
  String errorPrefix(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get students => 'الطلاب';

  @override
  String get searchStudentHint => 'بحث عن طالب...';

  @override
  String get noStudentsFound => 'لا يوجد طلاب';

  @override
  String get addStudent => 'إضافة طالب';

  @override
  String get editStudent => 'تعديل بيانات الطالب';

  @override
  String get newStudentTitle => 'طالب جديد';

  @override
  String get studentName => 'اسم الطالب';

  @override
  String get studentNameHint => 'الاسم الثلاثي أو الرباعي';

  @override
  String get gender => 'النوع';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get parentPhone => 'رقم ولي الأمر';

  @override
  String get isFreeStudent => 'طالب مجاني (بدون مصاريف)';

  @override
  String get barcode => 'الباركود';

  @override
  String get barcodeHint => 'اتركه فارغاً للتوليد التلقائي';

  @override
  String get studentCreated => 'تمت إضافة الطالب بنجاح';

  @override
  String get studentUpdated => 'تم تحديث بيانات الطالب';

  @override
  String get studentProfile => 'ملف';

  @override
  String get attendance => 'التحضير';

  @override
  String get payments => 'المالية';

  @override
  String get results => 'النتائج';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get financialStatus => 'الموقف المالي';

  @override
  String get attendanceRate => 'نسبة الحضور';

  @override
  String get averageScore => 'متوسط الدرجات';

  @override
  String get lastQuiz => 'آخر امتحان';

  @override
  String get free => 'مجاني';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String whatsappGenericGreeting(String name) {
    return 'مرحباً، بخصوص الطالب $name...';
  }

  @override
  String get year_1_sec => 'الأول الثانوي';

  @override
  String get year_2_sec => 'الثاني الثانوي';

  @override
  String get year_3_sec => 'الثالث الثانوي';

  @override
  String get year_6_primary => 'الصف السادس الابتدائي';

  @override
  String get year_5_primary => 'الصف الخامس الابتدائي';

  @override
  String get year_4_primary => 'الصف الرابع الابتدائي';

  @override
  String get year_3_primary => 'الصف الثالث الابتدائي';

  @override
  String get year_2_primary => 'الصف الثاني الابتدائي';

  @override
  String get year_1_primary => 'الصف الأول الابتدائي';

  @override
  String get year_3_prep => 'الثالث الإعدادي';

  @override
  String get year_2_prep => 'الثاني الإعدادي';

  @override
  String get year_1_prep => 'الأول الإعدادي';

  @override
  String get year_university => 'طالب جامعي';

  @override
  String get year_other => 'أخرى';

  @override
  String get exportStudentListSoon => 'سيتم تفعيل استخراج كشف الطلاب قريباً';

  @override
  String get searchByNameOrPhone => 'بحث بالاسم أو الرقم...';

  @override
  String get allGroupsFilter => 'كل المجموعات';

  @override
  String get addFirstStudent => 'أضف أول طالب';

  @override
  String studentsRegisteredCount(int count) {
    return '$count طالب مسجل';
  }

  @override
  String get deleteStudentTitle => 'حذف الطالب';

  @override
  String get deleteStudentConfirm =>
      'سيتم حذف الطالب وجميع بياناته ونتائجه نهائياً.';

  @override
  String get deletePermanently => 'حذف نهائياً';

  @override
  String get personalData => 'البيانات الشخصية';

  @override
  String get studentFullName => 'الاسم الثلاثي *';

  @override
  String get studentNameHintExample => 'مثال: أحمد محمد محمود';

  @override
  String get studentNameRequired => 'مطلوب إدخال الاسم';

  @override
  String get studentPhone => 'رقم هاتف الطالب';

  @override
  String get parentPhone1 => 'رقم ولي الأمر 1 *';

  @override
  String get parentPhoneRequired => 'مطلوب للتواصل';

  @override
  String get parentPhone2 => 'رقم ولي الأمر 2';

  @override
  String get emergencyPhoneHint => 'رقم إضافي للطوارئ';

  @override
  String get landline => 'تليفون أرضي';

  @override
  String get optional => 'اختياري';

  @override
  String get address => 'العنوان';

  @override
  String get addressHint => 'منطقة السكن / الشارع';

  @override
  String get academicData => 'البيانات الدراسية';

  @override
  String get targetGroup => 'المجموعة المستهدفة *';

  @override
  String get selectGroupHint => 'اختر مجموعة...';

  @override
  String get groupRequired => 'مطلوب اختيار مجموعة';

  @override
  String get errorLoadingGroups => 'خطأ في تحميل المجموعات';

  @override
  String get discountsAndExemptions => 'الخصومات والإعفاءات';

  @override
  String get freeStudentToggle => 'طالب مجاني / حالة خاصة';

  @override
  String get fullExemption => 'إعفاء كامل من المصروفات';

  @override
  String get hasIndividualDiscount => 'هل لدى الطالب خصم فردي؟';

  @override
  String get plusGroupDiscount => 'بالإضافة لخصم المجموعة إن وجد';

  @override
  String get discountValue => 'قيمة الخصم بالجنيه. مثال: 50';

  @override
  String get studentNotes => 'ملاحظات عن الطالب';

  @override
  String get studentNotesHint => 'ملاحظات للمنصة السكرتارية أو المدرس فقط...';

  @override
  String get studentNotFound => 'الطالب غير موجود';

  @override
  String get noPhoneFound => 'لا يوجد رقم هاتف';

  @override
  String get portalCodeGenerated => 'تم توليد كود البوابة بنجاح';

  @override
  String get groupNotSet => 'بدون مجموعة';

  @override
  String get outstanding => 'متأخرات';

  @override
  String get creditBalance => 'رصيد دائن';

  @override
  String get totalPaid => 'إجمالي المدفوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get requiredAmount => 'المطلوب';

  @override
  String get paidAmount => 'المدفوع';

  @override
  String get remainingAmount => 'المتبقي';

  @override
  String get portalCode => 'كود بوابة الطالب';

  @override
  String get inactivePortalCode => 'غير مفعل';

  @override
  String get activateCode => 'تفعيل الكود';

  @override
  String get codeCopied => 'تم نسخ الكود إلى الحافظة';

  @override
  String get performance => 'الأداء';

  @override
  String get attendanceTab => 'الحضور';

  @override
  String get paymentsTab => 'المدفوعات';

  @override
  String get gradesTab => 'الدرجات';

  @override
  String get quizzesTab => 'الاختبارات';

  @override
  String get reportsTab => 'التقارير';

  @override
  String get overallPerformanceSummary => 'ملخص الأداء العام';

  @override
  String get attendanceRateLabel => 'نسبة الحضور';

  @override
  String get excellent => 'ممتاز';

  @override
  String get needsImprovement =>
      'مستواك يحتاج لعناية واهتمام أكبر. لا تستسلم! 💪';

  @override
  String get low => 'منخفض';

  @override
  String get acceptable => 'مقبول';

  @override
  String get needsFollowUp => 'يحتاج متابعة';

  @override
  String get higherThanGroup => 'أعلى من المجموعة بـ';

  @override
  String get lowerThanGroup => 'أقل من المجموعة بـ';

  @override
  String get overallComparison => 'مقارنة شاملة بالمجموعة';

  @override
  String get noAttendanceRecords => 'لا يوجد سجلات حضور';

  @override
  String get noPaymentRecords => 'لا يوجد سجلات دفع';

  @override
  String get noGradesFound => 'لا توجد درجات مسجلة بعد';

  @override
  String get noQuizzesFound => 'لم يتم العثور على اختبارات';

  @override
  String get notEnoughQuizzesForChart => 'لا توجد اختبارات كافية لرسم المنحنى';

  @override
  String get studentProgressChart => 'تطور مستوى الطالب (الاختبارات)';

  @override
  String get deleteFromGroupConfirm =>
      'سيتم حذف الطالب من هذه المجموعة. هل أنت متأكد؟';

  @override
  String get newStudentLabel => 'طالب جديد';

  @override
  String get registerStudent => 'تسجيل الطالب';

  @override
  String get selectGroup => 'يرجى اختيار المجموعة';

  @override
  String get studentRegisteredSuccess => 'تم تسجيل الطالب بنجاح';

  @override
  String get academicYearLabel => 'السنة الدراسية';

  @override
  String get extra => 'إضافي';

  @override
  String get genderLabel => 'نوع الطالب';

  @override
  String get required => 'مطلوب';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get edit => 'تعديل';

  @override
  String get payment => 'دفعة';

  @override
  String get complete => 'مكتمل';

  @override
  String get averageGrade => 'متوسط الدرجات';

  @override
  String get monthlyPrice => 'السعر الشهري';

  @override
  String higherThanGroupWithVal(String value) {
    return 'أعلى من المجموعة بـ $value%';
  }

  @override
  String lowerThanGroupWithVal(String value) {
    return 'أقل من المجموعة بـ $value%';
  }

  @override
  String get incomplete => 'غير مكتمل';

  @override
  String get comparisonToGroup => 'مقارنة بالمجموعة';

  @override
  String get student => 'الطالب';

  @override
  String get group => 'المجموعة';

  @override
  String get groupDetailsTitle => 'تفاصيل المجموعة';

  @override
  String get editGroupTooltip => 'تعديل المجموعة';

  @override
  String get statMonthlyRequired => 'المطلوب الشهري';

  @override
  String get statOutstandingAmt => 'المتأخرات';

  @override
  String studentsWithCount(int count) {
    return 'الطلاب ($count)';
  }

  @override
  String get searchStudentsHint => 'بحث عن طالب...';

  @override
  String get noStudentsInGroup => 'لا يوجد طلاب في هذه المجموعة';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String discountAmount(String amount) {
    return 'خصم $amount';
  }

  @override
  String pricePerMonthLabel(String price) {
    return '$price ج/شهر';
  }

  @override
  String overdueAmtWithLabel(String amount) {
    return '$amount ج متأخر';
  }

  @override
  String creditAmtWithLabel(String amount) {
    return 'رصيد $amount ج';
  }

  @override
  String get completeLabel => 'مكتمل';

  @override
  String get studentFile => 'ملف';

  @override
  String get deleteAction => 'حذف';

  @override
  String get teacherFullName => 'الاسم الكامل';

  @override
  String get teacherSubject => 'المادة / التخصص';

  @override
  String get profileUpdateSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get invalidName => 'يرجى إدخال اسم صحيح';

  @override
  String get invalidPhone => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get invalidSubject => 'يرجى إدخال المادة الدراسية';

  @override
  String get selectImageSource => 'اختر مصدر الصورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get quizzes => 'الاختبارات';

  @override
  String get honorBoard => 'لوحة الشرف';

  @override
  String get expenses => 'المصاريف';

  @override
  String get financials => 'الشؤون المالية';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get userNotConnected => 'المستخدم غير متصل';

  @override
  String updateError(String error) {
    return 'خطأ في التحديث: $error';
  }

  @override
  String get attendanceSubtitle => 'متابعة حضور الطلاب والحصص';

  @override
  String get financialsSubtitle => 'إدارة المدفوعات والتحصيل والإحصائيات';

  @override
  String get expensesSubtitle => 'متابعة المصروفات اليومية والتكاليف';

  @override
  String get quizzesSubtitle => 'إدارة الامتحانات والنتائج والإحصائيات';

  @override
  String get honorBoardSubtitle => 'عرض وإدارة حصالة الطلاب المتفوقين';

  @override
  String get academicManagement => 'الإدارة الأكاديمية';

  @override
  String get financialManagement => 'الإدارة المالية';

  @override
  String get studentExcellence => 'تميز الطلاب';

  @override
  String get freeStudent => 'مجاني';

  @override
  String get addStudentLabel => 'إضافة طالب';

  @override
  String get fullNameLabel => 'الاسم الثلاثي *';

  @override
  String get fullNameHint => 'مثال: أحمد محمد محمود';

  @override
  String get nameRequired => 'مطلوب إدخال الاسم';

  @override
  String get phoneFormatHint => '01xxxxxxxxxx';

  @override
  String get invalidPrice => 'سعر غير صالح';

  @override
  String get discountGreaterPrice => 'الخصم لا يمكن أن يكون أكبر من السعر';

  @override
  String get paymentsTitle => 'المدفوعات';

  @override
  String get recordNewPayment => 'تسجيل دفعة جديدة';

  @override
  String get recordPayment => 'تسجيل الدفعة';

  @override
  String get pleaseSelectStudent => 'يرجى اختيار الطالب';

  @override
  String get amountGreaterThanZero => 'المبلغ يجب أن يكون أكبر من صفر';

  @override
  String get pleaseSelectMonth => 'يرجى تحديد الشهر';

  @override
  String get freeStudentTitle => 'طالب مجاني';

  @override
  String get freeStudentConfirmMessage =>
      'هذا الطالب مجاني، هل تريد تسجيل دفعة استثنائية؟';

  @override
  String get paymentRecordedSuccessfully => 'تم تسجيل الدفعة بنجاح ✓';

  @override
  String get groupOptionalFilter => 'المجموعة (اختياري للفلترة)';

  @override
  String get selectGroupFilter => 'اختر مجموعة للفلترة...';

  @override
  String get allStudents => 'كل الطلاب';

  @override
  String get studentRequired => 'الطالب *';

  @override
  String get selectStudent => 'اختر طالب...';

  @override
  String get freeLabelSuffix => ' (مجاني)';

  @override
  String get freeStudentSuffix => 'طالب مجاني';

  @override
  String requiredAmountSuffix(Object amount, Object currency) {
    return 'المطلوب: $amount $currency/شهر';
  }

  @override
  String amountCurrencyRequired(Object currency) {
    return 'المبلغ ($currency) *';
  }

  @override
  String partialPaymentLabel(Object amount, Object currency) {
    return '⚠️ دفع جزئي (متبقي $amount $currency)';
  }

  @override
  String excessPaymentLabel(Object amount, Object currency) {
    return '✅ رصيد دائن $amount $currency';
  }

  @override
  String get paymentCompletedLabel => '✅ مكتمل';

  @override
  String get monthRequired => 'الشهر *';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get paymentDate => 'تاريخ الدفع';

  @override
  String autoReceiptNumber(Object number) {
    return 'رقم الإيصال التلقائي: #$number';
  }

  @override
  String get deletePaymentTitle => 'حذف الدفعة';

  @override
  String get deletePaymentConfirmMessage => 'هل تريد حذف هذه الدفعة نهائياً؟';

  @override
  String get paymentDeletedMessage => 'تم حذف الدفعة';

  @override
  String get outstandingPaymentsTitle => 'المتأخرات';

  @override
  String get searchPaymentHint => 'بحث باسم الطالب أو رقم الإيصال...';

  @override
  String get allGroups => 'جميع المجموعات';

  @override
  String get noPaymentsFound => 'لا توجد مدفوعات';

  @override
  String totalPaymentsSummary(Object amount, Object count, Object currency) {
    return 'الإجمالي: $amount $currency ($count سجل)';
  }

  @override
  String receiptNumberLabel(Object number) {
    return 'رقم الإيصال: #$number';
  }

  @override
  String get addPaymentTooltip => 'إضافة دفعة';

  @override
  String get noPhoneNumberRegistered => 'لا يوجد رقم هاتف مسجل';

  @override
  String get outstandingStudentsCount => 'طلاب متأخرين';

  @override
  String get totalOutstandingAmount => 'إجمالي المتأخرات';

  @override
  String get filterByGroup => 'فلترة حسب المجموعة';

  @override
  String get noOutstandingPaymentsSuccess => 'لا توجد متأخرات لهذا الشهر!';

  @override
  String get allStudentsPaidMessage => 'جميع الطلاب سددوا مستحقاتهم بالكامل';

  @override
  String paidAmountSuffix(Object amount) {
    return 'مدفوع: $amount';
  }

  @override
  String get remind => 'تذكير';

  @override
  String get receive => 'استلام';

  @override
  String get manageExpensesTitle => 'إدارة المصروفات';

  @override
  String get expenseRecordedSuccessfully => 'تم تسجيل المصروف بنجاح ✓';

  @override
  String get deleteExpenseTitle => 'حذف المصروف';

  @override
  String get deleteExpenseConfirmMessage => 'هل تريد حذف هذا المصروف؟';

  @override
  String get totalExpensesAmount => 'إجمالي المصروفات';

  @override
  String get transactionsCount => 'عدد الحركات';

  @override
  String get allCategories => 'كل التصنيفات';

  @override
  String get noExpensesRecorded => 'لا توجد مصروفات مسجلة';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get recordNewExpense => 'سجل مصروف جديد';

  @override
  String get titleRequired => 'العنوان *';

  @override
  String get forMonth => 'عن شهر';

  @override
  String get recurringMonthlyExpense => 'مصروف متكرر شهرياً';

  @override
  String get saveExpenseButton => 'حفظ المصروف';

  @override
  String get method_cash => 'نقدي';

  @override
  String get method_bankTransfer => 'تحويل بنكي';

  @override
  String get method_vodafoneCash => 'فودافون كاش';

  @override
  String get category_rent => 'إيجار';

  @override
  String get category_salaries => 'رواتب';

  @override
  String get category_supplies => 'مستلزمات';

  @override
  String get category_utilities => 'مرافق';

  @override
  String get category_maintenance => 'صيانة';

  @override
  String get category_marketing => 'تسويق';

  @override
  String get currency_egp => 'ج';

  @override
  String get monthLabel => 'الشهر';

  @override
  String outstandingPaymentWhatsappTemplate(
    Object balance,
    Object currency,
    Object month,
    Object name,
  ) {
    return 'عزيزي ولي أمر $name،\nيرجى سداد المتأخرات بمبلغ $balance $currency عن شهر $month.\nشكراً لتعاونكم.';
  }

  @override
  String outstandingEntrySubtitle(Object group, Object paid, Object required) {
    return '$group · المطلوب: $required · مدفوع: $paid';
  }

  @override
  String get saveExpense => 'حفظ المصروف';

  @override
  String questionsCount(num count) {
    return '$count سؤال';
  }

  @override
  String resultsCount(num count) {
    return '$count نتيجة';
  }

  @override
  String get publish => 'نشر';

  @override
  String get close => 'إغلاق';

  @override
  String get quizzesTitle => 'الاختبارات';

  @override
  String get newQuiz => 'اختبار جديد';

  @override
  String get averageResults => 'متوسط النتائج';

  @override
  String get totalQuizzes => 'إجمالي الاختبارات';

  @override
  String get createFirstQuizMessage =>
      'قم بإنشاء أول اختبار لك لبدء تتبع تقدم الطلاب.';

  @override
  String get activeStatus => 'نشط';

  @override
  String get draftStatus => 'مسودة';

  @override
  String get closedStatus => 'مغلق';

  @override
  String get deleteQuizTitle => 'حذف الاختبار';

  @override
  String get deleteQuizConfirm =>
      'هل أنت متأكد من حذف هذا الاختبار؟ سيتم فقدان جميع النتائج المتعلقة به.';

  @override
  String get honorBoardTitle => 'لوحة الشرف';

  @override
  String get createQuiz => 'إنشاء اختبار';

  @override
  String get quizTitle => 'عنوان الاختبار *';

  @override
  String get targetGroupLabel => 'المجموعة المستهدفة *';

  @override
  String get examDateLabel => 'تاريخ الاختبار';

  @override
  String get durationLabel => 'المدة (دقيقة)';

  @override
  String questionsCountHeader(int count) {
    return 'الأسئلة ($count)';
  }

  @override
  String get mcqQuestion => 'سؤال اختيار متعدد';

  @override
  String get trueFalseQuestion => 'سؤال صح/خطأ';

  @override
  String get marksLabel => 'درجة';

  @override
  String get questionHint => 'اكتب نص السؤال هنا...';

  @override
  String get optionsLabel => 'الخيارات (حدد الإجابة الصحيحة ✓)';

  @override
  String optionHint(int number) {
    return 'الخيار $number';
  }

  @override
  String get tooltipMcq => 'سؤال اختياري';

  @override
  String get tooltipTrueFalse => 'صح أو خطأ';

  @override
  String get completeBasicInfo => 'يرجى إكمال البيانات الأساسية';

  @override
  String get completeAllQuestions =>
      'يرجى إكمال جميع الأسئلة والإجابات الصحيحة';

  @override
  String get quizSavedSuccess => 'تم حفظ الاختبار بنجاح ✓';

  @override
  String saveError(String error) {
    return 'خطأ أثناء الحفظ: $error';
  }

  @override
  String get quizResults => 'نتائج الاختبار';

  @override
  String get noResultsYet => 'لا يوجد نتائج لهذا الاختبار بعد';

  @override
  String get resultsWillShowHere =>
      'سيتم عرض النتائج هنا فور تسليم الطلاب للحلول';

  @override
  String get searchByStudent => 'بحث باسم الطالب...';

  @override
  String get submittedInfo => 'تم التسليم';

  @override
  String get avgScore => 'متوسط الدرجات';

  @override
  String get highestScore => 'أعلى درجة';

  @override
  String submissionDate(String date) {
    return 'تاريخ التسليم: $date';
  }

  @override
  String get shareWithParent => 'إرسال لولي الأمر';

  @override
  String get noPhoneRegistered => 'لا يوجد رقم هاتف مسجل';

  @override
  String whatsappQuizResultMessage(
    String studentName,
    String quizTitle,
    String score,
    int totalMarks,
    String percentage,
  ) {
    return 'نشيد بعلمكم بنتيجة الطالب $studentName في اختبار \"$quizTitle\":\nالدرجة: $score من $totalMarks\nالنسبة: $percentage%\nشكراً لمتابعتكم.';
  }

  @override
  String get groupLabel => 'المجموعة';

  @override
  String get noSufficientData => 'لا توجد بيانات كافية';

  @override
  String get pointsLabel => 'نقطة';

  @override
  String get loadingData => 'جاري التحميل...';

  @override
  String errorLoadingData(String error) {
    return 'خطأ في تحميل البيانات: $error';
  }

  @override
  String get home => 'الرئيسية';

  @override
  String get myAttendance => 'حضوري';

  @override
  String get attendanceHistory => 'سجل حضوري';

  @override
  String get noAttendanceFound => 'لا يوجد سجل حضور حتى الآن';

  @override
  String get attendanceWillShowHere =>
      'سيظهر سجل حضورك هنا بمجرد تسجيل المعلم له.';

  @override
  String get myGrades => 'درجاتي';

  @override
  String get myGradesAndResults => 'درجاتي ونتائجي';

  @override
  String scoreOutOf(String score, int max) {
    return 'الدرجة: $score من $max';
  }

  @override
  String get gradesWillShowHere => 'ستظهر نتائج اختباراتك هنا فور رصدها.';

  @override
  String get lastScore => 'آخر درجة';

  @override
  String get overallPerformance => 'الأداء الأكاديمي العام';

  @override
  String get exceptionalPerformance => 'أداء استثنائي! أنت من المتفوقين. 🌟';

  @override
  String get veryGoodPerformance => 'أداء جيد جداً، استمر في التقدم. 👍';

  @override
  String get goodPerformance => 'أداء مقبول، تحتاج لمزيد من الجهد. 📚';

  @override
  String get notebooksStore => 'متجر المذكرات';

  @override
  String get store => 'المتجر';

  @override
  String get whatsappOpenError =>
      'فشل فتح الواتساب. يرجى التأكد من تثبيت التطبيق.';

  @override
  String get storeIsEmpty => 'المتجر فارغ حالياً';

  @override
  String get noItemsAvailable =>
      'لا توجد مذكرات أو كتب متاحة للطلب في الوقت الحالي. يرجى مراجعة المعلم.';

  @override
  String get teacherPhoneUnavailable =>
      'عذراً، رقم هاتف المعلم غير متوفر حالياً لإتمام الطلب.';

  @override
  String whatsappStoreOrderMessage(
    String itemTitle,
    String itemCategory,
    double itemPrice,
    String studentName,
  ) {
    return 'مرحباً، أود طلب: $itemTitle\nالتصنيف: $itemCategory\nالسعر: $itemPrice ج.م\nالاسم: $studentName';
  }

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get orderNow => 'اطلب الآن';

  @override
  String get currentGroup => 'المجموعة الحالية';

  @override
  String keepGoing(String name) {
    return 'استمر في الاجتهاد يا $name! 🚀';
  }

  @override
  String get announcementsAndAlerts => 'الإعلانات والتنبيهات';

  @override
  String get privateMessage => 'رسالة خاصة';

  @override
  String get noNewNotifications => 'لا توجد تنبيهات جديدة حالياً. يومك سعيد!';

  @override
  String errorLoadingAnnouncements(String error) {
    return 'خطأ في تحميل التنبيهات: $error';
  }

  @override
  String get dayLabel => 'يوم';

  @override
  String get latestAnnouncements => 'أحدث الإعلانات';

  @override
  String get noAnnouncements => 'لا توجد إعلانات حالياً.';

  @override
  String performanceFeedback(String status) {
    return '$status';
  }

  @override
  String get performanceExceptional => 'أداء استثنائي! أنت من المتفوقين. 🌟';

  @override
  String get performanceDoingGreat => 'أداء جيد جداً، استمر في التقدم. 👍';

  @override
  String get performanceAcceptable => 'أداء مقبول، تحتاج لمزيد من الجهد. 📚';

  @override
  String get performanceNeedsAttention =>
      'مستواك يحتاج لعناية واهتمام أكبر. لا تستسلم! 💪';

  @override
  String get method_other => 'أخرى';

  @override
  String get deleteExpenseConfirm => 'هل أنت متأكد من حذف هذا المصروف؟';

  @override
  String get totalExpenses => 'إجمالي المصاريف';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get recurringExpenseLabel => 'مصروف متكرر';

  @override
  String get freeBadge => 'مجاني';

  @override
  String get paymentStatusCompleted => 'تم دفع المبلغ بالكامل';

  @override
  String get delete => 'حذف';

  @override
  String get confirmLogout => 'تأكيد تسجيل الخروج';

  @override
  String get logoutConfirmationMessage =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج من بوابة الطالب؟';

  @override
  String get expenseRecordedSuccess => 'تم تسجيل المصروف بنجاح';

  @override
  String get category_other => 'أخرى';

  @override
  String get suggestionAttendanceTitle => 'تنبيه غياب';

  @override
  String suggestionAttendanceMessage(int count) {
    return 'هناك $count غيابات اليوم. هل تريد إرسال تنبيهات واتساب؟';
  }

  @override
  String get welcome => 'مرحباً بك!';

  @override
  String welcomeMessage(int count) {
    return 'لديك $count طالب نشط في مجموعاتك حالياً.';
  }

  @override
  String get sendInstantMessages => 'إرسال رسائل فورية';
}
