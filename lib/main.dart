import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_pair/controller.dart';
import 'package:pet_pair/model.dart';

void main() {
  var tmp1 = List.generate(3, (index) => List.generate(4, (i) => Point()));
  var tmp2 = List.generate(12, (index) => Point());
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {}
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final controller = Get.put(PetController());
  late final state = controller.state;
  late double itemSize;

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    itemSize = (MediaQuery.of(context).size.width + 60) / 10;
    return Scaffold(
      backgroundColor: const Color(0xff130825),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
        child: Stack(
          children: List.generate(
            130,
            (i) => Obx(
              () => AnimatedPositioned(
                top: state.cMap[i].y.value * itemSize,
                left: state.cMap[i].x.value * itemSize - 30,
                duration: const Duration(milliseconds: 500),
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
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              // for (var element in state.cMap) {
              //   element.y.value = element.y.value + itemSize;
              // }
              controller.shuffleItems();
            },
          ),
        ],
      ),
    );
  }
}
