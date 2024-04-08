class Board {
  List<int> board = List.generate(64, (index) => 0);

  List<int> KingPositions = [];

  List<int> player1Pieces = [];
  List<int> player2Pieces = [];
  List<int> player1Rooks = [];
  List<int> player2Rooks = [];
  List<int> player1Queens = [];
  List<int> player2Queens = [];
}

List<int> piecesForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Pieces : board.player2Pieces;
}

// int? kingForPlayer(bool isWhite, Board board) {
//   return isWhite ? board.player1King : board.player2King;
// }

List<int> rooksForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Rooks : board.player2Rooks;
}

List<int> queensForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Queens : board.player2Queens;
}
