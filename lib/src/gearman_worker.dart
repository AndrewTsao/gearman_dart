part of gearman;

class _GearmanWorkerImpl implements GearmanWorker {
  Connection connection;
  var functions = new Map<String, GearmanFunction>();
  Queue<_Packet> commandQueue = new Queue<_Packet>();
  var _connected = false;
  
  _GearmanWorkerImpl();
  
  void addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    connection = new Connection(host, port);
    
    connection.onConnect = () {
      print("Connected!");
      _connected = true;
      _Packet setClientId = new _Packet.createSetClientId("SWCAO1");
      _send(setClientId);
      if (commandQueue.length > 0) {
        while (!commandQueue.isEmpty)
          connection.sendPacket(commandQueue.removeFirst());
      }
    };
    
    connection.onPacket = (_Packet packet) {
      print(packet);
      switch (packet.type) {
        case _Type.NO_JOB:
          _send(new _Packet.createPreSleep());
          break;
        case _Type.NOOP:
          _Packet grabjob = new _Packet.createGrabJob();
          _send(grabjob);
          break;
        case _Type.JOB_ASSIGN:
          var data = packet.getArgumentData(Argument.DATA);
          var jobHandle = packet.getArgumentData(Argument.JOB_HANDLE);
          var funcName = new String.fromCharCodes(packet.getArgumentData(Argument.FUNCTION_NAME));
          
          try {
            print(funcName);
            var func = functions[funcName];
            var res = func(jobHandle, funcName, data);
            var pack = new _Packet.createWorkComplete(_Magic.REQ, jobHandle, res);
            _send(pack); 
            _send(pack);
          } catch(e) {
            print("Error $e");
          }
          
          new Timer(0, (t) {
            _send(new _Packet.createGrabJob());
          });
          break;
      }
    };
  }
  
  void _send(var packet) {
    if (!commandQueue.isEmpty || !_connected) {
      commandQueue.addLast(packet);
      return;
    }
    connection.sendPacket(packet);
  }
  
  void addFunction(String funcName, GearmanFunction function) {
    if (functions.containsKey(funcName))
      return;
    functions[funcName] = function;
    _Packet cando = new _Packet.createCanDo(funcName);
    _send(cando);
    _Packet grabjob = new _Packet.createGrabJob();
    _send(grabjob);
  }
}