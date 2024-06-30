import 'dart:async';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool oTurn = true;
  List<String> displayXO = ['', '', '', '', '', '', '', '', ''];
  List<int> matchedIndexes = [];
  int attempts = 0;

  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  String resultDeclaration = '';
  bool winnerFound = false;
  bool playButtonEnabled = true; 

  static const maxSeconds = 30;
  int oSeconds = maxSeconds;
  int xSeconds = maxSeconds;
  Timer? oTimer;
  Timer? xTimer;

  void startTimer() {
    if (oTurn) {
      oTimer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          if (oSeconds > 0) {
            oSeconds--;
          } else {
            stopTimer();
          }
        });
      });
    } else {
      xTimer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          if (xSeconds > 0) {
            xSeconds--;
          } else {
            stopTimer();
          }
        });
      });
    }
  }

  void stopTimer() {
    if (oTurn) {
      oTimer?.cancel();
    } else {
      xTimer?.cancel();
    }
  }

  void resetTimer() {
    oSeconds = maxSeconds;
    xSeconds = maxSeconds;
  }

  void _tapped(int index) {
    final isRunning = (oTimer?.isActive ?? false) || (xTimer?.isActive ?? false);

    if (isRunning) {
      setState(() {
        if (oTurn && displayXO[index] == '') {
          displayXO[index] = 'O';
          filledBoxes++;
        } else if (!oTurn && displayXO[index] == '') {
          displayXO[index] = 'X';
          filledBoxes++;
        }

        stopTimer();
        oTurn = !oTurn;
        startTimer();
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    final List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in winningCombinations) {
      if (displayXO[combo[0]] == displayXO[combo[1]] &&
          displayXO[combo[0]] == displayXO[combo[2]] &&
          displayXO[combo[0]] != '') {
        setState(() {
          resultDeclaration = 'Player ${displayXO[combo[0]]} Wins!';
          matchedIndexes.addAll(combo);
          stopTimer();
          _updateScore(displayXO[combo[0]]);
        });
        showWinnerDialog(resultDeclaration);
        return;
      }
    }

    if (!winnerFound && filledBoxes == 9) {
      setState(() {
        resultDeclaration = 'Nobody Wins!';
      });
      showWinnerDialog('Nobody Wins!');
    }
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
    winnerFound = true;
  }

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayXO[i] = '';
      }
      resultDeclaration = '';
      matchedIndexes = [];
    });
    filledBoxes = 0;
    resetTimer();
    playButtonEnabled = true; 
  }

  Widget _buildTimer() {
  final oTimerRunning = oTimer?.isActive ?? false;
  final xTimerRunning = xTimer?.isActive ?? false;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                "Player O",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1 - oSeconds / maxSeconds,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 6,
                      backgroundColor: Colors.orange,
                    ),
                    Center(
                      child: Text(
                        '$oSeconds',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "Player X",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1 - xSeconds / maxSeconds,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 6,
                      backgroundColor: Colors.orange,
                    ),
                    Center(
                      child: Text(
                        '$xSeconds',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 20),
      
      playButtonEnabled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                startTimer();
                _clearBoard();
                attempts++;
                setState(() {
                  playButtonEnabled = false;
                });
              },
              child: Text(
                attempts == 0 ? 'Start' : 'Play Again',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          : Container(),
    ],
  );
}

  void showWinnerDialog(String winner) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Game Over'),
        content: Text(winner),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearBoard();
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); 
            },
            child: Text('Home'),
          ),
        ],
      );
    },
  );
}

 @override
Widget build(BuildContext context) {
  String currentPlayer = oTurn ? 'Player O' : 'Player X';

  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/home.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Adjusted alignment
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Player O',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            oScore.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Player X',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            xScore.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10), 
              
              Text(
                '$currentPlayer\'s turn',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Expanded(
                flex: 3,
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _tapped(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 5,
                            color: Colors.red,
                          ),
                          color: matchedIndexes.contains(index)
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Center(
                          child: Text(
                            displayXO[index],
                            style: TextStyle(
                              fontSize: 32,
                              color: matchedIndexes.contains(index)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        resultDeclaration,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      _buildTimer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}}