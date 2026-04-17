import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../quizzes/data/models/quiz_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class QuizBuilderScreen extends ConsumerStatefulWidget {
  const QuizBuilderScreen({super.key});

  @override
  ConsumerState<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends ConsumerState<QuizBuilderScreen> {
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  String? _selectedGroupId;
  String? _selectedGroupName;
  late String _examDate;
  bool _saving = false;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: const Uuid().v4(),
      text: '',
      type: 'mcq',
      options: ['', '', '', ''],
      correctAnswer: '',
      marks: 1,
    )
  ];

  @override
  void initState() {
    super.initState();
    _examDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addQuestion(String type) {
    setState(() {
      _questions.add(QuizQuestion(
        id: const Uuid().v4(),
        text: '',
        type: type,
        options: type == 'mcq' ? ['', '', '', ''] : ['صح', 'خطأ'],
        correctAnswer: '',
        marks: 1,
      ));
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() => _questions.removeAt(index));
    }
  }

  void _updateQuestion(int index, QuizQuestion updated) {
    setState(() => _questions[index] = updated);
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty || _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.completeBasicInfo)),
      );
      return;
    }

    if (_questions.any((q) => q.text.isEmpty || q.correctAnswer.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.completeAllQuestions)),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final quizDb = ref.read(quizDbProvider);
      await quizDb.create({
        'title': _titleController.text,
        'group_id': _selectedGroupId,
        'group_name': _selectedGroupName,
        'time_limit_minutes': int.tryParse(_timeLimitController.text) ?? 30,
        'publish_date': _examDate,
        'notes': _notesController.text,
        'status': 'published', // Publish immediately by default
        'questions': _questions.map((q) => q.toMap()).toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.quizSavedSuccess)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.saveError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.createQuiz,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : TextButton(
                  onPressed: _handleSave,
                  child: Text(context.l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Basic Info ───────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration:
                          _inputDecoration(context.l10n.quizTitle, Icons.title_rounded, colorScheme),
                    ),
                    const SizedBox(height: 12),
                    groupsAsync.when(
                      data: (groups) => DropdownButtonFormField<String>(
                        decoration: _inputDecoration(
                            context.l10n.targetGroupLabel, Icons.groups_rounded, colorScheme),
                        items: groups
                            .map((g) => DropdownMenuItem(
                                value: g.id, child: Text(g.name)))
                            .toList(),
                        onChanged: (val) {
                          final g = groups.firstWhere((x) => x.id == val);
                          setState(() {
                            _selectedGroupId = val;
                            _selectedGroupName = g.name;
                          });
                        },
                      ),
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                locale: const Locale('ar'),
                              );
                              if (picked != null) {
                                setState(() => _examDate =
                                    DateFormat('yyyy-MM-dd').format(picked));
                              }
                            },
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                  context.l10n.examDateLabel, Icons.event_rounded, colorScheme),
                              child: Text(_examDate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _timeLimitController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                                context.l10n.durationLabel, Icons.timer_outlined, colorScheme),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Questions Header ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.questionsCountHeader(_questions.length),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => _addQuestion('mcq'),
                      icon: const Icon(Icons.playlist_add_rounded, size: 20),
                      tooltip: context.l10n.tooltipMcq,
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      onPressed: () => _addQuestion('truefalse'),
                      icon: const Icon(Icons.check_box_outlined, size: 20),
                      tooltip: context.l10n.tooltipTrueFalse,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Questions List ───────────────────────────────────────
            ...List.generate(_questions.length, (idx) {
              return _QuestionEditor(
                question: _questions[idx],
                index: idx,
                onUpdate: (q) => _updateQuestion(idx, q),
                onDelete: () => _removeQuestion(idx),
                colorScheme: colorScheme,
              );
            }),

            const SizedBox(height: 80), // Space for floating button if any
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, IconData icon, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(50))),
    );
  }
}

class _QuestionEditor extends StatelessWidget {
  final QuizQuestion question;
  final int index;
  final Function(QuizQuestion) onUpdate;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;

  const _QuestionEditor({
    required this.question,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withAlpha(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colorScheme.primary,
                  child: Text('${index + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Text(
                  question.type == 'mcq' ? context.l10n.mcqQuestion : context.l10n.trueFalseQuestion,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const Spacer(),
                SizedBox(
                  width: 60,
                  height: 36,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: context.l10n.marksLabel,
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) => onUpdate(
                        QuizQuestion(
                          id: question.id,
                          text: question.text,
                          type: question.type,
                          options: question.options,
                          correctAnswer: question.correctAnswer,
                          marks: int.tryParse(val) ?? 1,
                        )),
                    controller: TextEditingController(text: question.marks.toString()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.l10n.questionHint,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => onUpdate(
                  QuizQuestion(
                    id: question.id,
                    text: val,
                    type: question.type,
                    options: question.options,
                    correctAnswer: question.correctAnswer,
                    marks: question.marks,
                  )),
              controller: TextEditingController(text: question.text),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(context.l10n.optionsLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ...List.generate(question.options.length, (optIdx) {
              final optValue = question.options[optIdx];
              final isCorrect = question.correctAnswer == optValue && optValue.isNotEmpty;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: question.type == 'mcq'
                          ? TextField(
                              decoration: InputDecoration(
                                hintText: context.l10n.optionHint(optIdx + 1),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onChanged: (val) {
                                final newOpts = List<String>.from(question.options);
                                newOpts[optIdx] = val;
                                onUpdate(QuizQuestion(
                                  id: question.id,
                                  text: question.text,
                                  type: question.type,
                                  options: newOpts,
                                  correctAnswer: isCorrect ? val : question.correctAnswer,
                                  marks: question.marks,
                                ));
                              },
                              controller: TextEditingController(text: optValue),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: colorScheme.outline.withAlpha(30))
                              ),
                              child: Text(optValue),
                            ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_off_rounded,
                        color: isCorrect ? Colors.green : colorScheme.outline,
                      ),
                      onPressed: optValue.isEmpty
                          ? null
                          : () => onUpdate(QuizQuestion(
                                id: question.id,
                                text: question.text,
                                type: question.type,
                                options: question.options,
                                correctAnswer: optValue,
                                marks: question.marks,
                              )),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
