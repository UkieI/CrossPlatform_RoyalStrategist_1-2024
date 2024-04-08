class Coord {
  late int row;
  late int col;

  Coord(this.row, this.col);

  Coord.fromSquare(int squareIndex)
      : row = squareIndex ~/ 8,
        col = squareIndex % 8;

  bool isLightSquare() {
    return (row + col) % 2 != 0;
  }

  int compareTo(Coord other) {
    return (row == other.row && col == other.col) ? 0 : 1;
  }

  static Coord plus(Coord a, Coord b) => Coord(a.row + b.row, a.col + b.col);

  static Coord minus(Coord a, Coord b) => Coord(a.row - b.row, a.col - b.col);
  static Coord muti(Coord a, int m) => Coord(a.row * m, a.col * m);

  bool isInBoard() => row >= 0 && row < 8 && col >= 0 && col < 8;
  // int squareIndex() => Board
}
