part of gearman;

class _Magic {
  static const _REQ_CODE = 0x00524551;
  static const _RES_CODE = 0x00524553;

  static const REQ = const _Magic._define(_REQ_CODE);
  static const RES = const _Magic._define(_RES_CODE);

  final int magicCode;
  const _Magic._define(this.magicCode);

  factory _Magic.fromMagicCode(int code) {
    if (code == _REQ_CODE) return REQ;
    if (code == _RES_CODE) return RES;
    throw new GearmanException("Invalid magic code");
  }

  String toString() => this==REQ?"Request":"Response";
}

/**
 * 参数定义
 * TEXT, FUNCTION_NAME, UNIQUE_ID, MINUTE, HOUR, DAY_OF_MONTH, MONTH, DAY_OF_WEEK,
 * EPOCH, JOB_HANDLE, OPTION, KNOWN_STATUS, RUNNING_STATUS, NUMERATOR, DENOMINATOR,
 * TIME_OUT, DATA, ERROR_CODE, ERROR_TEXT, CLIENT_ID
 */
class Argument {
  static const TEXT = const Argument._def("TEXT");
  static const FUNCTION_NAME = const Argument._def("FUNCTION_NAME");
  static const UNIQUE_ID = const Argument._def("UNIQUE_ID");
  static const MINUTE = const Argument._def("MINUTE");
  static const HOUR = const Argument._def("HOUR");
  static const DAY_OF_MONTH = const Argument._def("DAY_OF_MONTH");
  static const MONTH = const Argument._def("MONTH");
  static const DAY_OF_WEEK = const Argument._def("DAY_OF_WEEK");
  static const EPOCH = const Argument._def("EPOCH");
  static const JOB_HANDLE = const Argument._def("JOB_HANDLE");
  static const OPTION = const Argument._def("OPTION");
  static const KNOWN_STATUS = const Argument._def("KNOWN_STATUS");
  static const RUNNING_STATUS = const Argument._def("RUNNING_STATUS");
  static const NUMERATOR = const Argument._def("NUMERATOR");
  static const DENOMINATOR = const Argument._def("DENOMINATOR");
  static const TIME_OUT = const Argument._def("TIME_OUT");
  static const DATA = const Argument._def("DATA");
  static const ERROR_CODE = const Argument._def("ERROR_CODE");
  static const ERROR_TEXT = const Argument._def("ERROR_TEXT");
  static const CLIENT_ID = const Argument._def("CLIENT_ID");

  final name;
  const Argument._def(this.name);
  toString() => name;
}

