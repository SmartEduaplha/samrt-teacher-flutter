import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../quizzes/data/models/quiz_model.dart';

/// يكتشف اتجاه النص تلقائياً (عربي = RTL، إنجليزي = LTR)
TextDirection _detectDirection(String text) {
  if (text.isEmpty) return TextDirection.rtl;
  // نبحث عن أول حرف فعلي (ليس رقم أو رمز)
  for (final char in text.runes) {
    // Arabic & Hebrew range
    if ((char >= 0x0600 && char <= 0x06FF) || // Arabic
        (char >= 0x0750 && char <= 0x077F) || // Arabic Supplement
        (char >= 0xFB50 && char <= 0xFDFF) || // Arabic Presentation Forms-A
        (char >= 0xFE70 && char <= 0xFEFF) || // Arabic Presentation Forms-B
        (char >= 0x0590 && char <= 0x05FF)) {
      // Hebrew
      return TextDirection.rtl;
    }
    // Latin range
    if ((char >= 0x0041 && char <= 0x005A) || // A-Z
        (char >= 0x0061 && char <= 0x007A)) {
      // a-z
      return TextDirection.ltr;
    }
  }
  return TextDirection.rtl; // افتراضي: عربي
}

class StudentExamTakingScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const StudentExamTakingScreen({super.key, required this.quiz});

  @override
  ConsumerState<StudentExamTakingScreen> createState() =>
      _StudentExamTakingScreenState();
}

