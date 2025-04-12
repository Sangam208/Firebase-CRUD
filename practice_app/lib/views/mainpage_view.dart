import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:practice_app/services/db_services.dart';
import 'package:practice_app/views/pages/chats.dart';
import 'package:practice_app/views/pages/explore.dart';
import 'package:practice_app/views/pages/profile.dart';
import 'package:practice_app/views/pages/home.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  DateTime? currentBackPressTime; // store the first back press time
  bool canPopNow = false;
  int requiredSeconds = 2;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: PopScope(
          canPop: canPopNow,
          onPopInvokedWithResult: (didPop, result) {
            DateTime now = DateTime.now();

            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    Duration(seconds: requiredSeconds)) {
              // First back press
              currentBackPressTime = now;
              canPopNow = false; // Prevent popping immediately

              Fluttertoast.showToast(
                msg: 'Press again to exit app',
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                gravity: ToastGravity.BOTTOM,
                fontSize: 16.0,
              );

              // Reset `canPopNow` and `currentBackPressTime` after the required time
              Future.delayed(Duration(seconds: requiredSeconds), () {
                setState(() {
                  canPopNow = false; // Prevent old back press from causing exit
                  currentBackPressTime = null;
                });
              });
            } else if (now.difference(currentBackPressTime!) >=
                Duration(milliseconds: 700)) {
              Fluttertoast.cancel; // Cancel the toast before exiting
              // Second back press within `requiredSeconds`, allow exit
              setState(() {
                canPopNow = true;
              });
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            bottomNavigationBar: Theme(
              data: ThemeData.dark().copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color.fromARGB(255, 192, 103, 161),
                  unselectedItemColor: Colors.white60,
                  selectedFontSize: 0,
                  unselectedFontSize: 0,
                  showSelectedLabels: true,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.house, size: 25),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore, size: 25),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.envelope, size: 25),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.user, size: 25),
                      label: '',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _pageController.jumpToPage(index);
                    });
                  },
                  currentIndex: _selectedIndex,
                ),
              ),
            ),
            body: PageView(
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              children: [Home(), Explore(), Chats(), Profile()],
            ),

            endDrawer: Drawer(
              backgroundColor: Colors.black54,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Colors.redAccent),
                      child: Center(
                        child: Text(
                          'Menu',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Log out',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: Icon(Icons.logout, color: Colors.white60),
                    onTap: () async {
                      String result = await DbServices().logout();
                      if (result == "Logged out") {
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
