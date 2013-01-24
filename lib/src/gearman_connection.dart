part of gearman;

/**
 * 与Job Server建立连接，负责发送与接收Packet
 * 它有OnPacket和SendPacket两个基本接口
 * 之外，onConnect/onClosed/onError
 */
abstract class Connection {
  int get port;
  String get host;

  void set onPacket(void callback(_Packet packet));
  sendPacket(_Packet packet);
  void set onConnect(void callback());
  void set onClosed(void close());
  void set onError(void error(e));

  factory Connection([String host = 'localhost', int port = 4730])
    => new _Connection(host, port);
}

class _Connection implements Connection {
  String _host;
  int _port;

  Function _connect;
  Function _closed;
  Function _error;
  Function _packetReceived;

  List<_Packet> _queue;

  set onPacket(void callback(_Packet packet)) => _packetReceived = callback;
  set onConnect(void callback()) => _connect = callback;
  set onError(void error(e)) => _error = error;
  set onClosed(void callback()) => _closed = callback;

  String get host => _host;
  int get port => _port;

  Socket _socket;
  _GearmanParser _parser;
  List<int> _buffer;
  var _connected = false;

  _Connection(this._host, this._port) {
    _socket = new Socket(_host, _port);
    _socket.onConnect = () {
      _bindParserCallback();
      _connected = true;
      _connect();
    };
  }

  _bindParserCallback() {
    if (_parser == null) {
      _parser = new _GearmanParser();
    }

    _parser.packetReceived = () {
      if (_buffer == null) {
        _buffer = new List<int>();
      } else {
        _buffer.clear();
      }
    };

    _parser.packetData = (List<int> data) {
      _buffer.addAll(data);
    };

    _parser.packetEnd = () {
      try {
        var packet = new _Packet.fromBytes(_parser.packetMagic, _parser.packetType, _buffer);
        _buffer.clear();
        _packetReceived(packet);
      } catch(e) {
        if (_error == null) {
            throw e;
        }
        _error(e);
      }
    };

    _parser.error = (e) {
      // Parser throw and error
      if (_error == null) {
        throw e;
      }
      _error(e);
    };

    _parser.closed = () {
      print("Parser closed");
    };

    _socket.onError = _parser.streamError;
    _socket.onClosed = _parser.streamDone;
    receiveData() {
      _socket.onData = null;
      _parser.streamData(_socket.read());
      _socket.onData = receiveData;
    }
    _socket.onData = receiveData;
  }

  List<_Packet> _pending = new List<_Packet>();

  sendPacket(_Packet packet) {
    var buffer = packet.toBytes();
    _socket.writeList(buffer, 0, buffer.length);
//    _socket.outputStream.onNoPendingWrites = () {
//
//    };
  }
}