/**
  TEXT(0,1), CAN_DO(1,1), CANT_DO(2,1), RESET_ABILITIES(3,0), PRE_SLEEP(4,0), UNUSED(5,0),
  NOOP(6,0), SUBMIT_JOB(7,3), JOB_CREATED(8,1), GRAB_JOB(9,0), NO_JOB(10,0), JOB_ASSIGN(11,3),
  WORK_STATUS(12, 3), WORK_COMPLETE(13,2), WORK_FAIL(14,1), GET_STATUS(15,1), ECHO_REQ(16,1),
  ECHO_RES(17,1), SUBMIT_JOB_BG(18,3), ERROR(19, 2), STATUS_RES(20, 5), SUBMIT_JOB_HIGH(21,3),
  SET_CLIENT_ID(22,1), CAN_DO_TIMEOUT(23,2), ALL_YOURS(24,0), WORK_EXCEPTION(25,2),
  OPTION_REQ(26,1), OPTION_RES(27,1), WORK_DATA(28,2), WORK_WARNING(29, 2), GRAB_JOB_UNIQ(30,0),
  JOB_ASSIGN_UNIQ(31,4), SUBMIT_JOB_HIGH_BG(32,3), SUBMIT_JOB_LOW(33,3), SUBMIT_JOB_LOW_BG(34,3),
  SUBMIT_JOB_SCHED(35,8), SUBMIT_JOB_EPOCH(36,4);
*/
class _Type {
  static const TEXT = const _Type._def("TEXT", 0, const [Argument.TEXT]);
  static const CAN_DO = const _Type._def("CAN_DO", 1, const [Argument.FUNCTION_NAME]);
  static const CANT_DO = const _Type._def("CANT_DO", 2, const [Argument.FUNCTION_NAME]);
  static const RESET_ABILITIES = const _Type._def("RESET_ABILITIES", 3, const []);
  static const PRE_SLEEP = const _Type._def("PRE_SLEEP", 4, const []);
  static const UNUSED = const _Type._def("UNUSED", 5, const []);
  static const NOOP = const _Type._def("NOOP", 6, const []);
  static const SUBMIT_JOB = const _Type._def("SUBMIT_JOB", 7, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const JOB_CREATED = const _Type._def("JOB_CREATED", 8, const [Argument.JOB_HANDLE]);
  static const GRAB_JOB = const _Type._def("GRAB_JOB", 9, const []);
  static const NO_JOB = const _Type._def("NO_JOB", 10, const []);
  static const JOB_ASSIGN = const _Type._def("JOB_ASSIGN", 11, const [Argument.JOB_HANDLE, Argument.FUNCTION_NAME, Argument.DATA]);
  static const WORK_STATUS = const _Type._def("WORK_STATUS", 12, const [Argument.JOB_HANDLE, Argument.NUMERATOR, Argument.DENOMINATOR]);
  static const WORK_COMPLETE = const _Type._def("WORK_COMPLETE", 13, const [Argument.JOB_HANDLE, Argument.DATA]);
  static const WORK_FAIL = const _Type._def("WORK_FAIL", 14, const [Argument.JOB_HANDLE]);
  static const GET_STATUS = const _Type._def("GET_STATUS", 15, const [Argument.JOB_HANDLE]);
  static const ECHO_REQ = const _Type._def("ECHO_REQ", 16, const [Argument.DATA]);
  static const ECHO_RES = const _Type._def("ECHO_RES", 17, const [Argument.DATA]);
  static const SUBMIT_JOB_BG = const _Type._def("SUBMIT_JOB_BG", 18, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const ERROR = const _Type._def("ERROR", 19, const [Argument.ERROR_CODE, Argument.ERROR_TEXT]);
  static const STATUS_RES = const _Type._def("STATUS_RES", 20, const [Argument.JOB_HANDLE, Argument.KNOWN_STATUS, Argument.RUNNING_STATUS, Argument.NUMERATOR, Argument.DENOMINATOR]);
  static const SUBMIT_JOB_HIGH = const _Type._def("SUBMIT_JOB_HIGH", 21, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const SET_CLIENT_ID = const _Type._def("SET_CLIENT_ID", 22, const [Argument.CLIENT_ID]);
  static const CAN_DO_TIMEOUT = const _Type._def("CAN_DO_TIMEOUT", 23, const [Argument.FUNCTION_NAME, Argument.TIME_OUT]);
  static const ALL_YOURS = const _Type._def("ALL_YOURS", 24, const []);
  static const WORK_EXCEPTION = const _Type._def("WORK_EXCEPTION", 25, const [Argument.JOB_HANDLE, Argument.DATA]);
  static const OPTION_REQ = const _Type._def("OPTION_REQ", 26, const [Argument.OPTION]);
  static const OPTION_RES = const _Type._def("OPTION_RES", 27, const [Argument.OPTION]);
  static const WORK_DATA = const _Type._def("WORK_DATA", 28, const [Argument.JOB_HANDLE, Argument.DATA]);
  static const WORK_WARNING = const _Type._def("WORK_WARNING", 29, const [Argument.JOB_HANDLE, Argument.DATA]);
  static const GRAB_JOB_UNIQ = const _Type._def("GRAB_JOB_UNIQ", 30, const []);
  static const JOB_ASSIGN_UNIQ = const _Type._def("JOB_ASSIGN_UNIQ", 31, const [Argument.JOB_HANDLE, Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const SUBMIT_JOB_HIGH_BG = const _Type._def("SUBMIT_JOB_HIGH_BG", 32, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const SUBMIT_JOB_LOW = const _Type._def("SUBMIT_JOB_LOW", 33, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const SUBMIT_JOB_LOW_BG = const _Type._def("SUBMIT_JOB_LOW_BG", 34, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.DATA]);
  static const SUBMIT_JOB_SCHED = const _Type._def("SUBMIT_JOB_SCHED", 35, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.MINUTE, Argument.HOUR, Argument.DAY_OF_MONTH, Argument.MONTH, Argument.DAY_OF_WEEK, Argument.DATA]);
  static const SUBMIT_JOB_EPOCH = const _Type._def("SUBMIT_JOB_EPOCH", 36, const [Argument.FUNCTION_NAME, Argument.UNIQUE_ID, Argument.EPOCH, Argument.DATA]);
  static const PREDEFINED_TYPES = const [TEXT,CAN_DO,CANT_DO,RESET_ABILITIES,PRE_SLEEP,UNUSED,NOOP,SUBMIT_JOB,JOB_CREATED,GRAB_JOB,NO_JOB,JOB_ASSIGN,WORK_STATUS,WORK_COMPLETE,WORK_FAIL,GET_STATUS,ECHO_REQ,ECHO_RES,SUBMIT_JOB_BG,ERROR,STATUS_RES,SUBMIT_JOB_HIGH,SET_CLIENT_ID,CAN_DO_TIMEOUT,ALL_YOURS,WORK_EXCEPTION,OPTION_REQ,OPTION_RES,WORK_DATA,WORK_WARNING,GRAB_JOB_UNIQ,JOB_ASSIGN_UNIQ,SUBMIT_JOB_HIGH_BG,SUBMIT_JOB_LOW,SUBMIT_JOB_LOW_BG,SUBMIT_JOB_SCHED,SUBMIT_JOB_EPOCH];

  final name;
  final typeValue;
  final args;
  get argc => args.length;

  const _Type._def(this.name, this.typeValue,[this.args = const []]);

  factory _Type.fromTypeValue(int value) {
    if (!(0 <= value && value <= PREDEFINED_TYPES.length)) {
      throw new GearmanException("Invalid packet type");
    }
    return PREDEFINED_TYPES[value];
  }

  int indexOfArgument(Argument argument) => args.indexOf(argument);

  toString() => name;
}

class _Packet {
  static const HEADER_SIZE = 12;

  _Magic magic;
  _Type type;
  List<List<int>> arguments;

  String toString() => "$magic $type (#${arguments==null?0:arguments.length})";

  _Packet.create(this.magic, this.type, [this.arguments]) {
    // TODO:
    assert(type != _Type.TEXT);

    if (arguments == null) {
      arguments = new List<List<int>>();
    }
    for (var i = 0; i < arguments.length; i++) {
      if (arguments[i] == null) {
        arguments[i] = new List<int>(0);
      }
    }

    if (arguments.length != type.argc) {
      throw new GearmanException("Illegal arguments, packet($type) require ${type.argc}, but got ${arguments.length}");
    }

    for (var i = 0; i < arguments.length - 1; i++) {
      for (var j = 0; j < arguments[i].length; j++) {
        if (arguments[i][j] == 0) {
          throw new GearmanException("Illegal arguments $i contains null value.");
        }
      }
    }
  }

  _Packet.createEchoReq(List<int> data):
    this.create(_Magic.REQ, _Type.ECHO_REQ, [data]);

  _Packet.createCanDo(String funcName):
    this.create(_Magic.REQ, _Type.CAN_DO, [funcName.charCodes]);

  _Packet.createCantDo(String funcName):
    this.create(_Magic.REQ, _Type.CANT_DO, [funcName.charCodes]);

  _Packet.createResetAbilities():
    this.create(_Magic.REQ, _Type.RESET_ABILITIES);

  _Packet.createPreSleep():
    this.create(_Magic.REQ, _Type.PRE_SLEEP);

  _Packet.createNoOp():
    this.create(_Magic.RES, _Type.NOOP);

  _Packet.createSubmitJob(String funcName, List<int> uid, List<int> data):
    this.create(_Magic.REQ, _Type.SUBMIT_JOB, [funcName.charCodes, uid, data]);

  _Packet.createSubmitJobBg(String funcName, List<int> uid, List<int> data):
    this.create(_Magic.REQ, _Type.SUBMIT_JOB_BG, [funcName.charCodes, uid, data]);

  _Packet.createSubmitJobHigh(String funcName, List<int> uid, List<int> data):
    this.create(_Magic.REQ, _Type.SUBMIT_JOB_HIGH, [funcName.charCodes, uid, data]);

  _Packet.createSubmitJobHighBg(String function, List<int> uid, List<int> data):
    this.create(_Magic.REQ, _Type.SUBMIT_JOB_HIGH_BG, [function.charCodes, uid, data]);

  _Packet.createSubmitJobLow(String funcName, List<int> uid, List<int> data):
    this.create(_Magic.REQ, _Type.SUBMIT_JOB_LOW, [funcName.charCodes, uid, data]);

  _Packet.createSubmitJobLowBg(String funcName, List<int> uid, List<int> data):
    this.create(_Magic.REQ, _Type.SUBMIT_JOB_LOW_BG, [funcName.charCodes, uid, data]);

  _Packet.createGrabJob():
    this.create(_Magic.REQ, _Type.GRAB_JOB);

  _Packet.createGrabJobUniq():
    this.create(_Magic.REQ, _Type.GRAB_JOB_UNIQ);

  _Packet.createNoJob():
    this.create(_Magic.RES, _Type.NO_JOB);

  _Packet.createWorkComplete(_Magic magic, List<int> jobHandle, List<int> data):
    this.create(magic, _Type.WORK_COMPLETE, [jobHandle, data]);

  _Packet.createWorkFail(_Magic magic, List<int> jobHandle):
    this.create(magic, _Type.WORK_FAIL, [jobHandle]);

  _Packet.createWorkData(_Magic magic, List<int> jobHandle, List<int> data):
    this.create(magic, _Type.WORK_DATA, [jobHandle, data]);

  _Packet.createWorkWarning(_Magic magic, List<int> jobHandle, List<int> data):
    this.create(magic, _Type.WORK_WARNING, [jobHandle, data]);

  _Packet.createWorkStatus(_Magic magic, List<int> jobHandle, int numerator, int denominator):
    this.create(magic, _Type.WORK_STATUS, [jobHandle, numerator.toString().charCodes, denominator.toString().charCodes]);

  _Packet.createWorkException(_Magic magic, List<int> jobHandle, List<int> data):
    this.create(magic, _Type.WORK_EXCEPTION, [jobHandle, data]);

  _Packet.createSetClientId(String id):
    this.create(_Magic.REQ, _Type.SET_CLIENT_ID, [id.charCodes]);

  _Packet.createCanDoTimeout(String funcName, int timeout):
    this.create(_Magic.REQ, _Type.CAN_DO_TIMEOUT, [funcName.charCodes, timeout.toString().charCodes]);

  _Packet.createJobAssign(List<int> jobHandle, String funcName, List<int> data):
    this.create(_Magic.RES, _Type.JOB_ASSIGN, [jobHandle, funcName.charCodes, data]);

  _Packet.createJobAssignUniq(List<int> jobHandle, String funcName, List<int> uniqueId, List<int> data):
    this.create(_Magic.RES, _Type.JOB_ASSIGN_UNIQ, [jobHandle, funcName.charCodes, uniqueId, data]);

  _Packet.createGetStatus(List<int> jobHandle):
    this.create(_Magic.REQ, _Type.GET_STATUS, [jobHandle]);

  /**
   * Parse packet body, create a gearman packet.
   */
  _Packet.fromBytes(this.magic, this.type, [List<int> bytes]) {
    var argc = type.argc;
    if (arguments == null) {
      arguments = new List<List<int>>(argc);
    }
    if (bytes != null) {
      var beg = 0;
      var argi = 0;
      var i = 0;
      for (; i < bytes.length; i++) {
        if (bytes[i] == 0) {
          arguments[argi++] = bytes.getRange(beg, i - beg);
          beg = i + 1;
          if (argi == argc - 1) {
            break;
          }
        }
      }
      if (argc > 0) {
        arguments[argi++] = bytes.getRange(beg, bytes.length - beg);
      }
      assert(argi == argc);
    }
  }

  List<int> getArgumentData(Argument arg) =>
      arguments[type.indexOfArgument(arg)];

  int _calcBodySize() {
    var size = 0;
    if (type.argc == 0) {
      return size;
    }

    size += type.argc - 1;
    for (var arg in arguments) {
      size += arg.length;
    }
    return size;
  }

  static int _writeUint32BE(List<int> byteBuffer, int end, int val) {
    var pos =  end;
    assert(pos + 4 <= byteBuffer.length);
    byteBuffer[pos++] = (val >> 24) & 0xFF;
    byteBuffer[pos++] = (val >> 16) & 0xFF;
    byteBuffer[pos++] = (val >> 8) & 0xFF;
    byteBuffer[pos++] = (val) & 0xFF;
    return pos - end;
  }

  static int _writeBytes(List<int> byteBuffer, int end, List<int> bytes, [bool add_zero = true]) {
    var pos = end;
    if (bytes.length != 0) {
      Arrays.copy(bytes, 0, byteBuffer, pos, bytes.length);
      pos += bytes.length;
    }
    if (add_zero) {
      byteBuffer[pos++] = 0;
    }
    return pos - end;
  }

  List<int> toBytes() {
    var bodyLength = _calcBodySize();
    var byteBuffer = new List<int>(HEADER_SIZE + bodyLength);
    var pos = 0;
    pos += _writeUint32BE(byteBuffer, pos, magic.magicCode);
    pos += _writeUint32BE(byteBuffer, pos, type.typeValue);
    pos += _writeUint32BE(byteBuffer, pos, bodyLength);
    for (var i = 0; i < arguments.length; i++) {
      pos += _writeBytes(byteBuffer, pos, arguments[i], i != arguments.length - 1);
    }
    assert(pos == bodyLength + HEADER_SIZE);
    return byteBuffer;
  }
}
