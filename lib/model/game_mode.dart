// ignore_for_file: constant_identifier_names

class GameMode {
  int modeFlags; // un selectd mode

  final int difficultyIndex; //

  // color piece theme and theme for board
  String pieceTheme;
  String wSquares = '';
  String bSquares = '';

  // timer
  final double timer;
  final double bonusTime;

  // starting side
  int startingSide = 0; //  0 : white, 1 : black , 2 : random

  static const WhiteSide = 0;
  static const BlackSide = 1;
  static const RandomSide = 2;

  static const VsAiMode = 1;
  static const PassAndPlayMode = 2;
  static const CustomBoardMode = 0;

  // difficulty index
  // 0 : no hint and redo, 1 :  allow redo and undo, 2 : allow redo and hint
  static const dNoHintAndRedo = 0;
  static const dNoHintAndAllowedRedo = 1;
  static const dAllowHintAndRedo = 2;

  // Ai Mode (vs Computer Mode)
  int aiDiffcullty; // 1 - 6

  final String customFen;

  GameMode({
    required this.modeFlags,
    required this.pieceTheme,
    required this.bSquares,
    required this.wSquares,
    this.startingSide = -1,
    this.aiDiffcullty = -1,
    this.timer = 0,
    this.bonusTime = 0,
    this.difficultyIndex = -1,
    this.customFen = "",
  });
}
