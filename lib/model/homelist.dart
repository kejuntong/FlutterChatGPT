import 'package:chat_gpt_exploring/screen/chat_screen.dart';
import 'package:chat_gpt_exploring/screen/chat_screen_fancy.dart';
import 'package:chat_gpt_exploring/screen/edit_img_screen_step_2.dart';
import 'package:chat_gpt_exploring/screen/generate_img_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.icon,
    this.title = '',
    this.color
  });

  Widget? navigateScreen;
  IconData? icon;
  String title;
  Color? color;

  static List<HomeList> homeList = [
    HomeList(
      icon: Icons.chat,
      title: 'Chat',
      navigateScreen: const ChatScreenFancy(),
      color: Colors.deepOrange
    ),
    HomeList(
      icon: Icons.image,
      title: 'Image Generation',
      navigateScreen: const GenImgScreen(),
      color: Colors.greenAccent
    ),
    HomeList(
        icon: Icons.edit,
        title: 'Image Edit',
        navigateScreen: ImageEditScreen(),
        color: Colors.pinkAccent
    ),
    HomeList(
      icon: Icons.more_horiz,
      title: 'More to come...',
      color: Colors.deepPurple
    ),
  ];
}
