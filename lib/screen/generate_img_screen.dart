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
  String? imgDescription;

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
    super.dispose();
  }

  void _generateImage() async {
    setState(() {
      img = "loading";
    });
    if (imgDescription?.isNotEmpty == true) {
      // size 256 is $0.016 each image
      // https://openai.com/pricing
      final request = GenerateImage(imgDescription!, 1,size: ImageSize.size256,responseFormat: Format.url);

      final response = await openAI.generateImage(request);
      setState(() {
        img = "${response?.data?.last?.url}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AspectRatio(
                aspectRatio: 1.3,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (img == "") {
                        return Image.asset(
                            'assets/images/image-placeholder.jpg',
                            fit: BoxFit.fitHeight);
                      } else if (img == "loading") {
                        return Image.asset(
                          'assets/images/loading-spinner.gif',
                          scale: 1.8,
                        );
                      } else {
                        return Image.network(img);
                      }
                    })),
              ),
            ),
            // Expanded(child: Center(child: Text("test")))
            const SizedBox(height: 25,),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    hintText: 'Enter image description',
                    labelText: 'Image to generate',
                  ),
                  onChanged: (value) {
                    imgDescription = value;
                  },
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                Center(
                    child: ElevatedButton(
                        onPressed: () => _generateImage(),
                        child: const Text("Generate Image"))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
