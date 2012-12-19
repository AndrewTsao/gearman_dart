part of gearman;

class _GearmanClientImpl implements GearmanClient {
  Connection connection;
  Queue<_Packet> packet = new Queue<_Packet>();

  _GearmanClientImpl() {
  }
  
  addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    connection = new Connection(host, port);
    connection.onConnect = () {
      submitJob("reverse", "hello world".charCodes);
      // exit(0);
    };
    connection.onPacket = (packet) {
      print(packet);
      
      switch(packet.type) {
        case _Type.ERROR:
          var code = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_CODE));
          var text = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_TEXT));
          print("Error: $code, $text");
          break;
        case _Type.JOB_CREATED:
          var jobHandle = new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE));
          print(jobHandle);
          var getStatus = new _Packet.createGetStatus(jobHandle.charCodes);
          connection.sendPacket(getStatus);
          break;
        case _Type.WORK_COMPLETE: 
          var data = new String.fromCharCodes(packet.getArgumentData(Argument.DATA));
          print(data);
//          new Timer(5000, (t) {
//            submitJob("reverse", "hello world".charCodes);
//            submitJob("echo", "echo echo".charCodes);
//          });
          break;
        case _Type.STATUS_RES:
          print(new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE)));
          print(new String.fromCharCodes(packet.getArgumentData(Argument.KNOWN_STATUS)));
          print(new String.fromCharCodes(packet.getArgumentData(Argument.RUNNING_STATUS)));
          break;
      };
    };
  }
  
  submitJob(String func, List<int> data) {
    var packet = new _Packet.createSubmitJob(func, [], data);
    connection.sendPacket(packet);
  }
  
  submitJobBg(String func, List<int> data) {
    var packet = new _Packet.createSubmitJobBg(func, [], data);
    connection.sendPacket(packet);
  }
}