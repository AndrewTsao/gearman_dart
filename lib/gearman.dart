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
 *  TODO:
 *  charCodes 并不是NULL Terminated的字符数组，需要编码
 * 
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
}

typedef List<int> GearmanFunction(List<int> jobHandle, String funcName, List<int> data);

abstract class GearmanWorker {
  factory GearmanWorker() => new _GearmanWorkerImpl();
  
  void addServer([String host = GEARMAN_DEFAULT_HOST, int port = GEARMAN_DEFAULT_PORT]);
  
  void addFunction(String funcName, GearmanFunction function);
}

abstract class GearmanRequest {
  
}

abstract class GearmanResponse {
  
  void set OnComplete(Function callback);
}

class GearmanException implements Exception {
  const GearmanException([String this.message = ""]);
  String toString() => "GearmanException: $message";
  final String message;
}
