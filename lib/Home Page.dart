import 'package:flutter/material.dart';
import 'package:scribble/Create Room.dart';
import 'package:scribble/Join Room.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "sCriBblE",
                style: TextStyle(
                  fontFamily: 'TenOClock',
                  fontSize: 85,
                ),
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Create or Join room to scribble with your friends :)",
                  style: TextStyle(
                    fontFamily: 'alphabetized cassette tapes',
                    fontSize: 55,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateRoom()));
                    },
                    child: const Text('Create Room',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'JamesFajardo',
                            fontSize: 55)),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color: Colors.white,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const JoinRoom()));
                    },
                    child: const Text('Join Room',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'JamesFajardo',
                            fontSize: 55)),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color: Colors.black,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
