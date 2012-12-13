part of gearman;

class _GearmanWorkerImpl implements GearmanWorker {
  Socket _socket;
  GearmanParser _parser;
  
  _GearmanWorkerImpl();
  
  void addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    _socket = new Socket(host, port);
    
    _socket.onConnect = () {
      print("Connected!");
      _parser = new GearmanParser();
      _parser.packetReceived = () {
        String magic = Magic.REQ == _parser.packetMagic ? "\\0REQ" : "\\0RES";
        String type = PacketType.getTypeName(_parser.packetType);
        print("receive $magic $type ${_parser.packetLength}");
      };
      _parser.packetData = (List<int> data) {
        if (_parser.packetType == PacketType.JOB_CREATED) {
          print("Job created");
          print(new String.fromCharCodes(data));
        } else if(_parser.packetType == PacketType.WORK_COMPLETE) {
          print("Work Complete");
          int bb = 0;
          for (int i = 0; i < data.length; i++) {
            if (data[i] == 0) {
              print(new String.fromCharCodes(data.getRange(bb, i - bb)));
              bb = i + 1;
            }
          }
          print(new String.fromCharCodes(data.getRange(bb, data.length - bb)));
        } else if (_parser.packetType == PacketType.JOB_ASSIGN) {
          int i = 0;
          while(data[i] != 0 && i < data.length) i++;
          var job_handle = new String.fromCharCodes(data.getRange(0, i));
          i++;
          int func_start = i;
          while(data[i] != 0 && i < data.length) i++;
          var function = new String.fromCharCodes(data.getRange(func_start, i - func_start));
         
          i++;
          var workload = data.getRange(i, data.length - i);
          
          Packet workcomplete = new WorkCompletePacket(job_handle, function, workload);
          var bytes = workcomplete.getBytes();
          _socket.outputStream.write(bytes);
        }
      };
      _parser.packetEnd = () {
        print("Received a packet");
        
        if (_parser.packetType == PacketType.NO_JOB) {
          Packet grabjob = new PreSleepPacket();
          var bytes = grabjob.getBytes();
          print(bytes);
          _socket.outputStream.write(bytes);
        } else if (_parser.packetType == PacketType.NOOP) {
          Packet grabjob = new GrabJobPacket();
          var bytes = grabjob.getBytes();
          print(bytes);
          _socket.outputStream.write(bytes);
        }        
      };
      _parser.error = (e) {
        print(e);
      };
      
      var input = _socket.inputStream;
      handler() {
        input.onData = null;
        List<int> buffer = input.read();
        print(buffer);
        _parser.streamData(buffer);
        input.onData = handler;
      }
      input.onData = handler;
      
      var output = _socket.outputStream;
      Packet cando = new CanDoPacket("reverse");
      var bytes = cando.getBytes();
      print(bytes);
      output.write(bytes);
      
      Packet grabjob = new GrabJobPacket();
      bytes = grabjob.getBytes();
      print(bytes);
      output.write(bytes);
    };
    
    _socket.onError = (e) {
      print(e);
    };
  }
  
  void addFunction(String name, Function handler) {
    
  }
}