import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart' as p;

final RepositorySlug _repositorySlug = RepositorySlug("kee-org", "keepassrpc");

final searchProgramFiles = [
  "C:\\Program Files\\KeePass Password Safe 2\\Plugins",
  "C:\\Program Files (x86)\\KeePass Password Safe 2\\Plugins",
  "D:\\Program Files\\KeePass Password Safe 2\\Plugins",
  "D:\\Program Files (x86)\\KeePass Password Safe 2\\Plugins",
];
void main(List<String> args) async {
  print("Search for KeePass Path");
  Directory pathTo;
  bool multiplePaths = false;
  for (var path in searchProgramFiles) {
    var dir = Directory(path);

    if (dir.existsSync()) {
      if (pathTo != null) {
        multiplePaths = true;
      }
      print("Found KeePass on $path");
      pathTo = dir;
    }
  }

  if (multiplePaths) {
    print(
        "Found multiple KeePath Paths! Assistance required. At the moment we cannot handle this. It will be terminated within 2 minutes.");
    await Future.delayed(Duration(minutes: 1));
  }
  if (pathTo == null) {
    print(
        "Can't find KeePath. Do you installed it? If not please install it first. Custom paths are not supported.");
  }
  // TODO: Manual set the path

  var gitHub = GitHub(auth: Authentication.anonymous());

  Release release = await gitHub.repositories.getLatestRelease(_repositorySlug);
  var version = release.tagName;
  print("Version: $version");
  print("\n");
  print("Releaseinformationen:");
  print(release.body);

  try {
    for (var file in pathTo.listSync()) {
      print(p.extension(file.path));
      print(p.basename(file.path));
      if (p.extension(file.path) == '.plgx' &&
          p.basenameWithoutExtension(file.path).contains("KeePassRPC")) {
        var basename = p.basename(file.path);

        print("Found existing KeePassRPC Version. ($basename)");
        file.deleteSync();
      }
    }
  } on FileSystemException {
    print(
        "Can't delete files. Maybe this app is not started with privileged permissions?");
    await Future.delayed(Duration(minutes: 1));
    return;
  }

  File keePassRPCfile = File(p.join(pathTo.path, "KeePassRPC.plgx"));

  print("Übertrage Daten");

  var request = await HttpClient()
      .getUrl(Uri.parse(release.assets.first.browserDownloadUrl));
  HttpClientResponse response = await request.close();
  await response.pipe(keePassRPCfile.openWrite());
  print("Übertragung abgeschlossen. Schließe in einer Minute");
  await Future.delayed(Duration(minutes: 1));
}
