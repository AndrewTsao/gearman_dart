import "package:gearman/gearman.dart";

main(){
  var worker = new GearmanWorker();
  var future = worker.addServer();
  future..handleException((e) {
    print(e);
    return true;
  })..then((v) {
    worker.canDo("echo");
    worker.onJobAssigned = (AssignedJob job) {
      assert (job.funcName == 'echo');
      print("processing echo...");
      job.sendData(job.data);
      job.sendData(job.data);
      job.sendData(job.data);
      job.sendData(job.data);
      job.sendComplete();
      print("complete echo");
    };
    
    worker.onComplete = worker.grabJob;
    worker.onNoJob = worker.preSleep;
    worker.onNoOp = worker.grabJob;
    worker.grabJob();
  });
}
