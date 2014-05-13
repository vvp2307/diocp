/////////////////////初始化
//创建连接池组
FPoolGroup := TADOConnectionPoolGroup.Create();

//加载配置<初始化连接池>
TADOPoolGroupTools.loadconfig(FPoolGroup);
//配置文件
//{
//   "main":
//    {
//		"host": "192.168.1.2",
//		"user": "sa",
//		"password": "efsa",
//		"database": "EF_DATA"
//    },
//   "sys":
//    {
//		"host": "192.168.7.55",
//		  "user": "sa",
//		  "password": "efsa",
//		  "database": "EF_SYS"
//    },
//}


////////////使用连接池
var
  lvADOPool:TADOConnectionPool;
  lvConn:TADOConnection;
begin
  //连接池组中获取一个连接池
  lvADOPool := FPoolGroup.getPool('sys');
 
  //连接池中获取一个连接
  lvConn := TADOConnection(lvADOPool.beginUseObject);

  //归还一个连接
  lvADOPool.endUseObject(lvConn);
