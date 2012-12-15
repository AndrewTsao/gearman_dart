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
      submitJob("echo", "echo echo".charCodes);
    };
    connection.onPacket = (packet) {
      print(packet);
      
      switch(packet.type) {
        case _Type.ERROR:
          var code = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_CODE));
          var text = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_TEXT));
          print("Error: $code, $text");
          break;
        case _Type.WORK_COMPLETE: 
          var data = new String.fromCharCodes(packet.getArgumentData(Argument.DATA));
          print(data);
          new Timer(5000, (t) {
            submitJob("reverse", "hello world".charCodes);
            submitJob("echo", "echo echo".charCodes);
          });
          break;
      };
    };
  }
  
  submitJob(String func, List<int> data) {
    var packet = new _Packet.createSubmitJob(func, [], data);
    connection.sendPacket(packet);
  }
}