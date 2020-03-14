import 'package:flutter/material.dart';

import 'package:kanji_dictionary/ui/kanji_detail_page.dart';
import 'package:kanji_dictionary/models/kanji.dart';
import 'grade_chip.dart';

typedef void StringCallback(String str);

class KanjiListView extends StatefulWidget{
  final List<Kanji> kanjis;
  final String fallBackFont;
  final StringCallback onLongPressed;
  final bool canRemove;
  final ScrollController scrollController;


  KanjiListView({this.kanjis, this.fallBackFont, this.onLongPressed, this.canRemove = false, this.scrollController}) : assert(kanjis != null);
  @override
  State<StatefulWidget> createState() => _KanjiListViewState();
}

class _KanjiListViewState extends State<KanjiListView> {
  List<Kanji> kanjis;
  String fallBackFont;
  StringCallback onLongPressed;

  @override
  void initState() {
    kanjis = widget.kanjis;
    fallBackFont = widget.fallBackFont;
    onLongPressed = widget.onLongPressed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      controller: widget.scrollController,
        itemBuilder: (_, index) {
          return ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanjis[index])));
            },
            onLongPress: (){
              if(onLongPressed != null){
                onLongPressed(kanjis[index].kanji);
              }
            },
            leading: Container(
              width: 28,
              height: 28,
              child: Center(
                child: Hero(
                  tag: kanjis[index].kanji,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(kanjis[index].kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: fallBackFont ?? 'kazei')),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    kanjis[index].jlpt != 0
                        ? Padding(
                            padding: EdgeInsets.all(4),
                            child: Container(
                              child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    'N${kanjis[index].jlpt}',
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
                    kanjis[index].grade != 0
                        ? GradeChip(grade: kanjis[index].grade,)
                        : Container(),
                  ],
                ),
                Divider(height: 0),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    for (var kunyomi in kanjis[index].kunyomi)
                      Padding(
                          padding: EdgeInsets.all(4),
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  kunyomi,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                              //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                  ),
                            ),
                          )),
                    for (var onyomi in kanjis[index].onyomi)
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                onyomi,
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
                  ],
                ),
              ],
            ),
            subtitle: Text(
              kanjis[index].meaning,
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: kanjis.length);
  }
}