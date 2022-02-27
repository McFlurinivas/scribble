import 'package:flutter/material.dart';
import 'package:scribble/Widgets/customTextField.dart';
import 'Paint Screen.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _maxRoundsValue;
  String? _maxRoomSize;
  int code = 0000;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _maxRoomSize != null) {
      Map<String, String> data = {
        'nickname': _nameController.text,
        'name': _codeController.text,
        'occupancy': _maxRoomSize!,
        'maxRounds': _maxRoundsValue!
      };
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaintScreen(data: data, screenFrom: 'createRoom')));
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
              "Create Room",
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
              height: 20,
            ),

            DropdownButton<String>(
              value: _maxRoundsValue,
                focusColor: const Color(0xfff5f6fa),
                hint: const Text(
                  "Select Maximum Rounds",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontFamily: 'alphabetized cassette tapes',
                      fontWeight: FontWeight.w500),
                ),
                items: ['2', '5', '10', '15']
                    .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            )))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _maxRoundsValue = value;
                  });
                }),
            const SizedBox(
              height: 20,
            ),
            DropdownButton<String>(
              value: _maxRoomSize,
                focusColor: const Color(0xfff5f6fa),
                hint: const Text(
                  "Select Room Size",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontFamily: 'alphabetized cassette tapes',
                      fontWeight: FontWeight.w500),
                ),
                items: ['2', '3', '4', '5', '6', '7', '8']
                    .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            )))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _maxRoomSize = value;
                  });
                }),
            const SizedBox(
              height: 40,
            ),
            FlatButton(
              onPressed: createRoom,
              child: const Text('Create Room',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'JamesFajardo',
                      fontSize: 55)),
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}
