import 'package:flutter/material.dart';

import 'Home Page.dart';

class FinalLeaderboard extends StatelessWidget {
  final scoreboard;
  final String winner;

  const FinalLeaderboard(this.scoreboard, this.winner, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(0),
        height: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  primary: true,
                  shrinkWrap: true,
                  itemCount: scoreboard.length,
                  itemBuilder: (context, index) {
                    var data = scoreboard[index].values;
                    return Card(
                      child: ListTile(
                        title: Text(
                          data.elementAt(0),
                          style: const TextStyle(
                              fontSize: 50,
                              fontFamily: 'alphabetized cassette tapes'),
                        ),
                        trailing: Text(
                          data.elementAt(1).toString(),
                          style: const TextStyle(
                              fontSize: 30,
                              fontFamily: 'alphabetized cassette tapes',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style:const TextStyle(
                      fontSize: 65,
                      fontFamily: 'alphabetized cassette tapes',
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'CONGRATULATIONS!!!'),
                      TextSpan(text: '\n$winner ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'has won the game!')
                    ],
                  ),
                )
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) => const HomePage(),
                ));
              },
              child: const Text('Exit',
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
