import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:snake_game/utils/blank_pixel.dart';
import 'package:snake_game/utils/food_pixel.dart';
import 'package:snake_game/utils/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // dimensões grid
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  bool gameHasStarted = false;

  // pontuação
  int currentScore = 0;

  // snake posição
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  // direção da snake inicia para direita
  var currentDirection = snake_Direction.RIGHT;

  // comida posição
  int foodPos = 55;

  // comoçar o jogo
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        // mover a snake
        moveSnake();

        // testar se o jogo acabou
        if (gameOver()) {
          timer.cancel();

          // mostrar alerta
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Fim de Jogo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sua pontuação é: ' + currentScore.toString()),
                    SizedBox(height: 20),
                    MaterialButton(
                      onPressed: () {
                        newGame();
                        Navigator.pop(context);
                      },
                      child: Text('VOLTAR'),
                      color: Colors.pink,
                    ),
                  ],
                ),
              );
            },
          );
        }
      });
    });
  }

  void newGame() {
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    // criar nova comida
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          // barrar snake na ultima posição
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snake_Direction.LEFT:
        {
          // barrar snake na ultima posição
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          // barrar snake na ultima posição
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          // barrar snake na ultima posição
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }

    // snake comendo
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // remove tail
      snakePos.removeAt(0);
    }
  }

  // game over
  bool gameOver() {
    // snake bater em si mesma

    // lista com o corpo da snake sem cabeça
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // pontuação
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // pontuação do jogador
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pontuação Atual'),
                      Text(
                        currentScore.toString(),
                        style: TextStyle(fontSize: 36),
                      ),
                    ],
                  ),

                  // highscore
                  // Text(
                  //   'highscores...',
                  // ),
                ],
              ),
            ),

            // grid do jogo
            Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGHT) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                  itemCount: totalNumberOfSquares,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowSize,
                  ),
                  itemBuilder: (contex, index) {
                    if (snakePos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  },
                ),
              ),
            ),

            // controle
            Expanded(
              child: Center(
                child: MaterialButton(
                  onPressed: gameHasStarted ? () {} : startGame,
                  child: Text('PLAY'),
                  color: gameHasStarted ? Colors.grey : Colors.pink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
