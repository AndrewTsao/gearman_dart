import "package:gearman/gearman.dart";

main(){
  var worker = new GearmanWorker();
  worker.addServer();
  worker.addFunction("echo", echo);
}

List<int> echo(List<int> jobHandle, String echo, List<int> data) {
  return data;
}