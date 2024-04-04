import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/knight.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/models/queen.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';

class ChessFunctions {}

bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;

  bool isWhite = (x + y) % 2 == 0;
  return isWhite;
}

bool sameSquareColor(List<int> positions) {
  return (positions[0] + positions[1]) % 2 == 0;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

String getNamePieces(ChessPieces piece) {
  if (piece is Pawn) return 'pawn';
  if (piece is Rook) return 'rook';
  if (piece is Knight) return 'knight';
  if (piece is Bishop) return 'bishop';
  if (piece is Queen) return 'queen';
  if (piece is King) return 'king';

  return '';
}

ChessPieces? reConvertPiece(String piece, bool isWhite) {
  switch (piece) {
    case "_":
      return null;
    case "P":
      return Pawn(isWhite: isWhite);
    case "R":
      return Rook(isWhite: isWhite);
    case "N":
      return Knight(isWhite: isWhite);
    case "B":
      return Bishop(isWhite: isWhite);
    case "Q":
      return Queen(isWhite: isWhite);
    case "K":
      return King(isWhite: isWhite);
  }

  return null;
}

int reConvertRow(String row) {
  switch (row) {
    case "8":
      return 8;
    case "7":
      return 7;
    case "6":
      return 6;
    case "5":
      return 5;
    case "4":
      return 4;
    case "3":
      return 3;
    case "2":
      return 2;
    case "1":
      return 1;
  }
  return 8;
}

int reConvertCol(String col) {
  switch (col) {
    case "a":
      return 0;
    case "b":
      return 1;
    case "c":
      return 2;
    case "d":
      return 3;
    case "e":
      return 4;
    case "f":
      return 5;
    case "g":
      return 6;
    case "h":
      return 7;
  }
  return 8;
}

String convertPiece(ChessPieces piece) {
  if (piece is Pawn) return "P";
  if (piece is Rook) return "R";
  if (piece is Knight) return "N";
  if (piece is Bishop) return "B";
  if (piece is Queen) return "Q";
  if (piece is King) return "K";

  return "_";
}

String convertCol(int col) {
  switch (col) {
    case 0:
      return "8";
    case 1:
      return "7";
    case 2:
      return "6";
    case 3:
      return "5";
    case 4:
      return "4";
    case 5:
      return "3";
    case 6:
      return "2";
    case 7:
      return "1";
  }
  return "";
}

String convertRow(int row) {
  switch (row) {
    case 0:
      return "a";
    case 1:
      return "b";
    case 2:
      return "c";
    case 3:
      return "d";
    case 4:
      return "e";
    case 5:
      return "f";
    case 6:
      return "g";
    case 7:
      return "h";
  }
  return "";
}
