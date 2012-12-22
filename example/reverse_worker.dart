import "package:gearman/gearman.dart";
import "package:logging/logging.dart";

_configurateLogger() {
  final root = Logger.root;
  root.level = Level.ALL;
  root.on.record.add((LogRecord rec) 
      => print("${rec.time} [${rec.level}] [${rec.loggerName}] ${rec.message}"));  
}

main() {
  _configurateLogger();
  
  var worker = new GearmanWorker();
  var future = worker.addServer();
  
  future..handleException((Exception e) {
    print(e.toString());
    return true;
  })
  ..then((v) {
    worker.canDo("reverse");
    
    worker.onJobAssigned = (AssignedJob job) {
      if (job.funcName == "reverse") {
        var res = reverse(job.data);
        job.sendComplete(res);
      }
    };
    
    worker.onNoJob = worker.preSleep;
    worker.onNoOp = worker.grabJob;
    worker.onComplete = worker.grabJob;
    
    worker.grabJob();
  });
}

List<int> reverse(List<int> data) {
  for (int i = 0, j = data.length - 1; i < j; i++, j--) {
    var t = data[i]; 
    data[i] = data[j];
    data[j] = t;
  }
  return data;
}
