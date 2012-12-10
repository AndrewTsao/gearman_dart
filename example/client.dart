import "package:gearman/gearman.dart";

main() {
  var client = new GearmanClient.connectServer('localhost', 4730);
}
