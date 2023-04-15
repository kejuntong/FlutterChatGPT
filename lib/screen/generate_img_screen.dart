import 'dart:async';

import 'package:flutter/material.dart';
import '../chat_gpt_api/src/model/client/http_setup.dart';
import '../chat_gpt_api/src/model/gen_image/request/generate_image.dart';
import '../chat_gpt_api/src/openai.dart';
import '../constants.dart';

class GenImgScreen extends StatefulWidget {
  const GenImgScreen({Key? key}) : super(key: key);

  @override
  State<GenImgScreen> createState() => _GenImgScreenState();
}

class _GenImgScreenState extends State<GenImgScreen> {
  String img = "";
  late OpenAI openAI;
  StreamSubscription? subscription;

  @override
  void initState() {
    openAI = OpenAI.instance.build(
        token: token,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 6)),
        isLog: true);
    super.initState();
  }

  @override
  void dispose() {
    openAI.genImgClose();
    subscription?.cancel();
    super.dispose();
  }

  void _generateImage() async {
    // TODO: kejun add input text field
    const prompt = "beautiful girl";

    // size 256 is $0.016 each image
    // https://openai.com/pricing
    final request = GenerateImage(prompt, 1,size: ImageSize.size256,responseFormat: Format.url);
    subscription =
        openAI.generateImageStream(request).asBroadcastStream().listen((it) {
      setState(() {
        img = "${it.data?.last?.url}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: ElevatedButton(
                  onPressed: () => _generateImage(),
                  child: const Text("Generate Image"))),
          img == ""
              ? const Text("Loading...")
              : AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(img),
                )
        ],
      ),
    );
  }
}