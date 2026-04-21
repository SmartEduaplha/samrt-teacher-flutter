// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Teacher Assistant';

  @override
  String get navHome => 'Home';

  @override
  String get navGroups => 'Groups';

  @override
  String get navStudents => 'Students';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navMore => 'More';

  @override
  String get settings => 'Settings';

  @override
  String get themeAppearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get newGroup => 'New Group';

  @override
  String get searchHint => 'Search...';

  @override
  String get noGroupsFound => 'No groups found';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get addGroup => 'Add Group';

  @override
  String get all => 'All';

  @override
  String get center => 'Center';

  @override
  String get privateGroup => 'Private Group';

  @override
  String get privateLesson => 'Private Lesson';

  @override
  String get online => 'Online';

  @override
  String groupsCount(int count) {
    return '$count groups';
  }

  @override
  String errorOccurred(String error) {
    return 'An error occurred';
  }

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App Lock (PIN)';

  @override
  String get appLockSubtitle => 'Require code when opening the app';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupSubtitle => 'Manage manual backups';

  @override
  String get exportImport => 'Export/Import Data';

  @override
  String get comingSoon => 'This feature will be available soon';

  @override
  String get setPin => 'Setup PIN';

  @override
  String get enterFourDigits => 'Enter 4 digit code';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get saving => 'Saving...';

  @override
  String get notes => 'Notes';

  @override
  String get viewTasks => 'View Tasks';

  @override
  String get moreMenu => 'More Menu';

  @override
  String get profile => 'Profile';

  @override
  String get profileSubtitle => 'Manage your data and profile picture';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Notification and download settings';

  @override
  String get groupsAndLevel => 'Levels & Groups';

  @override
  String get groupsAndLevelSubtitle => 'Manage educational categories';

  @override
  String get appSettings => 'App Settings';

  @override
  String get appSettingsSubtitle => 'Language, Theme, and Security';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpSupportSubtitle => 'FAQ and Contact Us';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get loginTitle => 'Login';

  @override
  String get teacherPortal => 'Teacher Portal';

  @override
  String get studentPortal => 'Student Portal';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccount => 'Don\'t have an account? Register now';

  @override
  String get orViaGoogle => 'Or via Google';

  @override
  String get googleLogin => 'Login with Google';

  @override
  String get teacherLogin => 'Teacher Login';

  @override
  String get studentLogin => 'Student Login';

  @override
  String get studentWelcome =>
      'Welcome Hero! Enter your portal code to continue';

  @override
  String get studentCode => 'Student Code';

  @override
  String get studentCodeHint => 'You can get the code from your teacher';

  @override
  String get errorEmptyFields => 'Please fill in all fields';

  @override
  String get errorEmptyStudentCode => 'Please enter student code';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get statsGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get statsStudents => 'Students';

  @override
  String get studentsTitle => 'Students';

  @override
  String get statsTodayCollection => 'Today\'s Collection';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get statsOutstanding => 'Outstanding';

  @override
  String get debtsTitle => 'Debts';

  @override
  String get currentlyActive => 'Currently Active';

  @override
  String get activeNow => 'Active Now';

  @override
  String get total => 'Total';

  @override
  String get operations => 'Operations';

  @override
  String studentsCount(int count) {
    return '$count Students';
  }

  @override
  String totalCount(int count) {
    return 'Total $count Students';
  }

  @override
  String operationsCount(int count) {
    return '$count Operations';
  }

  @override
  String get currency => 'EGP';

  @override
  String get welcomeBack => 'Welcome,';

  @override
  String get teacher => 'Teacher';

  @override
  String get todayAttendance => 'Today\'s Attendance';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get todaySessions => 'Today\'s Sessions';

  @override
  String get noSessionsToday => 'No sessions today';

  @override
  String get studentsPresent => 'Students Present';

  @override
  String get outstandingAlerts => 'Outstanding Alerts';

  @override
  String get noOutstandingPayments => 'Great! No outstanding payments';

  @override
  String get totalOutstandingThisMonth => 'Total Outstanding This Month';

  @override
  String get recentFinancialActivity => 'Recent Financial Activity';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get communicationManagement => 'Communication Management';

  @override
  String get generalAnnouncements => 'General Announcements';

  @override
  String get generalAnnouncementsSubtitle =>
      'Send messages that appear instantly to students';

  @override
  String get smartSuggestions => 'Smart Suggestions 💡';

  @override
  String get takeAction => 'Take Action';

  @override
  String get convertToTask => 'Convert to Task';

  @override
  String suggestionConvertedToTask(String title) {
    return 'Suggestion converted to task: $title';
  }

  @override
  String get schedule => 'Schedule';

  @override
  String get recordAttendance => 'Record Attendance';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get viewAll => 'View All';

  @override
  String showMore(int count) {
    return 'Show More ($count)';
  }

  @override
  String get showLess => 'Show Less';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get am_suffix => 'AM';

  @override
  String get pm_suffix => 'PM';

  @override
  String sessions_count_label(Object count) {
    return '$count Sessions';
  }

  @override
  String get no_sessions_on_this_day => 'No sessions on this day';

  @override
  String student_label_count(int count) {
    return '$count Student';
  }

  @override
  String get attendance_title => 'Take Attendance';

  @override
  String get attendance_edit_registered => 'Edit Registered';

  @override
  String get attendance_select_group_hint => 'Select group...';

  @override
  String get attendance_session_date_label => 'Session Date';

  @override
  String get attendance_stat_present => 'Present';

  @override
  String get attendance_stat_absent => 'Absent';

  @override
  String get attendance_stat_total => 'Total';

  @override
  String get attendance_quick_all_present => '✅ All Present';

  @override
  String get attendance_quick_all_absent => '❌ All Absent';

  @override
  String get attendance_no_students_in_group => 'No students in this group';

  @override
  String get attendance_free_badge => 'Free';

  @override
  String get attendance_saving_state => 'Saving...';

  @override
  String get attendance_save_success_state => 'Saved ✓';

  @override
  String get attendance_save_button_label => 'Save Attendance';

  @override
  String get attendance_whatsapp_bulk_toggle => 'Bulk WhatsApp Alerts';

  @override
  String whatsappBulkConfirmTitle(String groupName) {
    return 'Attendance Confirmation: $groupName';
  }

  @override
  String get whatsappBulkDesc =>
      'Alerts will be sent to selected students only.';

  @override
  String get whatsappBetaNote => 'Beta: Please review messages before sending.';

  @override
  String get teacherNameLabel => 'Teacher Name (Optional)';

  @override
  String get teacherNameHint => 'Teacher Name...';

  @override
  String get messageTypeLabel => 'Message Type';

  @override
  String get absentNotification => '❌ Absence Notification';

  @override
  String get presentConfirmation => '✅ Presence Confirmation';

  @override
  String get lateNotification => '⏰ Lateness Notification';

  @override
  String get sessionReminder => '📢 Session Reminder';

  @override
  String get sendToLabel => 'Send To';

  @override
  String absentCountLabel(int count) {
    return 'Absentees ($count)';
  }

  @override
  String presentCountLabel(int count) {
    return 'Attendees ($count)';
  }

  @override
  String allStudentsLabel(int count) {
    return 'All ($count)';
  }

  @override
  String get messagePreviewTitle => 'Message Preview:';

  @override
  String get sendViaWhatsapp => 'Send via WhatsApp';

  @override
  String noStudentsOfType(String type) {
    return 'No $type students in this group.';
  }

  @override
  String suggestionAttendanceMissed(String name) {
    return 'Group $name has not been recorded yet, 1 hour after the session started.';
  }

  @override
  String get paymentOf => 'Payment of';

  @override
  String suggestionAttendanceTaskTitle(Object name) {
    return 'Record group $name';
  }

  @override
  String suggestionAttendanceTaskDesc(Object name) {
    return 'Please record today\'s attendance for group $name';
  }

  @override
  String get suggestionPerformanceTitle => 'Performance Drop';

  @override
  String suggestionPerformanceMessage(String name, String score) {
    return 'Student $name\'s score in the last test ($score%) is significantly below their average.';
  }

  @override
  String suggestionPerformanceTaskTitle(Object name) {
    return 'Monitor $name\'s level';
  }

  @override
  String suggestionPerformanceTaskDesc(Object name) {
    return 'Review student $name\'s performance after their score dropped in the last test';
  }

  @override
  String get suggestionAbsenceTitle => 'Frequent Absence';

  @override
  String suggestionAbsenceMessage(String name, int count) {
    return 'Student $name missed $count sessions out of the last 5. Follow-up is recommended.';
  }

  @override
  String suggestionAbsenceWhatsApp(Object name) {
    return 'Regarding student $name\'s frequent absence...';
  }

  @override
  String suggestionAbsenceTaskTitle(Object name) {
    return 'Contact $name\'s parent';
  }

  @override
  String suggestionAbsenceTaskDesc(Object count, Object name) {
    return 'Talk to student $name\'s parent regarding frequent absence ($count/5)';
  }

  @override
  String get suggestionDebtorTitle => 'Payment Follow-up';

  @override
  String suggestionDebtorMessage(Object name) {
    return 'Student $name attends regularly but hasn\'t paid this month\'s fees.';
  }

  @override
  String suggestionDebtorTaskTitle(Object name) {
    return 'Collect fees from $name';
  }

  @override
  String suggestionDebtorTaskDesc(Object month, Object name) {
    return 'Ask student $name for $month fees';
  }

  @override
  String get suggestionInactiveTitle => 'Inactive Group';

  @override
  String suggestionInactiveMessage(Object name) {
    return 'Group $name has no attendance recorded for a week. Has it stopped?';
  }

  @override
  String suggestionInactiveTaskTitle(Object name) {
    return 'Review group $name status';
  }

  @override
  String suggestionInactiveTaskDesc(Object name) {
    return 'Check if group $name is still active or needs to be closed';
  }

  @override
  String get suggestionHonorTitle => 'Honor Board Nomination';

  @override
  String suggestionHonorMessage(Object name) {
    return 'Student $name has excellent grades recently. They deserve a spot on the honor board.';
  }

  @override
  String suggestionHonorTaskTitle(Object name) {
    return 'Honor student $name';
  }

  @override
  String suggestionHonorTaskDesc(Object name) {
    return 'Add student $name to the honor board and prepare a certificate';
  }

  @override
  String get suggestionPortalTitle => 'Student Portal';

  @override
  String suggestionPortalMessage(Object name) {
    return 'New student $name doesn\'t have a portal code yet.';
  }

  @override
  String suggestionPortalTaskTitle(Object name) {
    return 'Create portal code for $name';
  }

  @override
  String suggestionPortalTaskDesc(Object name) {
    return 'Generate and send student $name\'s portal code';
  }

  @override
  String get suggestionGradingTitle => 'Grading Quizzes';

  @override
  String suggestionGradingMessage(String title, int count) {
    return 'Quiz $title needs grading for $count students.';
  }

  @override
  String suggestionGradingTaskTitle(Object title) {
    return 'Grade $title';
  }

  @override
  String suggestionGradingTaskDesc(Object count, Object title) {
    return 'Complete grading for $count students in $title';
  }

  @override
  String get suggestionWelcomeTitle => 'Welcome!';

  @override
  String suggestionWelcomeMessage(int count) {
    return 'You have $count active students now. Have a great day!';
  }

  @override
  String get suggestion_action_take => 'Take Action';

  @override
  String get suggestion_action_dismiss => 'Dismiss';

  @override
  String get suggestion_action_whatsapp => 'WhatsApp';

  @override
  String get suggestion_action_tasks => 'Tasks';

  @override
  String get attendance_wa_teacher_name_label => 'Teacher Name (Optional)';

  @override
  String get attendance_wa_teacher_name_hint => 'Teacher name...';

  @override
  String get attendance_wa_msg_type_label => 'Message Type';

  @override
  String get attendance_wa_type_absent => '❌ Absence Notice';

  @override
  String get attendance_wa_type_present => '✅ Attendance Confirmation';

  @override
  String get attendance_wa_type_late => '⏰ Lateness Notice';

  @override
  String get attendance_wa_type_reminder => '📢 Session Reminder';

  @override
  String get attendance_wa_send_to_label => 'Send to';

  @override
  String attendance_wa_target_absent(int count) {
    return 'Absent ($count)';
  }

  @override
  String attendance_wa_target_present(int count) {
    return 'Present ($count)';
  }

  @override
  String attendance_wa_target_all(int count) {
    return 'All ($count)';
  }

  @override
  String get attendance_wa_preview_label => 'Message Preview:';

  @override
  String get attendance_wa_preview_name_placeholder => 'Student Name';

  @override
  String attendance_wa_no_phone_warning(int count) {
    return '$count students without phone numbers — messages won\'t be sent';
  }

  @override
  String attendance_wa_send_button_label(int count) {
    return 'Send to $count Students';
  }

  @override
  String attendance_wa_msg_present_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'Peace be upon you 🌟\nWe would like to inform you that the student *$name* attended today\'s session.\n📚 Group: $group\n📅 Date: $date\n\nThank you for following up 🙏\n$teacher';
  }

  @override
  String attendance_wa_msg_absent_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'Peace be upon you ⚠️\nWe would like to inform you that the student *$name* was absent from today\'s session.\n📚 Group: $group\n📅 Date: $date\n\nPlease follow up 🤍\n$teacher';
  }

  @override
  String attendance_wa_msg_late_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'Peace be upon you ⏰\nWe would like to inform you that the student *$name* was late for today\'s session.\n📚 Group: $group\n📅 Date: $date\n\nPlease ensure punctuality 🙏\n$teacher';
  }

  @override
  String attendance_wa_msg_reminder_template(
    Object date,
    Object group,
    Object name,
    Object teacher,
  ) {
    return 'Peace be upon you 📢\nReminder for the student *$name* about the session time.\n📚 Group: $group\n📅 Date: $date\n\nWaiting for you 💪\n$teacher';
  }

  @override
  String get revenue => 'Revenue';

  @override
  String studentsCountLabel(Object count) {
    return '$count Students';
  }

  @override
  String takeAttendanceFor(Object name) {
    return 'Convert attendance for $name to task';
  }

  @override
  String followUpPerformance(Object name) {
    return 'Follow up performance of $name';
  }

  @override
  String callParent(Object name) {
    return 'Call parent of $name';
  }

  @override
  String collectFees(Object name) {
    return 'Collect fees from $name';
  }

  @override
  String reviewGroup(Object name) {
    return 'Review group $name';
  }

  @override
  String honorStudent(Object name) {
    return 'Honor student $name';
  }

  @override
  String generatePortalCode(Object name) {
    return 'Portal code for $name';
  }

  @override
  String gradeQuiz(Object title) {
    return 'Grade quiz $title';
  }

  @override
  String get activityAdded => 'Added';

  @override
  String get activityUpdated => 'Updated';

  @override
  String get activityDeleted => 'Deleted';

  @override
  String get activityAttendance => 'Attendance';

  @override
  String get activityPayment => 'Payment';

  @override
  String get weeklyScheduleTitle => 'Weekly Schedule';

  @override
  String get noRevenueToday => 'No revenue today';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get paidThisMonth => 'Paid this month';

  @override
  String get notPaidThisMonth => 'Not paid';

  @override
  String get groupData => 'Group Information';

  @override
  String get academicYear => 'Academic Year';

  @override
  String get location => 'Location';

  @override
  String get sessionLink => 'Session Link';

  @override
  String get weeklySchedule => 'Weekly Schedule';

  @override
  String get noScheduleSet => 'No schedule set';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String get deleteGroupConfirm =>
      'Are you sure you want to delete this group? All student data, attendance, and payments will be permanently deleted.';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get newGroupTitle => 'New Group';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get createGroup => 'Create Group';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupNameHint => 'e.g., Physics Center';

  @override
  String get groupType => 'Group Type';

  @override
  String get subject => 'Subject';

  @override
  String get subjectHint => 'e.g., Physics';

  @override
  String get defaultPrice => 'Default Monthly Price (EGP)';

  @override
  String get groupDiscount => 'Group Monthly Discount (EGP)';

  @override
  String actualPrice(String price) {
    return 'Actual Price: $price EGP';
  }

  @override
  String get locationHint => 'Center address or location';

  @override
  String get notesHint => 'Notes...';

  @override
  String get addTime => 'Add Slot';

  @override
  String get to => 'to';

  @override
  String get groupCreated => 'Group created successfully';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get students => 'Students';

  @override
  String get searchStudentHint => 'Search for a student...';

  @override
  String get noStudentsFound => 'No students found';

  @override
  String get addStudent => 'Add Student';

  @override
  String get editStudent => 'Edit Student Data';

  @override
  String get newStudentTitle => 'New Student';

  @override
  String get studentName => 'Student Name';

  @override
  String get studentNameHint => 'Full Name';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get parentPhone => 'Parent Phone';

  @override
  String get isFreeStudent => 'Free Student (Scholarship)';

  @override
  String get barcode => 'Barcode';

  @override
  String get barcodeHint => 'Leave empty to auto-generate';

  @override
  String get studentCreated => 'Student added successfully';

  @override
  String get studentUpdated => 'Student updated successfully';

  @override
  String get studentProfile => 'Profile';

  @override
  String get attendance => 'Attendance';

  @override
  String get payments => 'Financials';

  @override
  String get results => 'Results';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get financialStatus => 'Financial Status';

  @override
  String get attendanceRate => 'Attendance Rate';

  @override
  String get averageScore => 'Average Score';

  @override
  String get lastQuiz => 'Last Quiz';

  @override
  String get free => 'Free';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String whatsappGenericGreeting(String name) {
    return 'Hello, regarding the student $name...';
  }

  @override
  String get year_1_sec => '1st Secondary';

  @override
  String get year_2_sec => '2nd Secondary';

  @override
  String get year_3_sec => '3rd Secondary';

  @override
  String get year_6_primary => '6th Primary';

  @override
  String get year_5_primary => '5th Primary';

  @override
  String get year_4_primary => '4th Primary';

  @override
  String get year_3_primary => '3rd Primary';

  @override
  String get year_2_primary => '2nd Primary';

  @override
  String get year_1_primary => '1st Primary';

  @override
  String get year_3_prep => '3rd Preparatory';

  @override
  String get year_2_prep => '2nd Preparatory';

  @override
  String get year_1_prep => '1st Preparatory';

  @override
  String get year_university => 'University Student';

  @override
  String get year_other => 'Other';

  @override
  String get exportStudentListSoon =>
      'Exporting student list will be active soon';

  @override
  String get searchByNameOrPhone => 'Search by name or phone...';

  @override
  String get allGroupsFilter => 'All Groups';

  @override
  String get addFirstStudent => 'Add first student';

  @override
  String studentsRegisteredCount(int count) {
    return '$count registered students';
  }

  @override
  String get deleteStudentTitle => 'Delete Student';

  @override
  String get deleteStudentConfirm =>
      'The student and all their data and results will be permanently deleted.';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get personalData => 'Personal Data';

  @override
  String get studentFullName => 'Student Full Name *';

  @override
  String get studentNameHintExample => 'Example: John Doe';

  @override
  String get studentNameRequired => 'Name is required';

  @override
  String get studentPhone => 'Student Phone';

  @override
  String get parentPhone1 => 'Parent Phone 1 *';

  @override
  String get parentPhoneRequired => 'Required for contact';

  @override
  String get parentPhone2 => 'Parent Phone 2';

  @override
  String get emergencyPhoneHint => 'Additional emergency number';

  @override
  String get landline => 'Landline';

  @override
  String get optional => 'Optional';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Address / Street';

  @override
  String get academicData => 'Academic Data';

  @override
  String get targetGroup => 'Target Group *';

  @override
  String get selectGroupHint => 'Select a group...';

  @override
  String get groupRequired => 'Group selection is required';

  @override
  String get errorLoadingGroups => 'Error loading groups';

  @override
  String get noGroupsForYear => 'No active groups for this academic year';

  @override
  String get discountsAndExemptions => 'Discounts & Exemptions';

  @override
  String get freeStudentToggle => 'Free Student / Special Case';

  @override
  String get fullExemption => 'Full exemption from fees';

  @override
  String get hasIndividualDiscount =>
      'Does the student have an individual discount?';

  @override
  String get plusGroupDiscount => 'In addition to the group discount if any';

  @override
  String get discountValue => 'Discount value (EGP). Example: 50';

  @override
  String get studentNotes => 'Notes about student';

  @override
  String get studentNotesHint => 'Notes for administration or teacher only...';

  @override
  String get studentNotFound => 'Student not found';

  @override
  String get noPhoneFound => 'No phone number found';

  @override
  String get portalCodeGenerated => 'Portal code generated successfully';

  @override
  String get groupNotSet => 'No group';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get creditBalance => 'Credit Balance';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get thisMonth => 'This Month';

  @override
  String get requiredAmount => 'Required';

  @override
  String get paidAmount => 'Paid';

  @override
  String get remainingAmount => 'Remaining';

  @override
  String get portalCode => 'Student Portal Code';

  @override
  String get inactivePortalCode => 'Inactive';

  @override
  String get activateCode => 'Activate Code';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get performance => 'Performance';

  @override
  String get attendanceTab => 'Attendance';

  @override
  String get paymentsTab => 'Payments';

  @override
  String get gradesTab => 'Grades';

  @override
  String get quizzesTab => 'Quizzes';

  @override
  String get reportsTab => 'Reports';

  @override
  String get overallPerformanceSummary => 'Overall Performance Summary';

  @override
  String get attendanceRateLabel => 'Attendance Rate';

  @override
  String get excellent => 'Excellent';

  @override
  String get needsImprovement =>
      'Your level needs more care and attention. Don\'t give up! 💪';

  @override
  String get low => 'Low';

  @override
  String get acceptable => 'Acceptable';

  @override
  String get needsFollowUp => 'Needs follow-up';

  @override
  String get higherThanGroup => 'Higher than group by';

  @override
  String get lowerThanGroup => 'Lower than group by';

  @override
  String get overallComparison => 'Comprehensive comparison with group';

  @override
  String get noAttendanceRecords => 'No attendance records';

  @override
  String get noPaymentRecords => 'No payment records';

  @override
  String get noGradesFound => 'No grades recorded yet';

  @override
  String get noQuizzesFound => 'No quizzes found';

  @override
  String get notEnoughQuizzesForChart => 'Not enough quizzes to draw charts';

  @override
  String get studentProgressChart => 'Student Development (Quizzes)';

  @override
  String get deleteFromGroupConfirm =>
      'Student will be deleted from this group. Are you sure?';

  @override
  String get newStudentLabel => 'New Student';

  @override
  String get registerStudent => 'Register Student';

  @override
  String get selectGroup => 'Please select a group';

  @override
  String get studentRegisteredSuccess => 'Student registered successfully';

  @override
  String get academicYearLabel => 'Academic Year';

  @override
  String get extra => 'Extra';

  @override
  String get genderLabel => 'Gender';

  @override
  String get required => 'Required';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get edit => 'Edit';

  @override
  String get payment => 'Payment';

  @override
  String get complete => 'Complete';

  @override
  String get averageGrade => 'Avg Grade';

  @override
  String get monthlyPrice => 'Monthly Price';

  @override
  String higherThanGroupWithVal(String value) {
    return '$value% higher than group';
  }

  @override
  String lowerThanGroupWithVal(String value) {
    return '$value% lower than group';
  }

  @override
  String get incomplete => 'Incomplete';

  @override
  String get comparisonToGroup => 'Comparison to Group';

  @override
  String get student => 'Student';

  @override
  String get group => 'Group';

  @override
  String get groupDetailsTitle => 'Group Details';

  @override
  String get editGroupTooltip => 'Edit Group';

  @override
  String get statMonthlyRequired => 'Monthly Required';

  @override
  String get statOutstandingAmt => 'Outstanding';

  @override
  String studentsWithCount(int count) {
    return 'Students ($count)';
  }

  @override
  String get searchStudentsHint => 'Search for a student...';

  @override
  String get noStudentsInGroup => 'No students in this group';

  @override
  String get noResultsFound => 'No results found';

  @override
  String discountAmount(String amount) {
    return 'Discount $amount';
  }

  @override
  String pricePerMonthLabel(String price) {
    return '$price EGP/month';
  }

  @override
  String overdueAmtWithLabel(String amount) {
    return '$amount EGP overdue';
  }

  @override
  String creditAmtWithLabel(String amount) {
    return 'Credit $amount EGP';
  }

  @override
  String get completeLabel => 'Complete';

  @override
  String get studentFile => 'Profile';

  @override
  String get deleteAction => 'Delete';

  @override
  String get teacherFullName => 'Full Name';

  @override
  String get teacherSubject => 'Subject/Specialty';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get invalidName => 'Please enter a valid name';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get invalidSubject => 'Please enter a subject';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get honorBoard => 'Honor Board';

  @override
  String get expenses => 'Expenses';

  @override
  String get financials => 'Financials';

  @override
  String get aboutApp => 'About App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get phone => 'Phone Number';

  @override
  String get userNotConnected => 'User Not Connected';

  @override
  String updateError(String error) {
    return 'Update Error: $error';
  }

  @override
  String get attendanceSubtitle => 'Track student attendance and sessions';

  @override
  String get financialsSubtitle => 'Manage payments, income and statistics';

  @override
  String get expensesSubtitle => 'Track daily expenses and outgoing costs';

  @override
  String get quizzesSubtitle => 'Manage exams, results and statistics';

  @override
  String get honorBoardSubtitle => 'View and manage outstanding students';

  @override
  String get academicManagement => 'Academic Management';

  @override
  String get financialManagement => 'Financial Management';

  @override
  String get studentExcellence => 'Student Excellence';

  @override
  String get freeStudent => 'Free Student';

  @override
  String get addStudentLabel => 'Add Student';

  @override
  String get fullNameLabel => 'Full Name *';

  @override
  String get fullNameHint => 'e.g., Ahmed Mohamed Mahmoud';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phoneFormatHint => '01xxxxxxxxxx';

  @override
  String get invalidPrice => 'Invalid Price';

  @override
  String get discountGreaterPrice => 'Discount cannot be greater than price';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get recordNewPayment => 'Record New Payment';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get pleaseSelectStudent => 'Please select a student';

  @override
  String get amountGreaterThanZero => 'Amount must be greater than zero';

  @override
  String get pleaseSelectMonth => 'Please select month';

  @override
  String get freeStudentTitle => 'Free Student';

  @override
  String get freeStudentConfirmMessage =>
      'This student is free, do you want to record an exceptional payment?';

  @override
  String get paymentRecordedSuccessfully => 'Payment recorded successfully ✓';

  @override
  String get groupOptionalFilter => 'Group (Optional for filtering)';

  @override
  String get selectGroupFilter => 'Select group to filter...';

  @override
  String get allStudents => 'All Students';

  @override
  String get studentRequired => 'Student *';

  @override
  String get selectStudent => 'Select student...';

  @override
  String get freeLabelSuffix => ' (Free)';

  @override
  String get freeStudentSuffix => 'Free Student';

  @override
  String requiredAmountSuffix(Object amount, Object currency) {
    return 'Required: $amount $currency/month';
  }

  @override
  String amountCurrencyRequired(Object currency) {
    return 'Amount ($currency) *';
  }

  @override
  String partialPaymentLabel(Object amount, Object currency) {
    return '⚠️ Partial payment (Remaining $amount $currency)';
  }

  @override
  String excessPaymentLabel(Object amount, Object currency) {
    return '✅ Credit balance $amount $currency';
  }

  @override
  String get paymentCompletedLabel => '✅ Completed';

  @override
  String get monthRequired => 'Month *';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String autoReceiptNumber(Object number) {
    return 'Auto Receipt Number: #$number';
  }

  @override
  String get deletePaymentTitle => 'Delete Payment';

  @override
  String get deletePaymentConfirmMessage =>
      'Do you want to delete this payment permanently?';

  @override
  String get paymentDeletedMessage => 'Payment deleted';

  @override
  String get outstandingPaymentsTitle => 'Outstanding Payments';

  @override
  String get searchPaymentHint => 'Search by student name or receipt number...';

  @override
  String get allGroups => 'All Groups';

  @override
  String get noPaymentsFound => 'No payments found';

  @override
  String totalPaymentsSummary(Object amount, Object count, Object currency) {
    return 'Total: $amount $currency ($count records)';
  }

  @override
  String receiptNumberLabel(Object number) {
    return 'Receipt No: #$number';
  }

  @override
  String get addPaymentTooltip => 'Add Payment';

  @override
  String get noPhoneNumberRegistered => 'No phone number registered';

  @override
  String get outstandingStudentsCount => 'Outstanding Students';

  @override
  String get totalOutstandingAmount => 'Total Outstanding';

  @override
  String get filterByGroup => 'Filter by Group';

  @override
  String get noOutstandingPaymentsSuccess =>
      'No outstanding payments for this month!';

  @override
  String get allStudentsPaidMessage =>
      'All students have paid their dues in full';

  @override
  String paidAmountSuffix(Object amount) {
    return 'Paid: $amount';
  }

  @override
  String get remind => 'Remind';

  @override
  String get receive => 'Receive';

  @override
  String get manageExpensesTitle => 'Manage Expenses';

  @override
  String get expenseRecordedSuccessfully => 'Expense recorded successfully ✓';

  @override
  String get deleteExpenseTitle => 'Delete Expense';

  @override
  String get deleteExpenseConfirmMessage =>
      'Do you want to delete this expense?';

  @override
  String get totalExpensesAmount => 'Total Expenses';

  @override
  String get transactionsCount => 'Transactions Count';

  @override
  String get allCategories => 'All Categories';

  @override
  String get noExpensesRecorded => 'No expenses recorded';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get recordNewExpense => 'Record New Expense';

  @override
  String get titleRequired => 'Title *';

  @override
  String get forMonth => 'For Month';

  @override
  String get recurringMonthlyExpense => 'Recurring monthly expense';

  @override
  String get saveExpenseButton => 'Save Expense';

  @override
  String get method_cash => 'Cash';

  @override
  String get method_bankTransfer => 'Bank Transfer';

  @override
  String get method_vodafoneCash => 'Vodafone Cash';

  @override
  String get category_rent => 'Rent';

  @override
  String get category_salaries => 'Salaries';

  @override
  String get category_supplies => 'Supplies';

  @override
  String get category_utilities => 'Utilities';

  @override
  String get category_maintenance => 'Maintenance';

  @override
  String get category_marketing => 'Marketing';

  @override
  String get currency_egp => 'EGP';

  @override
  String get monthLabel => 'Month';

  @override
  String outstandingPaymentWhatsappTemplate(
    Object balance,
    Object currency,
    Object month,
    Object name,
  ) {
    return 'Dear parent of $name,\nPlease pay the outstanding balance of $balance $currency for the month of $month.\nThank you for your cooperation.';
  }

  @override
  String outstandingEntrySubtitle(Object group, Object paid, Object required) {
    return '$group · Required: $required · Paid: $paid';
  }

  @override
  String get saveExpense => 'Save Expense';

  @override
  String questionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Questions',
      one: '1 Question',
    );
    return '$_temp0';
  }

  @override
  String resultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Results',
      one: '1 Result',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'Publish';

  @override
  String get close => 'Close';

  @override
  String get quizzesTitle => 'Quizzes';

  @override
  String get newQuiz => 'New Quiz';

  @override
  String get averageResults => 'Average Results';

  @override
  String get totalQuizzes => 'Total Quizzes';

  @override
  String get createFirstQuizMessage =>
      'Create your first quiz to start tracking students progress.';

  @override
  String get activeStatus => 'Active';

  @override
  String get draftStatus => 'Draft';

  @override
  String get closedStatus => 'Closed';

  @override
  String get deleteQuizTitle => 'Delete Quiz';

  @override
  String get deleteQuizConfirm =>
      'Are you sure you want to delete this quiz? All related results will be lost.';

  @override
  String get honorBoardTitle => 'Honor Board';

  @override
  String get createQuiz => 'Create Quiz';

  @override
  String get quizTitle => 'Quiz Title *';

  @override
  String get targetGroupLabel => 'Target Group *';

  @override
  String get examDateLabel => 'Exam Date';

  @override
  String get durationLabel => 'Duration (minutes)';

  @override
  String questionsCountHeader(int count) {
    return 'Questions ($count)';
  }

  @override
  String get mcqQuestion => 'Multiple Choice Question';

  @override
  String get trueFalseQuestion => 'True/False Question';

  @override
  String get marksLabel => 'Marks';

  @override
  String get questionHint => 'Write question text here...';

  @override
  String get optionsLabel => 'Options (Mark correct answer ✓)';

  @override
  String optionHint(int number) {
    return 'Option $number';
  }

  @override
  String get tooltipMcq => 'MCQ Question';

  @override
  String get tooltipTrueFalse => 'True/False';

  @override
  String get completeBasicInfo => 'Please complete basic information';

  @override
  String get completeAllQuestions =>
      'Please complete all questions and correct answers';

  @override
  String get quizSavedSuccess => 'Quiz saved successfully ✓';

  @override
  String saveError(String error) {
    return 'Error while saving: $error';
  }

  @override
  String get quizResults => 'Quiz Results';

  @override
  String get noResultsYet => 'No results for this test yet';

  @override
  String get resultsWillShowHere =>
      'Results will be displayed here as students submit their solutions';

  @override
  String get searchByStudent => 'Search by student name...';

  @override
  String get submittedInfo => 'Submitted';

  @override
  String get avgScore => 'Average Score';

  @override
  String get highestScore => 'Highest Score';

  @override
  String submissionDate(String date) {
    return 'Submission Date: $date';
  }

  @override
  String get shareWithParent => 'Send to Parent';

  @override
  String get noPhoneRegistered => 'No phone number registered';

  @override
  String whatsappQuizResultMessage(
    String studentName,
    String quizTitle,
    String score,
    int totalMarks,
    String percentage,
  ) {
    return 'We inform you of the result of student $studentName in the quiz \"$quizTitle\":\nScore: $score out of $totalMarks\nPercentage: $percentage%\nThank you for your follow-up.';
  }

  @override
  String get groupLabel => 'Group';

  @override
  String get noSufficientData => 'No sufficient data';

  @override
  String get pointsLabel => 'Points';

  @override
  String get loadingData => 'Loading...';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get home => 'Home';

  @override
  String get myAttendance => 'My Attendance';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get noAttendanceFound => 'No attendance records found yet';

  @override
  String get attendanceWillShowHere =>
      'Your attendance history will appear here once recorded.';

  @override
  String get myGrades => 'My Grades';

  @override
  String get myGradesAndResults => 'My Grades & Results';

  @override
  String scoreOutOf(String score, int max) {
    return 'Score: $score out of $max';
  }

  @override
  String get gradesWillShowHere =>
      'Your quiz results will appear here once recorded.';

  @override
  String get lastScore => 'Last Score';

  @override
  String get overallPerformance => 'Overall Performance';

  @override
  String get exceptionalPerformance =>
      'Exceptional performance! You are among the top. 🌟';

  @override
  String get veryGoodPerformance => 'Very good performance, keep it up. 👍';

  @override
  String get goodPerformance => 'Acceptable performance, needs more effort. 📚';

  @override
  String get notebooksStore => 'Notebooks Store';

  @override
  String get store => 'Store';

  @override
  String get whatsappOpenError =>
      'Failed to open WhatsApp. Please ensure it is installed.';

  @override
  String get storeIsEmpty => 'Store is currently empty';

  @override
  String get noItemsAvailable =>
      'No notebooks or books are available for order right now.';

  @override
  String get teacherPhoneUnavailable =>
      'Sorry, teacher\'s phone number is not available right now.';

  @override
  String whatsappStoreOrderMessage(
    String itemTitle,
    String itemCategory,
    double itemPrice,
    String studentName,
  ) {
    return 'Hello, I would like to order: $itemTitle\nCategory: $itemCategory\nPrice: $itemPrice\nName: $studentName';
  }

  @override
  String get currencyEgp => 'EGP';

  @override
  String get orderNow => 'Order Now';

  @override
  String get currentGroup => 'Current Group';

  @override
  String keepGoing(String name) {
    return 'Keep going, $name! 🚀';
  }

  @override
  String get announcementsAndAlerts => 'Announcements & Alerts';

  @override
  String get privateMessage => 'Private Message';

  @override
  String get noNewNotifications =>
      'No new notifications for now. Have a nice day!';

  @override
  String errorLoadingAnnouncements(String error) {
    return 'Error loading announcements: $error';
  }

  @override
  String get dayLabel => 'Day';

  @override
  String get latestAnnouncements => 'Latest Announcements';

  @override
  String get noAnnouncements => 'No announcements for now.';

  @override
  String performanceFeedback(String status) {
    return '$status';
  }

  @override
  String get performanceExceptional =>
      'Exceptional performance! You are among the top. 🌟';

  @override
  String get performanceDoingGreat => 'Very good performance, keep it up. 👍';

  @override
  String get performanceAcceptable =>
      'Acceptable performance, needs more effort. 📚';

  @override
  String get performanceNeedsAttention =>
      'Your level needs more care and attention. Don\'t give up! 💪';

  @override
  String get method_other => 'Other';

  @override
  String get deleteExpenseConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get titleLabel => 'Title';

  @override
  String get amountLabel => 'Amount';

  @override
  String get categoryLabel => 'Category';

  @override
  String get notesLabel => 'Notes';

  @override
  String get recurringExpenseLabel => 'Recurring Expense';

  @override
  String get freeBadge => 'Free';

  @override
  String get paymentStatusCompleted => 'Payment Completed';

  @override
  String get delete => 'Delete';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get logoutConfirmationMessage =>
      'Are you sure you want to logout from the student portal?';

  @override
  String get expenseRecordedSuccess => 'Expense recorded successfully';

  @override
  String get category_other => 'Other';

  @override
  String get suggestionAttendanceTitle => 'Attendance Alert';

  @override
  String suggestionAttendanceMessage(int count) {
    return 'There are $count absences today. Do you want to send WhatsApp alerts?';
  }

  @override
  String get welcome => 'Welcome!';

  @override
  String welcomeMessage(int count) {
    return 'You have $count active students in your groups now.';
  }

  @override
  String get sendInstantMessages => 'Send Instant Messages';

  @override
  String get qrScanner => 'QR Scanner';

  @override
  String get attendanceMode => 'Record Attendance';

  @override
  String get paymentMode => 'Record Payment';

  @override
  String get scanStudentQrHint =>
      'Scan student QR code to record attendance or payment';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get exams => 'Exams';

  @override
  String get pendingExams => 'Pending';

  @override
  String get completedExams => 'Completed';

  @override
  String get smartTools => 'Smart Tools';

  @override
  String get studentQrCode => 'QR Code';

  @override
  String get submitExam => 'Submit Exam';

  @override
  String get examResult => 'Exam Result';

  @override
  String get timeLeft => 'Time Left';

  @override
  String manualGradingNote(int count) {
    return '$count question(s) need manual grading by teacher';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get submitting => 'Submitting...';

  @override
  String get exitExam => 'Exit Exam?';

  @override
  String get exitExamWarning =>
      'All your answers will be lost if you leave now. Are you sure?';

  @override
  String get backToExams => 'Back to Exams';

  @override
  String get startQuiz => 'Start Exam';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get showQrHint =>
      'Show this code to your teacher to record attendance or payment';

  @override
  String get screenshotHint => 'You can take a screenshot to keep the code';

  @override
  String get noScansYet => 'No scans yet';

  @override
  String get noScansYetHint =>
      'Scan records will appear here after using the QR scanner.';

  @override
  String get quickActionAttendance => 'Record Attendance';

  @override
  String get quickActionPayment => 'Add Payment';

  @override
  String get quickActionAddStudent => 'Add Student';

  @override
  String get quickActionPortalCode => 'Portal Code';

  @override
  String get customizeQuickActions => 'Customize Quick Actions';

  @override
  String get quickActionsHint => 'Enable actions and drag to reorder';

  @override
  String get selectStudentForPortalCode =>
      'Select student to generate portal code';

  @override
  String get searchStudents => 'Search for a student...';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get done => 'Done';
}
