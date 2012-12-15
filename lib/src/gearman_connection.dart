part of gearman;

/**
 * 与Job Server建立连接，负责发送与接收Packet
 * 它有OnPacket和SendPacket两个基本接口
 * 之外，onConnect/onClosed/onError
 */ 


abstract class GearmanConnection {
  int get port;
  String get host;
  
  void set onPacket(void callback());
  SendPacket(_Packet packet);
  void set onConnect(void callback());
  void set onClosed(void close());
  void set onError(void error(e));
}
