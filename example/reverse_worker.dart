import "package:gearman/gearman.dart";

main(){
  var worker = new GearmanWorker();
  worker.addServer();
}