class _StudentExamTakingScreenState
    extends ConsumerState<StudentExamTakingScreen> {
  late final Map<String, String> _answers; // questionId → answer
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  // Timer
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _answers = {};
    _pageController = PageController();

    // بدء المؤقت إذا كان هناك حد زمني
    if (widget.quiz.timeLimitMinutes > 0) {
      _remainingSeconds = widget.quiz.timeLimitMinutes * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _autoSubmit();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _autoSubmit() {
    if (!_isSubmitted) {
      _submitExam(isAutoSubmit: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return Colors.red;
    if (_remainingSeconds <= 300) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final questions = widget.quiz.questions;

    return PopScope(
      canPop: _isSubmitted,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSubmitted) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          automaticallyImplyLeading: false,
          actions: [
            // Timer
            if (widget.quiz.timeLimitMinutes > 0)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _timerColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _timerColor.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 18, color: _timerColor),
                    const SizedBox(width: 4),
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _timerColor,
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: _isSubmitted
            ? _buildSubmittedView(colorScheme)
            : Column(
                children: [
                  // ── Progress Indicator ──
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'السؤال ${_currentPage + 1} من ${questions.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withAlpha(160),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_answers.length}/${questions.length} تم الإجابة',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / questions.length,
                    backgroundColor: colorScheme.outline.withAlpha(40),
                    color: colorScheme.primary,
                    minHeight: 4,
                  ),

                  // ── Questions PageView ──
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (p) =>
                          setState(() => _currentPage = p),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(
                          questions[index],
                          index,
                          colorScheme,
                        );
                      },
                    ),
                  ),

                  // ── Navigation Buttons ──
                  _buildBottomBar(questions.length, colorScheme),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestionCard(
    QuizQuestion question,
    int index,
    ColorScheme colorScheme,
  ) {
    final questionDir = _detectDirection(question.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Number + Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Directionality(
                  textDirection: questionDir,
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Answer Input (depends on question type)
              if (question.type == 'mcq')
                _buildMcqOptions(question, colorScheme)
              else if (question.type == 'truefalse')
                _buildTrueFalseOptions(question, colorScheme)
              else
                _buildTextAnswer(question, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMcqOptions(QuizQuestion question, ColorScheme colorScheme) {
    final selectedAnswer = _answers[question.id];

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final optionText = entry.value;
        final isSelected = selectedAnswer == optionText;
        final optionDir = _detectDirection(optionText);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? colorScheme.primary.withAlpha(15)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(80),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() => _answers[question.id] = optionText);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withAlpha(100),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Directionality(
                        textDirection: optionDir,
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(
      QuizQuestion question, ColorScheme colorScheme) {
    final selectedAnswer = _answers[question.id];

    return Row(
      children: [
        Expanded(
          child: _tfOption(
            label: 'صحيح',
            value: 'true',
            isSelected: selectedAnswer == 'true',
            color: Colors.green,
            icon: Icons.check_circle_rounded,
            colorScheme: colorScheme,
            onTap: () =>
                setState(() => _answers[question.id] = 'true'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tfOption(
            label: 'خطأ',
            value: 'false',
            isSelected: selectedAnswer == 'false',
            color: Colors.red,
            icon: Icons.cancel_rounded,
            colorScheme: colorScheme,
            onTap: () =>
                setState(() => _answers[question.id] = 'false'),
          ),
        ),
      ],
    );
  }

  Widget _tfOption({
    required String label,
    required String value,
    required bool isSelected,
    required Color color,
    required IconData icon,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? color.withAlpha(20) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? color : colorScheme.outline.withAlpha(80),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextAnswer(QuizQuestion question, ColorScheme colorScheme) {
    final currentAnswer = _answers[question.id] ?? '';
    final textDir = _detectDirection(currentAnswer);

    return TextFormField(
      initialValue: currentAnswer,
      maxLines: 5,
      textDirection: textDir,
      textAlign: textDir == TextDirection.rtl
          ? TextAlign.right
          : TextAlign.left,
      onChanged: (val) {
        _answers[question.id] = val;
        // إعادة البناء لتحديث الاتجاه ديناميكياً
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'اكتب إجابتك هنا...',
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
    );
  }

  Widget _buildBottomBar(int totalQuestions, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withAlpha(40)),
        ),
      ),
      child: Row(
        children: [
          // Previous
          if (_currentPage > 0)
            OutlinedButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(context.l10n.previous),
            )
          else
            const SizedBox(width: 100),

          const Spacer(),

          // Next or Submit
          if (_currentPage < totalQuestions - 1)
            FilledButton.icon(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(context.l10n.next),
            )
          else
            FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _submitExam(),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(_isSubmitting ? context.l10n.submitting : context.l10n.submitExam),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
            ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.exitExam),
        content: Text(context.l10n.exitExamWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('البقاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExam({bool isAutoSubmit = false}) async {
    if (_isSubmitting || _isSubmitted) return;

    // تأكيد التسليم (إلا إذا كان تسليم تلقائي)
    if (!isAutoSubmit && mounted) {
      final unanswered =
          widget.quiz.questions.length - _answers.length;
      if (unanswered > 0) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.submitExam),
            content: Text(
                'لديك $unanswered سؤال بدون إجابة. هل تريد التسليم الآن؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('مراجعة'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('تسليم'),
              ),
            ],
          ),
        );
        if (confirm != true) return;
      }
    }

    setState(() => _isSubmitting = true);
    _timer?.cancel();

    try {
      final student = ref.read(currentStudentProvider);
      if (student == null) return;

      // حساب الدرجة تلقائياً (للـ MCQ و True/False)
      double score = 0;
      for (final q in widget.quiz.questions) {
        final studentAnswer = _answers[q.id];
        if (studentAnswer == null) continue;

        if (q.type == 'mcq' || q.type == 'truefalse') {
          if (studentAnswer.trim().toLowerCase() ==
              q.correctAnswer.trim().toLowerCase()) {
            score += q.marks;
          }
        }
        // الأسئلة المكتوبة تحتاج تصحيح يدوي من المعلم
      }

      await ref.read(quizResultDbProvider).create({
        'quiz_id': widget.quiz.id,
        'quiz_title': widget.quiz.title,
        'student_id': student.id,
        'student_name': student.fullName,
        'group_id': student.groupId,
        'answers': _answers,
        'score': score,
        'total_marks': widget.quiz.totalMarks,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        _isSubmitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSubmittedView(ColorScheme colorScheme) {
    // حساب النتيجة النهائية
    double score = 0;
    int manualGraded = 0;

    for (final q in widget.quiz.questions) {
      final answer = _answers[q.id];
      if (q.type == 'mcq' || q.type == 'truefalse') {
        if (answer != null &&
            answer.trim().toLowerCase() ==
                q.correctAnswer.trim().toLowerCase()) {
          score += q.marks;
        }
      } else {
        manualGraded++;
      }
    }

    final percentage = widget.quiz.totalMarks > 0
        ? (score / widget.quiz.totalMarks) * 100
        : 0.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'تم تسليم الاختبار بنجاح! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.quiz.title,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withAlpha(160),
              ),
            ),

            const SizedBox(height: 32),

            // Score Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 70
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(0)} / ${widget.quiz.totalMarks}',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurface.withAlpha(130),
                      ),
                    ),
                    if (manualGraded > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.l10n.manualGradingNote(manualGraded),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(context.l10n.backToExams),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
