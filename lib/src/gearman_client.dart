part of gearman;

const _JOB_UPDATE_PACKET_TYPES = 
  const [
         _Type.WORK_DATA, _Type.WORK_WARNING, 
         _Type.WORK_STATUS, _Type.WORK_COMPLETE,
         _Type.WORK_FAIL, _Type.WORK_EXCEPTION];

class _SubmittedJob implements SubmittedJob {
  _GearmanClientImpl _client;
  String _jobHandle;
  _SubmittedJob (this._client, this._jobHandle);
  
  Function _onComplete;
  Function _onData;
  Function _onFail;
  Function _onException;
  Function _onWarning;
  Function _onStatus;
  
  Future<JobStatus> getStatus() {
    var completer = new Completer<JobStatus>();
    _client._sendPacket(new _Packet.createGetStatus(_jobHandle.charCodes), completer);
    return completer.future;
  }
  
  get handle
    => _jobHandle;
  
  set onComplete(void callback()) 
    => _onComplete = callback;
  
  set onData (void callback(List<int> data))
    => _onData = callback;
  
  set onFail(void callback())
    => _onFail = callback;
  
  set onException(void callback(List<int> data))
    => _onException = callback;
    
  set onWarning(void callback(List<int> data))
    => _onWarning = callback;
  
  set onStatus(void callback(JobStatus status))
    => _onStatus = callback;
        
  _update(_Packet packet) {
    assert(new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE)) == handle);
    
    switch(packet.type) {
      case _Type.WORK_COMPLETE:
        _onData(packet.getArgumentData(Argument.DATA));
        _onComplete();
        break;
      case _Type.WORK_DATA:
        _onData(packet.getArgumentData(Argument.DATA));
        break;
      case _Type.WORK_WARNING:
        _onWarning(packet.getArgumentData(Argument.DATA));
        break;
      case _Type.WORK_EXCEPTION:
        _onException(packet.getArgumentData(Argument.DATA));
        break;
      case _Type.WORK_FAIL:
        _onFail();
        break;
      case _Type.WORK_STATUS:
        var status = new _JobStatus.fromPacket(packet);
        _onStatus(status);
        break;
      default:
        throw new GearmanException("invalid job packet receved");
    };
  }
}

class _JobStatus implements JobStatus {
  bool known;
  bool running;
  int denominator;
  int numerator;
   
  _JobStatus.fromPacket(_Packet packet) {
    known = packet.getArgumentData(Argument.KNOWN_STATUS)[0] == '0'.charCodes[0];
    running = packet.getArgumentData(Argument.RUNNING_STATUS)[0] == '0'.charCodes[0];
    denominator = int.parse(new String.fromCharCodes(packet.getArgumentData(Argument.DENOMINATOR)));
    numerator = int.parse(new String.fromCharCodes(packet.getArgumentData(Argument.NUMERATOR)));
  }
}

class _Request {
  _Packet packet;
  Completer completer;
  _Request(this.packet, this.completer);
}

class _GearmanClientImpl implements GearmanClient {
  static Logger _logger = new Logger("GearmanClient");
  Connection _connection;
  Map<String, _SubmittedJob> _submittedJobs;
  Queue<_Request> _pendingRequests;
  bool _waitingResponse;
  
  _GearmanClientImpl() {
    _pendingRequests = new Queue<_Request>();
  }
   
  Future addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]) {
    assert(_connection == null);
    _logger.fine("add server $host $port");
    
    var completer = new Completer();
    _connection = new Connection(host, port);
    
    _connection.onConnect = () {
      _logger.fine("conneted $host $port");
      _waitingResponse = false;
      completer.complete(null);
    };
    
    _connection.onPacket = _packetReceived;
    return completer.future;
  }
  
  _sendPacket(_Packet packet, Completer completer) {
    assert(_connection != null); //TODO: PUT REQUEST INTO QUEUE
    var request = new _Request(packet, completer);
    _pendingRequests.addLast(request);
    if (!_waitingResponse) {
      _processPendings();
      return;
    }
    _logger.fine("pending packet $packet");
  }

  _processPendings() {
    assert(!_waitingResponse);
    if (_pendingRequests.isEmpty) {
      return;
    }
    var req = _pendingRequests.first.packet;
    _logger.fine("send $req");
    _connection.sendPacket(req);
    _waitingResponse = true;    
  }
  
  _isJobUpdatePacket(_Packet packet) {
    return _JOB_UPDATE_PACKET_TYPES.indexOf(packet.type, 0) != -1;
  }
  
  _updateJob(_Packet packet) {
    var handle = new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE));
    if (_submittedJobs == null || _submittedJobs[handle] == null) {
      _logger.shout("received a cancelled job update");
      return;
    }   
    _submittedJobs[handle]._update(packet);
    if (packet.type == _Type.WORK_COMPLETE) {
      var handle = new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE));
      _submittedJobs.remove(handle);
    }
  }
  
  _packetReceived(_Packet packet) {
    _logger.fine("received a packet $packet");
    
    if (_isJobUpdatePacket(packet)) {
      return _updateJob(packet);
    }
    
    var request = _pendingRequests.removeFirst();
    switch (packet.type) {
      case _Type.ERROR:
        var code = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_CODE));
        var text = new String.fromCharCodes(packet.getArgumentData(Argument.ERROR_TEXT));
        request.completer.completeException(new GearmanException("<$code>$text"));
        break;
      case _Type.JOB_CREATED:
        var jobHandle = new String.fromCharCodes(packet.getArgumentData(Argument.JOB_HANDLE));
        var _submittedJob = new _SubmittedJob(this, jobHandle);
        if (_submittedJobs == null) {
          _submittedJobs = new Map<String, _SubmittedJob>();
        }
        _submittedJobs[jobHandle] = _submittedJob;
        request.completer.complete(_submittedJob);
        break;
      case _Type.STATUS_RES:
        assert(request.packet.type == _Type.GET_STATUS);
        JobStatus status = new _JobStatus.fromPacket(packet);
        request.completer.complete(status);
        break;
      case _Type.OPTION_RES:
        throw new Exception("not yet implemented");
        //break;
      default:
        // TODO: process other packets.
        assert(false);
    };
    _waitingResponse = false;
    _processPendings();
  }
  
  // TODO: priority
  Future<SubmittedJob> submitJob(String func, List<int> data, [GearmanJobPriority priority = GearmanJobPriority.NORMAL]) {
    var completer = new Completer<SubmittedJob>();
    var packet = new _Packet.createSubmitJob(func, [], data);
    _sendPacket(packet, completer);
    return completer.future;
  }
  
  Future<SubmittedJob> submitJobBg(String func, List<int> data, [GearmanJobPriority priority = GearmanJobPriority.NORMAL]) {
    var packet = new _Packet.createSubmitJobBg(func, [], data);
    _connection.sendPacket(packet);
  }
}