import 'package:flutter/material.dart';
import "dart:ui";
import "dart:typed_data";
import "dart:math";
import 'package:stack/stack.dart' as stack;


class Maze extends StatefulWidget {
  const Maze({super.key, mazeSize});
  final mazeSize = 20; //in terms of cells
  final cellSize = 16;

  //const Maze(int mazeSize);

  @override
  State<Maze> createState() => _MazeState();
}

class _MazeState extends State<Maze> {

  dynamic pngBytes;
  List<Cell> cells = [];
  Paint paint = Paint();
  Widget body = SizedBox(width: 400, height: 400,);
  Cell? current;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setMaze();
  }

  @override
  void didUpdateWidget(covariant Maze oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    cells.clear();
    setMaze();
  }

  void setMaze() async {
    await generateMaze();
    await calculateMaze();
    await drawMaze();
  }

  Future<void> drawMaze() async {
    PictureRecorder recorder = PictureRecorder();
    Canvas c = Canvas(recorder);
    paint.blendMode = BlendMode.darken;
    paint.strokeWidth = 2;
    for (var cell in cells) {
      paint.color = Colors.white;
      c.drawRect(cell.r!, paint);
      for (var wall in cell.walls) {
        //print("wall: (${wall.x1}, ${wall.y1}) to (${wall.x2}, ${wall.y2})");
        paint.color = Colors.black;
        if (wall.isVisible) c.drawLine(Offset(wall.x1!.toDouble(), wall.y1!.toDouble()), Offset(wall.x2!.toDouble(), wall.y2!.toDouble()), paint);
      }
    }
    //print(cells.length);
    Picture p = recorder.endRecording();
    var x = await p.toImage(widget.mazeSize * widget.cellSize + 3,widget.mazeSize * widget.cellSize + 3);
    pngBytes = await x.toByteData(format: ImageByteFormat.png);
    body = Image.memory(Uint8List.view(pngBytes!.buffer));
  }

  Future<void> generateMaze() async {
      for (int i = 0; i < widget.mazeSize; i++) {
        for (int j = 0; j < widget.mazeSize; j++) {
          Cell c = Cell(
              i * widget.cellSize, j * widget.cellSize, widget.cellSize, widget
              .cellSize); // = Rect.fromLTWH(j.toDouble() * widget.cellSize, i.toDouble() * widget.cellSize, widget.cellSize.toDouble(), widget.cellSize.toDouble());
          cells.add(c);
        }
      }
    current = cells.first;
  }

  Future<void> calculateMaze() async {
    stack.Stack<Cell> s = stack.Stack();
    current!.walls[0].isVisible = false;
    cells.last.walls[2].isVisible = false;
    while (true) {
      current!.visited = true;
      int x = current!.r!.topLeft.dx.toInt() ~/ widget.cellSize;
      int y = current!.r!.topLeft.dy.toInt() ~/ widget.cellSize;
      //print("($x, $y) -- (${current!.r!.topLeft.dx.toInt()}, ${current!.r!.topLeft.dy.toInt()})");

      Cell? top, right, bottom, left, next;

      List<Cell> adjacentCells = [];
      //var i = current!.r!.topLeft.dx.toInt() + current!.r!.topLeft.dy.toInt() * widget.mazeSize;
      if (getIndex(x, y - 1) > 0) top = cells[getIndex(x, y - 1)];
      if (getIndex(x + 1, y) > 0) right = cells[getIndex(x + 1, y)];
      if (getIndex(x, y + 1) > 0) bottom = cells[getIndex(x, y + 1)];
      if (getIndex(x - 1, y) > 0) left = cells[getIndex(x - 1, y)];

      if (top != null && !top.visited) adjacentCells.add(top);
      if (right != null && !right.visited) adjacentCells.add(right);
      if (bottom != null && !bottom.visited) adjacentCells.add(bottom);
      if (left != null && !left.visited) adjacentCells.add(left);

      if (adjacentCells.isNotEmpty) {
        Random rnd = Random();
        int ri = rnd.nextInt(adjacentCells.length);
        next = adjacentCells[ri];
        s.push(current!);
        removeWall(current!, next);
        current = next;
      }
      else if (s.length > 0) {
        current = s.pop();
      }
      else {
        build(context);
        break;
      }
    }
  }

  int getIndex(int x, int y) {
    if (x < 0 || y < 0 || x > widget.mazeSize-1 || y > widget.mazeSize-1) {
      return -1;
    }
    return y + x * widget.mazeSize;
  }

  void removeWall(Cell a, Cell b) {
    int x = (a.r!.topLeft.dx.toInt() ~/ widget.cellSize) - (b.r!.topLeft.dx.toInt() ~/ widget.cellSize);
    int y = (a.r!.topLeft.dy.toInt() ~/ widget.cellSize) - (b.r!.topLeft.dy.toInt() ~/ widget.cellSize);

    if (x == 1) {
      a.walls[3].isVisible = false;
      b.walls[1].isVisible = false;
    }
    else if  (x == -1) {
      a.walls[1].isVisible = false;
      b.walls[3].isVisible = false;
    }

    if (y == 1) {
      a.walls[0].isVisible = false;
      b.walls[2].isVisible = false;
    }
    else if  (y == -1) {
      a.walls[2].isVisible = false;
      b.walls[0].isVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return body;
  }
}

class Cell {
  Rect? r;
  List<Wall> walls = []; // from TRBL
  bool visited = false;

  Cell(int x, int y, int w, int h) {
    r = Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());
    walls.add(Wall(x, y, x + w, y)); // top wall
    walls.add(Wall(x + w, y, x + w, y + h)); // right wall
    walls.add(Wall(x + w, y + h, x, y + h)); // bottom wall
    walls.add(Wall(x, y, x, y + h)); // left wall
  }
}

class Wall {
  int? x1, x2, y1, y2;
  bool isVisible = true;
  Wall(this.x1, this.y1, this.x2, this.y2);
}