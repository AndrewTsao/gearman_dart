library gearman;
import 'dart:io';
import 'dart:scalarlist';
import 'dart:collection';
import 'dart:isolate';
import 'package:logging/logging.dart';

part "src/gearman_packet.dart";
part "src/gearman_parser.dart";
part "src/gearman_worker.dart";
part "src/gearman_client.dart";
part "src/gearman_connection.dart";

const GEARMAN_DEFAULT_HOST =  "localhost";
const GEARMAN_DEFAULT_PORT = 4730;
const GEARMAN_DEFAULT_JOB_TIMEOUT = 3000;

class GearmanJobPriority {
  final value;
  static const NORMAL = const GearmanJobPriority._def(0);
  static const LOW = const GearmanJobPriority._def(1);
  static const HIGH = const GearmanJobPriority._def(2);
  const GearmanJobPriority._def(this.value);
}

/**
 *  A Gearman powered application consists of three parts: a 
 *  client, a worker, and a job server. 
 *  
 *  The client is responsible for creating a job to be run and
 *  sending it to a job server. 
 *  
 *  The job server will find a suitable worker that can run the
 *  job and forwards the job on. 
 *   
 *  The worker performs the work requested by the client and 
 *  sends a response to the client through the job server.  
 */

abstract class GearmanWorker {
  factory GearmanWorker() => new _GearmanWorker();
  
  Future addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]);
  setClientId(String clientId);
  canDo(String funcName, [int timeout = GEARMAN_DEFAULT_JOB_TIMEOUT]);
  cantDo(String funcName);
  resetAbilities();
  grabJob();
  grabJobUniq();
  preSleep();
  
  set onJobAssigned(callback(AssignedJob job));
  set onNoOp(callback());
  set onNoJob(callback());
  set onError(callback(Exception e));
  set onComplete(callack());
}

abstract class AssignedJob {
  GearmanWorker get worker;
  bool get isUnique;
  String get funcName;
  String get handle;
  String get uniqueId;
  List<int> get data;
  
  sendData(List<int> data);
  sendWarning(List<int> data);
  sendException(List<int> data);
  sendComplete([List<int> data = const []]);
  sendFail();
  sendStatus(int numerator, int denominator);
  
  // on connection break?
}


/**
 * 一个Client可以连接多个Server，每一个连接都是一个Connection.
 * SUBMIT_JOB, SUBMIT_JOB_BG, SUBMIT_JOB_HIGH, SUBMIT_JOB_HIGH_BG, 
 * SUBMIT_JOB_LOW, SUBMIT_JOB_LOW_BG
 * 
 * BG 类型的任务提交之后就与Client没有关系了，任务的更新和数据都不会返回给Client
 * 而非BG的任务则会返回，而且一旦Client断开，JobServer就不会将暂留在队列中的任务清除掉，
 * 而不分发给Worker.
 */
abstract class GearmanClient {
  factory GearmanClient() => new _GearmanClientImpl();
  Future addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]);
  Future<SubmittedJob> submitJob(String funcName, List<int> data, [GearmanJobPriority priority = GearmanJobPriority.NORMAL]);
  Future<SubmittedJob> submitJobBg(String funcName, List<int> data, [GearmanJobPriority priority = GearmanJobPriority.NORMAL]);
}

abstract class JobStatus {
  bool get known;
  bool get running;
  int get denominator;
  int get numerator;
}

/**
 * 对于一个任务，Worker只要未发送Work_Complete之前，都可以不停地通过Work_Data
 * 包返回数据。前提是，这个任务是非BG的。BG任务返回数据的话是错误的。
 */
abstract class SubmittedJob {
  String get handle; // the length of handle no more than 64 bytes include NULL byte.
  Future<JobStatus> getStatus();
  set onComplete(void callback());
  set onData (void callback(List<int> data));
  set onException(void callback(List<int> data));
  set onWarning(void callback(List<int> data));
  set onFail(void callback());
  set onStatus(void callback(JobStatus status));
}

class GearmanException implements Exception {
  const GearmanException([String this.message = ""]);
  String toString() => "GearmanException: $message";
  final String message;
}
