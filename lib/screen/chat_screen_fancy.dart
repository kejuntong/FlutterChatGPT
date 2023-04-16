import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../chat_gpt_api/src/model/chat_complete/request/ChatCompleteText.dart';
import '../chat_gpt_api/src/model/client/http_setup.dart';
import '../chat_gpt_api/src/openai.dart';
import '../chat_gpt_api/src/utils/constants.dart';
import '../chat_ui_sdk/src/widgets/chat.dart';
import '../constants.dart';

class ChatScreenFancy extends StatefulWidget {
  const ChatScreenFancy({super.key});

  @override
  State<ChatScreenFancy> createState() => _ChatScreenFancyState();
}

class _ChatScreenFancyState extends State<ChatScreenFancy> {
  late OpenAI openAI;
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: 'ab6ba2f0-10e0-4a7f-a665-bfd8687f1355',
  );
  final _ai = const types.User(
    firstName: 'Chat',
    lastName: 'GPT',
    id: '011aa867-b71a-446f-a537-078a77f226e4',
  );

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage);

    String replyMessageId = const Uuid().v4();
    final replyMessage = types.TextMessage(
      author: _ai,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: replyMessageId,
      text: "......",
    );
    _addMessage(replyMessage);
    _chatRequest(message.text, replyMessageId);
  }

  void _chatRequest(String userMessage, String replyMessageId) async {
    final request = ChatCompleteText(messages: [
      Map.of({"role": "user", "content": userMessage})
    ], maxToken: 400, model: kChatGptTurboModel);

    final response = await openAI.onChatCompletion(request: request).catchError(
        (error) => _updateMessage(error.toString(), replyMessageId));
    String? replyMessageText = response?.choices.last.message.content;
    if (replyMessageText != null) {
      _updateMessage(replyMessageText, replyMessageId);
    }
  }

  void _updateMessage(String newMessage, String messageId) {
    final index = _messages.indexWhere((element) => element.id == messageId);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      text: newMessage,
      // createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }
}
