import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_pair/logic.dart';
import 'package:pet_pair/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final logic = Get.put(PetLogic());
  late final state = logic.state;
  late double itemSize;

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    itemSize = (MediaQuery.of(context).size.width + 60) / 10;
    return Scaffold(
      backgroundColor: const Color(0xff130825),
      body: Stack(
        children: [
          ...List.generate(
            130,
            (i) => Obx(
              () => AnimatedPositioned(
                curve: Curves.decelerate,
                top: state.cMap[i].y.value * itemSize + 100,
                left: state.cMap[i].x.value * itemSize - 30,
                duration: const Duration(milliseconds: 300),
                child: state.cMap[i].type.value == PetType.none
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () {
                          var item = state.cMap[i];
                          state.selectedItems
                              .add(state.map[item.x.value][item.y.value]);
                        },
                        child: Stack(
                          children: [
                            Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                    color: state.cMap[i].selected.value
                                        ? const Color(0xffbcd5ff)
                                        : const Color(0xffdcffbc),
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    borderRadius: BorderRadius.circular(3)),
                                margin: const EdgeInsets.all(0.5),
                                height: itemSize - 1,
                                width: itemSize - 1,
                              ),
                            ),
                            Obx(() {
                              return Image.asset(
                                'assets/pets/${state.cMap[i].type.value.name}.png',
                                width: itemSize,
                                height: itemSize - 1,
                              );
                            })
                          ],
                        ),
                      ),
              ),
            ),
          ).toList(),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Obx(() => LinearProgressIndicator(
                    value: state.timer.value / gameTimeLimit,
                    minHeight: 20,
                  )),
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 15),
          FloatingActionButton(
            child: const Icon(Icons.restart_alt),
            onPressed: () => logic.initMap(),
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            child: const Icon(Icons.shuffle),
            onPressed: () {
              logic.shuffleItems();
            },
          ),
        ],
      ),
    );
  }
}
