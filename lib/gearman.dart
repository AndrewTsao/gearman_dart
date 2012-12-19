library gearman;
import 'dart:io';
import 'dart:scalarlist';
import 'dart:collection';
import 'dart:isolate';

part "src/gearman_packet.dart";
part "src/gearman_parser.dart";
part "src/gearman_worker.dart";
part "src/gearman_client.dart";
part "src/gearman_connection.dart";

/**
 * log:
 *   2012.12.15 基本完成Gearman Packet的解析工作
 * 
 * TODO:
 *   抽象Gearman Client/Gearman Worker/Gearman Job
 *   面向Future和Stream的接口
 *   基于Isolate构建并发的Worker
 *  
 *  FIX:
 *  charCodes 并不是NULL Terminated的字符数组，需要编码 * 
 */

const GEARMAN_DEFAULT_HOST =  "localhost";
const GEARMAN_DEFAULT_PORT = 4730;
const GEARMAN_DEFAULT_JOB_TIMEOUT = 3000;

abstract class GearmanJobPriority {
  const NORMAL = 0;
  const LOW = 1;
  const HIGH = 2;
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

/**
 * SUBMIT_JOB, SUBMIT_JOB_BG, SUBMIT_JOB_HIGH, SUBMIT_JOB_HIGH_BG, 
 * SUBMIT_JOB_LOW, SUBMIT_JOB_LOW_BG
 * 
 * BG 类型的任务提交之后就与Client没有关系了，任务的更新和数据都不会返回给Client
 * 而非BG的任务则会返回，而且一旦Client断开，JobServer就不会将暂留在队列中的任务清除掉，
 * 而不分发给Worker.
 */
abstract class GearmanClient {
  factory GearmanClient() => new _GearmanClientImpl();
  
  void addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]);
  
  /**
   * Arguments:
    - NULL byte terminated function name.
    - NULL byte terminated unique ID.
    - Opaque data that is given to the function as an argument.
  */
  //Future<GearmanJob> submitJob(String func, List<int> data, GearmanJobPriority priority);
  // Job.getStatus() 查询Job的当前进度
}

typedef List<int> GearmanFunction(List<int> jobHandle, String funcName, List<int> data);

abstract class GearmanWorker {
  factory GearmanWorker() => new _GearmanWorkerImpl();
  
  void addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]);
  
  void addFunction(String funcName, GearmanFunction function);
}

abstract class GearmanWorker2 {
  Future<bool> setClientId(String clientId);
}

abstract class GearmanClient2 {
  Future<GearmanJob2> submitJob(String funcName, List<int> data);
}

/**
 * 对于一个任务，Worker只要未发送Work_Complete之前，都可以不停地通过Work_Data
 * 包返回数据。前提是，这个任务是非BG的。BG任务返回数据的话是错误的。
 * 
 * 
 */


abstract class GearmanJob2 {
  List<int> get jobHandle; //注意： 算上NULL不可以超出64字节
  Future<WorkStatus> getStatus();
  set onComplete(void callback(List<int> data));
  set onData (void callback(List<int> data));
  set onError(void callback(String code, String text));
  set onException(void callback());
  set onWarning(void callback());
}


class GearmanException implements Exception {
  const GearmanException([String this.message = ""]);
  String toString() => "GearmanException: $message";
  final String message;
}
