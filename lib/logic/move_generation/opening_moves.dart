import 'package:chess_flutter_app/logic/move_generation/move/move.dart';

var openings = [
  [
    // Ruy Lopez
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('e7'), squareToInt('e5')),
    Move(squareToInt('g1'), squareToInt('f3')),
    Move(squareToInt('b8'), squareToInt('c6')),
    Move(squareToInt('f1'), squareToInt('b5')),
  ],
  [
    // Italian Game
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('e7'), squareToInt('e5')),
    Move(squareToInt('g1'), squareToInt('f3')),
    Move(squareToInt('b8'), squareToInt('c6')),
    Move(squareToInt('f1'), squareToInt('c4'))
  ],
  [
    // Sicilian Defense
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('c7'), squareToInt('c5')),
  ],
  [
    // French Defense
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('e7'), squareToInt('e6')),
  ],
  [
    // Caro-Kann Defense
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('c7'), squareToInt('c6')),
  ],
  [
    // Pirc Defense
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('d7'), squareToInt('d6')),
  ],
  [
    // Queen's Gambit
    Move(squareToInt('d2'), squareToInt('d4')),
    Move(squareToInt('d7'), squareToInt('d5')),
    Move(squareToInt('c2'), squareToInt('c4')),
  ],
  [
    // King's Gambit
    Move(squareToInt('e2'), squareToInt('e4')),
    Move(squareToInt('e7'), squareToInt('e5')),
    Move(squareToInt('e4'), squareToInt('f4')),
  ],
  [
    // Indian Defense
    Move(squareToInt('d2'), squareToInt('d4')),
    Move(squareToInt('g8'), squareToInt('f6')),
  ],
  [
    // English Opening
    Move(squareToInt('c2'), squareToInt('c4')),
  ],
  [
    // Reti Opening
    Move(squareToInt('g1'), squareToInt('f3')),
  ]
];

int squareToInt(String squareIndex) {
  var col = squareIndex.codeUnitAt(0) - 97;
  var row = 8 - (int.tryParse(squareIndex[1]) ?? 0);
  return row * 8 + col;
}
