import 'package:flutter/material.dart';
import 'package:pass_fort/backend/twofac_info.dart';
import 'package:pass_fort/constants/application_consts.dart';

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
  bool iconButtonSelection = true;
  double iconSize = 35.0;
  List<TwofacInfo> exampleList = [
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 1',
      twoFacKey: '2fac1',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 2',
      twoFacKey: '2fac2',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 3',
      twoFacKey: '2fac3',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 4',
      twoFacKey: '2fac4',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 5',
      twoFacKey: '2fac5',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 6',
      twoFacKey: '2fac6',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 7',
      twoFacKey: '2fac7',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 8',
      twoFacKey: '2fac8',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 9',
      twoFacKey: '2fac9',
    ),
    TwofacInfo(
      image: Image.asset('assets/app_icon.png'),
      title: '2FA 10',
      twoFacKey: '2fac10',
    ),
  ];
  late TwofacInfo selectedService;
  TextEditingController searchController = TextEditingController();

  void filterList() {
    setState(() {
      filteredList = exampleList
          .where((item) => item.title
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void resetFilteredList() {
    setState(() {
      filteredList = exampleList;
    });
  }

  @override
  void initState() {
    super.initState();
    filteredList = exampleList;
    searchController.addListener(() {
      filterList();
    });
    selectedService = exampleList[0];
  }

  List<TwofacInfo> filteredList = [];
  bool _isSearching = false;
  String _searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ApplicationColors.mainScreenColor,
        actions: appBarActions,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              TwoFacWidget(
                twoFacService: selectedService,
              ),
              SizedBox(
                height: 10,
              ),
              twoFacList()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Expanded twoFacList() {
    return Expanded(
        child: SingleChildScrollView(
      child: Wrap(
        spacing: 8.0, // Yatay boşluk
        runSpacing: 8.0, // Dikey boşluk
        children: filteredList.map((TwofacInfo twofacInfo) {
          return SizedBox(
            width: 200.0,
            child: ListTile(
              leading: twofacInfo.image,
              title: Text(twofacInfo.title),
              onTap: () {
                setState(() {
                  selectedService = twofacInfo;
                  _isSearching = false;
                  _searchQuery = ""; // Arama alanını temizle
                  searchController.clear(); // Arama alanını temizle
                  resetFilteredList();
                });
              },
            ),
          );
        }).toList(),
      ),
    ));
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
              _searchQuery = ""; // Arama alanını temizle
              searchController.clear(); // Arama alanını temizle
              resetFilteredList();
            });
          },
        ),
      ];
    }

    return [
      SizedBox(width: 10),
      IconButton(
        iconSize: iconSize, // Increase the icon size
        onPressed: () {
          setState(() {
            _isSearching = true; // Arama modunu aç
          });
        },
        icon: const Icon(Icons.search_outlined),
      ),
      Spacer(),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(150),
            shape: BoxShape.rectangle,
            color: ApplicationColors
                .appBarContainerColor, // Add a color to make it visible
          ),
          child: Row(
            children: [
              Container(
                decoration: !iconButtonSelection
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        shape: BoxShape.rectangle,
                        color: ApplicationColors.appBarSelectedIconButtonColor)
                    : null,
                child: IconButton(
                  iconSize: iconSize / 1.5, // Increase the icon size
                  onPressed: () {
                    setState(() {
                      iconButtonSelection = false;
                    });
                  },
                  icon: Icon(
                    Icons.menu,
                    color: !iconButtonSelection ? Colors.white : null,
                  ),
                ),
              ),
              Container(
                decoration: iconButtonSelection
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        shape: BoxShape.rectangle,
                        color: ApplicationColors.appBarSelectedIconButtonColor)
                    : null,
                child: IconButton(
                  iconSize: iconSize / 1.5, // Increase the icon size
                  onPressed: () {
                    setState(() {
                      iconButtonSelection = true;
                    });
                  },
                  icon: Icon(
                    Icons.apps_sharp,
                    color: iconButtonSelection ? Colors.white : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Spacer(),
      IconButton(
        iconSize: iconSize, // Increase the icon size
        onPressed: () {},
        icon: const Icon(Icons.settings_outlined),
      ),
    ];
  }
}

class TwoFacWidget extends StatelessWidget {
  final TwofacInfo twoFacService;
  const TwoFacWidget({
    super.key,
    required this.twoFacService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 325.0,
      color: ApplicationColors.mainScreenColor,
      child: Column(
        children: [
          SizedBox(
            height: 25,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100.0, // Adjust the width as needed
                height: 100.0, // Adjust the height as needed
                child: twoFacService.image,
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Text(twoFacService.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
