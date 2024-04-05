abstract class ChessPieces {
  final bool isWhite;
  final int value;
  bool hasMoved;
  // List<int> currentPosition;

  ChessPieces({
    required this.value,
    required this.isWhite,
    this.hasMoved = false,
    // required this.currentPosition,
  });
  @override
  String toString();

  int compareTo(ChessPieces other);

  List<List<int>> move(int row, int col, List<List<ChessPieces?>> board,
      List<int> previousMoved, List<int> previousSelected);
}
