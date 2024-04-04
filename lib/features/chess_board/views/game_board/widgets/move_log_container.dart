import 'package:chess_flutter_app/features/chess_board/controller/move_log_controller.dart';
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
        child: GetX<MoveLogController>(
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
                        width: 60,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                              color: Colors.white60,
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {},
                          child: Text(
                            controller.moveLogs[index],
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                              color: Colors.white60,
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {},
                          child: Text(
                            controller.moveLogs[index],
                            style: const TextStyle(color: Colors.white54),
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
