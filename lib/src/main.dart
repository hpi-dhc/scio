import 'package:scio/src/comprehension_measurement_widget.dart';
import 'package:scio/src/config.dart';
import 'package:scio/src/models/comprehension_measurement_model.dart';
import 'package:scio/src/models/surveydata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> measureComprehension({
  required BuildContext context,
  required int surveyId,
  required String introText,
  required String surveyButtonText,
  Map<String, List<int>> questionContext = const {},
  int surveyLength = 4,
  int? feedbackId,
  String feedbackButtonText = 'Close',
  bool enablePersistence = true,
  required SupabaseConfig supabaseConfig,
}) async {
  if (enablePersistence) {
    await Hive.initFlutter();
    await initSurveyData();
  }

  if (SurveyData.instance.completedSurveys.contains(surveyId) ||
      SurveyData.instance.optOut) {
    return;
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: ChangeNotifierProvider(
          create: (context) => ComprehensionMeasurementModel(
            surveyId: surveyId,
            feedbackId: feedbackId,
            questionContext: questionContext,
            surveyLength: surveyLength,
            supabaseConfig: supabaseConfig,
            enablePersistence: enablePersistence,
          ),
          child: ComprehensionMeasurementWidget(
            introText: introText,
            surveyButtonText: surveyButtonText,
            feedbackButtonText: feedbackButtonText,
          ),
        ),
      );
    },
  );
}
