import "package:gearman/gearman.dart";

main() {
  var client = new GearmanClient();

  client.addServer().then((v) {
    var future = client.submitJob("echo", "hello world".charCodes);

    future.then((job) {
      job.onData = (List<int> data) {
        print(new String.fromCharCodes(data));
      };

      job.onComplete = () {
        print("echo completed!");
      };
    });
  });
}