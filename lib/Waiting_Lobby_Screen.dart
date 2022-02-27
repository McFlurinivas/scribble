import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaitingLobby extends StatefulWidget {
  final int occupancy;
  final int totalPlayers;
  final String code;
  final players;

  const WaitingLobby(
      {Key? key,
      required this.occupancy,
      required this.totalPlayers,
      required this.code,
      required this.players})
      : super(key: key);

  @override
  _WaitingLobbyState createState() => _WaitingLobbyState();
}

class _WaitingLobbyState extends State<WaitingLobby> {
  @override
  Widget build(BuildContext context) {
    int total = widget.occupancy - widget.totalPlayers;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              (total == 1)
                  ? 'Waiting for ${widget.occupancy - widget.totalPlayers} more player to join.'
                  : 'Waiting for ${widget.occupancy - widget.totalPlayers} more players to join.',
              style: const TextStyle(
                  fontSize: 40, fontFamily: 'alphabetized cassette tapes'),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                readOnly: true,
                onTap: () {
                  //Copy Room Code
                  Clipboard.setData(ClipboardData(text: widget.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code Copied')));
                },
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xfff5f5fa),
                    hintText: 'Tap To Copy Room Code',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    )),
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          const Text('Players',
              style: TextStyle(
                  fontFamily: 'alphabetized cassette tapes', fontSize: 60)),
          Expanded(
            child: ListView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: widget.totalPlayers,
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: Text(
                        '${index + 1}.',
                        style: const TextStyle(
                            fontSize: 50,
                            fontFamily: 'alphabetized cassette tapes',
                            fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        widget.players[index]['nickname'],
                        style: const TextStyle(
                            fontSize: 50,
                            fontFamily: 'alphabetized cassette tapes',
                            fontWeight: FontWeight.bold),
                      ));
                }),
          )
        ],
      ),
    );
  }
}
