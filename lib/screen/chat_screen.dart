import 'dart:async';
import 'dart:convert';
import 'package:chat_gpt_exploring/chat_gpt_api/chat_gpt_sdk.dart';
import 'package:chat_gpt_exploring/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// text controller
  final _txtWord = TextEditingController();

  late OpenAI openAI;

  final tController = StreamController<CTResponse?>.broadcast();
  final chatController = StreamController<ChatCTResponse?>.broadcast();

  void _testCompletion() async {
    final request = CompleteText(
        prompt: testCompletion(word: _txtWord.text.toString()),
        maxTokens: 200,
        model: kTextDavinci3);

    openAI
        .onCompletionStream(request: request)
        .asBroadcastStream()
        .listen((res) {
      tController.sink.add(res);
    }).onError((err) {
      print("$err");
    });
  }

  void _testChat() async {
    final request = ChatCompleteText(messages: [
      Map.of({"role": "user", "content": testChat(word: _txtWord.text.toString())})
    ], maxToken: 400, model: kChatGptTurboModel);

    openAI
        .onChatCompletionStream(request: request)
        .asBroadcastStream()
        .listen((res) {
      chatController.sink.add(res);
    }).onError((err) {
      print("$err");
    });
  }

  void _chatGpt3Example() async {
    final request = ChatCompleteText(messages: [
      Map.of({"role": "user", "content": 'Hello!'})
    ], maxToken: 200, model: kChatGptTurbo0301Model);

    final response = await openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      print("data -> ${element.message.content}");
    }
  }

  void modelDataList() async {
    final model = await OpenAI.instance.build(token: "").listModel();
  }

  void engineList() async {
    final engines = await OpenAI.instance.build(token: "").listEngine();
  }

  void completeWithSSE() {
    final request = CompleteText(
        prompt: "Hello world", maxTokens: 200, model: kTextDavinci3);
    openAI.onCompletionSSE(
        request: request,
        complete: (it) {
          it.map((data) => utf8.decode(data)).listen((data) {
            ///
            final raw = data
                .replaceAll(RegExp("data: "), '')
                .replaceAll(RegExp("[DONE]"), '');

            /// convert data
            String message = "";
            dynamic mJson = json.decode(raw);
            if (mJson is Map) {
              ///[message]
              message +=
              " ${mJson['choices'].last['text'].toString().replaceAll(RegExp("\n"), '')}";
            }
            debugPrint("${message}");
          }).onError((e) {
            ///handle error
          });
        });
  }

  void chatCompleteWithSSE() {
    final request = ChatCompleteText(messages: [
      Map.of({"role": "user", "content": 'Hello!'})
    ], maxToken: 200, model: kChatGptTurbo0301Model);

    openAI.onChatCompletionSSE(
        request: request,
        complete: (it) {
          it.map((it) => utf8.decode(it)).listen((data) {
            final raw = data
                .replaceAll(RegExp("data: "), '')
                .replaceAll(RegExp("[DONE]"), '')
                .replaceAll("[]", '')
                .trim();

            if (raw != null || raw.isNotEmpty) {
              ///
              final mJson = json.decode(raw);
              if (mJson is Map) {
                debugPrint(
                    "-> :${(mJson['choices'] as List).last['delta']['content'] ?? "not fond content"}");
              }
            }
          }).onError((e) {
            ///handle error
          });
        });
  }

  @override
  void initState() {
    openAI = OpenAI.instance.build(
        token: token,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
        isLog: true);
    super.initState();
  }

  @override
  void dispose() {
    ///close stream complete text
    openAI.close();
    tController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _inputCard(size),
                _resultCard(size),
                _btnTest()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnTest() {
    return ElevatedButton(
      onPressed: () {
        tController.sink.add(null);
        chatController.sink.add(null);
        _testChat();
        // TODO kejun not show why toast not working
        // Fluttertoast.showToast(
        //     msg: "This is a Toast message",
        //     toastLength: Toast.LENGTH_SHORT,
        // );
      },
      child: const Text('Test'),
    );
  }

  Widget _resultCard(Size size) {
    return StreamBuilder<ChatCTResponse?>(
      // stream: tController.stream,
      stream: chatController.stream,
      builder: (context, snapshot) {

        final usage = snapshot.data?.usage.totalTokens ?? 0;
        // Fluttertoast.showToast(
        //     msg: "token used: $usage",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
        // TODO: kejun why tf toast not working ^^
        final content = snapshot.data?.choices.last.message.content ?? "Loading...";
        final text = "token used: $usage\n\n$content"; // TODO kejun, message role
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 32.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Output:"),
                const SizedBox(
                  height: 18,
                ),
                Text(
                  text,
                  style: const TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(
                  width: size.width,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputCard(Size size) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: heroCard,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Input here:"),
              TextField(
                controller: _txtWord,
                autofocus: true,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}