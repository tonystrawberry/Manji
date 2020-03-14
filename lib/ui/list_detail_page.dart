import 'package:flutter/material.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/bloc//kanji_list_bloc.dart';
import 'package:kanji_dictionary/ui/kanji_detail_page.dart';


///This is the page that displays the list created by the user
class ListDetailPage extends StatefulWidget {
  final KanjiList kanjiList;

  ListDetailPage({this.kanjiList}) : assert(kanjiList != null);

  @override
  _ListDetailPageState createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final gridViewScrollController = ScrollController();
  final listViewScrollController = ScrollController();
  double elevation = 0;
  bool showGrid = false;
  bool sortByStrokes = false;

  @override
  void initState() {
    KanjiListBloc.instance.init();
    kanjiBloc.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
    super.initState();

    gridViewScrollController.addListener(() {
      if (this.mounted) {
        if (gridViewScrollController.offset <= 0) {
          setState(() {
            elevation = 0;
          });
        } else {
          setState(() {
            elevation = 8;
          });
        }
      }
    });

    listViewScrollController.addListener(() {
      if (this.mounted) {
        if (listViewScrollController.offset <= 0) {
          setState(() {
            elevation = 0;
          });
        } else {
          setState(() {
            elevation = 8;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: elevation,
          title: Text(widget.kanjiList.name),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: (){
                setState(() {
                  sortByStrokes = !sortByStrokes;
                });
              },
            ),
            AnimatedCrossFade(
              firstChild: IconButton(
                icon: Icon(
                  Icons.view_headline,
                  color: Colors.white,
                ),
                onPressed: () {
                  if(widget.kanjiList.kanjiStrs.isNotEmpty){
                    if(listViewScrollController.position.maxScrollExtent>0){
                      setState(() {
                        listViewScrollController.position.moveTo(0);
                        showGrid = !showGrid;
                      });
                    }else{
                      setState(() {
                        showGrid = !showGrid;
                      });
                    }
                  }
                },
              ),
              secondChild: IconButton(
                icon: Icon(
                  Icons.view_comfy,
                  color: Colors.white,
                ),
                onPressed: () {
                  if(widget.kanjiList.kanjiStrs.isNotEmpty){
                    if(gridViewScrollController.position.maxScrollExtent>0){
                      setState(() {
                        gridViewScrollController.position.moveTo(0);
                        showGrid = !showGrid;
                      });
                    }else{
                      setState(() {
                        showGrid = !showGrid;
                      });
                    }
                  }
                },
              ),
              crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200),
            )
          ],
        ),
        body: StreamBuilder(
          stream: kanjiBloc.kanjis,
          builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
            if (snapshot.hasData) {
              var kanjis = snapshot.data;
              //kanjis.sort((kanjiLeft, kanjiRight)=>kanjiLeft.strokes.compareTo(kanjiRight.strokes));
              //return KanjiGridView(kanjis: kanjis);
              if(sortByStrokes){
                kanjis.sort((a,b)=>a.strokes.compareTo(b.strokes));
              }else{
                kanjis = snapshot.data;
              }

              if (kanjis.isEmpty) {
                return Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      'When will you start studying！ (╯°Д°）╯',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              return AnimatedCrossFade(
                  firstChild: buildGridView(kanjis),
                  secondChild: buildListView(kanjis),
                  crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 200));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  void onLongPressed(String kanjiStr) {
    scaffoldKey.currentState.showBottomSheet((_) => ListTile(
          title: Text('Remove $kanjiStr from ${widget.kanjiList.name}'),
          onTap: () {
            Navigator.pop(context);
            scaffoldKey.currentState.showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('Are you sure you want to remove $kanjiStr from ${widget.kanjiList.name}'),
              action: SnackBarAction(
                  label: 'Yes',
                  onPressed: () {
                    scaffoldKey.currentState.hideCurrentSnackBar();

                    widget.kanjiList.kanjiStrs.remove(kanjiStr);
                    kanjiBloc.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
                    KanjiListBloc.instance.removeKanji(widget.kanjiList.name, kanjiStr);
                  }),
            ));
          },
        ));
  }

  Widget buildGridView(List<Kanji> kanjis) {
    return GridView.count(
        controller: gridViewScrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        crossAxisCount: 6,
        children: List.generate(kanjis.length, (index) {
          var kanji = kanjis[index];
          return InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width / 6,
                height: MediaQuery.of(context).size.width / 6,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'kazei')),
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(fontSize: 8, color: Colors.white24),
                      ),
                    )
                  ],
                )),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
            },
            onLongPress: () {
              onLongPressed(kanji.kanji);
            },
          );
        }));
  }

  Widget buildListView(List<Kanji> kanjis) {
    return ListView.separated(
        controller: listViewScrollController,
        itemBuilder: (_, index) {
          var kanji = kanjis[index];

          return ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
            },
            onLongPress: () {
              onLongPressed(kanji.kanji);
            },
            leading: Container(
              width: 28,
              height: 28,
              child: Center(
                child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'kazei')),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                        ? Padding(
                            padding: EdgeInsets.all(4),
                            child: Container(
                              child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    'Grade ${kanji.grade}',
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
                  ],
                ),
                Divider(height: 0),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    for (var kunyomi in kanji.kunyomi)
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
                    for (var onyomi in kanji.onyomi)
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
              kanji.meaning,
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: kanjis.length);
  }
}
