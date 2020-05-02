import 'dart:math';
import 'package:flutter/material.dart';
import 'package:two_thousand_forty_eight/models/position-madel.dart';
import 'package:two_thousand_forty_eight/theme/theme.dart';


class Board extends StatefulWidget {
  Board({
    Key key,
    @required this.boardSize,
    this.score,
    @required this.screenSize
  }) : super(key: key);
  final int boardSize;
  final Size screenSize;
  final Function(int) score;
    @override
    _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> with  TickerProviderStateMixin{
  double x = 0;
  double y = 0;
  List<int> gesture = [0,0];
  int boardSize = 0;
  bool gestureFound = false;
  bool actionHappened = false;
  bool isGameOver = false;
  Map<String, Color> colorOfCell = {
    '2': Colors.orange[50],
    '4': Colors.orange[100],
    '8': Colors.orange[200],
    '16': Colors.orange[300],
    '32': Colors.orange[400],
    '64': Colors.orange[500],
    '128': Colors.orange[600],
    '256': Colors.orange[700],
    '512': Colors.orange[800],
    '1024': Colors.orange[900],
    '2048': Colors.deepOrange,
  };
  List<List<AnimationController>> addController = [];
  List<List<Animation<double>>> addAnimation = [];
  List<List<GlobalKey>> listOfKeys = [];
  List<AnimationController> transformController = [];
  List<Animation<dynamic>> transformAnimation = [];
  List<Position> positionList = [];
  List<List<String>> border = [];
  bool needToLook = true;

  bool _canSwipeAlgorithm() {
    bool canSwipe = false;
    for(int i = 0; i < boardSize; i++){
      for(int j = 0; j < boardSize; j++){
        if((_verification(j + 1, i) && border[i][j] == border[i][j+1]) ||
            (_verification(j, i+1) && border[i][j] == border[i+1][j] )){
          canSwipe = true;
          break;
        }
      }
      if(canSwipe){
        break;
      }
    }
    return !canSwipe;
  }

  bool _thereIsAZeroCell() {
    bool thereIsAZeroCell = true;
    border.forEach((el) => el.forEach((e){
      if(e == ''){
        thereIsAZeroCell = false;
      }
    }));
    return thereIsAZeroCell;
  }

  bool _gameOverAlgorithm(){
    return  _thereIsAZeroCell() ? _canSwipeAlgorithm() : false;
  }

  bool _weHaveElLikeThis(String el, int sX, int sY) {
    int _x = sX - gesture[1];
    int _y = sY - gesture[0];
    bool willReturn = false;
    while(_verification(_x, _y)){
      if(el == border[_y][_x]) {
        willReturn = true;
        break;
      } else if(border[_y][_x] != ''){
        break;
      }
      _x -= gesture[1];
      _y -= gesture[0];
    } return willReturn;
  }

  bool _verification(int _x, int _y) =>
      (_x >= 0 && _x < boardSize && _y >= 0 && _y < boardSize);

  bool _helperWeNeedToContinue(int sX,int sY, moderatedBoarder, _gesture){
    int _x = sX;
    int _y = sY;
    bool weNeedToContinue = false;
    while(_verification(_x,_y)){
      _x += _gesture[1];
      _y += _gesture[0];
      if(_verification(_x, _y)){
        weNeedToContinue = moderatedBoarder[_y][_x] != '';
        if(moderatedBoarder[_y][_x] != ''){
          break;
        }
      }
    }
    return weNeedToContinue;
  }

  int _calculateScore () {
    int score = 0;
    border.forEach((list) => list.forEach((el) =>   score += (el != '' ? int.parse(el) : 0)));
    return score;
  }

  int _endPosition(int sX, int sY) {
    int _x = sX;
    int _y = sY;
    bool verticalGuest = gesture[1] == 0;
    int count = verticalGuest ? sY  : sX;
    while(_verification(_x, _y)){
      if(_verification(_x, _y) && border[_y][_x] == '') {
        count -= verticalGuest ? gesture[0] : gesture[1];
      } else if(_weHaveElLikeThis(border[_y][_x], _x, _y)){
        count -= verticalGuest ? gesture[0] : gesture[1];
      }
      _x -= gesture[1];
      _y -= gesture[0];
    }
    return count;
  }

  double _autoSizeTextAlg() => sizeOfCube() * 40 / 100;

  double sizeOfCube() => ((widget.screenSize.width - 50) / boardSize)  - ((widget.screenSize.width - 50) / boardSize) / 10 ;

  List<int> array(int length) {
    List<int> willReturn = [];
    for(int i = 0;i < length;i++){
      willReturn.add(i);
    }
    return willReturn;
  }

  List<List<String>> _boardWithRandomNum() {
    List<String> random = ['2','2','2','2','4','2','2','2','2','2'];
    List<List<String>> moderatedBorder =  List<List<String>>.from(border);
    while(true && !_thereIsAZeroCell()) {
      int y = Random().nextInt(boardSize);
      int x = Random().nextInt(boardSize);
      if(moderatedBorder[y][x] == ''){
        moderatedBorder[y][x] = random[Random().nextInt(10)];
        _addAnimationNewEl(border[y][x], x, y);
        break;
      }
    }
    return moderatedBorder;
  }

  List<List<String>> _helperTransform(int sX,int sY,moderatedBoarder, _gesture){
    int _x = sX;
    int _y = sY;
    while(_verification(_x, _y)){
      if(moderatedBoarder[_y][_x] == ''){
        if( _verification(_x + _gesture[1], _y + _gesture[0])){
          moderatedBoarder[_y][_x] = moderatedBoarder[_y + _gesture[0]][_x + _gesture[1]];
          moderatedBoarder[_y + _gesture[0]][_x + _gesture[1]] = '';
        }
      }
      _x += _gesture[1];
      _y += _gesture[0];
    }
    return moderatedBoarder;
  }

  List<List<String>> _helperMerger(int sX,int sY,moderatedBoarder, _gesture) {
    int _x = sX;
    int _y = sY;
    moderatedBoarder[_y][_x] = '${int.parse(moderatedBoarder[_y][_x]) * 2}';
    moderatedBoarder[_y + _gesture[0]][_x + _gesture[1]] = '';
    return moderatedBoarder;
  }

  List<List<String>> _secondStageOfTheAlgorithm(int sY,int sX, saved, _gesture) {
    int _x = sX;
    int _y = sY;
    List<List<String>> moderatedBoarder = List<List<String>>.from(saved);
    while(_verification(_x, _y) && _helperWeNeedToContinue(_x, _y, moderatedBoarder, _gesture)) {
      if(moderatedBoarder[_y][_x] == '' || (_verification(_x + _gesture[1], _y + _gesture[0]) &&
          moderatedBoarder[_y + _gesture[0]][_x + _gesture[1]] == '')){
        moderatedBoarder = _helperTransform(_x, _y,moderatedBoarder, _gesture);
      } else if(_verification(_x + _gesture[1], _y + _gesture[0]) &&
          moderatedBoarder[_y][_x] == moderatedBoarder[_y + _gesture[0]][_x + _gesture[1]]){
        moderatedBoarder  = _helperMerger(_x,_y,moderatedBoarder, _gesture);
        _x += _gesture[1];
        _y += _gesture[0];
      } else {
        _x += _gesture[1];
        _y += _gesture[0];
      }
    }
    return moderatedBoarder;
  }

  List<List<String>> _firstStageOfTheAlgorithm(final List<List<String>> saved, _gesture) {
    positionList = [];
    transformController = [];
    transformAnimation = [];
    List<List<String>> moderatedBoarder = List<List<String>>.from(saved);
    bool verticalGuest = _gesture[1] == 0;
    for(int i = _gesture[1] >= 0 ? 0 : boardSize-1;
    verticalGuest ? _verification(0, i) : _gesture[1] > 0 ? boardSize > i :  0 <= i; i += _gesture[1] > 0 ? 1 : -1) {
      verticalGuest ? null : _calculatePositionForAnimation(i,_gesture[1] >= 0 ? 0 : boardSize-1);
      verticalGuest ? null :
      moderatedBoarder =
      List<List<String>>.from(_secondStageOfTheAlgorithm(i,_gesture[1] >= 0 ? 0 : boardSize-1, moderatedBoarder, _gesture));
      for(int j = _gesture[0] >= 0 ? 0 : boardSize-1; _gesture[0] > 0 ? boardSize > j : 0 <= j; j += _gesture[0] > 0 ? 1 : -1) {
        !verticalGuest ? null : _calculatePositionForAnimation(_gesture[0] >= 0 ? 0 : boardSize-1, j);
        verticalGuest ?
        moderatedBoarder =
        List<List<String>>.from(_secondStageOfTheAlgorithm(_gesture[0] >= 0 ? 0 : boardSize-1, j, moderatedBoarder, _gesture)) : null;
      }
    }
    needToLook = false;
    Future.delayed(Duration(milliseconds: (((boardSize * 10) * 1000) / 100 - ((boardSize * 10) * 500) / 100).toInt()), () => setState(() {
      needToLook = true;
      positionList = [];
    }));
    return moderatedBoarder;
  }

  void _clearBoard () {
    setState(() {
      gestureFound = false;
      actionHappened = false;
      colorOfCell = {
        '2': Colors.orange[50],
        '4': Colors.orange[100],
        '8': Colors.orange[200],
        '16': Colors.orange[300],
        '32': Colors.orange[400],
        '64': Colors.orange[500],
        '128': Colors.orange[600],
        '256': Colors.orange[700],
        '512': Colors.orange[800],
        '1024': Colors.orange[900],
        '2048': Colors.deepOrange,
      };
      addController = [];
      addAnimation = [];
      listOfKeys = [];
      transformController = [];
      transformAnimation = [];
      positionList = [];
      border = [];
      needToLook = true;
      isGameOver = false;
      widget.score(0);
    });
    _createBoard();
    _boardWithRandomNum();
    _boardWithRandomNum();

  }

  void _createBoard (){
    for(int i = 0; i < boardSize; i++){
      border.add([]);
      listOfKeys.add([]);
      addController.add([]);
      addAnimation.add([]);
      for(int j = 0; j < boardSize; j++){
        listOfKeys[i].add(GlobalKey());
        addController[i].add(AnimationController(vsync: this,duration: Duration(milliseconds: (sizeOfCube() * 1.3).toInt()), reverseDuration: Duration(milliseconds: 0)));
        addAnimation[i].add(Tween(begin: sizeOfCube() / 2, end: sizeOfCube()).animate(addController[i][j])..addListener((){setState((){});}));
        addController[i][j].forward();
        border[i].add('');
      }
    }
  }

  void _findTheGesture() {
    if(x != 0.0 && (x > y || x < y)){
      if(x > 0){
        setState(() => gesture = [0, -1]);
        actionHappened = false;
        gestureFound = true;
      } else {
        setState(() => gesture = [0, 1]);
        actionHappened = false;
        gestureFound = true;
      }
    } else if(y != 0.0 &&(x < y || x > y)){
      if(y > 0){
        setState(() => gesture = [-1, 0]);
        gestureFound = true;
        actionHappened = false;
      } else {
        setState(() => gesture = [1, 0]);
        gestureFound = true;
        actionHappened = false;
      }
    }
  }

  void _calculatePositionForAnimation (int sY, int sX) {
    int _x = sX;
    int _y = sY;
    while(_verification(_x, _y)){
      if(_verification(_x, _y) && border[_y][_x] != ''){
        int coord = _endPosition(_x, _y);
        bool verticalGuest = gesture[1] == 0;
        RenderBox fBox = listOfKeys[verticalGuest ? coord : _y][verticalGuest ? _x : coord].currentContext.findRenderObject();
        RenderBox sBox = listOfKeys[_y][_x].currentContext.findRenderObject();
        positionList.add(Position(coord: sBox.localToGlobal(Offset.zero), el: border[_y][_x]));
        int lastEl = positionList.length-1;
        transformController.add(AnimationController(vsync: this, duration: Duration(milliseconds: (((boardSize * 10) * 1000) / 100 - ((boardSize * 10) * 600) / 100).toInt())));
        transformAnimation.add(Tween(begin: positionList[lastEl].coord , end: fBox.localToGlobal(Offset.zero)).animate(transformController[lastEl])..addListener(() {
          setState(() => positionList[lastEl].coord = transformAnimation[lastEl].value);
        }));
        transformController[lastEl].forward();
      }
      _x += gesture[1];
      _y += gesture[0];
    }
  }

  void _addAnimationNewEl(final String num, final int x, final int y) {
    border[y][x] = num;
    addController[y][x].reverse();
    addController[y][x].forward();
  }

  @override
  void initState(){
    boardSize = widget.boardSize;
    _createBoard();
    _boardWithRandomNum();
    _boardWithRandomNum();
    super.initState();
  }
//--------------------------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    _findTheGesture();
    if(gestureFound && !actionHappened) {
      border = _firstStageOfTheAlgorithm (border, gesture);
      Future.delayed(
          Duration(
              milliseconds: (
                  ((boardSize * 10) * 1000) / 100 - ((boardSize * 10) * 500) / 100
              ).toInt()
          ),
              () => setState(
                  () {
                if(_gameOverAlgorithm()) {
                  isGameOver = true;
                  widget.score(_calculateScore());
                } else
                  _boardWithRandomNum();
                  widget.score(_calculateScore());
              }
          )
      );

      y = 0.0;
      x = 0.0;
      actionHappened = true;
    }

    return GestureDetector(
      onPanCancel: (){
        gestureFound = false;
      },
      onVerticalDragUpdate: (details) => !gestureFound ? setState(() => y = details.delta.dy) : null,
      onHorizontalDragUpdate: (details) =>!gestureFound ? setState(() => x = details.delta.dx) : null,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              height: widget.screenSize.width - 50,
              width: widget.screenSize.width - 50,
              decoration: BoxDecoration(
                  color: MyTheme.brow
              ),
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: array(boardSize).map((el) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: array(boardSize).map((e) =>
                          Stack(
                            children: <Widget>[
                              Container(
                                height: sizeOfCube(),
                                width: sizeOfCube(),
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: MyTheme.white,
                                            borderRadius: BorderRadius.circular(sizeOfCube() * 5 / 100)
                                        ),
                                        height: sizeOfCube(),
                                        width: sizeOfCube(),
                                      ),
                                      border[el][e] != '' && needToLook ? Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: colorOfCell[border[el][e]],
                                              borderRadius: BorderRadius.circular(sizeOfCube() * 5 / 100)
                                          ),
                                          height: addAnimation[el][e].value,
                                          width: addAnimation[el][e].value,
                                          child: Center(child:  Text(border[el][e], style: TextStyle(color: MyTheme.black,fontSize: _autoSizeTextAlg()),),),
                                        ),
                                      ) : SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                key: listOfKeys[el][e],
                                child: Container(
                                  height: 1,
                                  width: 1,
                                  color: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                      ).toList(),
                    )).toList(),
                  ),
                  isGameOver ? GestureDetector(
                    onTap: () => _clearBoard(),
                    child: Container(
                      height: widget.screenSize.width - 50,
                      width: widget.screenSize.width - 50,
                      color: Colors.black54,
                      alignment:  Alignment.center,
                      child:  Text('Game Over', style: TextStyle(color: Colors.white, fontSize: 20),),
                    ),
                  ) : SizedBox()
                ],
              ),
            ),
          ),
          Stack(
            children: positionList.map((el) => Transform.translate(
              offset: el.coord,
              child: Container(
                decoration: BoxDecoration(
                    color: colorOfCell[el.el],
                    borderRadius: BorderRadius.circular(sizeOfCube() * 5 / 100)
                ),
                height: sizeOfCube(),
                width: sizeOfCube(),
                child: Center(child:  Text(el.el, style: TextStyle(color: MyTheme.black, fontSize: _autoSizeTextAlg()),),),
              ),
            )).toList(),
          )
        ],
      ),
    );
  }
}