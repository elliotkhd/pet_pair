import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_pair/model.dart';
import 'package:pet_pair/state.dart';

var shuffling = false;
const gameTimeLimit = 176;

class PetLogic extends GetxController {
  final state = PetState();
  Timer? counter;

  @override
  void onInit() {
    initMap();
    initSelectedItemListener();
    super.onInit();
  }

  void initMap() {
    // state.gameMode = GameMode.values[Random().nextInt(GameMode.values.length)];
    state.timer.value = gameTimeLimit;
    counter?.cancel();
    counter = Timer.periodic(const Duration(seconds: 1), (timer) {
      state.timer.value--;
      if (state.timer.value == 0) {
        timer.cancel();
        Get.dialog(AlertDialog(
          title: const Text('游戏结束'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                initMap();
              },
              child: const Text('重新开始'),
            ),
          ],
        ));
      }
    });
    var type = Random().nextInt(4);
    state.gameMode = type == 0
        ? GameMode.queueToRight
        : type == 1
            ? GameMode.queueToBottom
            : type == 2
                ? GameMode.queueToTop
                : type == 3
                    ? GameMode.queueToLeft
                    : GameMode.still;
    var items = generatePetItems();
    for (int x = 0; x < 10; x++) {
      for (int y = 0; y < 13; y++) {
        late PetType petType;
        if (x == 0 || x == 9 || y == 0 || y == 12) {
          petType = PetType.none;
        } else {
          petType = items[(x - 1) * 11 + y - 1];
        }
        state.map[x][y] = Point(x, y)..type = petType;
        state.map[x][y].saveLastPosition();
        state.cMap[13 * x + y]
          ..x.value = x
          ..y.value = y
          ..type.value = petType;
      }
    }
  }

  void initSelectedItemListener() {
    state.selectedItems.listen((items) {
      if (items.length == 1) {
        selectItem(items.first);
      } else if (items.length == 2) {
        var success = match(items[0], items[1], state.copyMap);
        debugPrint('$success');
        if (success) {
          unselectedItem(items.first);
          state.cMap
              .firstWhere(
                  (p0) => p0.x.value == items[0].x && p0.y.value == items[0].y)
              .type
              .value = PetType.none;
          state.cMap
              .firstWhere(
                  (p0) => p0.x.value == items[1].x && p0.y.value == items[1].y)
              .type
              .value = PetType.none;

          items[0].type = PetType.none;
          items[1].type = PetType.none;
          moveItems(items[0], items[1]);
          state.selectedItems.value.clear();
          if (state.petCount == 0) {
            initMap();
            return;
          }
          var exist = checkPairExistSync(state.copyMap);
          if (!exist) shuffleItems();
        } else {
          unselectedItem(items.first);
          state.selectedItems.value.removeAt(0);
          selectItem(items.first);
        }
      }
    });
  }

  void swapPoint(Point a, Point b) {
    var lastX = a.lastX;
    var lastY = a.lastY;
    var type = a.type;
    a.lastX = b.lastX;
    a.lastY = b.lastY;
    a.type = b.type;
    b.lastX = lastX;
    b.lastY = lastY;
    b.type = type;
  }

  Point findPoint(int value, GameMode mode) {
    for (int i = 1; i < 9; i++) {
      for (int j = 1; j < 12; j++) {
        if (state.map[i][j].getValue(mode) == value) return state.map[i][j];
      }
    }
    return state.map[0][0];
  }

  void moveItems(Point a, Point b) async {
    for (int i = 1; i < 9; i++) {
      for (int j = 1; j < 12; j++) {
        state.map[i][j].saveLastPosition();
      }
    }
    switch (state.gameMode) {
      case GameMode.still:
        break;
      case GameMode.snakeHTopRight:
      case GameMode.snakeHTopLeft:
      case GameMode.snakeVBottomLeft:
      case GameMode.snakeVBottomRight:
        adjustAllSnakeMode(a, b, state.gameMode);
        break;
      case GameMode.queueToTop:
      case GameMode.queueToBottom:
      case GameMode.queueToLeft:
      case GameMode.queueToRight:
        adjustAllQueueMode(state.gameMode);
        break;
      case GameMode.shrinkTop:
        break;
      case GameMode.shrinkBottom:
        break;
      case GameMode.shrinkLeft:
        break;
      case GameMode.shrinkRight:
        break;
      case GameMode.shrinkTopLeft:
        break;
      case GameMode.shrinkTopRight:
        break;
      case GameMode.shrinkBottomLeft:
        break;
      case GameMode.shrinkBottomRight:
        break;
    }
  }

  void adjustAllQueueMode(GameMode mode) {
    switch (mode) {
      case GameMode.queueToTop:
        for (int i = 1; i < 12; i++) {
          for (int j = 1; j <= 8; j++) {
            swapPoint(state.map[j][i - 1], state.map[j][i]);
          }
        }
        for (int j = 1; j <= 8; j++) {
          swapPoint(state.map[j][11], state.map[j][0]);
        }
        break;
      case GameMode.queueToBottom:
        for (int i = 11; i >= 0; i--) {
          for (int j = 1; j <= 8; j++) {
            swapPoint(state.map[j][i + 1], state.map[j][i]);
          }
        }
        for (int j = 1; j <= 8; j++) {
          swapPoint(state.map[j][1], state.map[j][12]);
        }
        break;
      case GameMode.queueToLeft:
        for (int i = 1; i < 9; i++) {
          for (int j = 1; j <= 11; j++) {
            swapPoint(state.map[i - 1][j], state.map[i][j]);
          }
        }
        for (int j = 1; j <= 11; j++) {
          swapPoint(state.map[0][j], state.map[8][j]);
        }
        break;
      case GameMode.queueToRight:
        for (int i = 8; i >= 0; i--) {
          for (int j = 1; j <= 11; j++) {
            swapPoint(state.map[i + 1][j], state.map[i][j]);
          }
        }
        for (int j = 1; j <= 11; j++) {
          swapPoint(state.map[1][j], state.map[9][j]);
        }
        break;
      default:
        return;
    }

    adjustCMap();
  }

  void adjustAllSnakeMode(Point a, Point b, GameMode mode) {
    int firstLoopLength, secondLoopLength, remainder;
    switch (mode) {
      case GameMode.snakeHTopRight:
        firstLoopLength = 12;
        secondLoopLength = 9;
        remainder = 0;
        break;
      case GameMode.snakeHTopLeft:
        firstLoopLength = 12;
        secondLoopLength = 9;
        remainder = 1;
        break;
      case GameMode.snakeVBottomRight:
        firstLoopLength = 9;
        secondLoopLength = 12;
        remainder = 0;
        break;
      case GameMode.snakeVBottomLeft:
        firstLoopLength = 9;
        secondLoopLength = 12;
        remainder = 0;
        break;
      default:
        return;
    }
    late Point behind, front;
    behind = a.getValue(mode) > b.getValue(mode) ? a : b;
    front = a.getValue(mode) > b.getValue(mode) ? b : a;
    void shrinkOneItem(int j, int i) {
      var value = state.map[j][i].getValue(mode);
      if (value > front.getValue(mode) && value < behind.getValue(mode)) {
        swapPoint(state.map[j][i], findPoint(value - 1, mode));
      } else if (value > front.getValue(mode) &&
          value > behind.getValue(mode)) {
        swapPoint(state.map[j][i], findPoint(value - 2, mode));
      }
    }

    for (int i = 1; i < firstLoopLength; i++) {
      if (i % 2 == remainder) {
        for (int j = 1; j < secondLoopLength; j++) {
          switch (mode) {
            case GameMode.snakeHTopRight:
            case GameMode.snakeHTopLeft:
              shrinkOneItem(j, i);
              break;
            case GameMode.snakeVBottomRight:
            case GameMode.snakeVBottomLeft:
              shrinkOneItem(i, j);
              break;
            default:
              return;
          }
        }
      } else {
        for (int j = secondLoopLength - 1; j >= 1; j--) {
          switch (mode) {
            case GameMode.snakeHTopRight:
            case GameMode.snakeHTopLeft:
              shrinkOneItem(j, i);
              break;
            case GameMode.snakeVBottomRight:
            case GameMode.snakeVBottomLeft:
              shrinkOneItem(i, j);
              break;
            default:
              return;
          }
        }
      }
    }
    adjustCMap();
  }

  void isAfter() {}

  //宠物随机列表，保证每个宠物数量是双数
  List<PetType> generatePetItems() {
    var items = <PetType>[];
    var random = Random();
    late int i1, i2, i3, i4;
    i1 = random.nextInt(40);
    i2 = random.nextInt(40);
    while (i2 == i1) {
      i2 = random.nextInt(40);
    }
    i3 = random.nextInt(40);
    while ([i1, i2].contains(i3)) {
      i3 = random.nextInt(40);
    }
    i4 = random.nextInt(40);
    while ([i1, i2, i3].contains(i4)) {
      i4 = random.nextInt(40);
    }
    for (int i = 0; i < 40; i++) {
      var element = PetType.values[i];
      items.addAll([element, element]);
      if ([i1, i2, i3, i4].contains(i)) items.addAll([element, element]);
    }
    items.shuffle();
    return items;
  }

  bool checkPairExistSync(List<List<Point>> map) {
    for (int i = 1; i < 9; i++) {
      for (int j = 1; j < 12; j++) {
        if (map[i][j].type == PetType.none) continue;
        for (int x = 1; x < 9; x++) {
          for (int y = 1; y < 12; y++) {
            if (map[x][y].type == PetType.none) continue;
            if (match(map[i][j], map[x][y], map)) {
              print('check exist ${map[i][j]}-${map[x][y]}');
              return true;
            }
          }
        }
      }
    }
    print('check not exist');
    return false;
  }

  //没有可以消除的对儿的时候打乱
  void shuffleItems() async {
    if (shuffling) return;
    shuffling = true;
    late List<List<Point>> splitItems;
    //记录每个点打乱前的位置
    for (int x = 1; x < 9; x++) {
      for (int y = 1; y < 12; y++) {
        state.map[x][y].saveLastPosition();
      }
    }
    while (true) {
      splitItems = getShuffledCopy(state.copyMap);
      if (checkPairExistSync(splitItems)) break;
    }
    state.map = splitItems;
    adjustCMap();
    shuffling = false;
  }

  void adjustCMap() {
    for (int x = 1; x < 9; x++) {
      for (int y = 1; y < 12; y++) {
        var item = state.cMap.firstWhere((e) =>
            e.x.value == state.map[x][y].lastX &&
            e.y.value == state.map[x][y].lastY &&
            e.type.value == state.map[x][y].type);
        item.x.value = x;
        item.y.value = y;
      }
    }
  }

  List<List<Point>> getShuffledCopy(List<List<Point>> copyMap) {
    var allItems = <Point>[];
    allItems = copyMap.sublist(1, 9).fold(
        <Point>[], (value, element) => [...value, ...element.sublist(1, 12)]);
    var filledItems = allItems
        .where((e) => e.type != PetType.none)
        .map((e) => e.clone())
        .toList();
    var emptyItems = allItems
        .where((e) => e.type == PetType.none)
        .map((e) => e.clone())
        .toList();
    var random = Random();
    var length = filledItems.length;
    while (length > 1) {
      var pos = random.nextInt(length);
      length--;
      var tmp1 = filledItems[pos].clone();
      var tmp2 = filledItems[length].clone();
      filledItems[pos]
        ..x = tmp2.x
        ..y = tmp2.y;
      filledItems[length]
        ..x = tmp1.x
        ..y = tmp1.y;
    }
    var map = List.generate(
        10, (x) => List.generate(13, (y) => Point(x, y), growable: false),
        growable: false);
    var tmpAll = [...filledItems, ...emptyItems];
    for (int x = 1; x < 9; x++) {
      for (int y = 1; y < 12; y++) {
        map[x][y] =
            tmpAll.firstWhere((element) => element.x == x && element.y == y);
      }
    }
    return map;
  }

  void selectItem(Point point) {
    state.cMap
        .firstWhere((p0) => p0.x.value == point.x && p0.y.value == point.y)
        .selected
        .value = true;
  }

  void unselectedItem(Point point) {
    state.cMap
        .firstWhere((p0) => p0.x.value == point.x && p0.y.value == point.y)
        .selected
        .value = false;
  }

  static bool match(Point a, Point b, List<List<Point>> map) {
    return basicCondition(a, b) &&
        (matchLine(a, b, map) ||
            matchOneTurn(a, b, map) ||
            matchTwoTurn(a, b, map));
  }

  static bool isEmpty(Point a) => a.type == PetType.none;

  static bool basicCondition(Point a, Point b) {
    return !a.equalsByPosition(b) &&
        a.type != PetType.none &&
        b.type != PetType.none &&
        a.type == b.type;
  }

  static bool matchLine(Point a, Point b, List<List<Point>> map) {
    if (a.x == b.x) {
      var minY = min(a.y, b.y);
      var maxY = max(a.y, b.y);
      for (int i = minY + 1; i < maxY; i++) {
        if (!isEmpty(map[a.x][i])) return false;
      }
      return true;
    } else if (a.y == b.y) {
      var minX = min(a.x, b.x);
      var maxX = max(a.x, b.x);
      for (int i = minX + 1; i < maxX; i++) {
        if (!isEmpty(map[i][a.y])) return false;
      }
      return true;
    } else {
      return false;
    }
  }

  static bool matchOneTurn(Point a, Point b, List<List<Point>> map) {
    Point c1 = map[a.x][b.y];
    Point c2 = map[b.x][a.y];
    if (isEmpty(c1) && matchLine(a, c1, map) && matchLine(b, c1, map)) {
      return true;
    } else if (isEmpty(c2) && matchLine(a, c2, map) && matchLine(b, c2, map)) {
      return true;
    }
    return false;
  }

  static bool matchTwoTurn(Point a, Point b, List<List<Point>> map) {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 13; j++) {
        if (!isEmpty(map[i][j])) continue;
        var c = Point(i, j);
        if ((matchLine(a, c, map) && matchOneTurn(c, b, map)) ||
            (matchLine(b, c, map) && matchOneTurn(c, a, map))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> checkPairExistIsolate(List<List<Point>> map) async {
    final p = ReceivePort();
    await Isolate.spawn<List<dynamic>>(checkPairExist, [p.sendPort, map]);
    return await p.first as bool;
  }

  static Future<void> checkPairExist(List<dynamic> parameters) async {
    List<List<Point>> map = parameters[1];
    SendPort p = parameters[0];
    for (int i = 1; i < 9; i++) {
      for (int j = 1; j < 12; j++) {
        if (map[i][j].type == PetType.none) continue;
        for (int x = 1; x < 9; x++) {
          for (int y = 1; y < 12; y++) {
            if (map[x][y].type == PetType.none) continue;
            if (match(map[i][j], map[x][y], map)) {
              print('check exist ${map[i][j]}-${map[x][y]}');
              Isolate.exit(p, true);
            }
          }
        }
      }
    }
    print('check not exist');
    Isolate.exit(p, false);
  }
}
