import 'package:flutter/material.dart';
import 'package:two_thousand_forty_eight/theme/theme.dart';
import 'package:two_thousand_forty_eight/widgets/board.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  Offset sizeOfAppBar = Offset(0, 0);
  int sizeOfBoard = 3;
  String bestScore = '0';
  String score = '0';
  String indentAlgorithm (String str){
    List indentedStr = [];
    str.split('').forEach((el) => indentedStr.add(int.parse(el)));
    for(int i = 0; i < str.length; i++){
      if(i % 3 == 0){
        indentedStr.insert(str.length - i, ' ');
      }
    }
    return indentedStr.join('');
  }
  double autoSizeTextAlg (String str) => (20.0 - str.length / 5) < 13 ? 13 : (20.0 - str.length / 3);
  bool clearBtnPressed = false;
  RenderBox box;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: Container(
                  height: 60,
                  width: 150,
                  decoration: BoxDecoration(
                    color: MyTheme.brow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('SCORE',style: TextStyle(color: MyTheme.white,fontSize: 20,fontFamily: 'Poppins'),),
                      Text(indentAlgorithm(score),style: TextStyle(color: MyTheme.white,fontSize: autoSizeTextAlg(indentAlgorithm(score)),fontFamily: 'Poppins'),)
                    ],
                  ),
                ),
              ),
              Container(
                  color: Colors.transparent,
                  height: MediaQuery.of(context).size.width - 50,
                  width: MediaQuery.of(context).size.width - 50,
              ),
              Center(
                child: Container(
                  height: 60,
                  width: 150,
                  decoration: BoxDecoration(
                    color: MyTheme.brow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('BEST SCORE',style: TextStyle(color: MyTheme.white,fontSize: 15,fontFamily: 'Poppins'),),
                      Text(indentAlgorithm(bestScore),style: TextStyle(color: MyTheme.white,fontSize: autoSizeTextAlg(indentAlgorithm(bestScore)),fontFamily: 'Poppins'),)
                    ],
                  ),
                ),
              )
            ],
          ),
          Board(
            boardSize: sizeOfBoard,
            screenSize: MediaQuery.of(context).size,
            score: (int returnedScore) => setState(() {
              score = "$returnedScore";
              bestScore = int.parse(bestScore) > returnedScore ? bestScore : "$returnedScore";
            }),
          ),
        ],
      ),
    );
  }
}
