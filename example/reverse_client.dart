import "package:gearman/gearman.dart";
import "package:logging/logging.dart";

_configurateLogger() {
  final root = Logger.root;
  root.level = Level.ALL;
  root.on.record.add((LogRecord rec) => print("${rec.time} [${rec.level}] [${rec.loggerName}] ${rec.message}"));  
}

main() {
  _configurateLogger();
  
  var client= new GearmanClient();
  var future = client.addServer();
  
  future.then((v) {
    // TODO: add timeout and disconnect policy
    submitJob() {
      var submittedJob = client.submitJob("reverse", "hello world".charCodes);
      submittedJob
        ..handleException((e) {
          print(e);
          return true;
        })
        ..then((job) {
          job.onComplete = () {
            print("job completed!");
          };
          job.onData = (data) {
            print(new String.fromCharCodes(data));
          };
      });
    };
    submitJob();
    submitJob();
    submitJob();
  });
}
