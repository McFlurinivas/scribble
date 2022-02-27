import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scribble/Leaderboard_Screen.dart';
import 'package:scribble/Waiting_Lobby_Screen.dart';
import 'package:scribble/models/touch_points.dart';
import 'package:scribble/sidebar/player_scoreboard.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:scribble/models/custom_painter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scribble/Home Page.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;

  const PaintScreen({Key? key, required this.data, required this.screenFrom})
      : super(key: key);

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();
  int correctUserCounter = 0;
  var isGuessFieldOpen = false;
  int _start = 90;
  final int _totalTime = 90;
  late Timer _timer;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
    print(widget.data);
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      text.replaceAll(' ', '');
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  //connect to Socket.io
  void connect() {
    _socket = IO.io('http://192.168.0.112:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    //listen to socket
    _socket.onConnect((data) {
      print('connected');
      _socket.on('updateRoom', (roomData) {
        //print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on(
          'notCorrectGame',
          (data) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room code under this name already exists')));
          }
      );

      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        }
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });

      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          correctUserCounter = msgData['correctUserCounter'];
        });
        if (correctUserCounter == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  isTextInputReadOnly = false;
                  correctUserCounter = 0;
                  _start = 90;
                  points.clear();
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                title: Center(
                  child: Text(
                    "Word was $oldWord",
                    style: const TextStyle(
                        fontFamily: 'alphabetized cassette tapes',
                        fontSize: 50),
                  ),
                ),
              );
            });
      });

      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name']);
        setState(() {
          isTextInputReadOnly = true;
        });
      });

      _socket.on('show-leaderboard', (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'].toString()
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
          }
        }
        setState(() {
          _timer.cancel();
          isShowFinalLeaderboard = true;
        });
      });

      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'].toString()
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Choose Color"),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      String colorString = color.toString();
                      String valueString =
                          colorString.split('(0x')[1].split(')')[0];
                      //print(colorString);
                      //print(valueString);
                      Map map = {
                        'color': valueString,
                        'roomName': dataOfRoom['name']
                      };
                      _socket.emit('color-change', map);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              ));
    }

    return Scaffold(
      key: scaffoldkey,
      drawer: PlayerScore(scoreboard),
      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
              ? !isShowFinalLeaderboard
                  ? Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width,
                              height: height * 0.55,
                              child: dataOfRoom['turn']['nickname'] ==
                                      widget.data['nickname']
                                  ? GestureDetector(
                                      onPanUpdate: (details) {
                                        //print(details.localPosition.dx);
                                        _socket.emit('paint', {
                                          'details': {
                                            'dx': details.localPosition.dx,
                                            'dy': details.localPosition.dy
                                          },
                                          'roomName': widget.data['name']
                                        });
                                      },
                                      onPanStart: (details) {
                                        //print(details.localPosition.dx);
                                        _socket.emit('paint', {
                                          'details': {
                                            'dx': details.localPosition.dx,
                                            'dy': details.localPosition.dy
                                          },
                                          'roomName': widget.data['name']
                                        });
                                      },
                                      onPanEnd: (details) {
                                        _socket.emit('paint', {
                                          'details': null,
                                          'roomName': widget.data['name']
                                        });
                                      },
                                      child: SizedBox.expand(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                          child: RepaintBoundary(
                                            child: CustomPaint(
                                              size: Size.infinite,
                                              painter: MyCustomPainter(
                                                  pointsList: points),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.expand(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        child: RepaintBoundary(
                                          child: CustomPaint(
                                            size: Size.infinite,
                                            painter: MyCustomPainter(
                                                pointsList: points),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            dataOfRoom['turn']['nickname'] ==
                                    widget.data['nickname']
                                ? Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            selectColor();
                                          },
                                          icon: Icon(Icons.color_lens,
                                              color: selectedColor)),
                                      Expanded(
                                          child: Slider(
                                        min: 1,
                                        max: 10,
                                        label: "Strokewidth $strokeWidth",
                                        activeColor: selectedColor,
                                        value: strokeWidth,
                                        onChanged: (double value) {
                                          Map map = {
                                            'value': value,
                                            'roomName': dataOfRoom['name']
                                          };
                                          _socket.emit('stroke-width', map);
                                        },
                                      )),
                                      IconButton(
                                          onPressed: () {
                                            _socket.emit('clear-screen',
                                                dataOfRoom['name']);
                                          },
                                          icon: Icon(
                                            Icons.layers_clear,
                                            color: selectedColor,
                                          )),
                                    ],
                                  )
                                : Text(
                                    "${dataOfRoom['turn']['nickname']} is drawing...",
                                    style: const TextStyle(
                                        fontSize: 45,
                                        fontFamily:
                                            'alphabetized cassette tapes'),
                                  ),
                            dataOfRoom['turn']['nickname'] !=
                                    widget.data['nickname']
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: textBlankWidget,
                                  )
                                : Center(
                                    child: Text(
                                      dataOfRoom['word'],
                                      style: const TextStyle(
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                            //display messages
                            SizedBox(
                              height: height * 0.3,
                              child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    var msg = messages[index].values;
                                    //print(msg);
                                    return ListTile(
                                      title: Text(
                                        msg.elementAt(0),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        msg.elementAt(1),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                        dataOfRoom['turn']['nickname'] !=
                                widget.data['nickname']
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: guessField())
                            : Container(),
                        SafeArea(
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black),
                            onPressed: () =>
                                scaffoldkey.currentState!.openDrawer(),
                          ),
                        )
                      ],
                    )
                  : FinalLeaderboard(scoreboard, winner)
              : WaitingLobby(
                  code: dataOfRoom['name'],
                  totalPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: dataOfRoom['isJoin'] != true
          ? !isShowFinalLeaderboard
          ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: FloatingActionButton(
                        onPressed: () {},
                        elevation: 5,
                        backgroundColor: Colors.white,
                        child: Text(
                          '$_start',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'alphabetized cassette tapes'),
                        ),
                      ),
                    ),
                    Container(
                      child: (keyboardIsOpened ||
                              (dataOfRoom['turn']['nickname'] ==
                                  widget.data['nickname']))
                          ? null
                          : FloatingActionButton(
                              elevation: 5,
                              child: Icon(
                                (isGuessFieldOpen)
                                    ? Icons.close
                                    : Icons.message,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.black,
                              onPressed: () {
                                setState(() {
                                  isGuessFieldOpen =
                                      (isGuessFieldOpen) ? false : true;
                                });
                              },
                            ),
                    ),
                  ],
                ):Container():Container()
    );
  }

  Widget guessField() {
    return TweenAnimationBuilder<double>(
      builder: (context, value, child) {
        return Transform.scale(
            scale: value, child: child, origin: const Offset(1, 0.5));
      },
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(end: (isGuessFieldOpen) ? 1 : 0),
      child: SizedBox(
        child: TextField(
          readOnly: isTextInputReadOnly,
          showCursor: true,
          textInputAction: TextInputAction.go,
          controller: controller,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Map map = {
                'username': widget.data['nickname'],
                'msg': value.trim(),
                'word': dataOfRoom['word'],
                'roomName': dataOfRoom['name'],
                'correctUserCounter': correctUserCounter,
                'totalTime': _totalTime,
                'timeTaken': _totalTime - _start
              };
              _socket.emit('msg', map);
              controller.clear();
            }
          },
          autocorrect: false,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xfff5f5fa),
              hintText: 'Type your guess here...',
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )),
        ),
      ),
    );
  }
}
