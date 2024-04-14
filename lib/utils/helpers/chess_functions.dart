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

bool isDigit(String char) {
  final codeUnit = char.codeUnitAt(0);
  return codeUnit >= 48 && codeUnit <= 57;
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
