class VersionHelper {
  static bool isNewerVersion(String currentVersion, String newVersion) {
    List<String> currentSplit = currentVersion.split('.');
    List<String> newSplit = newVersion.split('.');

    int currentMajor = int.parse(currentSplit[0]);
    int currentMinor = int.parse(currentSplit[1]);
    int currentPatch = int.parse(currentSplit[2]);

    int newMajor = int.parse(newSplit[0]);
    int newMinor = int.parse(newSplit[1]);
    int newPatch = int.parse(newSplit[2]);

    if (newMajor > currentMajor) return true;
    if (newMinor > currentMinor) return true;
    if (newPatch > currentPatch) return true;

    return false;
  }
}
