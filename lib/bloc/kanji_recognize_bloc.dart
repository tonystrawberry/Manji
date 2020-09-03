import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import '../ui/kanji_recognize_page/resource/brain.dart';

class KanjiRecognizeBloc {
  final _predictedKanjiFetcher = PublishSubject<List<Kanji>>();
  final brain = AppBrain();

  Stream<List<Kanji>> get predictedKanji => _predictedKanjiFetcher.stream;

  KanjiRecognizeBloc() {
    brain.loadModel();
  }

  void predict(List<Offset> points, double canvasSize) {
    brain.processCanvasPoints(points, canvasSize).then((predicts) {
      var temp = <Kanji>[];
      for (var p in predicts) {
        if (kanjiBloc.allKanjisMap.containsKey(p['label'])) {
          temp.add(kanjiBloc.allKanjisMap[p['label']]);
        }
      }
      _predictedKanjiFetcher.sink.add(temp);
    });
  }

  dispose() {
    _predictedKanjiFetcher.close();
  }
}

final kanjiRecogBloc = KanjiRecognizeBloc();