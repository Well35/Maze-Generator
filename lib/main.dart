import 'package:flutter/material.dart';
import "package:maze_generator/generated_maze_screen.dart";
import "package:maze_generator/home.dart";

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/GeneratedMazeScreen",
    routes: {
      "/Home": (context) => Home(),
      "/GeneratedMazeScreen": (context) => GeneratedMazeScreen(),
  }
));