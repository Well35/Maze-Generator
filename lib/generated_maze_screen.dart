import 'package:flutter/material.dart';
import 'maze.dart';
import 'package:screenshot/screenshot.dart';
import "dart:typed_data";
import 'package:image_gallery_saver/image_gallery_saver.dart';

class GeneratedMazeScreen extends StatefulWidget {
  const GeneratedMazeScreen({super.key});

  @override
  State<GeneratedMazeScreen> createState() => _GeneratedMazeScreenState();
}

class _GeneratedMazeScreenState extends State<GeneratedMazeScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  Maze maze = Maze();
  Uint8List? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),
        title: const Text("Maze Generator"),
      ),
      backgroundColor: Colors.blue[200],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Screenshot(
                child: maze,
                controller: screenshotController
            ),
            const SizedBox(height: 20,),
            Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      maze = Maze();
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Generate New Maze",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                )
            ),
            const SizedBox(height: 10,),
            Center(
                child: TextButton(
                  onPressed: () {
                    screenshotController.capture().then((img) {
                      imageFile = img;
                      ImageGallerySaver.saveImage(imageFile!);
                    });
                    print("captured");
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                  ),
                  child: const Text(
                    "Save to Gallery",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
