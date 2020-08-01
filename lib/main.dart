import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart';

final RepositorySlug _repositorySlug = RepositorySlug("kee-org", "keepassrpc");

final searchProgramFiles = [
  "C:\\Program Files\\KeePass Password Safe 2\\Plugins",
  "C:\\Program Files (x86)\\KeePass Password Safe 2\\Plugins",
  "D:\\Program Files\\KeePass Password Safe 2\\Plugins",
  "D:\\Program Files (x86)\\KeePass Password Safe 2\\Plugins",
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

  if(multiplePaths){
    print("Found multiple KeePath Paths! Assistance required.");
  }
  // TODO: Manual set the path


  var gitHub = GitHub(auth: Authentication.anonymous());

  Release release = await gitHub.repositories.getLatestRelease(_repositorySlug);
  var version = release.tagName;
  print("Version $version");
  print(release.body);

  release.
}
