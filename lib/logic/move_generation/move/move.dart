import 'package:chess_flutter_app/logic/board/piece.dart';

class Move {
  final int start;
  final int end;
  int promotionType;

  Move(this.start, this.end, {this.promotionType = Piece.None});

  // Method to convert Move instance to serializable data
  Map<String, dynamic> toSerializableData() {
    return {
      'start': start,
      'end': end,
      'promotionType': promotionType,
    };
  }

  // Static factory method to create Move instance from serializable data
  factory Move.fromSerializableData(Map<String, dynamic> data) {
    return Move(
      data['start'],
      data['end'],
      promotionType: data['promotionType'] ?? Piece.None,
    );
  }
}
