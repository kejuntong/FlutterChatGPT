import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../image_processor.dart';
import 'edit_img_screen_step_2.dart';

class EditImgScreen extends StatefulWidget {
  const EditImgScreen({Key? key}) : super(key: key);

  @override
  State<EditImgScreen> createState() => _EditImgScreenState();
}

class _EditImgScreenState extends State<EditImgScreen> {

  @override
  void initState() {
    super.initState();
  }

  _enterImageEditController() async {
    final imageBytes = await ImageProcessor.getImageBytesAsset('assets/images/image-placeholder.jpg');
    final bgImageBytes = await ImageProcessor.getImageBytesAsset('assets/images/supportIcon.png');
    ui.decodeImageFromList(imageBytes, (result) async {
      ui.decodeImageFromList(bgImageBytes, (bgResult) async {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) => ImageEditScreen(
              imageBytes: imageBytes,
              bgImageBytes: bgImageBytes,
              image: result,
              bgImage: bgResult,
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 66, 66),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                _enterImageEditController();
              },
              child: const Text(
                'ImageEdit Controller',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
