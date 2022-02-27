import 'package:flutter/material.dart';
import 'package:scribble/Paint%20Screen.dart';
import 'package:scribble/Widgets/customTextField.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({Key? key}) : super(key: key);

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  void join() {
    if (_nameController.text.isNotEmpty && _codeController.text.isNotEmpty) {
      Map<String, String> data = {'nickname': _nameController.text, 'name': _codeController.text};
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: 'joinRoom')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Join Room",
              style: TextStyle(
                  fontFamily: 'alphabetized cassette tapes', fontSize: 100),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextField(
                Controller: _nameController,
                hintText: "Enter Your Name",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextField(
                Controller: _codeController,
                hintText: "Enter Room Code",
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            FlatButton(
              onPressed: join,
              child: const Text('Join Room',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'JamesFajardo',
                      fontSize: 55)),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.black, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}
