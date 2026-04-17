/// نموذج الاختبار (Quiz)
class QuizModel {
  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final String subject;
  final List<QuizQuestion> questions;
  final int timeLimitMinutes; // 0 = بلا حد
  final String status; // draft | published | closed
  final String publishDate;
  final String notes;
  final String createdDate;
  final String updatedDate;

  const QuizModel({
    required this.id,
    required this.title,
    this.groupId = '',
    this.groupName = '',
    this.subject = '',
    this.questions = const [],
    this.timeLimitMinutes = 0,
    this.status = 'draft',
    this.publishDate = '',
    this.notes = '',
    required this.createdDate,
    required this.updatedDate,
  });

  int get totalMarks => questions.fold(0, (sum, q) => sum + q.marks);

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      groupId: map['group_id'] as String? ?? '',
      groupName: map['group_name'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      timeLimitMinutes: map['time_limit_minutes'] as int? ?? 0,
      status: map['status'] as String? ?? 'draft',
      publishDate: map['publish_date'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'group_id': groupId,
      'group_name': groupName,
      'subject': subject,
      'questions': questions.map((q) => q.toMap()).toList(),
      'time_limit_minutes': timeLimitMinutes,
      'status': status,
      'publish_date': publishDate,
      'notes': notes,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}

/// سؤال داخل الاختبار
class QuizQuestion {
  final String id;
  final String text;
  final String type; // mcq | truefalse | text
  final List<String> options; // للـ MCQ
  final String correctAnswer;
  final int marks;

  const QuizQuestion({
    required this.id,
    required this.text,
    this.type = 'mcq',
    this.options = const [],
    this.correctAnswer = '',
    this.marks = 1,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      type: map['type'] as String? ?? 'mcq',
      options: (map['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctAnswer: map['correct_answer'] as String? ?? '',
      marks: map['marks'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'correct_answer': correctAnswer,
      'marks': marks,
    };
  }
}

/// نتيجة اختبار طالب (QuizResult)
class QuizResultModel {
  final String id;
  final String quizId;
  final String quizTitle;
  final String studentId;
  final String studentName;
  final String groupId;
  final Map<String, String> answers; // questionId → answer
  final double score;
  final int totalMarks;
  final String submittedAt;
  final String createdDate;
  final String updatedDate;

  const QuizResultModel({
    required this.id,
    required this.quizId,
    this.quizTitle = '',
    required this.studentId,
    this.studentName = '',
    this.groupId = '',
    this.answers = const {},
    required this.score,
    required this.totalMarks,
    this.submittedAt = '',
    required this.createdDate,
    required this.updatedDate,
  });

  double get percentage => totalMarks > 0 ? (score / totalMarks) * 100 : 0;

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      id: map['id'] as String,
      quizId: map['quiz_id'] as String? ?? '',
      quizTitle: map['quiz_title'] as String? ?? '',
      studentId: map['student_id'] as String? ?? '',
      studentName: map['student_name'] as String? ?? '',
      groupId: map['group_id'] as String? ?? '',
      answers: Map<String, String>.from(map['answers'] as Map? ?? {}),
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      totalMarks: map['total_marks'] as int? ?? 0,
      submittedAt: map['submitted_at'] as String? ?? '',
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'student_id': studentId,
      'student_name': studentName,
      'group_id': groupId,
      'answers': answers,
      'score': score,
      'total_marks': totalMarks,
      'submitted_at': submittedAt,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}
