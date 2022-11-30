import 'package:get/get.dart';

class PetItem {
  var x = RxInt(0);
  var y = RxInt(0);
  var type = Rx<PetType>(PetType.none);
  var selected = RxBool(false);

  PetItem();

  @override
  String toString() => '[${x.value},${y.value},${type.value.name}]';
}

class Point {
  int x, y;

  int lastX = 0, lastY = 0;
  PetType type;

  Point([this.x = 0, this.y = 0, this.type = PetType.none]);

  @override
  String toString() => '[$x,$y,${type.name}]';

  Point clone() => Point(x, y, type)
    ..lastX = lastX
    ..lastY = lastY;

  void saveLastPosition() {
    lastX = x;
    lastY = y;
  }

  bool equalsByPosition(Point other) {
    return other.x == x && other.y == y;
  }

  int getValue(GameMode mode) {
    switch (mode) {
      case GameMode.snakeHTopRight:
        var inOddLine = y % 2 == 1;
        return 8 * (y - 1) + (inOddLine ? (8 - x + 1) : x);
      case GameMode.snakeHTopLeft:
        var inOddLine = y % 2 == 1;
        return 8 * (y - 1) + (inOddLine ? x : (8 - x + 1));
      case GameMode.snakeVBottomRight:
        var inOddLine = x % 2 == 1;
        return 11 * (8 - x) + (inOddLine ? y : (11 - y + 1));
      case GameMode.snakeVBottomLeft:
        var inOddLine = x % 2 == 1;
        return 11 * (x - 1) + (inOddLine ?  (11 - y + 1): y);

      default:
        return 0;
    }
  }

  bool isAfter(Point other, GameMode mode) =>
      getValue(mode) > other.getValue(mode);
}

enum GameMode {
  still,
  snakeHTopLeft,
  snakeHTopRight,
  snakeVBottomLeft,
  snakeVBottomRight,
  queueToTop,
  queueToBottom,
  queueToLeft,
  queueToRight,
  shrinkTop,
  shrinkBottom,
  shrinkLeft,
  shrinkRight,
  shrinkTopLeft,
  shrinkTopRight,
  shrinkBottomLeft,
  shrinkBottomRight,
}

enum PetType {
  bat, //蝙蝠==
  cat, //猫
  chameleon, //变色龙
  cow, //奶牛==
  deer, //圣诞鹿==
  dog, //黄狗
  dogRed, //红狗==
  dolphin, //海豚==
  elephant, //大象==
  fox, //狐狸
  frog, //青蛙
  hedgehog, //刺猬
  horse, //马
  jay, //松鸦==
  koala, //考拉
  lion, //狮子==
  lionFire, //火狮子==
  lizard, //蜥蜴==
  monkey, //猴子
  monkeyPurple, //紫猴
  mouse, //老鼠
  owl, //猫头鹰
  parrot, //鹦鹉==
  parrotBig, //大头鹦鹉==
  peacock, //孔雀
  penguin, //企鹅
  pig, //猪
  rabbit, //兔子
  rhino, //犀牛
  seal, //海豹
  sheep, //绵羊==
  sheepBig, //蓝脸绵羊
  smurfs, //蓝精灵==
  snail, //蜗牛
  squirrel, //松鼠==
  stegosaurus, //剑龙
  tiger, //老虎==
  tRex, //霸王龙==
  triceratops, //三角龙
  whale, //蓝鲸
  none, //空
}
