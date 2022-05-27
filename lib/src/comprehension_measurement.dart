import 'package:comprehension_measurement/src/models/comprehension_measurement.dart';
import 'package:comprehension_measurement/src/models/question.dart';
import 'package:comprehension_measurement/src/types/multi_choice.dart';
import 'package:comprehension_measurement/src/types/single_choice.dart';
import 'package:comprehension_measurement/src/types/text_answer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComprehensionMeasurementWidget extends StatelessWidget {
  const ComprehensionMeasurementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final PageController controller = PageController();
    return Container(
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Consumer<ComprehensionMeasurementModel>(
          builder: (context, value, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.emoji_emotions,
                        color: theme.primaryColor,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    children: value.survey!.questions.map(
                      (question) {
                        Widget questionWidget;

                        switch (question.type) {
                          case QuestionType.single_choice:
                            questionWidget = SingleChoiceWidget(
                              questionId: question.id,
                              model: value,
                            );
                            break;
                          case QuestionType.multiple_choice:
                            questionWidget = MultipleChoiceWidget(
                              questionId: question.id,
                              model: value,
                            );
                            break;
                          case QuestionType.text_answer:
                            questionWidget = TextAnswerWidget(
                              questionId: question.id,
                              model: value,
                            );
                            break;
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                                thickness: 2,
                                height: 2,
                                color: theme.backgroundColor),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: Text(
                                question.title,
                              ),
                            ),
                            Divider(thickness: 2, color: theme.backgroundColor),
                            questionWidget,
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  switch (question.type) {
                                    case QuestionType.single_choice:
                                      value.saveSingleChoiceAnswer(question.id);
                                      break;
                                    case QuestionType.multiple_choice:
                                      value.saveMultipleChoiceAnswer(
                                          question.id);
                                      break;
                                    case QuestionType.text_answer:
                                      value.saveTextAnswer(question.id);
                                      break;
                                  }
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text('Send!'),
                              ),
                            )
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
