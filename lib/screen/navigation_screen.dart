import 'package:chat_gpt_exploring/screen/chat_screen.dart';
import 'package:chat_gpt_exploring/screen/edit_img_screen.dart';
import 'package:chat_gpt_exploring/screen/generate_img_screen.dart';
import 'package:chat_gpt_exploring/screen/home_screen.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../drawer/drawer_user_controller.dart';
import '../drawer/home_drawer.dart';
import 'chat_screen_fancy.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const HomeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const HomeScreen();
          });
          break;
        case DrawerIndex.CHAT:
          setState(() {
            screenView = ChatScreenFancy();
          });
          break;
        case DrawerIndex.IMAGE_GEN:
          setState(() {
            // screenView = GenImgScreen();
            screenView = EditImgScreen();
          });
          break;
        case DrawerIndex.MORE:
        default:
          break;
      }
    }
  }
}
