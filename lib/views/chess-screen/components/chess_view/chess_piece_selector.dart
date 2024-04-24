import 'package:chess_flutter_app/common/widgets/square/square_promotion.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:flutter/material.dart';

class ChessPieceSelector extends StatelessWidget {
  // const ChessPieceSelector(
  //     {super.key, required this.piece, required this.isWhite});
  final Function(int) onPieceSelected;
  final bool isWhite;
  final double width;

  const ChessPieceSelector({
    super.key,
    required this.onPieceSelected,
    required this.isWhite,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.grey.shade200,
      // padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildPieceButton(Piece.Queen),
          _buildPieceButton(Piece.Bishop),
          _buildPieceButton(Piece.Knight),
          _buildPieceButton(Piece.Rook),
        ],
      ),
    );
  }

  Widget _buildPieceButton(int piece) {
    return SquarePromotion(
      onTap: () => onPieceSelected(piece),
      isWhite: Piece.isWhite(piece),
      piece: piece,
    );
  }
}
