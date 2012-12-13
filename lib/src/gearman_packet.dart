part of gearman;

abstract class Magic {
  static const int REQ = 0x00524551; // \0REQ
  static const int RES = 0x00524553; // \0RES
}

abstract class PacketType {
  static const int CAN_DO = 1;
  static const int CANT_DO = 2;
  static const int RESET_ABILITIES = 3;
  static const int PRE_SLEEP = 4;
  static const int UNUSED1 = 5;
  static const int NOOP = 6;
  static const int SUBMIT_JOB = 7;
  static const int JOB_CREATED = 8;
  static const int GRAB_JOB = 9;
  static const int NO_JOB = 10;
  static const int JOB_ASSIGN = 11;
  static const int WORK_STATUS = 12;
  static const int WORK_COMPLETE = 13;
  static const int WORK_FAIL = 14;
  static const int GET_STATUS = 15;
  static const int ECHO_REQ = 16;
  static const int ECHO_RES = 17;
  static const int SUBMIT_JOB_BG = 18;
  static const int ERROR = 19;
  static const int STATUS_RES = 20;
  static const int SUBMIT_JOB_HIGH = 21;
  static const int SET_CLIENT_ID = 22;
  static const int CAN_DO_TIMEOUT = 23;
  static const int ALL_YOURS = 24;
  static const int WORK_EXCEPTION = 25;
  static const int OPTION_REQ = 26;
  static const int OPTION_RES = 27;
  static const int WORK_DATA = 28;
  static const int WORK_WARNING = 29;
  static const int GRAB_JOB_UNIQ = 30;
  static const int JOB_ASSIGN_UNIQ = 31;
  static const int SUBMIT_JOB_HIGH_BG = 32;
  static const int SUBMIT_JOB_LOW = 33;
  static const int SUBMIT_JOB_LOW_BG = 34;
  static const int SUBMIT_JOB_SCHED = 35;
  static const int SUBMIT_JOB_EPOCH = 36;

  static String getTypeName(int type) {
    return const [
      "",
      "CAN_DO",
      "CANT_DO",
      "RESET_ABILITIES",
      "PRE_SLEEP",
      "UNUSED1",
      "NOOP",
      "SUBMIT_JOB",
      "JOB_CREATED",
      "GRAB_JOB",
      "NO_JOB",
      "JOB_ASSIGN",
      "WORK_STATUS",
      "WORK_COMPLETE",
      "WORK_FAIL",
      "GET_STATUS",
      "ECHO_REQ",
      "ECHO_RES",
      "SUBMIT_JOB_BG",
      "ERROR",
      "STATUS_RES",
      "SUBMIT_JOB_HIGH",
      "SET_CLIENT_ID",
      "CAN_DO_TIMEOUT",
      "ALL_YOURS",
      "WORK_EXCEPTION",
      "OPTION_REQ",
      "OPTION_RES",
      "WORK_DATA",
      "WORK_WARNING",
      "GRAB_JOB_UNIQ",
      "JOB_ASSIGN_UNIQ",
      "SUBMIT_JOB_HIGH_BG",
      "SUBMIT_JOB_LOW",
      "SUBMIT_JOB_LOW_BG",
      "SUBMIT_JOB_SCHED",
      "SUBMIT_JOB_EPOCH"][type];
  }
}

class Packet {
  static const int HEADER_LENGTH = 12;

  int _magic;
  int _type;

  Packet(this._magic, this._type);

  int get _BodyLength => 0;

  encodeHeader (Codec encoder) {
    encoder.writeUint32BE(_magic);
    encoder.writeUint32BE(_type);
    encoder.writeUint32BE(_BodyLength);
  }

  List<int> getBytes() {
    var encoder = new Codec.Encoder(HEADER_LENGTH + _BodyLength);
    encodeHeader(encoder);
    return encoder.Bytes;
  }
}

class SubmitJobPacket extends Packet {
  String _function;
  List<int> _uniqueId;
  List<int> _workload;

  SubmitJobPacket(this._function, [this._uniqueId = null, this._workload = const []]):
    super(Magic.REQ, PacketType.SUBMIT_JOB);

  int get _BodyLength => super._BodyLength + _function.charCodes.length + 1 + _uniqueId.length + 1 + _workload.length;

  List<int> getBytes() {
    Codec encoder = new Codec.Encoder(Packet.HEADER_LENGTH + _BodyLength);
    encodeHeader(encoder);
    encoder.writeBytes(_function.charCodes);
    encoder.writeBytes(_uniqueId);
    encoder.writeBytes(_workload, false);
    return encoder.Bytes;
  }
}

class CanDoPacket extends Packet {
  String _function;
  CanDoPacket(this._function):
    super(Magic.REQ, PacketType.CAN_DO);
  int get _BodyLength => super._BodyLength + _function.charCodes.length;
  
  List<int> getBytes() {
    Codec encoder = new Codec.Encoder(Packet.HEADER_LENGTH + _BodyLength);
    encodeHeader(encoder);
    encoder.writeBytes(_function.charCodes, false);
    return encoder.Bytes;
  }
}

class GrabJobPacket extends Packet {
  GrabJobPacket():
    super(Magic.REQ, PacketType.GRAB_JOB);
}

class PreSleepPacket extends Packet {
  PreSleepPacket():
    super(Magic.REQ, PacketType.PRE_SLEEP);
}

class WorkCompletePacket extends Packet {
  List<int> _res;
  String _handle;
  String _function;
  WorkCompletePacket(this._handle, this._function, this._res):
    super(Magic.REQ, PacketType.WORK_COMPLETE);
  
  int get _BodyLength => super._BodyLength + _handle.charCodes.length + 1 + _res.length;
  
  List<int> getBytes() {
    Codec encoder = new Codec.Encoder(Packet.HEADER_LENGTH + _BodyLength);
    encodeHeader(encoder);
    encoder.writeBytes(_handle.charCodes);
    encoder.writeBytes(_res, false);
    return encoder.Bytes;    
  }
}
