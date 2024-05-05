import 'package:chess_flutter_app/common/widgets/piece/dead_piece.dart';
import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class BoardDeadPieces extends StatelessWidget {
  const BoardDeadPieces({
    super.key,
    required this.isWhitePlayer,
    required this.theme,
  });
  final String theme;

  final bool isWhitePlayer;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: GetBuilder<ChessBoardController>(builder: (controller) {
          var pieceTakens = controller.piecesTaken.entries.toList();
          var pieces = pieceTakens.where((element) => (element.key == element.key.toUpperCase()) == isWhitePlayer).toList();
          pieces.sort((a, b) {
            var aValue = Piece.pieceValue(Piece.getPieceTypeFromSymbol(a.key));
            var bValue = Piece.pieceValue(Piece.getPieceTypeFromSymbol(b.key));
            return aValue.compareTo(bValue);
          });
          int length = pieces.length;

          return GridView.builder(
              itemCount: length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
              itemBuilder: (context, index) {
                if (index == length) {
                  var point = controller.whiteTakenValue.value - controller.blackTakenValue.value;
                  if (point == 0) {
                    return const SizedBox.shrink();
                  }
                  if (point > 0) {
                    return isWhitePlayer ? Center(child: Text("+${point.abs().toString()}", style: const TextStyle(color: Colors.white70))) : const SizedBox.shrink();
                  }
                  if (point < 0) {
                    return !isWhitePlayer ? Center(child: Text("+${point.abs().toString()}", style: const TextStyle(color: Colors.white70))) : const SizedBox.shrink();
                  }
                } else {
                  var piece = pieces[index];
                  String key = piece.key;
                  return DeadPieces(
                    piece: Piece.getPieceFromSymbol(key),
                    value: piece.value,
                    theme: theme,
                  );
                }
                return null;
              });
        }),
      ),
    );
  }
}
