part of gearman;

class Codec {
  List<int> _buf;
  int _pos;

  Codec.Encoder(int size) {
    _buf = new Uint8List(size);
    _pos = 0;
  }

  List<int> get Bytes => _buf;

  void writeUint32BE(int val) {
    assert(_pos + 4 <= _buf.length);

    _buf[_pos++] = (val >> 24) & 0xFF;
    _buf[_pos++] = (val >> 16) & 0xFF;
    _buf[_pos++] = (val >> 8) & 0xFF;
    _buf[_pos++] = (val) & 0xFF;
  }

  writeBytes(List<int> bytes, [bool add_zero = true]) {
    if (bytes.length != 0) {
      Arrays.copy(bytes, 0, _buf, _pos, bytes.length);
      _pos += bytes.length;
    }
    if (add_zero)
      _buf[_pos++] = 0;
  }
}