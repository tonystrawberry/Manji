import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kanji_dictionary/bloc/incorrect_question_bloc.dart';

import 'package:kanji_dictionary/models/kanji_list.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/models/question.dart';
import 'package:kanji_dictionary/models/quiz.dart';
import 'package:kanji_dictionary/models/quiz_result.dart';
import '../components/chip_collections.dart';
import '../kanji_detail_page.dart';

class QuizDetailPage extends StatefulWidget {
  final KanjiList kanjiList;

  QuizDetailPage({this.kanjiList}) : assert(kanjiList != null && kanjiList.kanjiStrs.isNotEmpty);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final scrollController = ScrollController();
  bool showShadow = false;

  int currentIndex = 0;
  bool showResult = false;
  QuizResult quizResult;
  Quiz quiz;

  @override
  void initState() {
    super.initState();

    var kanjis = <Kanji>[];
    for (var kanjiString in widget.kanjiList.kanjiStrs) {
      kanjis.add(kanjiBloc.allKanjisMap[kanjiString]);
    }

    quiz = Quiz(targetedKanjis: kanjis);
    print(quiz.questions.first.choices);

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(elevation: showShadow?8:0),
        body: showResult ? buildResultView() : buildQuizView());
  }

  Widget buildResultView() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            Container(
              height: 220,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${quizResult.percentage.toStringAsFixed(1).replaceFirst('.0', '')}%",
                    style: TextStyle(color: Colors.white, fontSize: 96),
                  ),
                  Icon(getCharm(quizResult.percentage), color: Colors.white, size: 90)
                ],
              )),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(FontAwesomeIcons.timesCircle, color: Colors.white),
                ),
                Text("Incorrect: ${quizResult.totalIncorrect}", style: TextStyle(color: Colors.white)),
                Spacer(),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(FontAwesomeIcons.checkCircle, color: Colors.white),
                ),
                Text("Correct: ${quizResult.totalCorrect}", style: TextStyle(color: Colors.white)),
                SizedBox(width: 12)
              ],
            ),
            ...quizResult.incorrectQuestions.map((question) => buildIncorrectListTile(question)).toList()
          ],
        ));
  }

  Widget buildQuizView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Flexible(
            flex: 4,
            child: Container(
              child: Center(
                  child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(quiz.currentQuestion.targetedKanji.kanji, style: TextStyle(fontSize: 128, color: Colors.white, fontFamily: 'kazei')),
                      Text(quiz.currentQuestion.targetedKanji.kanji, style: TextStyle(fontSize: 128, color: Colors.white, fontFamily: 'ming')),
                    ],
                  ),
                  Text(
                    quiz.currentQuestion.targetedKanji.meaning,
                    style: TextStyle(fontSize: 18, color: Colors.white60),
                    textAlign: TextAlign.center,
                  )
                ],
              )),
            ),
          ),
          Flexible(
              flex: 6,
              child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  children: List.generate(quiz.currentQuestion.choices.length, (index) {
                    return Padding(
                        padding: EdgeInsets.all(12),
                        child: Material(
                          child: Ink(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (quiz.submitAnswer(index) == false) {
                                    showResult = true;
                                    quizResult = quiz.getQuizResult();
                                    iqBloc.addIncorrectQuestions(quizResult.incorrectQuestions);
                                  }
                                });
                              },
                              child: Container(
                                child: Center(
                                  child: Text(quiz.currentQuestion.choices[index], style: TextStyle(fontSize: 24)),
                                ),
                              ),
                            ),
                          ),
                        ));
                  })))
        ],
      ),
    );
  }

  Widget buildIncorrectListTile(Question question) {
    var kanji = question.targetedKanji;
    var wrongKana = question.choices[question.selected];
    var rightKana = question.rightAnswer;
    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
      },
      leading: Container(
        width: 28,
        height: 28,
        child: Center(
          child: Hero(
            tag: kanji,
            child: Material(
              color: Colors.transparent,
              child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'kazei')),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8),
          Wrap(
            children: <Widget>[
              kanji.jlpt != 0
                  ? Padding(
                      padding: EdgeInsets.all(4),
                      child: Container(
                        child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              'N${kanji.jlpt}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        decoration: BoxDecoration(
                          //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                              ),
                        ),
                      ),
                    )
                  : Container(),
              kanji.grade != 0
                  ? GradeChip(
                      grade: kanji.grade,
                    )
                  : Container(),
            ],
          ),
          Divider(),
          Row(children: <Widget>[
            Icon(FontAwesomeIcons.checkCircle, color: Colors.greenAccent),
            Spacer(),
            Text(rightKana, style: TextStyle(color: Colors.greenAccent))
          ]),
          Divider(),
          Row(children: <Widget>[
            Icon(FontAwesomeIcons.timesCircle, color: Colors.redAccent),
            Spacer(),
            Text(wrongKana, style: TextStyle(color: Colors.redAccent))
          ]),
          Divider(),
          Text(
            question.targetedKanji.meaning,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData getCharm(double percentage) {
    if (percentage == 100) {
      return FontAwesomeIcons.award;
    } else if (percentage >= 95) {
      return FontAwesomeIcons.badgeCheck;
    } else if (percentage >= 90) {
      return FontAwesomeIcons.certificate;
    } else if (percentage >= 80) {
      return FontAwesomeIcons.dragon;
    } else {
      return FontAwesomeIcons.bookReader;
    }
  }
}