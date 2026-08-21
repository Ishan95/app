import 'package:app/app/export.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/screens/notification/tab_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int selectIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - 10.0,
      child: Consumer<AccountProvider>(
        builder: (context, acc, child) {
          // if(acc.appUser?.isEnable == false){
          //   return Center(
          //     child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             'Your account has been disabled. Please contact support for more information.',
          //             style: const TextStyle(color: Colors.red),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          //     ),
          //   );
          // }
          return Column(
        children: [
          SizedBox(
            height: context.verticalSize(40),
          ),
          Center(
            child: Text(
              "Notifications",
              style: context.semiBold20(color: Colors.white),
            ),
          ),
          SizedBox(
            height: context.verticalSize(20),
          ),
          Padding(
            padding: context.padding(horizontal: 24, vertical: 16),
            child: Container(
              height: context.verticalSize(50),
              decoration: BoxDecoration(
                  color: ColorManager.white10,
                  borderRadius: BorderRadius.circular(25.0)),
              child: TabBar(
                onTap: (value) => setState(() {}),
                controller: _tabController,
                labelColor: ColorManager.black,
                labelStyle: context.bold12(color: ColorManager.black),
                labelPadding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicatorColor: ColorManager.white,
                indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ColorManager.gradientButtons2,
                      begin: const Alignment(1.00, -0.00),
                      end: const Alignment(-1, 0),
                    ),
                    borderRadius: BorderRadius.circular(40.0)),
                unselectedLabelColor: ColorManager.disabledText,
                tabs: const [
                  Tab(
                    text: "New",
                  ),
                  Tab(
                    text: "Read",
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: context.verticalSize(10),
          ),
          _tabController!.index == 0
              ? Padding(
                  padding: context.padding(horizontal: 24),
                  // child: 
                )
              : SizedBox.shrink(),
          SizedBox(
            height: context.verticalSize(10),
          ),
          Expanded(
            child: Padding(
              padding: context.padding(horizontal: 15),
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TabView(index: 1),
                  TabView(index: 2),
                ],
              ),
            ),
          ),
          SizedBox(
            height: context.verticalSize(50),
          ),
        ],
      );
        })
    );
  }
}