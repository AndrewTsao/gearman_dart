import "package:gearman/gearman.dart";

main(){
  var worker = new GearmanWorker();
  worker.addServer();
  worker.addFunction("reverse", reverse);
  worker.addFunction("echo", echo);
}

List<int> reverse(List<int> jobHandle, String funcName, List<int> data) {
  for (int i = 0, j = data.length - 1; i < j; i++, j--) {
    var t = data[i]; 
    data[i] = data[j];
    data[j] = t;
  }
  return data;
}

List<int> echo(List<int> jobHandle, String echo, List<int> data) {
  return data;
}