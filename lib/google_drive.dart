// import 'dart:io';
// import 'package:drive_assignment/secure_storage.dart';
// import 'package:googleapis/drive/v3.dart' as ga;
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as p;
// // import 'package:personal_diary/app/utils/secure_storage.dart';
// import 'package:url_launcher/url_launcher.dart';

// const _clientId = "YOUR CLIENT ID FROM GOOGLE CONSOLE";
// const _scopes = ['https://www.googleapis.com/auth/drive.file'];

// class GoogleDrive {
//   // Get Authenticated Http Client
//   Future<http.Client> getHttpClient() async {
//     // Get Credentials
//     var credentials = await SecureStorageService.getInstance();
//     if (credentials == null) {
//       //Needs user authentication
//       var authClient =
//           await clientViaUserConsent(ClientId(_clientId), _scopes, (url) {
//         //Open Url in Browser
//         launch(url);
//       });
//       return authClient;
//     } else {
//       print(credentials);
//       //Already authenticated
//       return authenticatedClient(
//           http.Client(),
//           AccessCredentials(
//               AccessToken(credentials["type"], credentials["data"],
//                   DateTime.tryParse(credentials["expiry"])!),
//               credentials["refreshToken"],
//               _scopes));
//     }
//   }

// // check if the directory forlder is already available in drive , if available return its id
// // if not available create a folder in drive and return id
// //   if not able to create id then it means user authetication has failed
//   Future<String?> _getFolderId(ga.DriveApi driveApi) async {
//     final mimeType = "application/vnd.google-apps.folder";
//     String folderName = "personalDiaryBackup";

//     try {
//       final found = await driveApi.files.list(
//         q: "mimeType = '$mimeType' and name = '$folderName'",
//         $fields: "files(id, name)",
//       );
//       final files = found.files;
//       if (files == null) {
//         print("Sign-in first Error");
//         return null;
//       }

//       // The folder already exists
//       if (files.isNotEmpty) {
//         return files.first.id;
//       }

//       // Create a folder
//       ga.File folder = ga.File();
//       folder.name = folderName;
//       folder.mimeType = mimeType;
//       final folderCreation = await driveApi.files.create(folder);
//       print("Folder ID: ${folderCreation.id}");

//       return folderCreation.id;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   uploadFileToGoogleDrive(File file) async {
//     var client = await getHttpClient();
//     var drive = ga.DriveApi(client);
//     String? folderId = await _getFolderId(drive);
//     if (folderId == null) {
//       print("Sign-in first Error");
//     } else {
//       ga.File fileToUpload = ga.File();
//       fileToUpload.parents = [folderId];
//       fileToUpload.name = p.basename(file.absolute.path);
//       var response = await drive.files.create(
//         fileToUpload,
//         uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
//       );
//       print(response);
//     }
//   }
// }
