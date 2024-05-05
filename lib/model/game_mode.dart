// ignore_for_file: constant_identifier_names

class GameMode {
  int modeFlags; // un selectd mode

  int difficultyIndex; //

  // color piece theme and theme for board
  String pieceTheme;
  String wSquares = '';
  String bSquares = '';

  // timer
  double timer = 0;
  double bonusTime = 0;

  // starting side
  int startingSide = 0; //  0 : white, 1 : black , 2 : random

  static const WhiteSide = 0;
  static const BlackSide = 1;
  static const RandomSide = 2;

  static const VsAiMode = 1;
  static const PassAndPlayMode = 2;

  // difficulty index
  // 0 : no hint and redo, 1 :  allow redo and undo, 2 : allow redo and hint
  static const dNoHintAndRedo = 0;
  static const dNoHintAndAllowedRedo = 1;
  static const dAllowHintAndRedo = 2;

  // Ai Mode (vs Computer Mode)
  int aiDiffcullty = 0; // 1 - 6

  String customFen = "";

  GameMode(this.modeFlags, this.timer, this.bonusTime, this.startingSide, this.aiDiffcullty, this.difficultyIndex, this.customFen, this.pieceTheme, this.bSquares, this.wSquares);
}
