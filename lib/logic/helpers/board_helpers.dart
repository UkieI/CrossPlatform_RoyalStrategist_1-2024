import 'package:chess_flutter_app/logic/board/coord.dart';

class BoardHelper {
  static var rookDirections = [
    Coord(-1, 0),
    Coord(1, 0),
    Coord(0, 1),
    Coord(0, -1)
  ];

  static var bishopDirections = [
    Coord(-1, 1),
    Coord(1, 1),
    Coord(1, -1),
    Coord(-1, -1)
  ];

  static String rowName = "12345678";
  static String colName = "abcdefgh";

  static const a1 = 0;
  static const b1 = 1;
  static const c1 = 2;
  static const d1 = 3;
  static const e1 = 4;
  static const f1 = 5;
  static const g1 = 6;
  static const h1 = 7;

  static const a8 = 56;
  static const b8 = 57;
  static const c8 = 58;
  static const d8 = 59;
  static const e8 = 60;
  static const f8 = 61;
  static const g8 = 62;
  static const h8 = 63;

  static int rowIndex(int squareIndex) => squareIndex >> 3;
  static int colIndex(int squareIndex) => squareIndex & 7; // 0b000111
  static int indexFromRowCol(int row, int col) => row * 8 + col;
  static int indexFromCoord(Coord coord) =>
      indexFromRowCol(coord.row, coord.col);

  static Coord coordFromIndex(int squareIndex) =>
      Coord(rowIndex(squareIndex), colIndex(squareIndex));
  static bool lightSquareRowCol(int rowIndex, int colIndex) =>
      (rowIndex + colIndex) % 2 != 0;
  static bool lightSquareSquare(int squareIndex) =>
      lightSquareRowCol(rowIndex(squareIndex), colIndex(squareIndex));

  static String squareNameFromRowCol(int fileIndex, int rankIndex) =>
      "${colName[fileIndex]} ${rankIndex + 1}";

  static String squareNameFromIndex(int squareIndex) {
    var coord = coordFromIndex(squareIndex);
    return squareNameFromRowCol(coord.row, coord.col);
  }

  static String squareNameFromCoord(Coord coord) {
    return squareNameFromRowCol(coord.row, coord.col);
  }

  static bool isValidCoordinate(int x, int y) =>
      x >= 0 && x < 8 && y >= 0 && y < 8;
}
