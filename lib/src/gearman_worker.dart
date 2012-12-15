part of gearman;

class _GearmanWorkerImpl implements GearmanWorker {
  Socket _socket;
  Uint8List _bytesBuffer;
  _GearmanParser _parser;
  
  _GearmanWorkerImpl();
  
  void addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    _socket = new Socket(host, port);
    
    _socket.onConnect = () {
      print("Connected!");
      _parser = new _GearmanParser();
       
      _parser.packetReceived = () {
        var magic = _parser.packetMagic;
        var type = _parser.packetType;
        var bodyLength = _parser.packetLength;
        print("receive $magic $type, bodyLength: $bodyLength");
        if (_bytesBuffer == null)
          _bytesBuffer = new Uint8List(bodyLength);
        else
          _bytesBuffer.clear();
      };
      
      _parser.packetData = (List<int> data) {
        _bytesBuffer.addAll(data);
      };
      
      _parser.packetEnd = () {
        var packet = new _Packet.fromBytes(_parser.packetMagic, _parser.packetType, _bytesBuffer);
        
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
      _Packet cando = new _Packet.createCanDo("reverse");
      var bytes = cando.toBytes();
      print(bytes);
      output.write(bytes);
      
      _Packet grabjob = new _Packet.createGrabJob();
      bytes = grabjob.toBytes();
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