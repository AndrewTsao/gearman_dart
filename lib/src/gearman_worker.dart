part of gearman;

class _AssignedJob implements AssignedJob {
  _GearmanWorker _worker;
  bool _isUnique;
  String _funcName;
  String _handle;
  String _uniqueId;
  List<int> _data;

  GearmanWorker get worker => _worker;
  String get funcName => _funcName;
  String get handle => _handle;
  String get uniqueId => _uniqueId;
  List<int> get data => _data;
  bool get isUnique => _uniqueId != null;

  _AssignedJob.fromPacket(this._worker, _Packet packet) {
    _handle = new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE));
    _funcName = new String.fromCharCodes(packet.getArgumentData(Argument.FUNCTION_NAME));
    _uniqueId = null;
    _data = packet.getArgumentData(Argument.DATA);
  }

  _AssignedJob.fromPacketUnique(this._worker, _Packet packet) {
    _handle = new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE));
    _funcName = new String.fromCharCodes(packet.getArgumentData(Argument.FUNCTION_NAME));
    _uniqueId = new String.fromCharCodes(packet.getArgumentData(Argument.UNIQUE_ID));
    _data = packet.getArgumentData(Argument.DATA);
  }

  sendData(List<int> data) {
    assert(_handle != null);
    _worker._updateWorkData(this, data);
  }

  sendWarning(List<int> data) {
    assert(_handle != null);
    _worker._updateWorkWarning(this, data);
    _handle = null;
  }

  sendException(List<int> data) {
    assert(_handle != null);
    _worker._updateWorkException(this, data);
    _handle = null;
  }

  sendComplete([List<int> data = const []]) {
    assert(_handle != null);
    _worker._complete(this, data);
    _handle = null;
  }

  sendFail() {
    assert(_handle != null);
    _worker._fail(this);
    _handle = null;
  }

  sendStatus(int numerator, int denominator) {
    assert(_handle != null);
    _worker._updateStatus(this, numerator, denominator);
  }
}

class _GearmanFunction {
  String funcName;
  Map<String, AssignedJob> assignedJobs;
  bool retired;
  int timeout;

  _GearmanFunction(this.funcName, [this.timeout = 0]):
    retired = false;
}

class _GearmanWorker implements GearmanWorker {
  static Logger _logger = new Logger("GearmanWorker");
  Connection _connection;
  bool _connected;
  Map<String, _GearmanFunction> _functions;
  Queue<_Packet> _pendingPackets;
  bool _isSleeping;

  Function _onNoJob;
  Function _onNoOp;
  Function _onJobAssigned;
  Function _onError;
  Function _onComplete;

  set onNoJob(callback())
    => _onNoJob = callback;

  set onNoOp(callback())
    => _onNoOp = callback;

  set onJobAssigned(callback(AssignedJob job))
    => _onJobAssigned = callback;

  set onError(callback(Exception e))
    => _onError = callback;

  set onComplete(callback())
    => _onComplete = callback;

  _GearmanWorker():
     _connected = false,
     _isSleeping = false;

  _send(var packet) {
    if (!_connected || _pendingPackets == null || !_pendingPackets.isEmpty) {
      if (_pendingPackets == null) {
        _pendingPackets = new Queue<_Packet>();
      }
      _pendingPackets.addLast(packet);
      return;
    }
    _logger.fine("send $packet");
    _connection.sendPacket(packet);
  }

  void setClientId(String clientId) {
    var setClientId = new _Packet.createSetClientId(clientId);
    _send(setClientId);
  }

  void grabJob() {
    var grabjob = new _Packet.createGrabJob();
    _send(grabjob);
  }

  void grabJobUniq() {
    var grabjob = new _Packet.createGrabJobUniq();
    _send(grabjob);
  }

  void preSleep() {
    if (_isSleeping) return;
    _send(new _Packet.createPreSleep());
    _isSleeping = true;
  }


  void canDo(String funcName, [int timeout = GEARMAN_DEFAULT_JOB_TIMEOUT]) {
    if (_functions == null) {
      _functions = new Map<String, _GearmanFunction>();
    }
    if (_functions.containsKey(funcName)) {
      return;
    }
    _functions[funcName] = new _GearmanFunction(funcName, timeout);
    var cando = new _Packet.createCanDo(funcName);
    _send(cando);
  }


