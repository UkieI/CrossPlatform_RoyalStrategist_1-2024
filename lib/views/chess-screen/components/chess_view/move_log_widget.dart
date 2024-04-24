import 'package:chess_flutter_app/controller/chess_board_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoveLogContainer extends StatelessWidget {
  const MoveLogContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        height: 40,
        child: GetX<ChessBoardController>(
          builder: (controller) {
            return ListView.builder(
              itemCount: controller.moveLogs.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index % 2 == 0) {
                  return Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        '${index ~/ 2}.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                                color: Colors.white60, fontSize: 14),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {},
                          child: Text(
                            controller.moveLogs[index],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      SizedBox(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {},
                          child: Text(
                            controller.moveLogs[index],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
