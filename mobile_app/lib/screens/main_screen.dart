import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_fort/backend/two_factor_auth.dart';
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
        auth: TwoFactorAuth(secret: "SLSJHDFJKSHFDKJSHKJFSHKJFDKLFSDD")),
    TwofacInfo(
        image: Image.asset('assets/app_icon.png'),
        title: '2FA 2',
        auth: TwoFactorAuth(secret: "SLSJHDFJKSHFDKJSHKJFSHKJFDALFSDD")),
  ];
  late bool twoFacEnabled;
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
    twoFacEnabled = exampleList.isNotEmpty;
    filteredList = exampleList;
    searchController.addListener(() {
      filterList();
    });
    if (twoFacEnabled) {
      selectedService = exampleList[0];
    }
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
        child: Column(
          children: <Widget>[
            if (twoFacEnabled)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // String data = "";
          // FlutterBarcodeScanner.scanBarcode(
          //         "#000000", "Cancel", true, ScanMode.QR)
          //     .then((value) {
          //   setState(() {
          //     data = value;
          //   });
          // });
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

  Expanded twoFacList() {
    if (twoFacEnabled) {
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
    } else {
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Widget'lar arasını aç
        children: [
          Column(
            children: [
              SizedBox(height: 25),
              SizedBox(
                width: 100.0, // Adjust the width as needed
                height: 100.0, // Adjust the height as needed
                child: twoFacService.image,
              ),
              SizedBox(height: 25),
              Text(
                twoFacService.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<int>(
                stream:
                    Stream.periodic(Duration(seconds: 1), (int count) => count),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000) %
                        twoFacService.auth.period;
                    var tsCalculated = twoFacService.auth.period - ts;
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          twoFacService.auth.generate(),
                          style: const TextStyle(
                              fontSize: 45, fontWeight: FontWeight.bold),
                        ),
                        // SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 90),
                            Text(
                              'Your code expires in $tsCalculated seconds',
                              style: const TextStyle(fontSize: 15),
                            ),
                            SizedBox(width: 25),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: twoFacService.auth.generate()));
                                },
                                icon: Icon(Icons.copy),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
            child: StreamBuilder<int>(
              stream: Stream.periodic(
                  Duration(milliseconds: 1000), (count) => count),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  var currentTime =
                      (DateTime.now().millisecondsSinceEpoch ~/ 1000) %
                          twoFacService.auth.period;
                  var remainingTime = twoFacService.auth.period -
                      (currentTime % twoFacService.auth.period);
                  var progress = remainingTime / twoFacService.auth.period;

                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                } else {
                  return LinearProgressIndicator(
                    value: 0,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
