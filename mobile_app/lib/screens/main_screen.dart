import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pass_fort/backend/two_fac_info.dart';
import 'package:pass_fort/constants/application_consts.dart';
import 'package:pass_fort/screens/add_totp.dart';
import 'package:pass_fort/screens/passwords_screen.dart';
import 'package:pass_fort/screens/two_fac_widget_grid.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double iconSize = 35.0;
  List<TwofacInfo> twoFactorAuthInfoList = [];
  bool twoFacEnabled = false;
  late TwofacInfo selectedService;
  TextEditingController searchController = TextEditingController();

  void filterList() {
    setState(() {
      filteredList = twoFactorAuthInfoList
          .where((item) => item.title
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void resetFilteredList() {
    setState(() {
      filteredList = twoFactorAuthInfoList;
    });
  }

  Future<void> _loadTwoFactorAuthInfoList() async {
    var box = await Hive.openBox<TwofacInfo>('twofacInfoBox');
    List<TwofacInfo> allInfo = box.values.toList();
    setState(() {
      twoFactorAuthInfoList = allInfo;
      filteredList = twoFactorAuthInfoList;
      twoFacEnabled = twoFactorAuthInfoList.isNotEmpty;
      if (twoFacEnabled) {
        selectedService = twoFactorAuthInfoList[0];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTwoFactorAuthInfoList();
    searchController.addListener(() {
      filterList();
    });
  }

  List<TwofacInfo> filteredList = [];
  bool _isSearching = false;
  // ignore: unused_field
  String _searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ApplicationColors.mainScreenColor,
        actions: appBarActions,
      ),
      body: SafeArea(
        child: gridMenu(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var val = Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTotpScreen(),
            ),
          );
          setState(() {
            val.then((_) {
              _loadTwoFactorAuthInfoList();
            });
          });
        },
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  gridMenu() {
    return Column(
      children: <Widget>[
        if (twoFacEnabled)
          TwoFacWidgetGrid(
            twoFacService: selectedService,
          ),
        SizedBox(
          height: 10,
        ),
        buildTwoFactorList()
      ],
    );
  }

  buildTwoFactorList() {
    if (twoFacEnabled) {
      return Wrap(
        children: filteredList.map((TwofacInfo twofacInfo) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.0,
                child: ListTile(
                  leading: Image.memory(base64Decode(twofacInfo.imageBase64)),
                  onTap: () {
                    setState(() {
                      selectedService = twofacInfo;
                      _isSearching = false;
                      _searchQuery = "";
                      searchController.clear();
                      resetFilteredList();
                    });
                  },
                ),
              ),
              SizedBox(height: 1),
              Text(twofacInfo.title),
              SizedBox(height: 20),
            ],
          );
        }).toList(),
      );
    } else {
      return NoTwoFac();
    }
  }

  List<Widget> get appBarActions {
    if (_isSearching) {
      return [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              autofocus: true,
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                border: InputBorder.none,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = "";
              searchController.clear();
              resetFilteredList();
            });
          },
        ),
      ];
    }

    return [
      SizedBox(width: 10),
      IconButton(
        iconSize: iconSize,
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
        icon: const Icon(Icons.search_outlined),
      ),
      Spacer(),
      IconButton(
        iconSize: iconSize,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PasswordsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.lock),
      ),
      Spacer(),
      IconButton(
        iconSize: iconSize,
        onPressed: () {},
        icon: const Icon(Icons.settings_outlined),
      ),
    ];
  }
}

class NoTwoFac extends StatelessWidget {
  const NoTwoFac({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "No 2FA services found\nPress the + button to add a new service",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
