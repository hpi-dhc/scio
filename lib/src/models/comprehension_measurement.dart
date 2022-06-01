import 'package:comprehension_measurement/src/constants.dart';
import 'package:comprehension_measurement/src/models/survey.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

class ComprehensionMeasurementModel extends ChangeNotifier {
  ComprehensionMeasurementModel({
    Key? key,
    required this.surveyId,
    this.feedbackId,
  });

  Survey? survey;
  final int surveyId;
  final int? feedbackId;

  Map<int, int> singleChoiceAnswers = {};
  Map<int, Set<int>> multipleChoiceAnswers = {};
  Map<int, String> textAnswers = {};

  var client = SupabaseClient(
    supabaseUrl,
    supabaseKey,
  );

  Future<void> loadSurvey() async {
    await _loadQuestions(surveyId);
  }

  Future<void> loadFeedback() async {
    await _loadQuestions(feedbackId);
  }

  Future<void> _loadQuestions(int? id) async {
    // syntax is equivalent to https://postgrest.org/en/stable/api.html

    if (id == null) {
      return;
    }

    final response = await client
        .from('surveys')
        .select('*,questions(*),questions(*,answers(*))')
        .eq('id', id)
        .single()
        .execute();

    survey = Survey.fromJson(response.data);

    notifyListeners();
  }

  void changeSingleChoiceAnswer(int questionId, int? answerId) async {
    if (answerId == null) {
      return;
    }

    singleChoiceAnswers[questionId] = answerId;

    notifyListeners();
  }

  void changeMultipleChoiceAnswer(int questionId, int? answerId) async {
    if (answerId == null) {
      return;
    }

    if (multipleChoiceAnswers[questionId]!.contains(answerId)) {
      multipleChoiceAnswers[questionId]!.remove(answerId);
    } else {
      multipleChoiceAnswers[questionId]!.add(answerId);
    }

    notifyListeners();
  }

  void changeTextAnswer(int questionId, String? answerText) async {
    if (answerText == null) {
      return;
    }

    textAnswers[questionId] = answerText;

    notifyListeners();
  }

  Future<bool> saveSingleChoiceAnswer(questionId) async {
    final answerId = singleChoiceAnswers[questionId];

    if (answerId == null) {
      return false;
    }

    await client.rpc(
      'select_answer',
      params: {'row_id': answerId},
    ).execute();

    return true;
  }

  Future<bool> saveMultipleChoiceAnswer(int questionId) async {
    final answerIds = multipleChoiceAnswers[questionId];

    if (answerIds == null || answerIds.isEmpty) {
      return false;
    }

    for (int answerId in answerIds) {
      await client.rpc(
        'select_answer',
        params: {'row_id': answerId},
      ).execute();
    }
    return true;
  }

  Future<bool> saveTextAnswer(int questionId) async {
    final answerText = textAnswers[questionId];

    if (answerText == null || answerText == '') {
      return false;
    }
    await client.from('text_answers').insert([
      {
        'answer_text': answerText,
        'question_id': questionId,
      },
    ]).execute();

    return true;
  }
}
