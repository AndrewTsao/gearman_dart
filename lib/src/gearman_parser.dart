part of gearman;

class _State {
  static const int START = 1;
  static const int PACKET_MAGIC = 2;
  static const int PACKET_TYPE = 3;
  static const int PACKET_LENGTH = 4;
  static const int PACKET_BODY = 5;
  static const int CLOSED = 6;
  static const int FAILURE = 7;
}

/**
 * TODO: Parser 还可以支持TEXT模式，包开头为0表示Binary，否则为行文本模式
 * 文本模式是以包含.的单行结束（多行命令）。而maxqueue和version则只返回一行结束。
 * 文本模式主要是用于管理服务器和查询服务器的。
 */

class _GearmanParser {
  int _state;
  List<int> _buffer;
  int _index;
  int _lastIndex;
  int _remainingBody;

  List<int> _temp;
  _Magic _packetMagic;
  _Type _packetType;
  int _packetLength;

  _Magic get packetMagic => _packetMagic;
  _Type get packetType => _packetType;
  int get packetLength => _packetLength;

  _reset() {
    _state = _State.START;
    _temp = new List();
  }

  _GearmanParser() {
    _remainingBody = null;
    _reset();
  }

  void _parse() {
    try {
      if (_state == _State.CLOSED) {
        throw new GearmanParserException("Data on closed connection");
      }
      if (_state == _State.FAILURE) {
        throw new GearmanParserException("Data on failed connection");
      }

      while (_buffer != null &&
             _index < _lastIndex &&
             _state != _State.FAILURE) {
        int byte = _buffer[_index++];
        switch(_state) {
          case _State.START:
            if (byte != 0) {
              throw new GearmanParserException("Text mode unimplementation"); 
            }
            _temp.add(byte);
            _state = _State.PACKET_MAGIC;
            break;
          case _State.PACKET_MAGIC:
            _temp.add(byte);
            if (_temp.length == 4) {
              _packetMagic = new _Magic.fromMagicCode(_readUint32BE(_temp));
              _temp.clear();
              _state = _State.PACKET_TYPE;
            }
            break;
          case _State.PACKET_TYPE:
            _temp.add(byte);
            if (_temp.length == 4) {
              _packetType = new _Type.fromTypeValue(_readUint32BE(_temp));
              _temp.clear();
              _state = _State.PACKET_LENGTH;
            }
            break;
          case _State.PACKET_LENGTH:
            _temp.add(byte);
            if (_temp.length == 4) {
              _packetLength = _readUint32BE(_temp);
              _temp.clear();
              packetReceived();
              _state = _State.PACKET_BODY;

              if (_packetLength == 0) {
                packetEnd();
                _reset();
              } else {
                _remainingBody = _packetLength;
              }
            }
            break;
          case _State.PACKET_BODY:
            _index--;
            int dataAvailable = _lastIndex - _index;
            List<int> data;
            if (_remainingBody == null ||
                dataAvailable <= _remainingBody) {
              data = new Uint8List(dataAvailable);
              data.setRange(0, dataAvailable, _buffer, _index);
            } else {
              data = new Uint8List(_remainingBody);
              data.setRange(0, _remainingBody, _buffer, _index);
            }
            packetData(data);
            if (_remainingBody != null) {
              _remainingBody -= data.length;
            }
            _index += data.length;
            if (_remainingBody == 0) {
              packetEnd();
              _reset();
            }
            break;
          default:
            assert(false);
            break;
        }
      }
    } catch (e) {
      _state = _State.FAILURE;
      error(e);
    }

    _releaseBuffer();
  }

  int _readUint32BE(List<int> buf) {
    return ((buf[0] & 0xFF) << 24)
        | ((buf[1] & 0xFF) << 16)
        | ((buf[2] & 0xFF) << 8)
        | (buf[3] & 0xFF);
  }

  _releaseBuffer() {
    _buffer = null;
    _temp.clear();
  }

  // 处理流输入事件
  streamData(List<int> buffer) {
    assert(buffer != null);
    _buffer = buffer;
    _index = 0;
    _lastIndex = buffer.length;
    _parse();
  }

  // 处理流结束事件
  streamDone() {
    // TODO:
    print("stream done");
  }

  // 处理流错误事件
  streamError(e) {
    if (_state == _State.START) {
      closed();
      return;
    }
    error(e);
  }

  Function packetReceived;
  Function packetData;
  Function packetEnd;
  Function closed;
  Function error;
}

class GearmanParserException implements Exception {
  const GearmanParserException([String this.message = ""]);
  String toString() => "GearmanParserException: $message";
  final String message;
}