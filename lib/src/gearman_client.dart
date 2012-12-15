part of gearman;

class _GearmanClientImpl implements GearmanClient {
  _GearmanParser _parser;
  Socket _socket;
  List<int> _bytesBuffer;

  _GearmanClientImpl() {
  }
  
  addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    _socket = new Socket(host, port);
    _socket.onConnect = () {
      _parser = new _GearmanParser();

      _parser.packetReceived = () {
        var magic = _parser.packetMagic;
        var type = _parser.packetType;
        var bodyLength = _parser.packetLength;
        print("receive $magic $type, bodyLength: $bodyLength");
        if (_bytesBuffer == null)
          _bytesBuffer = new List<int>();
        else {
          _bytesBuffer.clear();
        }
      };
      _parser.packetData = (List<int> data) {
        _bytesBuffer.addAll(data);
      };
      _parser.packetEnd = () {
        print("Received a packet");
        var packet = new _Packet.fromBytes(_parser.packetMagic, _parser.packetType, _bytesBuffer);
        
        switch(packet.type) {
          case _Type.JOB_CREATED:
            print("job created");
            break;
          case _Type.WORK_COMPLETE:
            var data = packet.getArgumentData(Argument.DATA);
            print(new String.fromCharCodes(data));
            break;
          case _Type.ERROR:
            var code = packet.getArgumentData(Argument.ERROR_CODE);
            var text = packet.getArgumentData(Argument.ERROR_TEXT);
            print(new String.fromCharCodes(code));
            print(new String.fromCharCodes(text));
            break;
        }
      };
      _parser.error = (e) {
        print(e);
      };

      var input = _socket.inputStream;
      handler() {
        input.onData = null;
        List<int> buffer = input.read();
        _parser.streamData(buffer);
        input.onData = handler;
      }
      input.onData = handler;

      var os = _socket.outputStream;
      var packet = new _Packet.createSubmitJob('reverse', [], 'Test'.charCodes);
      os.write(packet.toBytes());
    };
  }
  
  submitJob(String func, String uniqueId, List<int> data) {
    
  }
}