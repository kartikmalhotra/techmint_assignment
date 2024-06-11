import 'dart:io';

import 'package:drive_assignment/Screen/googleHttpClient.dart';
import 'package:drive_assignment/Screen/login.dart';
import 'package:drive_assignment/secure_storage.dart';
import 'package:drive_assignment/shared/models/user_models.dart';
import 'package:drive_assignment/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drive_assignment/Screen/files.dart';
import 'package:drive_assignment/Screen/homeScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:googleapis/drive/v2.dart' as ga;
import 'package:path/path.dart' as path;

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Drive Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Google Drive Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _widgetBody = HomeScreen();
  int _currrentIndex = 0;
  ga.DriveApi? driveApi;
  List<ga.File> _files = [];

  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  void _onItemTapped(int index) async {
    setState(() {
      if (index == 0) {
        _currrentIndex = index;
        _widgetBody = HomeScreen();
      } else if (index == 1) {
        _currrentIndex = index;
        _widgetBody = const Center(
          child: Text('Hell'),
        );
      } else if (index == 2) {
        _currrentIndex = index;
        _widgetBody = const Center(
          child: Text('Hell'),
        );
      } else if (index == 3) {
        _currrentIndex = index;
        _widgetBody = MyDriveScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  searchDriveFormFeild(),
                ];
              },
              body: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  return _displayDriveCard(_files[index]);
                },
              ),
            ),
            if (showLoader) ...[
              const Center(child: CircularProgressIndicator()),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _uploadFile(),
        isExtended: true,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currrentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blue.shade700,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: _currrentIndex == 0
                  ? const Icon(
                      Icons.home,
                      size: 25,
                    )
                  : const Icon(Icons.home_outlined, size: 25),
              label: "Home"),
          BottomNavigationBarItem(
              icon: _currrentIndex == 1
                  ? const Icon(
                      Icons.star,
                      size: 25,
                    )
                  : const Icon(Icons.star_border_outlined, size: 25),
              label: "Starred"),
          BottomNavigationBarItem(
              icon: _currrentIndex == 2
                  ? const Icon(
                      Icons.supervised_user_circle,
                      size: 25,
                    )
                  : const Icon(Icons.supervised_user_circle, size: 25),
              label: "Shared"),
          BottomNavigationBarItem(
              icon: _currrentIndex == 3
                  ? const Icon(
                      Icons.folder,
                      size: 25,
                    )
                  : const Icon(Icons.folder_open, size: 25),
              label: "Files"),
        ],
      ),
    );
  }

  Future<void> _uploadFile() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles();

      // Load Google credentials from a file.

      final googleAuthData = await GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/drive'],
      ).signIn();

      if (googleAuthData == null) {
        return;
      }

      final client = GoogleHttpClient(await googleAuthData.authHeaders);

      // var driveApi = ga.DriveApi(client);
      File? file = await _pickFile();
      if (mounted) {
        showLoader = true;
        setState(() {});
      }
      if (file != null) {
        final driveApi = ga.DriveApi(client);
        final ga.File driveFile = ga.File();
        driveFile.originalFilename = file.path.split("/").last;

        await driveApi.files
            .insert(
          driveFile,
          uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
        )
            .whenComplete(() {
          Utils.showSuccessToast("File successfully uploaded");
        }).onError((error, stackTrace) {
          Utils.showSuccessToast("Something went wrong, Unable to upload file");
          return Future.value(null);
        });

        if (mounted) {
          showLoader = false;
          setState(() {});
        }

        // Retrieve list of files
        await _listFiles();
      }
    } catch (exe) {}
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Widget _displayDriveCard(ga.File file) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(file.iconLink ?? ""),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    file.originalFilename ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                const SizedBox(width: 20.0),
                const Icon(Icons.more_vert),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchDriveFormFeild() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: SliverAppBar(
        toolbarHeight: 80,
        pinned: false,
        backgroundColor: Colors.white,
        title: Container(
          child: Material(
            elevation: 2,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 50,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: "Search in Drive",
                    border: InputBorder.none,
                    icon: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Icon(Icons.dehaze)),
                    suffixIcon: InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: ElevatedButton(
                              child: const Text("Logout"),
                              onPressed: () async {
                                try {
                                  await FirebaseAuth.instance.signOut();
                                  GoogleSignIn googleSignIn = GoogleSignIn();
                                  googleSignIn.signOut();
                                  await SecureStorageService.getInstance()!
                                      .deleteAllDataFromSecureStorage();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()));
                                } catch (exe) {}
                              },
                            ),
                          );
                        },
                      ),
                      child: Container(
                        height: 5,
                        width: 5,
                        margin: const EdgeInsets.all(5),
                        child: CircleAvatar(
                          radius: 14.0,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 14.0,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(AppUser.photoUrl),
                          ),
                        ),
                      ),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _listFiles() async {
    // Load Google credentials from a file.

    final googleAuthData = await GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/drive'],
    ).signIn();

    if (googleAuthData == null) {
      return;
    }
    final client = GoogleHttpClient(await googleAuthData.authHeaders);
    var driveApi = ga.DriveApi(client);
    var files = await driveApi.files.list();
    setState(() {
      _files = files.items!;
    });
  }
}
