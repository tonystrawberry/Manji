import 'package:flutter/material.dart';

class GradeChip extends StatelessWidget{
  final int grade;
  final Color color;

  GradeChip({@required this.grade, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        child: Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              getStr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
        decoration: BoxDecoration(
          //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
          color: this.color,
          borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
          ),
        ),
      ),
    );
  }

  String getStr(){
    if(grade > 3){
      return '${grade}th Grade';
    }else{
      switch(grade){
        case 1: return '1st Grade';
        case 2: return '2nd Grade';
        case 3: return '3rd Grade';
        case 0: return 'Junior High';
        default: throw Exception('Unmatched grade');
      }
    }
  }
}