  void cantDo(String funcName) {
    if (_functions != null || _functions[funcName] == null) {
      return;
    }
    _functions[funcName].retired = true;
    var cantDo = new _Packet.createCantDo(funcName);
    _send(cantDo);
  }


  void resetAbilities() {
    _functions.forEach((String _, _GearmanFunction func){
      func.retired = true;
    });
    var resetAbilities = new _Packet.createResetAbilities();
    _send(resetAbilities);
  }

  Future addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    var completer = new Completer<bool>();
    _connection = new Connection(host, port);

    connectedFailed(Exception e) {
      assert(_connected == false);
      _logger.shout("connected fail: $e");
      completer.completeException(e);
    }

    connectionBreak(var e) {
      _logger.shout("connection break: $e");
      _connected = false;
      //TODO: socket break?
    }

    _connection.onError = connectedFailed;

    _connection.onConnect = () {
      _logger.fine("connected gearman server");
      _connected = true;
      _connection.onError = connectionBreak;
      completer.complete(true);
      if (_pendingPackets != null) {
        while (!_pendingPackets.isEmpty) {
          _connection.sendPacket(_pendingPackets.removeFirst());
        }
      }
    };

    _connection.onPacket = (_Packet packet) {
      _logger.fine("received packet: $packet");
      switch (packet.type) {
        case _Type.NO_JOB:
          if (_onNoJob != null) {
            _onNoJob();
          }
          break;
        case _Type.NOOP:
          assert(_isSleeping);
          if (_onNoOp != null) {
            _isSleeping = false;
            _onNoOp();
          }
          break;
        case _Type.JOB_ASSIGN:
          var job = new _AssignedJob.fromPacket(this, packet);
          _addAssignedJob(job);
          break;
        case _Type.JOB_ASSIGN_UNIQ:
          var job = new _AssignedJob.fromPacketUnique(this, packet);
          _addAssignedJob(job);
          break;
        case _Type.ERROR:
          var code = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_CODE));
          var text = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_TEXT));
          _onError(new GearmanException("<$code>$text"));
          break;
        default:
          _logger.shout("received a packet no handler: $packet");
      }
    };

    _connection.onClosed = () {
      _connected = false;
      _logger.shout("connection closed");
    };

    return completer.future;
  }

  _addAssignedJob(_AssignedJob job) {
    if (_functions[job.funcName].assignedJobs == null) {
      _functions[job.funcName].assignedJobs = new Map<String, AssignedJob>();
    }
    _functions[job.funcName].assignedJobs[job.handle] = job;
    // TODO:
    if (_onJobAssigned == null) {
      throw new GearmanException("No `onJobAssigned handler.");
    }
    _onJobAssigned(job);
  }

  _removeAssignedJob(_AssignedJob job) {
    _functions[job.funcName].assignedJobs.remove(job.handle);
    if (_onComplete != null) {
      new Timer(0, (t) => _onComplete());
    }
  }

  _updateWorkData(AssignedJob job, List<int> data) {
    _logger.fine("send work data ${job.funcName}");
    _send(new _Packet.createWorkData(_Magic.REQ, job.handle.charCodes, data));
  }

  _updateWorkWarning(AssignedJob job, List<int> data) {
    _logger.shout("warning a job ${job.funcName}");
    _removeAssignedJob(job);
    _send(new _Packet.createWorkWarning(_Magic.REQ, job.handle.charCodes, data));
  }

  _updateWorkException(AssignedJob job, List<int> data) {
    _logger.shout("exception a job ${job.funcName}");
    _removeAssignedJob(job);
    _send(new _Packet.createWorkException(_Magic.REQ, job.handle.charCodes, data));
  }

  _complete(AssignedJob job, List<int> data) {
    _logger.fine("complete a job ${job.funcName}");
    _removeAssignedJob(job);
    _send(new _Packet.createWorkComplete(_Magic.REQ, job.handle.charCodes, data));
  }

  _fail(AssignedJob job) {
    _logger.shout("fail a job ${job.funcName}");
    _removeAssignedJob(job);
    _send(new _Packet.createWorkFail(_Magic.REQ, job.handle.charCodes));
  }

  _updateStatus(AssignedJob job, int numerator, int denominator) {
    _send(new _Packet.createWorkStatus(_Magic.REQ, job.handle.charCodes, numerator, denominator));
  }
}