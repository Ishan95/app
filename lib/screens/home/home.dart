import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/app/widgets/bottom_nav_bar.dart';
import 'package:app/app/widgets/custom_height_box.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/screens/home/tabs/chat_screen.dart';
import 'package:app/screens/home/tabs/home_screen.dart';
import 'package:app/screens/home/tabs/notification_screen.dart';
import 'package:app/screens/home/tabs/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.index});

  final int index;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.index;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<AccountProvider>(ContextHelper.navigatorKey.currentContext!, listen: false);
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const NotificationScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Column(
        children: [const CustomHeightBox(height: 30), Expanded(child: _widgetOptions.elementAt(_selectedIndex))],
      ),
      bottomNavigationBar: BottomNavBar(onPress: _onItemTapped),
    );
  }
}
