gearman_dart
============
The [Gearman](http://gearman.org/) Protocol ([中文](https://github.com/AndrewTsao/gearman_dart/blob/master/gearman_protocol.txt)) implementation in Dart.

Inspired by [java-gearman-service](http://code.google.com/p/java-gearman-service/).

The project is underlying development, many facilities have not implemeted yet.

Please feel free to report issue or fork it, thank you!

Example
=======

create a 'reverse' worker:

```dart
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
```

create a 'reverse' client:

```dart
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
```
