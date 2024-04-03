import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/knight.dart';
import 'package:chess_flutter_app/features/chess_board/models/queen.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';
import 'package:chess_flutter_app/common/widgets/square/square_promotion.dart';

import 'package:flutter/material.dart';

class ChessPieceSelector extends StatelessWidget {
  // const ChessPieceSelector(
  //     {super.key, required this.piece, required this.isWhite});
  final Function(ChessPieces) onPieceSelected;
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
          _buildPieceButton(Queen(isWhite: isWhite)),
          _buildPieceButton(Bishop(isWhite: isWhite)),
          _buildPieceButton(Knight(isWhite: isWhite)),
          _buildPieceButton(Rook(isWhite: isWhite)),
        ],
      ),
    );
  }

  Widget _buildPieceButton(ChessPieces chessPiece) {
    return SquarePromotion(
      onTap: () => onPieceSelected(chessPiece),
      isWhite: chessPiece.isWhite,
      piece: chessPiece,
    );
  }
}
