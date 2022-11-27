import 'package:get/get.dart';

import 'model.dart';

class PetState {
  var map = List.generate(
    10,
    (x) => List.generate(
      13,
      (y) => Point(),
      growable: false,
    ),
    growable: false,
  );
  var cMap = List.generate(130, (index) => PetItem(), growable: false);

  List<List<Point>> get copyMap =>
      map.map((e) => e.map((e) => e).toList()).toList();

  int get petCount =>
      cMap.where((element) => element.type.value != PetType.none).length;
  var gameMode = GameMode.still;

  var selectedItems = RxList<Point>([]);
}
