part of gearman;

abstract class GearmanClient {
  factory GearmanClient.connectServer(String host, int port) {
    var c = new GearmanClientImpl();
    c.connectServer(host, port);
  }
}

class GearmanClientImpl implements GearmanClient {
  GearmanParser _parser;
  Socket _socket;

  GearmanClient() {
  }
  bool connectServer(String host, int port) {
    _socket = new Socket('localhost', 4730);
    _socket.onConnect = () {
      _parser = new GearmanParser();

      _parser.packetReceived = () {
        String magic = Magic.REQ == _parser.packetMagic ? "\0REQ" : "\0RES";
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


        }
      };
      _parser.packetEnd = () {
        print("Received a packet");
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
      var packet = new SubmitJobPacket('reverse', 0, 'Test String'.charCodes);
      os.write(packet.getBytes());
      os.write(packet.getBytes());
      os.write(packet.getBytes());
    };
  }
}