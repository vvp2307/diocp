unit qxml;

{$I 'qdac.inc'}
{
  本源码来自QDAC项目，版权归swish(QQ:109867294)所有。
  (1)、使用许可及限制
  您可以自由复制、分发、修改本源码，但您的修改应该反馈给作者，并允许作者在必要时，
合并到本项目中以供使用，合并后的源码同样遵循QDAC版权声明限制。
  您的产品的关于中，应包含以下的版本声明:
  本产品使用的XML解析器来自QDAC项目中的QXML，版权归作者所有。
  (2)、技术支持
  有技术问题，您可以加入QDAC官方QQ群250530692共同探讨。
  (3)、赞助
  您可以自由使用本源码而不需要支付任何费用。如果您觉得本源码对您有帮助，您可以赞
助本项目（非强制），以使作者不为生活所迫，有更多的精力为您呈现更好的作品：
  赞助方式：
  支付宝： guansonghuan@sina.com 姓名：管耸寰
  建设银行：
    户名：管耸寰
    账号：4367 4209 4324 0179 731
    开户行：建设银行长春团风储蓄所
}
//测试环境仅为Delphi 2007或XE6，其它版本的开发环境，请自行修改
{修订日志
2014.5.14
=========
  + 加入CopyIf/DeleteIf/FindIf函数
  + 加入for..in语法支持

2014.5.6
========
  + 加入ParseBlock函数支持
2014.5.1
========
  + 加入AddRecord函数，支持直接保存记录数据，但以下类型的成员会被忽略
    对象(Class)、函数(Method)、接口(Interface)、类型引用(ClassRef),指针(Pointer)、过程(Procedure)
    将来可能根据实际需要决定是否添加支持
  + 加入ToRecord函数，完成Json直接到记录类型的转换
  + 加入Copy函数用于创建当前结点的一个拷贝实例，注意目前版本克隆内部调用了Copy函数，将来可能改掉
  * 修正了Assign函数的一处错误
}
interface
uses classes,sysutils,qstring,typinfo,variants,qrbtree
  {$IFDEF QDAC_UNICODE}
  ,Generics.Collections,RegularExpressionsCore
  {$ENDIF}
  {$IFDEF QDAC_RTTI}
  ,Rtti
  {$ENDIF}
  ;

{$M+}
  ///本单元是QDAC的组成部分，受QDAC授权限制，详情访问QDAC网站了解
  /// <summary>
  /// XML解析单元，用于快速解析和维护XML结构.全局变量XMLDateFormat和XMLDateTimeFormat
  /// 约定了日期时间类型转换为XML属性时的数据格式
  /// QXML解析器不支持DTD定义，遇到相关的结点会忽略，保存的XML文件也不会包含DTD数据
  /// </summary>
type
  TQXMLNode=class;
  PQXMLNode=^TQXMLNode;
  TQXMLAttr=class;
  PQXMLAttr=^TQXMLAttr;
  /// <summary>
  /// XML属性类定义，用于保存一项XML属性的值
  /// </summary>
  TQXMLAttr=class
  private
    FName,FValue:QStringW;
    FNameHash:Integer;
    function GetAsInteger: Integer;
    procedure SetAsInteger(const Value: Integer);
    function GetAsInt64: Int64;
    procedure SetAsInt64(const Value: Int64);
    function GetAsFloat: Extended;
    procedure SetAsFloat(const Value: Extended);
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(const Value: Boolean);
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetName(const Value: QStringW);
  public
    /// <summary>属性名称</summary>
    property Name:QStringW read FName write SetName;
    /// <summary>属性值</summary>
    property Value:QStringW read FValue write FValue;
    /// <summary>尝试按整形值来访问值内容</summary>
    property AsInteger:Integer read GetAsInteger write SetAsInteger;
    /// <summary>尝试以64位整数形式来访问值内容</summary>
    property AsInt64:Int64 read GetAsInt64 write SetAsInt64;
    /// <summary>尝试以浮点数的形式来访问值内容</summary>
    property AsFloat:Extended read GetAsFloat write SetAsFloat;
    /// <summary>尝试以字符串的形式来访问值内容（等价于访问Value)
    property AsString:QStringW read FValue write FValue;
    /// <summary>尝试以布尔的形式访问值内容
    property AsBoolean:Boolean read GetAsBoolean write SetAsBoolean;
    /// <summary>尝试以日期时间类型访问内容
    property AsDateTime:TDateTime read GetAsDateTime write SetAsDateTime;
  end;
  {$IFDEF QDAC_UNICODE}
  TQXMLAttrList=TList<TQXMLAttr>;
  {$ELSE}
  TQXMLAttrList=TList;
  {$ENDIF !QDAC_UNICODE}
  TQXMLAttrEnumerator=class;
  /// <summary>XML属性列表，内部使用</summary>
  TQXMLAttrs=class
  private
    FItems:TQXMLAttrList;
    FOwner:TQXMLNode;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TQXMLAttr;
  public
    /// <summary>创建一个XML属性列表</summary>
    ///  <param name="AOwner">所隶属的XML结点</param>
    constructor Create(AOwner:TQXMLNode);overload;
    /// <summary>复制一个XML属性的内容</summary>
    procedure Assign(ASource:TQXMLAttrs);
    /// <summary>添加一个XML属性</summary>
    ///  <param name="AName">要添加的XML属性名称</param>
    ///  <returns>返回添加的XML属性对象
    function Add(const AName:QStringW):TQXMLAttr;overload;
    /// <summary>添加一个XML属性的值</summary>
    ///  <param name="AName">属性名称</param>
    ///  <param name="AValue">属性值</param>
    ///  <returns>返回添加的XML属性的索引</returns>
    ///  <remarks>QXML不检查是否重复，如果不确定是否已存在，在添加前，请用
    /// ItemByName或IndexByName来检查是否存在属性
    function Add(const AName,AValue:QStringW):Integer;overload;
    /// <summary>查找指定名称的属性</summary>
    /// <param name="AName">要查找的属性名称</param>
    /// <returns>返回找到的属性对象</returns>
    function ItemByName(const AName:QStringW):TQXMLAttr;
    /// <summary>获取指定名称的属性的索引号</summary>
    /// <param name="AName">要查找的属性名称</param>
    /// <returns>返回找到的属性的索引，如果未找到，返回-1</returns>
    function IndexOfName(const AName:QStringW):Integer;
    /// <summary>获取指定名称的属性的值</summary>
    /// <param name="AName">属性名称</param>
    /// <param name="ADefVal">如果属性不存在，返回的默认值</param>
    /// <returns>返回找到的属性的值，如果未找到，返回ADefVal参数的值</returns>
    function ValueByName(const AName:QStringW;const ADefVal:QStringW=''):QStringW;
    /// <summary>删除指定索引的属性值</summary>
    /// <param name="AIndex">属性索引</param>
    procedure Delete(AIndex:Integer);overload;
    /// <summary>删除指定名称的属性值</summary>
    /// <param name="AName">属性名称</param>
    /// <remarks>如果有重名的属性，只会删除第一个找到的属性</remarks>
    procedure Delete(AName:QStringW);overload;
    /// <summary>清除所有的属性</summary>
    procedure Clear;
    /// <summary>析构函数</summary>
    destructor Destroy;override;
    /// <summary>for..in支持函数</summary>
    function GetEnumerator:TQXMLAttrEnumerator;
    /// <summary>属性个数</summary>
    property Count:Integer read GetCount;
    /// <summary>属性列表</summary>
    property Items[AIndex:Integer]:TQXMLAttr read GetItems;default;
    /// <summary>属性所有者结点</summary>
    property Owner:TQXMLNode read FOwner;
  end;

  TQXMLAttrEnumerator=class
  private
    FIndex: Integer;
    FList: TQXMLAttrs;
  public
    constructor Create(AList: TQXMLAttrs);
    function GetCurrent: TQXMLAttr; inline;
    function MoveNext: Boolean;
    property Current: TQXMLAttr read GetCurrent;
  end;
  /// <summary>XML结点类型<summary>
  ///  <list>
  ///  <item><term>xntNode</term><description>普通结点</description></item>
  ///  <item><term>xntText</term><description>文本内容</description></item>
  ///  <item><term>xntComment</term><description>注释</description></item>
  ///  <item><term>xntCData</term><description>CDATA</description></item>
  ///  </list>
  TQXMLNodeType=(xntNode,xntText,xntComment,xntCData);
  {$IFDEF QDAC_UNICODE}
  TQXMLNodeList=TList<TQXMLNode>;
  {$IFDEF QDAC_RTTI}
  TQXMLRttiFilterEventA=reference to procedure (ASender:TQXMLNode;AObject:Pointer;AName:QStringW;AType:PTypeInfo;var Accept:Boolean;ATag:Pointer);
  /// <summary>
  /// 结点过滤处理函数，以在XE6上支持匿名函数
  /// </summary>
  /// <param name="ASender">触发事件的TQJson对象</param>
  /// <param name="AItem">要过滤的对象</param>
  /// <param name="Accept">是否要处理该对象</param>
  /// <param name="ATag">用户附加的数据项</param>
  TQXMLFilterEventA=reference to procedure(ASender,AItem:TQXMLNode;var Accept:Boolean;ATag:Pointer);

  {$ENDIF QDAC_RTTI}
  {$ELSE}
  TQXMLNodeList=TList;
  {$ENDIF QDAC_UNICODE}
  TQXMLRttiFilterEvent=procedure (ASender:TQXMLNode;AObject:Pointer;AName:QStringW;AType:PTypeInfo;var Accept:Boolean;ATag:Pointer) of object;
  TQXMLFilterEvent=reference to procedure(ASender,AItem:TQXMLNode;var Accept:Boolean;ATag:Pointer);

  /// <summary>
  ///   AddObject/AddRecord时内部过滤时使用附加的Tag类型，仅用于内部使用
  /// </summary>
  TQXMLTagType=(ttAnonEvent,ttNameFilter);
  /// <summary>内部使用的标记数据定义</summary>
  PQXMLInternalTagData=^TQXMLInternalTagData;
  /// <summary>内部使用的标记数据定义</summary>
  TQXMLInternalTagData=record
    /// <summary>Tag数据的类型</summary>
    TagType:TQXMLTagType;
    {$IFDEF QDAC_RTTI}
    /// <summary>过滤使用的匿名函数</summary>
    OnEvent:TQXMLRttiFilterEventA;
    {$ENDIF}
    /// <summary>接受的属性(AddObject)或记录字段(AddRecord)名称，如果名称同时在IgnoreNames出现，则IgnoreNames里的信息被忽略</summary>
    AcceptNames:QStringW;
    /// <summary>忽略的属性(AddObject)或记录字段(AddRecord)名称，如果名称同时在AcceptNameds里，则AcceptNames优先</summary>
    IgnoreNames:QStringW;
    /// <summary>原始传递给AddObject或AddRecord的附加数据成员，它将被传递给OnEvent的Tag，以供用户使用</summary>
    Tag:Pointer;
  end;
  TQXMLNodeEnumerator=class
  private
    FIndex: Integer;
    FList: TQXMLNode;
  public
    constructor Create(AList: TQXMLNode);
    function GetCurrent: TQXMLNode; inline;
    function MoveNext: Boolean;
    property Current: TQXMLNode read GetCurrent;
  end;
  ///<summary>用于外部支持对象池的函数，创建一个新的TQXMLNode对象，注意从池中创建的对象</summary>
  ///  <returns>返回新创建的QXMLNode对象</returns>
  TQXMLCreateNode=function:TQXMLNode;
  ///<summary>用于外部将对象缓存，以便重用对象</summary>
  ///  <param name="ANode">要释放的tQXMLNode对象</param>
  TQXMLFreeNode=procedure (ANode:TQXMLNode);
  /// <summary>
  ///  TQXMLNode用于解析并维护XML格式数据，要使用前，需要先在堆中创建对应的实例。
  ///  TQJson和TQXML在绝大多数接口上保持一致，但由于Json是有类型信息，而XML没有类型
  ///  信息（始终认为是字符串），因此少部分接口会略有不同.
  ///  与其它实现不同，QXML没有所谓的文档对象，也没有所谓一个根结点下只能有一个结点
  ///  的限制，但如果根结点下有多个子结点，在保存到文件或流中时，如果根结点没有命名
  ///  则会自动加入一个<xml></xml>根结点以保证生成的文件符合XML标准要求。
  ///  您可以认为根结点就是文档对象，任意一级结点都可以直接从文件或流中加载内容，
  ///  或者保存到文件或流中。
  /// </summary>
  TQXMLNode=class
  private
    FAttrs:TQXMLAttrs;
    FItems:TQXMLNodeList;
    FNodeType: TQXMLNodeType;
    FParent: TQXMLNode;
    FName: QStringW;
    FNameHash:Integer;//名称的哈希值
    FData: Pointer;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TQXMLNode;
    function XMLEncode(const S:QStringW):QStringW;
    function XMLDecode(const S:QStringW):QStringW;overload;
    function XMLDecode(const p:PQCharW;l:Integer):QStringW;overload;
    function GetItemIndex: Integer;
    function GetText: QStringW;
    procedure SetText(const Value: QStringW);
    procedure SetName(const Value: QStringW);
    function GetAttrs: TQXMLAttrs;
    function GetPath: QStringW;
    function GetCapacity: Integer;
    procedure SetCapacity(const Value: Integer);
    function InternalEncode(ABuilder:TQStringCatHelperW;ADoFormat:Boolean;const AIndent:QStringW):TQStringCatHelperW;
    function GetName: QStringW;
    procedure InternalRttiFilter(ASender:TQXMLNode;AObject:Pointer;APropName:QStringW;APropType:PTypeInfo;var Accept:Boolean;ATag:Pointer);
    function InternalAddObject(AName: QStringW; AObject: TObject;
      AOnFilter: TQXMLRttiFilterEvent;ANest: Boolean;
      ATag: Pointer): TQXMLNode;
    function GetAsXML: QStringW;
    procedure SetAsXML(const Value: QStringW);
    procedure DoParse(p:PQCharW);
    procedure SetNodeType(const Value: TQXMLNodeType);
    function CreateNode:TQXMLNode;virtual;
    procedure FreeNode(ANode:TQXMLNode);inline;
    {$IFDEF QDAC_RTTI}
    function InternalAddRecord(ATypeInfo: PTypeInfo; ABaseAddr: Pointer;
      AOnFilter: TQXMLRttiFilterEvent; ATag: Pointer): Boolean;
    procedure InternalToRecord(ATypeInfo:PTypeInfo;ABaseAddr:Pointer);
    {$ENDIF}
  public
    /// <summary>构造函数</summary>
    constructor Create;overload;
    /// <summary>析构函数</summary>
    destructor Destroy;override;
    /// <summary>值拷贝函数</summary>
    procedure Assign(ANode:TQXMLNode);
    /// <summary>添加一个未命名结点</summary>
    /// <remarks>如果您添加了一个未命名结点，保存时，该结点层级将被忽略而直接保存子一级</remarks>
    function Add: TQXMLNode;overload;
    /// <summary>添加一个结点、文本、注释或CData</summary>
    ///  <param name="AName_Text">名称或内容，具体取决于AType参数</param>
    ///  <returns>返回添加的结点实例</returns>
    function Add(const AName_Text:QStringW;AType:TQXMLNodeType=xntNode):TQXMLNode;overload;
    /// <summary>添加一个结点</summary>
    /// <param name="AName">结点名称</param>
    ///  <returns>返回添加的结点实例</returns>
    /// <remarks>等价于调用Add(AName,xntNode)</remarks>
    function AddNode(const AName:QStringW):TQXMLNode;virtual;
    /// <summary>添加一个文本结点</summary>
    /// <param name="AText">要添加的文本内容</param>
    /// <returns>返回添加的结点实例</returns>
    /// <remarks>等价于调用Add(AText,xntText)</remarks>
    function AddText(const AText:QStringW):TQXMLNode;
    /// <summary>添加一个注释</summary>
    /// <param name="AText">要添加的注释内容，不能包含--&gt;</param>
    /// <returns>返回添加的结点实例</returns>
    /// <remarks>等价于调用Add(AText,xntComment)</remarks>
    function AddComment(const AText:QStringW):TQXMLNode;
    /// <summary>添加一个注释</summary>
    /// <param name="AText">要添加的CData，不能包含]]&gt;</param>
    /// <returns>返回添加的结点实例</returns>
    /// <remarks>等价于调用Add(AText,xntCData)</remarks>
    function AddCData(const AText:QStringW):TQXMLNode;
    {$IFDEF QDAC_RTTI}
    /// <summary>添加一个对象到当前结点</summary>
    ///  <param name="AName">要添加的对象结点名称</param>
    ///  <param name="AObject">要添加的对象</param>
    ///  <param name="AOnFilter">指定属性过滤事件，以过滤掉不需要转换的属性</param>
    ///  <param name="ANest">如果属性的是对象，是否递归</param>
    ///  <param name="ATag">附加的数据成功，用于事件回调中用户自己的用途</param>
    function AddObject(AName:QStringW;AObject:TObject;AOnFilter:TQXMLRttiFilterEventA;ANest:Boolean;ATag:Pointer=nil):TQXMLNode;overload;
    /// 添加一个记录（结构体）到当前结点
    /// <param name="AName">要添加的对象的结点名称</param>
    /// <param name="AObject">要添加的记录实例</param>
    /// <returns>返回创建的结点实例</returns>
    /// <remarks>
    function AddRecord<T>(AName:QStringW;const AObject:T;AcceptFields,AIgnoreFields:QStringW):TQXMLNode;overload;
    /// 添加一个记录（结构体）到当前结点
    /// <param name="AName">要添加的对象的结点名称</param>
    /// <param name="AObject">要添加的对象实例</param>
    /// <returns>返回创建的结点实例</returns>
    function AddRecord<T>(AName:QStringW;const AObject:T):TQXMLNode;overload;
    /// 添加一个记录（结构体）到当前结点
    /// <param name="AName">要添加的对象的结点名称</param>
    /// <param name="AObject">要添加的对象实例</param>
    /// <param name="AOnFilter">指定属性过滤事件，以过滤掉不需要转换的属性</param>
    /// <param name="ATag">附加的数据成功，用于事件回调中用户自己的用途</param>
    /// <returns>返回创建的结点实例</returns>
    function AddRecord<T>(AName:QStringW;const AObject:T;AOnFilter:TQXMLRttiFilterEvent;ATag:Pointer):TQXMLNode;overload;
    /// 添加一个记录（结构体）到Json中
    /// <param name="AName">要添加的对象的结点名称</param>
    /// <param name="AObject">要添加的对象实例</param>
    /// <param name="AOnFilter">指定属性过滤事件，以过滤掉不需要转换的属性</param>
    /// <param name="ATag">附加的数据成功，用于事件回调中用户自己的用途</param>
    /// <returns>返回创建的结点实例</returns>
    function AddRecord<T>(AName:QStringW;const AObject:T;AOnFilter:TQXMLRttiFilterEventA;ATag:Pointer):TQXMLNode;overload;
    {$ENDIF}
    /// <summary>添加一个对象到结点</summary>
    ///  <param name="AName">要添加的对象结点名称</param>
    ///  <param name="AObject">要添加的对象</param>
    ///  <param name="AOnFilter">指定属性过滤事件，以过滤掉不需要转换的属性</param>
    ///  <param name="ANest">如果属性的是对象，是否递归</param>
    ///  <param name="ATag">附加的数据成功，用于事件回调中用户自己的用途</param>
    /// <returns>返回添加的结点</returns>
    function AddObject(AName:QStringW;AObject:TObject;AOnFilter:TQXMLRttiFilterEvent;ANest:Boolean;ATag:Pointer=nil):TQXMLNode;overload;
    /// <summary>添加一个对象到Json对象</summary>
    ///  <param name="AName">要添加的对象结点名称</param>
    ///  <param name="AObject">要添加的对象</param>
    ///  <param name="AcceptProps">允许加入的属性/param>
    ///  <param name="AIgnoreProps">忽略不加入的属性</param>
    /// <returns>返回添加的结点</returns>
    function AddObject(AName:QStringW;AObject:TObject;ANest:Boolean;AcceptProps,AIgnoreProps:QStringW):TQXMLNode;overload;
    /// <summary>获取指定名称的第一个结点</summary>
    /// <param name="AName">结点名称</param>
    /// <returns>返回找到的结点，如果未找到，返回空(NULL/nil)</returns>
    /// <remarks>注意XML允许重名，因此，如果存在重名的结点，只会返回第一个结点</remarks>
    function ItemByName(const AName:QStringW):TQXMLNode;overload;
    /// <summary>获取指定名称的结点到列表中</summary>
    /// <param name="AName">结点名称</param>
    ///  <param name="AList">用于保存结点的列表对象</param>
    ///  <param name="ANest">是否递归查找子结点</param>
    /// <returns>返回找到的结点数量，如果未找到，返回0</returns>
    function ItemByName(const AName:QStringW;AList:TQXMLNodeList;ANest:Boolean=False):Integer;overload;
    /// <summary>获取指定路径的JSON对象</summary>
    ///  <param name="APath">路径，以"."或"/"或"\"分隔</param>
    ///  <returns>返回找到的子结点，如果未找到返回NULL(nil)</returns>
    function ItemByPath(const APath:QStringW):TQXMLNode;
    /// <summary>获取符合指定名称规则的结点到列表中</summary>
    /// <param name="ARegex">正则表达式</param>
    ///  <param name="AList">用于保存结点的列表对象</param>
    ///  <param name="ANest">是否递归查找子结点</param>
    /// <returns>返回找到的结点数量，如果未找到，返回0</returns>
    function ItemByRegex(const ARegex:QStringW;AList:TQXMLNodeList;ANest:Boolean=False):Integer;overload;
    /// <summary>获取指定路径结点的文本内容</summary>
    /// <param name="APath">路径，以"."或"/"或"\"分隔</param>
    /// <param name="ADefVal">若路径不存在，返回的默认值</param>
    /// <returns>如果找到结点，返回找到的结点的文本内容，否则返回ADefVal参数的值</returns>
    /// <remarks>
    function TextByPath(const APath,ADefVal:QStringW):QStringW;

    function ItemWithAttrValue(const APath:QStringW;const AttrName,AttrValue:QStringW):TQXMLNode;
    /// <summary>获取指定路径结点的指定属性</summary>
    /// <param name="APath">路径，以"."或"/"或"\"分隔</param>
    /// <param name="AttrName">属性名称</param>
    /// <returns>如果找到结点相应的属性，返回找到的属性，否则返回NULL/nil</returns>
    /// <remarks>
    function AttrByPath(const APath,AttrName:QStringW):TQXMLAttr;
    /// <summary>获取指定路径结点的指定属性值</summary>
    /// <param name="APath">路径，以"."或"/"或"\"分隔</param>
    /// <param name="AttrName">属性名称</param>
    /// <param name="ADefVal">若路径不存在，返回的默认值</param>
    /// <returns>如果找到结点相应的属性，返回找到的属性的文本内容，否则返回ADefVal参数的值</returns>
    /// <remarks>
    function AttrValueByPath(const APath,AttrName,ADefVal:QStringW):QStringW;

    /// <summary>强制一个路径存在,如果不存在,则依次创建需要的结点</summary>
    /// <param name="APath">要添加的结点路径</param>
    /// <returns>返回路径对应的对象</returns>
    function ForcePath(APath:QStringW):TQXMLNode;
    /// <summary>编码为字符串</summary>
    /// <param name="ADoFormat">是否格式化字符串，以增加可读性</param>
    /// <param name="AIndent">ADoFormat参数为True时，缩进内容，默认为两个空格</param>
    /// <returns>返回编码后的字符串</returns>
    ///  <remarks>AsXML等价于Encode(True,'  ')</remarks>
    function Encode(ADoFormat:Boolean;AIndent:QStringW='  '):QStringW;
    /// <summary>拷贝生成一个新的实例</summary>
    /// <returns>返回新的拷贝实例</returns>
    /// <remarks>因为是拷贝，所以新旧对象之间的内容变更没有任何关系，更改任意一个
    ///  对象，不会对另外一个对象造成影响。
    ///  </remarks>
    function Copy:TQXMLNode;
    {$IFDEF QDAC_RTTI}
    function CopyIf(const ATag:Pointer;AFilter:TQXMLFilterEventA):TQXMLNode;overload;
    {$ENDIF}
    function CopyIf(const ATag:Pointer;AFilter:TQXMLFilterEvent):TQXMLNode;overload;
    /// <summary>克隆生成一个新的实例</summary>
    /// <returns>返回新的拷贝实例</returns>
    /// <remarks>因为实际上执行的是拷贝，所以新旧对象之间的内容变更没有任何关系，
    ///  更改任意一个对象，不会对另外一个对象造成影响，但此行为将来并不保证，可能
    ///  会调整为引用，以便相互影响。
    ///  </remarks>
    function Clone:TQXMLNode;
    /// <summary>删除指定索引的结点</summary>
    /// <param name="AIndex">要删除的结点索引</param>
    /// <remarks>
    /// 如果指定索引的结点不存在，则抛出EOutRange异常
    /// </remarks>
    procedure Delete(AIndex:Integer);overload;virtual;
    {$IFDEF QDAC_RTTI}
    ///<summary>
    /// 删除符合条件的子结点
    ///</summary>
    ///  <param name="ATag">用户自己附加的额外标记</param>
    ///  <param name="ANest">是否嵌套调用，如果为false，则只对当前子结点过滤</param>
    ///  <param name="AFilter">过滤回调函数，如果为nil，等价于Clear</param>
    procedure DeleteIf(const ATag:Pointer;ANest:Boolean;AFilter:TQXMLFilterEventA);overload;
    {$ENDIF QDAC_RTTI}
    ///<summary>
    /// 删除符合条件的子结点
    ///</summary>
    ///  <param name="ATag">用户自己附加的额外标记</param>
    ///  <param name="ANest">是否嵌套调用，如果为false，则只对当前子结点过滤</param>
    ///  <param name="AFilter">过滤回调函数，如果为nil，等价于Clear</param>
    procedure DeleteIf(const ATag:Pointer;ANest:Boolean;AFilter:TQXMLFilterEvent);overload;

    /// <summary>删除指定名称的结点</summary>
    ///  <param name="AName">要删除的结点名称</param>
    ///  <param name="ADeleteAll">是否删除全部同名的结点</param>
    procedure Delete(AName:QStringW;ADeleteAll:Boolean=True);overload;
    /// <summary>查找指定名称的结点的索引</summary>
    ///  <param name="AName">要查找的结点名称</param>
    ///  <returns>返回索引值，未找到返回-1</returns>
    function IndexOf(const AName:QStringW):Integer;virtual;
    {$IFDEF QDAC_RTTI}
    ///<summary>遍历结点查找符合条件的结点</summary>
    /// <param name="ATag">用户自定义的附加额外标记</param>
    ///  <param name="ANest">是否嵌套调用，如果为false，则只对当前子结点过滤</param>
    ///  <param name="AFilter">过滤回调函数，如果为nil，则返回nil</param>
    function FindIf(const ATag:Pointer;ANest:Boolean;AFilter:TQXMLFilterEventA):TQXMLNode;overload;
    {$ENDIF QDAC_RTTI}
    ///<summary>遍历结点查找符合条件的结点</summary>
    /// <param name="ATag">用户自定义的附加额外标记</param>
    ///  <param name="ANest">是否嵌套调用，如果为false，则只对当前子结点过滤</param>
    ///  <param name="AFilter">过滤回调函数，如果为nil，则返回nil</param>
    function FindIf(const ATag:Pointer;ANest:Boolean;AFilter:TQXMLFilterEvent):TQXMLNode;overload;

    /// <summary>清除所有的结点</summary>
    procedure Clear;virtual;
    /// <summary>解析指定的XML字符串</summary>
    /// <param name="p">要解析的字符串</param>
    /// <param name="l">字符串长度，<=0认为是以\0(#0)结尾的C语言标准字符串</param>
    /// <remarks>如果l>=0，会检测p[l]是否为\0，如果不为\0，则会创建拷贝实例并解析拷贝实例</remarks>
    procedure Parse(p:PQCharW;len:Integer=-1);overload;
    /// <summary>解析指定的JSON字符串</summary>
    /// <param name='s'>要解析的JSON字符串</param>
    procedure Parse(const s:QStringW);overload;
    /// <summmary>从流中解析首个XML结点</summary>
    ///  <param name="AStream">流对象</param>
    ///  <param name="AEncoding">流数据的编码方式</param>
    /// <remarks>ParseBlock适合解析分段式XML，它会从当前位置开始，解析到当前对象结束为止.
    ///  可以很好的满足渐进式传输的需要</remarks>
    procedure ParseBlock(AStream:TStream;AEncoding:TTextEncoding);
    /// <summary>从指定的文件中加载当前对象</summary>
    ///  <param name="AFileName">要加载的文件名</param>
    ///  <param name="AEncoding">源文件编码，如果为teUnknown，则自动判断</param>
    procedure LoadFromFile(AFileName:QStringW;AEncoding:TTextEncoding=teUnknown);
    /// <summary>从流的当前位置开始加载JSON对象</summary>
    ///  <param name="AStream">源数据流</param>
    ///  <param name="AEncoding">源文件编码，如果为teUnknown，则自动判断</param>
    ///  <remarks>流的当前位置到结束的长度必需大于2字节，否则无意义</remarks>
    procedure LoadFromStream(AStream:TStream;AEncoding:TTextEncoding=teUnknown);
    /// <summary>保存当前对象内容到文件中</summary>
    ///  <param name="AFileName">文件名</param>
    ///  <param name="AEncoding">编码格式</param>
    ///  <param name="AWriteBOM">是否写入UTF-8的BOM</param>
    ///  <remarks>注意当前结点的名称不会被写入</remarks>
    procedure SaveToFile(AFileName:QStringW;AEncoding:TTextEncoding=teUTF8;AWriteBom:Boolean=False);
    /// <summary>保存当前对象内容到流中</summary>
    ///  <param name="AStream">目标流对象</param>
    ///  <param name="AEncoding">编码格式</param>
    ///  <param name="AWriteBom">是否写入BOM</param>
    ///  <remarks>注意当前结点的名称不会被写入</remarks>
    procedure SaveToStream(AStream:TStream;AEncoding:TTextEncoding=teUTF8;AWriteBom:Boolean=False);
    /// <summary>重载TObject.ToString函数</summary>
    function ToString: string;{$IFDEF QDAC_UNICODE}override;{$ENDIF}
    /// 将XML的数据还原回原来的对象属性
    procedure ToObject(AObject:TObject);
    {$IFDEF QDAC_RTTI}
    /// <summary>将Json的数据还原回原来的结构体（记录）字段值</summary>
    /// <param name="ARecord">目标结构体实例</param>
    procedure ToRecord<T>(const ARecord:T);
    {$ENDIF QDAC_RTTI}
    /// <summary>for..in支持函数</summary>
    function GetEnumerator:TQXMLNodeEnumerator;
    ///<summary>子结点数量</<summary>summary>
    property Count:Integer read GetCount;
    ///<summary>子结点数组</summary>
    property Items[AIndex:Integer]:TQXMLNode read GetItems;default;
    ///<summary>额外的附加数据成员，供用户关联附加内容</summary>
    property Data:Pointer read FData write FData;
    ///<summary>结点的路径，中间以"\"分隔</summary>
    property Path:QStringW read GetPath;
    ///<summary>结点在父结点上的索引，如果自己是根结点，则返回-1</summary>
    property ItemIndex:Integer read GetItemIndex;
    /// <summary>父结点</summary>
    property Parent:TQXMLNode read FParent write FParent;
  published
    ///<summary>结点名称</summary>
    property Name:QStringW read GetName write SetName;
    ///<summary>结点的纯文本内容（不含注释，只包含Text和CDATA)</summary>
    property Text:QStringW read GetText write SetText;
    ///<summary>结点类型</summary>
    property NodeType:TQXMLNodeType read FNodeType write SetNodeType;
     ///<summary>属性列表</summary>
    property Attrs:TQXMLAttrs read GetAttrs;
    ///<summary>列表容量</summary>
    property Capacity:Integer read GetCapacity write SetCapacity;
    ///<summary>返回XML格式的数据</summary>
    property AsXML:QStringW read GetAsXML write SetAsXML;
  end;

  TQHashedXMLNode=class(TQXMLNode)
  protected
    FHashTable:TQHashTable;
    function CreateNode:TQXMLNode;override;
  public
    constructor Create;overload;
    destructor Destroy;override;
    function AddNode(const AName:QStringW):TQXMLNode;override;
    function IndexOf(const AName:QStringW):Integer;override;
    procedure Delete(AIndex:Integer);override;
    procedure Clear;override;
  end;
var
  /// 日期时间类型转换为Json数据时会转换成字符串，这两个变量控制如何格式化
  XMLDateFormat,XMLDateTimeFormat,XMLTimeFormat:QStringW;
  /// 在ItemByName/ItemByPath/ValueByName/ValueByPath等函数的判断中，是否区分名称大小写
  XMLCaseSensitive:Boolean;
  /// 强制编码时XML节点名称必需配对出现,如果为True，则如果对应的结点没有子结点时，会
  ///  直接以/>结尾，如果为False，则会强制配对出现
  XMLTagShortClose:Boolean;
  /// 在需要新建一个TQXMLNode对象时触发
  OnQXMLNodeCreate:TQXMLCreateNode;
  /// 在需要释放一个TQXMLNode对象时触发
  OnQXMLNodeFree:TQXMLFreeNode;
implementation
uses math;

resourcestring
  SNodeWithoutName='指定的结点名称未指定，无法生成XML数据。';
  SBadXMLName='无效的XML结点名称，名称不能以数字或xml打头，也不能包含空白或控制符。';
  SBadXMLComment='无效的XML注释！注释中不能包含“--”。';
  SUnterminateXMLComment='未结束的XML注释！';
  SBadXMLCData='无效的CData内容！CData内容中不能出现“]]>”。';
  SUnterminateXMLCData='未结束的CDATA标记！';
  SBadXMLEncoding='无效的XML内容编码，QXML只支持UTF-8、UTF-16编码。';
  SXMLBadAttrValue='无效的XML属性值，属性值必需使用引号包裹。';
  SXMLAttrValueMissed='未找到XML属性值定义。';
  SUnterminatedXMLTag='未结束的XML标签定义。';
  SUnclosedXMLTag='未关闭的XML标签定义。';
  SBadXMLEscape='无效的XML转义序列定义。';
  SNotSupport='不支持的函数[%s]';
  SUnknownXMLEscape='未知的XML转义字符串[%s]。';
  SXMLNameNotSupport='当前结点类型不支持名称。';
  SValueNotNumeric='字符串 %s 不是有效的数值。';
  SValueNotBoolean='字符串 %s 不是有效的布尔值。';
  SValueNotDateTime='字符串 %s 不是有效的日期时间值。';
  SBadXMLTagStart='XML文档需要以<开始一个结点名称。';
  SXMLNameNeeded='XML结点在编码前必需指定一个名称。';
{ TQXMLAttrs }
{
名称中的位置	 允许的字符
任何位置
["A"-"Z"]、["a"-"z"]、"_"、[0x00C0-0x02FF]、[0x0370-0x037D]、[0x037F-0x1FFF]、[0x200C-0x200D]、
[0x2070-0x218F]、[0x2C00-0x2FEF]、[0x3001-0xD7FF]、[0xF900-0xEFFF]
除第一个位置之外的任何位置
"-"、"."、["0"-"9"]、0x00B7、[0x0300-0x036F]、[0x203F-0x2040]
元素或属性名称（架构树视图中的节点名称）以英文表示的最佳实践可概括为以下几点：
使用字母数字字符，但名称不要以数字开头。

使用下划线 (_)、连字符 (-)、句点 (.) 和中间点 (·)。

不要使用空格。

使用以自然语言表示的有意义单词或单词的组合。
}
function ValidXMLName(const S:QStringW):Boolean;
var
  p:PQCharW;
  function InRange(const c,cmin,cmax:QCharW):Boolean;inline;
  begin
  Result:=(c>=cmin) and (c<=cmax);
  end;
begin
p:=PQCharW(S);
if InRange(p^,'A','Z') or InRange(p^,'a','z') or (p^='_') or
  InRange(p^,#$00C0,#$02FF) or InRange(p^,#$0370,#$037D) or
  InRange(p^,#$037F,#$1FFF) or InRange(p^,#$200C,#$200D) or
  InRange(p^,#$2070,#$218F) or InRange(p^,#$2C00,#$2FEF) or
  InRange(p^,#$3001,#$D7FF) or InRange(p^,#$F900,#$EFFF) then
  begin
  Inc(p);
  while p^<>#0 do
    begin
    if InRange(p^,'A','Z') or InRange(p^,'a','z') or
      InRange(p^,'0','9') or (p^='_') or (p^='-') or
      (p^='.') or (p^=':') or (p^=#$00B7) or
      InRange(p^,#$00C0,#$02FF) or InRange(p^,#$0300,#$037D) or
      InRange(p^,#$037F,#$1FFF) or InRange(p^,#$200C,#$200D) or
      InRange(p^,#$203F,#$2040) or InRange(p^,#$2070,#$218F) or
      InRange(p^,#$2C00,#$2FEF) or InRange(p^,#$3001,#$D7FF) or
      InRange(p^,#$F900,#$EFFF) then
      Inc(p)
    else
      Break;
    end;
  Result:=(p^=#0);
  end
else
  Result:=False;
end;

function ValidXMLComment(const Value:QStringW):Boolean;
var
  ps:PQCharW;
begin
ps:=PQCharW(Value);
Result:=True;
while ps^<>#0 do
  begin
  if (ps[0]='-') and (ps[1]='-') then
    begin
    Result:=False;
    Break;
    end
  else
    Inc(ps);
  end;
end;

function ValidXMLCData(const Value:QStringW):Boolean;
var
  ps:PQCharW;
begin
ps:=PQCharW(Value);
Result:=True;
while ps^<>#0 do
  begin
  //CDATA里不能出现]]>串
  if (ps[0]=']') and (ps[1]=']') and (ps[2]='>') then
    begin
    Result:=False;
    Break;
    end
  else
    Inc(ps);
  end;
end;

function TQXMLAttrs.Add(const AName, AValue: QStringW): Integer;
var
  Attr:TQXMLAttr;
begin
if ValidXMLName(AName) then
  begin
  Attr:=TQXMlAttr.Create;
  Attr.FName:=AName;
  Attr.FValue:=AValue;
  Result:=FItems.Add(Attr);

  end
else
  raise Exception.Create(SBadXMLName);
end;

function TQXMLAttrs.Add(const AName: QStringW): TQXMLAttr;
begin
if ValidXMLName(AName) then
  begin
  Result:=TQXMlAttr.Create;
  Result.FName:=AName;
  FItems.Add(Result);
  end
else
  raise Exception.Create(SBadXMLName);
end;

procedure TQXMLAttrs.Assign(ASource: TQXMLAttrs);
var
  I:Integer;
  Attr,ASrc:TQXMLAttr;
begin
Clear;
if (ASource<>nil) and (ASource.Count>0) then
  begin
  for I := 0 to ASource.Count-1 do
    begin
    ASrc:=ASource[I];
    Attr:=TQXMLAttr.Create;
    Attr.FName:=ASrc.FName;
    Attr.FValue:=ASrc.FValue;
    FItems.Add(Attr);
    end;
  end;
end;

procedure TQXMLAttrs.Clear;
var
  I:Integer;
begin
for I := 0 to FItems.Count-1 do
  FreeObject(Items[I]);
FItems.Clear;
end;

constructor TQXMLAttrs.Create(AOwner:TQXMLNode);
begin
inherited Create;
FOwner:=AOwner;
FItems:=TQXMLAttrList.Create;
end;

procedure TQXMLAttrs.Delete(AIndex: Integer);
begin
FreeObject(Items[AIndex]);
FItems.Delete(AIndex);
end;

procedure TQXMLAttrs.Delete(AName: QStringW);
var
  AIndex:Integer;
begin
AIndex:=IndexOfName(AName);
if AIndex<>-1 then
  Delete(AIndex);
end;

destructor TQXMLAttrs.Destroy;
begin
Clear;
FreeObject(FItems);
end;

function TQXMLAttrs.GetCount: Integer;
begin
Result:=FItems.Count;
end;

function TQXMLAttrs.GetEnumerator: TQXMLAttrEnumerator;
begin
Result:=TQXMLAttrEnumerator.Create(Self);
end;

function TQXMLAttrs.GetItems(AIndex: Integer): TQXMLAttr;
begin
Result:=FItems[AIndex];
end;

function TQXMLAttrs.IndexOfName(const AName: QStringW): Integer;
var
  I,L,AHash:Integer;
  AItem:TQXMLAttr;
begin
Result:=-1;
L:=Length(AName);
AHash:=HashOf(PQCharW(AName),L shl 1);
for I := 0 to Count-1 do
  begin
  AItem:=Items[I];
  if Length(AItem.FName)=L then
    begin
    if XMLCaseSensitive then
      begin
      if AItem.FNameHash=0 then
        AItem.FNameHash:=HashOf(PQCharW(AItem.FName),L shl 1);
      if AItem.FNameHash=AHash then
        begin
        if AItem.FName=AName then
          begin
          Result:=I;
          Break;
          end;
        end;
      end
    else if StartWithW(PQCharW(AItem.FName),PQCharW(AName),True) then
      begin
      Result:=I;
      Break;
      end;
    end;
  end;
end;

function TQXMLAttrs.ItemByName(const AName: QStringW): TQXMLAttr;
var
  I:Integer;
begin
Result:=nil;
I:=IndexOfName(AName);
if I<>-1 then
  Result:=Items[I];
end;

function TQXMLAttrs.ValueByName(const AName, ADefVal: QStringW): QStringW;
var
  I:Integer;
begin
I:=IndexOfName(AName);
if I<>-1 then
  Result:=Items[I].FValue
else
  Result:=ADefVal;
end;

{ TQXMLNode }

function TQXMLNode.Add: TQXMLNode;
begin
Result:=CreateNode;
Result.FParent:=Self;
if not Assigned(FItems) then
  FItems:=TQXMLNodeList.Create;
FItems.Add(Result);
end;

function TQXMLNode.Add(const AName_Text: QStringW;AType:TQXMLNodeType): TQXMLNode;
begin
if AType=xntNode then
  Result:=AddNode(AName_Text)
else
  begin
  Result:=Add;
  Result.FNodeType:=AType;
  Result.Text:=AName_Text;
  end;
end;
function TQXMLNode.AddCData(const AText: QStringW): TQXMLNode;
begin
Result:=Add(AText,xntCData);
end;

function TQXMLNode.AddComment(const AText: QStringW): TQXMLNode;
begin
Result:=Add(AText,xntComment);
end;

function TQXMLNode.AddNode(const AName: QStringW): TQXMLNode;
begin
ValidXMLName(AName);
Result:=Add;
Result.FNodeType:=xntNode;
Result.FName:=AName;
end;

function TQXMLNode.AddObject(AName: QStringW; AObject: TObject;
  AOnFilter: TQXMLRttiFilterEvent;ANest: Boolean;ATag:Pointer): TQXMLNode;
begin
Result:=InternalAddObject(AName,AObject,AOnFilter,ANest,ATag);
end;

function TQXMLNode.IndexOf(const AName: QStringW): Integer;
var
  I,L,AHash:Integer;
  AItem:TQXMLNode;
  AFound:Boolean;
begin
Result:=-1;
L:=Length(AName);
if L>0 then
  AHash:=HashOf(PQCharW(AName),L shl 1)
else
  AHash:=0;
AFound:=False;
for I := 0 to Count-1 do
  begin
  AItem:=Items[I];
  if (AItem.NodeType=xntNode) and (Length(AItem.FName)=L) then
    begin
    if XMLCaseSensitive then
      begin
      if AItem.FNameHash=0 then
        AItem.FNameHash:=HashOf(PQCharW(AItem.FName),Length(AItem.FName) shl 1);
      if AItem.FNameHash=AHash then
        begin
        if Items[I].FName=AName then
          AFound:=True;
        end;
      end
    else //忽略大小写，不推荐
      AFound:=StartWithW(PQCharW(AItem.FName),PQCharW(AName),True);
    if AFound then
      begin
      Result:=I;
      Break;
      end;
    end;
  end;
end;

function TQXMLNode.InternalAddObject(AName: QStringW; AObject: TObject;
  AOnFilter: TQXMLRttiFilterEvent;ANest: Boolean;ATag:Pointer): TQXMLNode;
  function GetObjectName(AObj:TObject):String;
  begin
  if AObj<>nil then
    begin
    {$IFDEF TYPENAMEASMETHODPREF}
    Result:=TObject(AObj).ClassName;
    {$ELSE}
    if TObject(AObj) is TComponent then
      Result:=TComponent(AObj).GetNamePath
    else if GetPropInfo(AObj,'Name')<>nil then
      Result:=GetStrProp(AObj,'Name');
    if Length(Result)=0 then
      Result:=TObject(AObj).ClassName;
    {$ENDIF}
    end
  else
    SetLength(Result,0);
  end;

  function GetMethodName(AMethod:TMethod):String;
  var
    AMethodName:String;
  begin
  if AMethod.Data<>nil then
    begin
    Result:=GetObjectName(AMethod.Data);
    AMethodName:=TObject(AMethod.Data).MethodName(AMethod.Code);
    {$IFDEF CPUX64}
    if Length(Result)=0 then
      Result:=IntToHex(Int64(AMethod.Data),16);
    if Length(AMethodName)=0 then
      AMethodName:=IntToHex(Int64(AMethod.Code),16);
    {$ELSE}
    if Length(Result)=0 then
      Result:=IntToHex(IntPtr(AMethod.Data),8);
    if Length(AMethodName)=0 then
      AMethodName:=IntToHex(IntPtr(AMethod.Code),8);
    {$ENDIF}
    Result:=Result+'.'+AMethodName;
    end
  else if AMethod.Code<>nil then
    begin
    {$IFDEF CPUX64}
    Result:=IntToHex(Int64(AMethod.Code),16);
    {$ELSE}
    Result:=IntToHex(IntPtr(AMethod.Code),8);
    {$ENDIF}
    end
  else
    SetLength(Result,0);
  end;

  procedure AddChildren(AParent:TQXMLNode;AObj:TObject);
  var
    AList:PPropList;
    ACount:Integer;
    I:Integer;
    AChild:TQXMLNode;
    ACharVal:QStringA;
    V:Variant;
    Accept:Boolean;
  const
    AttrName:QStringW='value';
  begin
  if AObj=nil then
    Exit;
  if PTypeInfo(AObject.ClassInfo)=nil then//对象没有RTTI信息
    Exit;
  AParent.Attrs.Add('class',AObject.ClassName);//记录类型名称
  AList:=nil;
  ACount:=GetPropList(AObj,AList);
  try
    for I := 0 to ACount-1 do
      begin
      if Assigned(AOnFilter) then
        begin
        Accept:=True;
        {$IFDEF QDAC_RTTI_NAMEFIELD}
        AOnFilter(AParent,AObj,AList[I].NameFld.ToString,AList[I].PropType^,Accept,ATag);
        {$ELSE}
        AOnFilter(AParent,AObj,AList[I].Name,AList[I].PropType^,Accept,ATag);
        {$ENDIF}
        if not Accept then
          Continue;
        end;
      {$IFDEF QDAC_RTTI_NAMEFIELD}
      AChild:=AParent.Add(AList[I].NameFld.ToString);
      {$ELSE}
      AChild:=AParent.Add(AList[I].Name);
      {$ENDIF}
      case AList[I].PropType^.Kind of
        tkChar:
          begin
          ACharVal.Length:=1;
          ACharVal.Chars[0]:=GetOrdProp(AObj, AList[I]);
          AChild.Attrs.Add(AttrName,ACharVal);
          end;
        tkWChar:
          AChild.Attrs.Add(AttrName,QCharW(GetOrdProp(AObj, AList[I])));
        tkInteger:
          AChild.Attrs.Add(AttrName,IntToStr(GetOrdProp(AObj, AList[I])));
        tkClass:
          if ANest then
            AddChildren(AChild,TObject(GetOrdProp(AObj,AList[I])))
          else
            AChild.Attrs.Add(AttrName,GetObjectName(TObject(GetOrdProp(AObj,AList[I]))));
        tkEnumeration:
          AChild.Attrs.Add(AttrName,GetEnumProp(AObj,AList[I]));
        tkSet:
          AChild.Attrs.Add(AttrName,'['+GetSetProp(AObj,AList[I])+']');
        tkFloat:
          AChild.Attrs.Add(AttrName,FloatToStr(GetFloatProp(AObj, AList[I])));
        tkMethod:
          AChild.Attrs.Add(AttrName,GetMethodName(GetMethodProp(AObj,AList[I])));
        {$IFNDEF NEXTGEN}
        tkString, tkLString:
          AChild.Attrs.Add(AttrName,GetStrProp(AObj, AList[I]));
        tkWString:
          AChild.Attrs.Add(AttrName,GetWideStrProp(AObj, AList[I]));
        {$ENDIF !NEXTGEN}
        {$IFDEF QDAC_UNICODE}
        tkUString:
          AChild.Attrs.Add(AttrName,GetStrProp(AObj, AList[I]));
        {$ENDIF}
        tkVariant:
          AChild.Attrs.Add(AttrName,VarToStr(GetVariantProp(AObj, AList[I])));
        tkInt64:
          AChild.Attrs.Add(AttrName,IntToStr(GetInt64Prop(AObj, AList[I])));
        tkDynArray:
          begin
          DynArrayToVariant(V,GetDynArrayProp(AObj, AList[I]),AList[I].PropType^);
          AChild.Attrs.Add(AttrName,VarToStr(V));
          end;
      end;
      end;
  finally
    if AList<>nil then
      FreeMem(AList);
  end;
  end;
begin
//利用RTTI直接获取对象的属性信息并保存到结果中
Result:=Add(AName);
AddChildren(Result,AObject);
end;

{$IFDEF QDAC_UNICODE}
function TQXMLNode.AddObject(AName: QStringW; AObject: TObject; AOnFilter: TQXMLRttiFilterEventA;
  ANest: Boolean;ATag:Pointer): TQXMLNode;
  function AddWithAnonCallback:TQXMLNode;
  var
    ATagData:TQXMLInternalTagData;
  begin
  ATagData.TagType:=ttAnonEvent;
  ATagData.OnEvent:=AOnFilter;
  ATagData.Tag:=ATag;
  Result:=InternalAddObject(AName,AObject,InternalRttiFilter,ANest,Pointer(@ATagData));
  end;
begin
if Assigned(AOnFilter) then
  Result:=AddWithAnonCallback
else
  Result:=InternalAddObject(AName,AObject,nil,ANest,nil);
end;
{$ENDIF}
function TQXMLNode.AddObject(AName: QStringW; AObject: TObject; ANest: Boolean;
  AcceptProps, AIgnoreProps: QStringW): TQXMLNode;
var
  ATagData:TQXMLInternalTagData;
begin
ATagData.TagType:=ttNameFilter;
ATagData.AcceptNames:=AcceptProps;
ATagData.IgnoreNames:=AIgnoreProps;
Result:=AddObject(AName,AObject,InternalRttiFilter,ANest,@ATagData);
end;
function TQXMLNode.AddText(const AText: QStringW): TQXMLNode;
begin
Result:=Add(AText,xntText);
end;

{$IFDEF QDAC_RTTI}
function TQXMLNode.AddRecord<T>(AName: QStringW; const AObject: T; AcceptFields,
  AIgnoreFields: QStringW): TQXMLNode;
var
  ATagData:TQXMLInternalTagData;
begin
ATagData.TagType:=ttNameFilter;
ATagData.AcceptNames:=AcceptFields;
ATagData.IgnoreNames:=AIgnoreFields;
Result:=AddRecord(AName,AObject,InternalRttiFilter,@ATagData);
end;

function TQXMLNode.AddRecord<T>(AName: QStringW; const AObject: T): TQXMLNode;
begin
Result:=AddRecord(Aname,AObject,TQXMLRttiFilterEvent(nil),nil);
end;

function TQXMLNode.AddRecord<T>(AName: QStringW; const AObject: T;
  AOnFilter: TQXMLRttiFilterEvent; ATag: Pointer): TQXMLNode;
begin
Result:=Add(AName);
Result.InternalAddRecord(TypeInfo(T),@AObject,AOnFilter,ATag);
end;

function TQXMLNode.AddRecord<T>(AName:QStringW;const AObject:T;AOnFilter:TQXMLRttiFilterEventA;ATag:Pointer):TQXMLNode;
var
  ATagData:TQXMLInternalTagData;
begin
ATagData.TagType:=ttAnonEvent;
ATagData.Tag:=ATag;
ATagData.OnEvent:=AOnFilter;
Result:=AddRecord(AName,AObject,InternalRttiFilter,@ATagData);
end;

function TQXMLNode.InternalAddRecord(ATypeInfo: PTypeInfo;
  ABaseAddr: Pointer;AOnFilter:TQXMLRttiFilterEvent;ATag:Pointer): Boolean;
var
  AContext:TRttiContext;
  AType:TRttiType;
  I:Integer;
  AFields:TArray<TRttiField>;
  AChild:TQXMLNode;
  Accept:Boolean;
  function ValueToVariant(AValue:TValue):Variant;
  var
    J,L:Integer;
    AItemValue:TValue;
  begin
  L:=AValue.GetArrayLength;
  Result:=VarArrayCreate([0,L-1],varVariant);
  for J := 0 to L-1 do
    begin
    AItemValue:=AValue.GetArrayElement(J);
    if AItemValue.IsArray then
      Result[J]:=ValueToVariant(AItemValue)
    else
      Result[J]:=AItemValue.AsVariant;
    end;
  end;

  procedure ParseVariant(ANode:TQXMLNode;const Value:Variant);
  var
    I:Integer;
    vDouble:Double;
  begin
  if VarIsArray(Value) then
    begin
    ANode.Attrs.Add('type','array');
    //目前实际只支持一维数组
    for I := VarArrayLowBound(Value,VarArrayDimCount(Value)) to VarArrayHighBound(Value,VarArrayDimCount(Value)) do
      ParseVariant(ANode.Add('item'),Value[I]);
    end
  else
    begin
    case VarType(Value) of
      varSmallInt,varInteger,varByte,varShortInt,varWord,varLongWord,varInt64:
        begin
        ANode.Attrs.Add('type','int');
        ANode.Attrs.Add('value',VarToStr(Value));
        end;
      varSingle,varDouble,varCurrency:
        begin
        ANode.Attrs.Add('type','float');
        ANode.Attrs.Add('value',VarToStr(Value));
        end;
      varDate:
        begin
        vDouble:=Value;
        if Trunc(vDouble)=0 then
          begin
          ANode.Attrs.Add('type','time');
          ANode.Attrs.Add('value',FormatDateTime(XMLTimeFormat,vDouble));
          end
        else if SameValue(vDouble,Trunc(vDouble)) then
          begin
          ANode.Attrs.Add('type','date');
          ANode.Attrs.Add('value',FormatDateTime(XMLDateFormat,vDouble));
          end
        else
          begin
          ANode.Attrs.Add('type','datetime');
          ANode.Attrs.Add('value',FormatDateTime(XMLDateTimeFormat,vDouble));
          end;
        end;
      varOleStr,varString{$IFDEF QDAC_UNICODE},varUString{$ENDIF}:
        begin
        ANode.Attrs.Add('type','string');
        ANode.Attrs.Add('value',VarToStr(Value));
        end;
      varBoolean:
        begin
        ANode.Attrs.Add('type','bool');
        ANode.Attrs.Add('value',BoolToStr(Value,true));
        end;
    end;
    end;
  end;

  procedure ParseDynArray;
  var
    AValue:TValue;
  begin
  AValue:=AFields[I].GetValue(ABaseAddr);
  if AValue.IsArray then
    ParseVariant(AChild,ValueToVariant(AValue))
  end;
begin
Result:=False;
if Assigned(ATypeInfo) then
  begin
  AType:=AContext.GetType(ATypeInfo);
  if AType<>nil then
    begin
    if AType.TypeKind=tkRecord then
      begin
      Result:=True;
      AFields:=AType.GetFields;
      for I := Low(AFields) to High(AFields) do
        begin
        Accept:=True;
        if Assigned(AOnFilter) then
          AOnFilter(Self,ABaseAddr,AFields[I].Name,AFields[I].FieldType.Handle,Accept,ATag);
        if not Accept then
          Continue;
        AChild:=Add(AFields[I].Name);
        case AFields[I].FieldType.TypeKind of
          tkInteger,tkInt64:
            begin
            AChild.Attrs.Add('type','int');
            AChild.Attrs.Add('value',IntToStr(AFields[I].GetValue(ABaseAddr).AsInt64));
            end;
          tkUString{$IFNDEF NEXTGEN},tkString,tkLString,tkWString,tkChar,tkWChar{$ENDIF}:
            begin
            AChild.Attrs.Add('type','string');
            AChild.Attrs.Add('value',AFields[I].GetValue(ABaseAddr).ToString);
            end;
          tkRecord:
            begin
            AChild.Attrs.Add('type','record');
            AChild.InternalAddRecord(AFields[I].FieldType.Handle,Pointer(IntPtr(ABaseAddr)+AFields[I].Offset),AOnFilter,ATag);
            end;
          tkEnumeration:
            begin
            AChild.Attrs.Add('type','enum');
            AChild.Attrs.Add('value',AFields[I].GetValue(ABaseAddr).ToString);
            end;
          tkSet:
            begin
            AChild.Attrs.Add('type','set');
            AChild.Attrs.Add('value',AFields[I].GetValue(ABaseAddr).ToString);
            end;
          tkFloat:
            begin
            if (AFields[I].FieldType.Handle=TypeInfo(TDate)) then
              begin
              AChild.Attrs.Add('type','date');
              AChild.Attrs.Add('value',FormatDateTime(XMLDateFormat,AFields[I].GetValue(ABaseAddr).AsExtended));
              end
            else if (AFields[I].FieldType.Handle=TypeInfo(TTime)) then
              begin
              AChild.Attrs.Add('type','time');
              AChild.Attrs.Add('value',FormatDateTime(XMLTimeFormat,AFields[I].GetValue(ABaseAddr).AsExtended));
              end
            else if (AFields[I].FieldType.Handle=TypeInfo(TDateTime)) then
              begin
              AChild.Attrs.Add('type','datetime');
              AChild.Attrs.Add('value',FormatDateTime(XMLDateTimeFormat,AFields[I].GetValue(ABaseAddr).AsExtended));
              end
            else
              begin
              AChild.Attrs.Add('type','float');
              AChild.Attrs.Add('value',FloatToStr(AFields[I].GetValue(ABaseAddr).AsExtended));
              end;
            end;
          tkVariant:
            ParseVariant(AChild,AFields[I].GetValue(ABaseAddr).AsVariant);
          tkArray,tkDynArray:
            ParseDynArray;
          tkClass,tkMethod,tkInterface,tkClassRef,tkPointer,tkProcedure:
            begin
//            AChild.AsString:='<OBJECT>';
            end;
        end;
        end;
      end;
    end;
  end;
end;
{$ENDIF !QDAC_RTTI}

procedure TQXMLNode.Assign(ANode: TQXMLNode);
var
  I:Integer;
begin
FName:=ANode.FName;
FNodeType:=ANode.NodeType;
Clear;
if Assigned(ANode.FAttrs) then
  Attrs.Assign(ANode.Attrs);
for I := 0 to ANode.Count - 1 do
  Add.Assign(ANode.Items[I]);
end;

function TQXMLNode.AttrByPath(const APath, AttrName: QStringW): TQXMLAttr;
var
  ANode:TQXMLNode;
begin
ANode:=ItemByPath(APath);
if Assigned(ANode) then
  Result:=ANode.Attrs.ItemByName(AttrName)
else
  Result:=nil;
end;

function TQXMLNode.AttrValueByPath(const APath, AttrName,
  ADefVal: QStringW): QStringW;
var
  Attr:TQXMLAttr;
begin
Attr:=AttrByPath(APath,AttrName);
if Assigned(Attr) then
  Result:=Attr.Value
else
  Result:=ADefVal;
end;

procedure TQXMLNode.Clear;
var
  I:Integer;
begin
if Assigned(FItems) then
  begin
  for I := 0 to FItems.Count-1 do
    FreeNode(Items[I]);
  FItems.Clear;
  end;
if Assigned(FAttrs) then
  FAttrs.Clear;
end;

function TQXMLNode.Clone: TQXMLNode;
begin
Result:=Copy;
end;

function TQXMLNode.Copy: TQXMLNode;
begin
Result:=CreateNode;
Result.Assign(Self);
end;
{$IFDEF QDAC_RTTI}
function TQXMLNode.CopyIf(const ATag: Pointer;
  AFilter: TQXMLFilterEventA): TQXMLNode;
  procedure NestCopy(AParentSource,AParentDest:TQXMLNode);
  var
    I:Integer;
    Accept:Boolean;
    AChildSource,AChildDest:TQXMLNode;
  begin
  for I := 0 to AParentSource.Count-1 do
    begin
    Accept:=True;
    AChildSource:=AParentSource[I];
    AFilter(Self,AChildSource,Accept,ATag);
    if Accept then
      begin
      AChildDest:=AParentDest.Add(AChildSource.FName,AChildSource.NodeType);
      if Assigned(AChildSource.FAttrs) then
        AChildDest.Attrs.Assign(AChildSource.Attrs);
      if AChildSource.Count>0 then
        NestCopy(AChildSource,AChildDest);
      end;
    end;
  end;
begin
if Assigned(AFilter) then
  begin
  Result:=CreateNode;
  Result.FNodeType:=NodeType;
  Result.FName:=FName;
  if Count>0 then
    NestCopy(Self,Result);
  end
else
  Result:=Copy;
end;
{$ENDIF QDAC_RTTI}
function TQXMLNode.CopyIf(const ATag: Pointer;
  AFilter: TQXMLFilterEvent): TQXMLNode;

  procedure NestCopy(AParentSource,AParentDest:TQXMLNode);
  var
    I:Integer;
    Accept:Boolean;
    AChildSource,AChildDest:TQXMLNode;
  begin
  for I := 0 to AParentSource.Count-1 do
    begin
    Accept:=True;
    AChildSource:=AParentSource[I];
    AFilter(Self,AChildSource,Accept,ATag);
    if Accept then
      begin
      AChildDest:=AParentDest.Add(AChildSource.FName,AChildSource.NodeType);
      if Assigned(AChildSource.FAttrs) then
        AChildDest.Attrs.Assign(AChildSource.Attrs);
      if AChildSource.Count>0 then
        NestCopy(AChildSource,AChildDest);
      end;
    end;
  end;

begin
if Assigned(AFilter) then
  begin
  Result:=CreateNode;
  Result.FNodeType:=NodeType;
  Result.FName:=FName;
  if Count>0 then
    NestCopy(Self,Result);
  end
else
  Result:=Copy;
end;

constructor TQXMLNode.Create;
begin
inherited;
end;

function TQXMLNode.CreateNode: TQXMLNode;
begin
if Assigned(OnQXMLNodeCreate) then
  Result:=OnQXMLNodeCreate
else
  Result:=TQXMLNode.Create;
end;

procedure TQXMLNode.Delete(AIndex: Integer);
begin
if Assigned(FItems) then
  begin
  FreeNode(Items[AIndex]);
  FItems.Delete(AIndex);
  end;
end;

procedure TQXMLNode.Delete(AName: QStringW; ADeleteAll: Boolean);
var
  I:Integer;
begin
I:=0;
while I<Count do
  begin
  if Items[I].FName=AName then
    begin
    Delete(I);
    if not ADeleteAll then
      Break;
    end
  else
    Inc(I);
  end;
end;
{$IFDEF QDAC_RTTI}
procedure TQXMLNode.DeleteIf(const ATag: Pointer; ANest: Boolean;
  AFilter: TQXMLFilterEventA);
  procedure DeleteChildren(AParent:TQXMLNode);
  var
    I:Integer;
    Accept:Boolean;
    AChild:TQXMLNode;
  begin
  I:=0;
  while I<AParent.Count do
    begin
    Accept:=True;
    AChild:=AParent.Items[I];
    if ANest then
      DeleteChildren(AChild);
    AFilter(Self,AChild,Accept,ATag);
    if Accept then
      AParent.Delete(I)
    else
      Inc(I);
    end;
  end;
begin
if Assigned(AFilter) then
  DeleteChildren(Self)
else
  Clear;
end;
{$ENDIF QDAC_RTTI}

procedure TQXMLNode.DeleteIf(const ATag: Pointer; ANest: Boolean;
  AFilter: TQXMLFilterEvent);
  procedure DeleteChildren(AParent:TQXMLNode);
  var
    I:Integer;
    Accept:Boolean;
    AChild:TQXMLNode;
  begin
  I:=0;
  while I<AParent.Count do
    begin
    Accept:=True;
    AChild:=AParent.Items[I];
    if ANest then
      DeleteChildren(AChild);
    AFilter(Self,AChild,Accept,ATag);
    if Accept then
      AParent.Delete(I)
    else
      Inc(I);
    end;
  end;
begin
if Assigned(AFilter) then
  DeleteChildren(Self)
else
  Clear;
end;

destructor TQXMLNode.Destroy;
begin
if Assigned(FItems) then
  begin
  Clear;
  FreeObject(FItems);
  end;
if Assigned(FAttrs) then
  FreeObject(FAttrs);
inherited;
end;

procedure TQXMLNode.DoParse(p: PQCharW);
var
  ACol,ARow:Integer;
  ps,pl:PQCharW;
  AttrName:QStringW;
  //解析DTD部分，但QXML不支持DTD部分，会忽略掉其中的内容
  function ParseDTD:Boolean;
  var
    APairCount:Integer;
  begin
  if StartWithW(p,'<!DOCTYPE',false) or
    StartWithW(p,'<!ELEMENT',false) or
    StartWithW(p,'<!ATTLIST',false)
    then
    begin
    APairCount:=1;
    Inc(p,9);//都是9个字符长度,:)
    while (p^<>#0) do
      begin
      if p^='<' then
        Inc(APairCount)
      else if p^='>' then
        begin
        Dec(APairCount);
        if APairCount=0 then
          begin
          Inc(p);
          SkipSpaceW(p);
          Break;
          end;
        end
      else
        Inc(p);
      end;
    Result:=True;
    end
  else
    Result:=False;
  end;
  procedure InternalParse(AParent:TQXMLNode);
  var
    AChild:TQXMLNode;
    ws:PQCharW;
    AClosed:Boolean;
  const
    TagStart:PQCharW='<';
    TagClose:PQCharW='>';
    Question:PQCharW='?';
    TagNameEnd:PQCharW=#9#10#13#32'/>';
    AttrNameEnd:PQCharW=#9#10#13#32'=/>';
  begin
  while p^<>#0 do
    begin
    SkipSpaceW(p);
    if p^='<' then //标签开始
      begin
      if p[1]='/' then//</AParent.Name>
        begin
        Inc(p,2);
        ws:=p;
        SkipUntilW(p,TagClose);
        if p^='>' then
          begin
          if (Length(AParent.Name)=(p-ws)) and StartWithW(ws,PQCharW(AParent.Name),false) then
            begin
            Inc(p);
            Exit;
            end
          else
            raise Exception.Create(SUnclosedXMLTag);
          end
        else
          raise Exception.Create(SUnclosedXMLTag);
        end
      else if p[1]='!' then
        begin
        if (p[2]='-') and (p[3]='-') then//注释
          begin
          Inc(p,4);
          ws:=p;
          AClosed:=False;
          while p^<>#0 do
            begin
            if (p[0]='-') and (p[1]='-') then
              begin
              if p[2]='>' then
                begin
                AParent.Add(StrDupX(ws,p-ws),xntComment);
                Inc(p,3);
                AClosed:=True;
                Break;
                end
              else
                raise Exception.Create(SBadXMLComment);
              end
            else
              Inc(p);
            end;
          if not AClosed then
            raise Exception.Create(SUnterminateXMLComment);
          end
        else if StartWithW(p,'<![CDATA[',False) then//CDATA
          begin
          Inc(p,9);
          ws:=p;
          AClosed:=False;
          while p^<>#0 do
            begin
            if (p[0]=']') and (p[1]=']') then
              begin
              if p[2]='>' then
                begin
                AParent.Add(StrDupX(ws,p-ws),xntCDATA);
                Inc(p,3);
                AClosed:=True;
                Break;
                end
              else
                Inc(p);
              end
            else
              Inc(p);
            end;
          if not AClosed then
            raise Exception.Create(SUnterminateXMLCData);
          end
        else//DTD 定义？
          begin
          if not ParseDTD then
            raise Exception.Create(SBadXMLName);
          end;
        end
      else if p[1]='?' then
        begin
        if StartWithW(p,'<?xml',true) and IsSpaceW(p+5)  then
          begin
          Inc(p,6);
          SkipUntilW(p,Question);
          if StartWithW(p,'?>',False) then
            begin
            Inc(p,2);
            SkipSpaceW(p);
            end
          else
            raise Exception.Create(SUnclosedXMLTag);
          end
        else
          raise Exception.Create(SBadXMLName);
        end
      else//结点
        begin
        Inc(p);
        SkipSpaceW(p);
        ws:=p;
        SkipUntilW(p,TagNameEnd);
        AChild:=AParent.Add(StrDupX(ws,p-ws),xntNode);
        if (p^<>'>') and (p^<>'/') then
          begin
        //解析属性
          while p^<>#0 do
            begin
            SkipSpaceW(p);
            ws:=p;
            SkipUntilW(p,AttrNameEnd);
            AttrName:=StrDupX(ws,p-ws);
            SkipSpaceW(p);
            if p^='=' then
              begin
              Inc(p);
              SkipSpaceW(p);
              if (p^='''') or (p^='"') then
                begin
                ws:=p;
                Inc(p);
                while p^<>#0 do
                  begin
                  if p^=ws^ then
                    begin
                    Inc(p);
                    Break;
                    end
                  else
                    Inc(p);
                  end;
                AChild.Attrs.Add(AttrName,XMLDecode(ws+1,p-ws-2));
                end
              else
                raise Exception.Create(SXMLBadAttrValue);
              end
            else if (p^='/') or (p^='>') then
              Break
            else
              raise Exception.Create(SXMLAttrValueMissed);
            end;
          end;
        if p^='>' then
          Inc(p)
        else if (p[0]='/') and (p[1]='>') then //直接结束，没有附加内容的结点
          begin
          Inc(p,2);
          Continue;
          end
        else
          raise Exception.Create(SUnterminatedXMLTag);
        SkipSpaceW(p);
        if p^='<' then
          InternalParse(AChild)
        else//不是标签开始,中间包含文本内容了
          begin
          ws:=p;
          SkipUntilW(p,TagStart);
          AChild.Add(XMLDecode(ws,p-ws),xntText);
          if (p[0]='<') then
            InternalParse(AChild);
          end;
        end;
      end
    else if p^<>#0 then//不是<开始的标签，为文本
      begin
      if p<>ps then
        begin
        ws:=p;
        SkipUntilW(p,TagStart);
        AParent.Add(StrDupX(ws,p-ws),xntText);
        end
      else
        raise Exception.Create(SBadXMLTagStart);
      end;
    end;
  end;
begin
ps:=p;
SkipSpaceW(p);
try
  InternalParse(Self);
except on E:Exception do
  begin
  pl:=StrPosW(ps,p,ACol,ARow);
  raise Exception.CreateFmt('%s'#13#10'位置:第%d行 第%d列'#13#10'行内容：%s',[E.Message,ARow,ACol,DecodeLineW(pl)]);
  end;
end;
end;

//Redo:格式化不对
function TQXMLNode.Encode(ADoFormat: Boolean; AIndent: QStringW): QStringW;
var
  ABuilder:TQStringCatHelperW;
begin
ABuilder:=TQStringCatHelperW.Create;//(16384);
try
  InternalEncode(ABuilder,ADoFormat,AIndent);
  Result:=ABuilder.Value;
finally
  FreeObject(ABuilder);
end;
end;
{$IFDEF QDAC_RTTI}
function TQXMLNode.FindIf(const ATag: Pointer; ANest: Boolean;
  AFilter: TQXMLFilterEventA): TQXMLNode;
  function DoFind(AParent:TQXMLNode):TQXMLNode;
  var
    I:Integer;
    AChild:TQXMLNode;
    Accept:Boolean;
  begin
  Result:=nil;
  for I := 0 to AParent.Count-1 do
    begin
    AChild:=AParent[I];
    Accept:=True;
    AFilter(Self,AChild,Accept,ATag);
    if Accept then
      Result:=AChild
    else if ANest then
      Result:=DoFind(AChild);
    if Result<>nil then
      Break;
    end;
  end;
begin
if Assigned(AFilter) then
  Result:=DoFind(Self)
else
  Result:=nil;
end;
{$ENDIF QDAC_RTTI}
function TQXMLNode.FindIf(const ATag: Pointer; ANest: Boolean;
  AFilter: TQXMLFilterEvent): TQXMLNode;
function DoFind(AParent:TQXMLNode):TQXMLNode;
  var
    I:Integer;
    AChild:TQXMLNode;
    Accept:Boolean;
  begin
  Result:=nil;
  for I := 0 to AParent.Count-1 do
    begin
    AChild:=AParent[I];
    Accept:=True;
    AFilter(Self,AChild,Accept,ATag);
    if Accept then
      Result:=AChild
    else if ANest then
      Result:=DoFind(AChild);
    if Result<>nil then
      Break;
    end;
  end;
begin
if Assigned(AFilter) then
  Result:=DoFind(Self)
else
  Result:=nil;
end;

function TQXMLNode.ForcePath(APath: QStringW): TQXMLNode;
var
  AName:QStringW;
  p:PQCharW;
  AParent:TQXMLNode;
const
  PathDelimiters:PWideChar='./\';
begin
p:=PQCharW(APath);
AParent:=Self;
Result:=Self;
while p^<>#0 do
  begin
  AName:=DecodeTokenW(p,PathDelimiters,WideChar(0),True);
  Result:=AParent.ItemByName(AName);
  if not Assigned(Result) then
    Result:=AParent.Add(AName);
  AParent:=Result;
  end;
end;

procedure TQXMLNode.FreeNode(ANode: TQXMLNode);
begin
if Assigned(OnQXMLNodeFree) then
  OnQXMLNodeFree(ANode)
else
  FreeObject(ANode);
end;

function TQXMLNode.GetAsXML: QStringW;
begin
Result:=Encode(True,'  ');
end;

function TQXMLNode.GetAttrs: TQXMLAttrs;
begin
if not Assigned(FAttrs) then
  FAttrs:=TQXMLAttrs.Create(Self);
Result:=FAttrs;
end;

function TQXMLNode.GetCapacity: Integer;
begin
if Assigned(FItems) then
  Result:=FItems.Capacity
else
  Result:=0;
end;

function TQXMLNode.GetCount: Integer;
begin
if Assigned(FItems) then
  Result:=FItems.Count
else
  Result:=0;
end;

function TQXMLNode.GetEnumerator: TQXMLNodeEnumerator;
begin
Result:=TQXMLNodeEnumerator.Create(Self);
end;

function TQXMLNode.GetItemIndex: Integer;
var
  I:Integer;
begin
Result:=-1;
if Assigned(FParent) then
  begin
  for I := 0 to FParent.Count-1 do
    begin
    if FParent.Items[I]=Self then
      begin
      Result:=I;
      Break;
      end;
    end;
  end;
end;

function TQXMLNode.GetItems(AIndex: Integer): TQXMLNode;
begin
Result:=FItems[AIndex];
end;

function TQXMLNode.GetName: QStringW;
begin
if NodeType=xntNode then
  Result:=FName
else
  SetLength(Result,0);
end;

function TQXMLNode.GetPath: QStringW;
var
  AParent:TQXMLNode;
begin
Result:=Name;
AParent:=FParent;
while Assigned(AParent) do
  begin
  if Length(AParent.Name)>0 then
    Result:=AParent.Name+'\'+Result;
  AParent:=AParent.FParent;
  end;
end;

function TQXMLNode.GetText: QStringW;
var
  ABuilder:TQStringCatHelperW;
  procedure InternalGetText(ANode:TQXMLNode);
  var
    I:Integer;
  begin
  if ANode.NodeType=xntNode then
    begin
    for I := 0 to ANode.Count-1 do
      InternalGetText(ANode.Items[I]);
    end
  else //if ANode.NodeType<>xntComment then //注释不包含在Text中，文本或CDATA数据返回
    ABuilder.Cat(ANode.FName);
  end;
begin
ABuilder:=TQStringCatHelperW.Create;
try
  InternalGetText(Self);
  Result:=ABuilder.Value;
finally
  ABuilder.Free;
end;
end;

function TQXMLNode.ItemByName(const AName: QStringW): TQXMLNode;
var
  AIndex:Integer;
begin
AIndex:=IndexOf(AName);
if AIndex<>-1 then
  Result:=Items[AIndex]
else
  Result:=nil;
end;

function TQXMLNode.InternalEncode(ABuilder: TQStringCatHelperW;
  ADoFormat: Boolean; const AIndent: QStringW):TQStringCatHelperW;
const
  TagStart:PWideChar='<';
  TagEnd:PWideChar='/>';
  TagClose:PWideChar='>';
  TagCloseStart:PWideChar='</';
  Space:PWideChar=' ';
  ValueStart:PWideChar='="';
  Quoter:PWideChar='"';
  CommentStart:PWideChar='<!--';
  CommentEnd:PWideChar='-->';
  CDataStart:PWideChar='<![CDATA[';
  CDataEnd:PWideChar=']]>';
  procedure DoEncode(AItem:TQXMLNode;ALevel:Integer);
  var
    I:Integer;
    ANode:TQXMLNode;
  begin
  if ADoFormat then
      ABuilder.Replicate(AIndent,ALevel);
  if (Length(AItem.FName)>0) then
    ABuilder.Cat(TagStart,1).Cat(AItem.FName)
  else if (AItem.Parent<>nil) and (NodeType in [xntNode]) then
    raise Exception.Create(SNodeWithoutName);
  if Assigned(AItem.FAttrs) then
    begin
    for I := 0 to AItem.FAttrs.Count-1 do
      ABuilder.Cat(Space,1).Cat(AItem.Attrs[I].FName).Cat(ValueStart,2).Cat(XMLEncode(AItem.Attrs[I].FValue)).Cat(Quoter);
    end;
  if AItem.Count=0 then
    begin
    if XMLTagShortClose then
      ABuilder.Cat(TagEnd,2)
    else if Length(AItem.FName)>0 then
      ABuilder.Cat(TagClose,1).Cat(TagCloseStart,2).Cat(AItem.FName).Cat(TagClose,1);
    end
  else
    begin
    if Length(AItem.Name)>0 then
      ABuilder.Cat(TagClose,1).Cat(SLineBreak);
    for I := 0 to AItem.Count-1 do
      begin
      ANode:=AItem[I];
      case ANode.NodeType of
        xntNode:
          begin
          if Length(ANode.Name)=0 then
            raise Exception.Create(SXMLNameNeeded);
          DoEncode(ANode,ALevel+1);
          end;
        xntText:
          begin
          if ADoFormat then
            ABuilder.Replicate(AIndent,ALevel);
          ABuilder.Cat(XMLEncode(ANode.FName));
          end;
        xntComment:
          begin
          if ADoFormat then
            ABuilder.Replicate(AIndent,ALevel);
          ABuilder.Cat(CommentStart,4).Cat(ANode.FName).Cat(CommentEnd,3);
          end;
        xntCData:
          begin
          if ADoFormat then
            ABuilder.Replicate(AIndent,ALevel);
          ABuilder.Cat(CDataStart,9).Cat(ANode.FName).Cat(CDataEnd,3);
          end;
      end;
      if ADoFormat then
        ABuilder.Cat(SLineBreak);
      end;
    if ADoFormat then
      ABuilder.Replicate(AIndent,ALevel);
    if (Length(AItem.FName)>0) then
      ABuilder.Cat(TagCloseStart,2).Cat(AItem.FName).Cat(TagClose,1);
    end;
  end;
begin
Result:=ABuilder;
DoEncode(Self,0);
end;

procedure TQXMLNode.InternalRttiFilter(ASender: TQXMLNode; AObject: Pointer;
  APropName: QStringW; APropType: PTypeInfo; var Accept: Boolean;
  ATag: Pointer);
var
  AFilter:PQXMLInternalTagData;
  procedure DoNameFilter;
  var
    ps:PQCharW;
  begin
  if Length(AFilter.AcceptNames)>0 then
    begin
    Accept:=False;
    ps:=StrIStrW(PQCharW(AFilter.AcceptNames),PQCharW(APropName));
    if (ps<>nil) and ((ps=PQCharW(AFilter.AcceptNames)) or (ps[-1]=',') or (ps[-1]=';')) then
      begin
      ps:=ps+Length(APropName);
      Accept:=(ps^=',') or (ps^=';') or (ps^=#0);
      end;
    end
  else if Length(AFilter.IgnoreNames)>0 then
    begin
    ps:=StrIStrW(PQCharW(AFilter.IgnoreNames),PQCharW(APropName));
    Accept:=True;
    if (ps<>nil) and ((ps=PQCharW(AFilter.IgnoreNames)) or (ps[-1]=',') or (ps[-1]=';')) then
      begin
      ps:=ps+Length(APropName);
      Accept:=not ((ps^=',') or (ps^=';') or (ps^=#0));
      end;
    end;
  end;
begin
AFilter:=PQXMLInternalTagData(ATag);
{$IFDEF QDAC_UNICODE}
if AFilter.TagType=ttAnonEvent then
  AFilter.OnEvent(ASender,AObject,APropName,APropType,Accept,AFilter.Tag)
else
{$ENDIF}
if AFilter.TagType=ttNameFilter then
  DoNameFilter;
end;
{$IFDEF QDAC_RTTI}
procedure TQXMLNode.InternalToRecord(ATypeInfo: PTypeInfo; ABaseAddr: Pointer);
var
  AContext:TRttiContext;
  AType:TRttiType;
  I:Integer;
  AFields:TArray<TRttiField>;
  AChild:TQXMLNode;
  Attr:TQXMLAttr;
  procedure SetAsIntValue(AValue:Int64);
  begin
  if AFields[I].FieldType.TypeKind=tkInt64 then
    PInt64(IntPtr(ABaseAddr)+AFields[I].Offset)^:=AValue
  else
    begin
    case GetTypeData(AFields[I].FieldType.Handle)^.OrdType
      //AFields[I].FieldType.Handle.TypeData.OrdType
      of
        otSByte, otUByte:
          PByte(IntPtr(ABaseAddr)+AFields[I].Offset)^:=AValue;
        otSWord, otUWord:
          PSmallint(IntPtr(ABaseAddr)+AFields[I].Offset)^:=AValue;
        otSLong, otULong:
          PInteger(IntPtr(ABaseAddr)+AFields[I].Offset)^:=AValue;
      end;
    end
  end;

  function AttrAsVariant(ANode:TQXMLNode):Variant;
  var
    ATypeAttr,AValueAttr:TQXMLAttr;
    I:Integer;
    AList:TQXMLNodeList;
  begin
  ATypeAttr:=ANode.Attrs.ItemByName('type');
  if Assigned(ATypeAttr) then
    begin
    if ATypeAttr.Value='array' then
      begin
      AList:=TQXMLNodeList.Create;
      try
        ANode.ItemByName('item',AList,false);
        if AList.Count>0 then
          begin
          Result:=VarArrayCreate([0,AList.Count-1],varVariant);
          for I := 0 to AList.Count-1 do
            Result[I]:=AttrAsVariant(AList[I]);
          end
      finally
        FreeObject(AList);
      end;
      end
    else
      begin
      AValueAttr:=ANode.Attrs.ItemByName('value');
      if AValueAttr=nil then
        begin
        Result:=Null;
        Exit;
        end;
      if ATypeAttr.Value='int' then
        Result:=AValueAttr.AsInt64
      else if ATypeAttr.Value='float' then
        Result:=AValueAttr.AsFloat
      else if (ATypeAttr.Value='time') or (ATypeAttr.Value='date') or (ATypeAttr.Value='datetime') then
        Result:=AValueAttr.AsDateTime
      else if ATypeAttr.Value='string' then
        Result:=AValueAttr.AsString
      else if ATypeAttr.Value='bool' then
        Result:=AValueAttr.AsBoolean
      end;
    end;
  end;

  procedure ParseDynArray;
  var
    AValue:array of TValue;
    J:Integer;
  begin
  SetLength(AValue,AChild.Count);
  for J := 0 to AChild.Count-1 do
   AValue[J]:=TValue.FromVariant(AttrAsVariant(AChild));
  AFields[I].SetValue(ABaseAddr,TValue.FromArray(AFields[I].FieldType.Handle,AValue));
  end;

  {$IFNDEF NEXTGEN}
  procedure ParseShortString;
  var
    S: ShortString;
    AValue:TValue;
  begin
  S:= ShortString(Attr.AsString);
  TValue.Make(@S, AFields[I].FieldType.Handle, AValue);
  AFields[I].SetValue(ABaseAddr,AValue);
  end;
  {$ENDIF}
begin
if not Assigned(ATypeInfo) then
  Exit;
AType:=AContext.GetType(ATypeInfo);
if AType=nil then
  Exit;
if AType.TypeKind<>tkRecord then
  Exit;
AFields:=AType.GetFields;
for I := Low(AFields) to High(AFields) do
  begin
  AChild:=ItemByName(AFields[I].Name);
  if Assigned(AChild) then
    begin
    Attr:=AChild.Attrs.ItemByName('value');
    if Assigned(Attr) then
      begin
      if  AFields[I].FieldType.TypeKind =tkInteger then
        SetAsIntValue(Attr.AsInt64)
      else if AFields[I].FieldType.TypeKind=tkInt64 then
        SetAsIntValue(Attr.AsInt64)
      else if AFields[I].FieldType.TypeKind in [tkUString{$IFNDEF NEXTGEN},tkString,tkLString,tkWString,tkChar,tkWChar{$ENDIF}] then
        begin
        {$IFDEF NEXTGEN}
        AFields[I].SetValue(ABaseAddr,TValue.From(Attr.AsString));
        {$ELSE}
        if AFields[I].FieldType.TypeKind=tkString then
          ParseShortString
        else
          AFields[I].SetValue(ABaseAddr,TValue.From(Attr.AsString));
        {$ENDIF}
        end
      else if AFields[I].FieldType.TypeKind=tkRecord then
        InternalToRecord(AFields[I].FieldType.Handle,Pointer(IntPtr(ABaseAddr)+AFields[I].Offset))
      else if AFields[I].FieldType.TypeKind=tkEnumeration then
        SetAsIntValue(GetEnumValue(AFields[I].FieldType.Handle,Attr.AsString))
      else if AFields[I].FieldType.TypeKind=tkSet then
        SetAsIntValue(StringToSet(AFields[I].FieldType.Handle,Attr.AsString))
      else if AFields[I].FieldType.TypeKind=tkFloat then
        begin
        if (AFields[I].FieldType.Handle=TypeInfo(TDate)) or
          (AFields[I].FieldType.Handle=TypeInfo(TTime)) or
          (AFields[I].FieldType.Handle=TypeInfo(TDateTime))
          then
          AFields[I].SetValue(ABaseAddr,TValue.From(Attr.AsDateTime))
        else
          AFields[I].SetValue(ABaseAddr,TValue.From(Attr.AsFloat));
        end
      else if (AFields[I].FieldType.TypeKind=tkVariant) then
        begin
        AFields[I].SetValue(ABaseAddr,TValue.From(AttrAsVariant(AChild)))
        end
      else if (AFields[I].FieldType.TypeKind in [tkArray,tkDynArray]) then
        ParseDynArray
      else//
        begin
  //      tkClass,tkMethod,tkInterface,tkClassRef,tkPointer,tkProcedure:
          {不受支持的类型，忽略};
        end;
      end;
    end;
  end;
end;
{$ENDIF}
function TQXMLNode.ItemByName(const AName: QStringW;
  AList: TQXMLNodeList;ANest:Boolean): Integer;
var
  ANode:TQXMLNode;
  function InternalFind(AParent:TQXMLNode):Integer;
  var
    I:Integer;
  begin
  Result:=0;
  for I := 0 to AParent.Count-1 do
    begin
    ANode:=AParent.Items[I];
    if ANode.Name=AName then
      begin
      AList.Add(ANode);
      Inc(Result);
      end;
    if ANest then
      Inc(Result,InternalFind(ANode));
    end;
  end;
begin
Result:=InternalFind(Self);
end;

function TQXMLNode.ItemByPath(const APath: QStringW): TQXMLNode;
var
  AName:QStringW;
  pPath:PQCharW;
  AParent,AItem:TQXMLNode;
const
  PathDelimiters:PWideChar='/\.';
begin
if Length(APath)>0 then
  begin
  pPath:=PQCharW(APath);
  AParent:=Self;
  AItem:=nil;
  while pPath^<>#0 do
    begin
    AName:=DecodeTokenW(pPath,PathDelimiters,WideChar(0),False);
    AItem:=AParent.ItemByName(AName);
    if Assigned(AItem) then
      AParent:=AItem
    else
      Break;
    end;
  if AParent=AItem then
    Result:=AParent
  else
    Result:=nil;
  end
else
  Result:=Self;
end;

function TQXMLNode.ItemByRegex(const ARegex: QStringW; AList: TQXMLNodeList;
  ANest: Boolean): Integer;
var
  ANode:TQXMLNode;
{$IFDEF QDAC_UNICODE}
  APcre:TPerlRegEx;
{$ENDIF}
  function InternalFind(AParent:TQXMLNode):Integer;
  var
    I:Integer;
  begin
  Result:=0;
  for I := 0 to AParent.Count-1 do
    begin
    ANode:=AParent.Items[I];
    {$IFDEF QDAC_UNICODE}
    APcre.Subject:=ANode.Name;
    if APcre.Match then
    {$ELSE}
    if ANode.Name=ARegex then
    {$ENDIF}
      begin
      AList.Add(ANode);
      Inc(Result);
      end;
    if ANest then
      Inc(Result,InternalFind(ANode));
    end;
  end;
begin
{$IFDEF QDAC_UNICODE}
APcre:=TPerlRegex.Create;
try
  APcre.RegEx:=ARegex;
  APcre.Compile;
  Result:=InternalFind(Self);
finally
  FreeObject(APcre);
end;
{$ELSE}
raise Exception.Create(Format(SNotSupport,['ItemByRegex']));
{$ENDIF}
end;

function TQXMLNode.ItemWithAttrValue(const APath, AttrName,
  AttrValue: QStringW): TQXMLNode;
var
  ANode:TQXMLNode;
  I:Integer;
  Attr:TQXMLAttr;
  AFound:Boolean;
begin
Result:=nil;
ANode:=ItemByPath(APath);
if Assigned(ANode) then
  begin
  I:=ANode.ItemIndex;
  while I<ANode.Parent.Count do
    begin
    ANode:=ANode.Parent[I];
    Attr:=ANode.Attrs.ItemByName(AttrName);
    if Attr<>nil then
      begin
      if Length(Attr.Value)=Length(AttrValue) then
        begin
        if XMLCaseSensitive then
          AFound:=Attr.Value=AttrValue
        else
          AFound:=StartWithW(PQCharW(Attr.Value),PQCharW(AttrValue),True);
        if AFound then
          begin
          Result:=ANode;
          Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TQXMLNode.LoadFromFile(AFileName: QStringW;AEncoding:TTextEncoding);
var
  AStream:TFileStream;
begin
AStream:=TFileStream.Create(AFileName,fmOpenRead or fmShareDenyWrite);
try
  LoadFromStream(AStream);
finally
  FreeObject(AStream);
end;
end;

procedure TQXMLNode.LoadFromStream(AStream: TStream;AEncoding:TTextEncoding);
var
  S:QStringW;
  procedure DetectXMLEncoding;
  //快速通过xml的头部定义来判定XML文件的编码，如果未定义，则通过LoadText来判断
  var
    APos:Int64;
    S:TBytes;
    I:Integer;
  const
    UTF8Code:array[0..4] of Byte=($55,$54,$46,$2D,$38);//UTF8的编码串的ASCII码
    UTF16LECode:array[0..11] of Byte=($55,$00,$54,$00,$46,$00,$2D,$00,$31,$00,$36,$00);
    UTF16BECode:array[0..11] of Byte=($00,$55,$00,$54,$00,$46,$00,$2D,$00,$31,$00,$36);
  begin
  APos:=AStream.Position;
  SetLength(S,1024);//读取前1024个字节来判定
  AStream.Read((@S[0])^,1024);
  //BOM?
  if (S[0]=$EF) and (S[1]=$BB) and (S[2]=$BF) then
    begin
    AEncoding:=teUtf8;
    AStream.Position:=APos+3;
    end
  else if (S[0]=$FF) and (S[1]=$FE) then
    begin
    AEncoding:=teUnicode16LE;
    AStream.Position:=APos+2;
    end
  else if (S[0]=$FE) and (S[1]=$FF) then
    begin
    AEncoding:=teUnicode16BE;
    AStream.Position:=APos+2;
    end
  else //查找xml头部,查找UTF-8，UTF-16，UTF-16BE
    begin
    I:=0;
    AStream.Position:=APos;
    while I<1024 do
      begin
      if (S[I]=0) and (S[I+1]=$55) then
        begin
        if CompareMem(@S[I],@UTF16BECode[0],12) then
          begin
          AEncoding:=teUnicode16BE;
          Break;
          end;
        end
      else if S[I]=$55 then
        begin
        if CompareMem(@S[I],@Utf8Code[0],5) then
          begin
          AEncoding:=teUTF8;
          Break;
          end
        else if CompareMem(@S[I],@UTF16LECode[0],12) then
          begin
          AEncoding:=teUnicode16LE;
          Break;
          end;
        end;
      Inc(I);
      end;
    end;
  end;
begin
if AEncoding=teUnknown then
  DetectXMLEncoding;
S:=LoadTextW(AStream,AEncoding);
Parse(S);
end;

procedure TQXMLNode.Parse(const s: QStringW);
begin
Parse(PQCharW(s),Length(s));
end;

procedure TQXMLNode.ParseBlock(AStream: TStream; AEncoding: TTextEncoding);
var
  AMS:TMemoryStream;
  procedure ParseUCS2;
  var
    c:QCharW;
    ATagStart,ACharSize:Integer;
    ATagName,ATag:QStringW;
    ps,p:PQCharW;
  const
    XMLTagNameEnd:PWideChar=' '#9#10#13'/>';
  begin
  //查找标签开始，并记录标签的名称
  repeat
    AStream.ReadBuffer(c,SizeOf(QCharW));
    AMS.WriteBuffer(c,SizeOf(QCharW));
    until c='<';
  ATagStart:=AMS.Position-2;
  //读取Tag名称
  repeat
    AStream.Read(c,SizeOf(QCharW));
    AMS.WriteBuffer(c,SizeOf(QCharW));
  until c='>';
  ATag:=StrDupW(PQCharW(AMS.Memory),ATagStart,(AMS.Position-ATagStart) shr 1);
  ps:=PQCharW(ATag);
  if StartWithW(ps,'<?xml',true) then
    begin
    AMS.Size:=0;
    ParseUCS2;
    end
  else if ps[1]<>'!' then//非注释，CDATA和DTD
    begin
    p:=ps;
    while not CharInW(p,XMLTagNameEnd,@ACharSize) do
      Inc(p);
    ATagName:=StrDupW(ps,1,p-ps-1);
    //检查是否是短标签<xxx />
    if StartWithW(ps+Length(ATag)-2,'/>',false) then
      DoParse(PQCharW(ATag))
    else
      begin
      //重复直到找到</ATagName>止
      ATagStart:=0;
      ATagName:='</'+ATagName+'>';
      repeat
        AStream.ReadBuffer(c,SizeOf(QCharW));
        AMS.WriteBuffer(c,SizeOf(QCharW));
        if c='<' then
          ATagStart:=AMS.Position-2
        else if ATagStart<>0 then
          begin
          if AMS.Position-ATagStart=(Length(ATagName) shl 1) then
            begin
            if StartWithW(PWideChar(AMS.Memory)+(ATagStart shr 1),PQCharW(ATagName),false) then
              begin
              //OK,Found Close
              c:=#0;
              AMS.Write(c,sizeof(QCharW));
              DoParse(AMS.Memory);
              Exit;
              end
            else
              ATagStart:=0;
            end;
          end;
      until 1>2;
      end;
    end
  else//注释，CDATA，DocType
    begin
    //DTD,忽略
    if StartWithW(ps,'<!DOCTYPE',false) or
      StartWithW(ps,'<!ELEMENT',false) or
      StartWithW(ps,'<!ATTLIST',false) then
      begin
      AMS.Size:=0;
      ParseUCS2;
      end
    else
      DoParse(PQCharW(ATag));
    end;
  end;

 
  procedure ParseUtf8;
  var
    c:QCharA;
    ATagStart,ACharSize:Integer;
    ATagName,ATag:QStringA;
    ps,p:PQCharA;
  const
    XMLTagNameEnd:array [0..5] of QCharA=($9,$A,$D,$20,$2F,$3E);
    XMLTagStart:QCharA=$3C;
    XMLTagEnd:QCharA=$3E;
    XMLTagClose:array[0..1] of QCharA=($2F,$3E);// />
    XMLDeclare:array [0..4] of QCharA=($3C,$3F,$78,$6D,$6C);//<?xml
    XMLComment:QCharA=$21;
    DTDDocType:array [0..8] of QCharA=(Ord('<'),Ord('!'),Ord('D'),Ord('O'),Ord('C'),Ord('T'),Ord('Y'),Ord('P'),Ord('E'));
    DTDElement:array [0..8] of QCharA=(Ord('<'),Ord('!'),Ord('E'),Ord('L'),Ord('E'),Ord('M'),Ord('E'),Ord('N'),Ord('T'));
    DTDAttrList:array [0..8] of QCharA=(Ord('<'),Ord('!'),Ord('A'),Ord('T'),Ord('T'),Ord('L'),Ord('I'),Ord('S'),Ord('T'));
  begin
  //查找标签开始，并记录标签的名称
  repeat
    AStream.ReadBuffer(c,SizeOf(QCharA));
    AMS.WriteBuffer(c,SizeOf(QCharA));
    until c=XMLTagStart;
  ATagStart:=AMS.Position-1;
  //读取Tag名称
  repeat
    AStream.Read(c,SizeOf(QCharA));
    AMS.WriteBuffer(c,SizeOf(QCharA));
  until c=XMLTagEnd;
  ATag.From(PQCharA(AMS.Memory),ATagStart,(AMS.Position-ATagStart));
  ps:=PQCharA(ATag);
  p:=ps;
  Inc(p);
  if CompareMem(ps,@XMLDeclare[0],5) then
    begin
    AMS.Size:=0;
    ParseUTF8;
    end
  else if p^<>XMLComment then//非注释，CDATA和DTD
    begin
    p:=ps;
    while not CharInA(p,XMLTagNameEnd,@ACharSize) do
      Inc(p);
    ATagName.Length:=IntPtr(p)-IntPtr(ps)+2;
    ATagName[0]:=XMLTagStart;
    ATagName[1]:=$2F;// </
    ATagName[ATagName.Length-1]:=XMLTagEnd;
    p:=PQCharA(ATagName);
    Inc(p,2);
    Inc(ps);
    Move(ps^,p^,ATagName.Length-3);
    //检查是否是短标签<xxx />
    p:=ps;
    Inc(p,ATag.Length-1);
    if CompareMem(p,@XMLTagClose[0],2) then
      DoParse(PQCharW(QString.Utf8Decode(ATag)))
    else
      begin
      //重复直到找到</ATagName>止
      ATagStart:=0;
      repeat
        AStream.ReadBuffer(c,SizeOf(QCharA));
        AMS.WriteBuffer(c,SizeOf(QCharA));
        if c=XMLTagStart then
          ATagStart:=AMS.Position-1
        else if ATagStart<>0 then
          begin
          if AMS.Position-ATagStart=ATagName.Length then
            begin
            p:=PQCharA(AMS.Memory);
            Inc(p,ATagStart);
            if CompareMem(p,PQCharA(ATagName),ATagName.Length) then
              begin
              //OK,Found Close
              ATag.From(AMS.Memory,0,AMS.Size);
              DoParse(PQCharW(QString.Utf8Decode(ATag)));
              Exit;
              end
            else
              ATagStart:=0;
            end;
          end;
      until 1>2;
      end;
    end
  else//注释，CDATA，DocType
    begin
    //DTD,忽略
    if CompareMem(ps,@DTDDocType[0],9) or
      CompareMem(ps,@DTDElement[0],9) or
      CompareMem(ps,@DTDAttrList[0],9) then
      begin
      AMS.Size:=0;
      ParseUtf8;
      end
    else
      DoParse(PQCharW(QString.Utf8Decode(ATag)));
    end;
  end;

begin
AMS:=TMemoryStream.Create;
try
  if AEncoding=teUtf8 then
    ParseUtf8
  else if AEncoding=teUnicode16LE then
    ParseUCS2
  else
    raise Exception.Create(SBadXMLEncoding);
finally
  AMS.Free;
end;
end;

procedure TQXMLNode.Parse(p: PQCharW; len: Integer);
  procedure ParseCopy;
  var
    S:QStringW;
  begin
  S:=StrDupX(p,len);
  p:=PQCharW(S);
  DoParse(p);
  end;
begin
Clear;
if (len>0) and (p[len]<>#0) then
  ParseCopy
else
  begin
  DoParse(p);
  end;
end;

procedure TQXMLNode.SaveToFile(AFileName: QStringW; AEncoding: TTextEncoding;
  AWriteBom: Boolean);
var
  AStream:TMemoryStream;
begin
AStream:=TMemoryStream.Create;
try
  SaveToStream(AStream,AEncoding,AWriteBOM);
  AStream.SaveToFile(AFileName);
finally
  FreeObject(AStream);
end;
end;

procedure TQXMLNode.SaveToStream(AStream: TStream; AEncoding: TTextEncoding;
  AWriteBom: Boolean);
var
  ABuilder:TQStringCatHelperW;
const
  XMLHeader:PQCharW='<?xml version="1.0" encoding="';
  UTF8Format:PQCharW='UTF-8"?>';
  UTF16Format:PQCharW='UTF-16"?>';
  XMLTagStart:PQCharW='<xml>';
  XMLTagEnd:PQCharW='</xml>';
begin
ABuilder:=TQStringCatHelperW.Create;
try
  ABuilder.Cat(XMLHeader,30);
  if AEncoding=teUTF8 then
    begin
    ABuilder.Cat(UTF8Format,8).Cat(SLineBreak);
    if Count<>1 then
      ABuilder.Cat(XMLTagStart,5).Cat(SLineBreak);
    InternalEncode(ABuilder,True,' ');
    if Count<>1 then
      ABuilder.Cat(XMLTagEnd,6);
    SaveTextU(AStream,QString.Utf8Encode(ABuilder.Value),AWriteBom)
    end
  else if AEncoding=teUnicode16LE then
    begin
    ABuilder.Cat(UTF16Format,9).Cat(SLineBreak);
    if Count<>1 then
      ABuilder.Cat(XMLTagStart,5).Cat(SLineBreak);
    InternalEncode(ABuilder,True,' ');
    if Count<>1 then
      ABuilder.Cat(XMLTagEnd,6);
    SaveTextW(AStream,ABuilder.Value,AWriteBom)
    end
  else
    raise Exception.Create(SBadXMLEncoding);
finally
  FreeObject(ABuilder);
end;
end;

procedure TQXMLNode.SetAsXML(const Value: QStringW);
begin
Clear;
Parse(Value);
end;

procedure TQXMLNode.SetCapacity(const Value: Integer);
begin
if not Assigned(FItems) then
  FItems:=TQXMLNodeList.Create;
FItems.Capacity:=Value;
end;

procedure TQXMLNode.SetName(const Value: QStringW);
  procedure ValidName;
  begin
  if not ValidXMLName(Value) then
    raise Exception.Create(SBadXMLName);
  end;
begin
if FName<>Value then
  begin
  if NodeType=xntNode then
    begin
    ValidName;
    FName := Value;
    FNameHash := 0;
    end
  else
    raise Exception.Create(SXMLNameNotSupport);
  end;
end;

procedure TQXMLNode.SetNodeType(const Value: TQXMLNodeType);
var
  S:QStringW;
begin
if FNodeType <> Value then
  begin
  if FNodeType=xntNode then
    begin
    S:=Text;//Node转换为其它类型时,文本内容被保留，但属性和子结点的信息将丢失
    if Value=xntComment then
      begin
      if not ValidXMLComment(S) then
        raise Exception.Create(SBadXMLComment);
      end
    else if Value=xntCData then
      begin
      if not ValidXMLCData(S) then
        raise Exception.Create(SBadXMLCData);
      end;
    Clear;
    FName:=S;
    end
  else if Value=xntNode then
    SetLength(FName,0)
  else
    begin
    if Value=xntComment then
      begin
      if not ValidXMLComment(FName) then
        raise Exception.Create(SBadXMLComment);
      end
    else if Value=xntCData then
      begin
      if not ValidXMLCData(FName) then
        raise Exception.Create(SBadXMLCData);
      end;
    end;
  FNodeType:=Value;
  end;
end;

procedure TQXMLNode.SetText(const Value: QStringW);
begin
if NodeType=xntNode then
  Parse(Value)
else if NodeType=xntComment then
  begin
  if not ValidXMLComment(Value) then
    raise Exception.Create(SBadXMLComment);
  FName:=Value;
  end
else if NodeType=xntCData then
  begin
  if not ValidXMLCData(Value) then
    raise Exception.Create(SBadXMLCData);
  FName:=Value;
  end
else//Text没有任何限制，保存时会进行必要的转码
  FName:=Value;
end;

function TQXMLNode.TextByPath(const APath, ADefVal: QStringW): QStringW;
var
  ANode:TQXMLNode;
begin
ANode:=ItemByPath(APath);
if Assigned(ANode) then
  Result:=ANode.Text
else
  Result:=ADefVal;
end;

procedure TQXMLNode.ToObject(AObject: TObject);
  procedure AssignProp(AParent:TQXMLNode;AObj:TObject);
  var
    APropInfo:PPropInfo;
    I,AValIdx:Integer;
    AChild:TQXMLNode;
  begin
  if AObj=nil then
    Exit;
  for I := 0 to Count-1 do
    begin
    AChild:=AParent[I];
    APropInfo:=GetPropInfo(AObj,AChild.Name);
    if Assigned(APropInfo) then
      begin
      AValIdx:=AChild.Attrs.IndexOfName('value');
      if AValIdx<>-1 then
        begin
        case APropInfo.PropType^.Kind of
          tkChar:
            SetOrdProp(AObj,APropInfo,QString.AnsiEncode(AChild.Attrs[AValIdx].Value)[0]);
          tkWChar:
            SetOrdProp(AObj,APropInfo,PWord(PWideChar(AChild.Attrs[AValIdx].Value))^);
          tkInteger:
            SetOrdProp(AObj,APropInfo,StrToInt(AChild.Attrs[AValIdx].Value));
          tkClass:
            AChild.ToObject(TObject(GetOrdProp(AObj,APropInfo)));
          tkEnumeration:
            SetEnumProp(AObj,APropInfo,AChild.Attrs[AValIdx].Value);
          tkSet:
            SetSetProp(AObj,APropInfo,AChild.Attrs[AValIdx].Value);
          tkFloat:
            SetFloatProp(AObj,APropInfo,StrToFloat(AChild.Attrs[AValIdx].Value));
          tkMethod:
            {绑定函数的值暂时忽略};
          {$IFNDEF NEXTGEN}
          tkString, tkLString,tkWString:
            SetStrProp(AObj,APropInfo,AChild.Attrs[AValIdx].Value);
          {$ENDIF !NEXTGEN}
          {$IFDEF QDAC_UNICODE}
          tkUString:
            SetStrProp(AObj,APropInfo,AChild.Attrs[AValIdx].Value);
          {$ENDIF}
          tkVariant:
            {变体类型的属性暂时忽略
            SetVariantProp(AObj,APropInfo,AChild.AsVariant);};
          tkInt64:
            SetInt64Prop(AObj,APropInfo,StrToInt64(AChild.Attrs[AValIdx].Value));
          tkDynArray:
            begin
            {动态数组类型的属性暂时忽略
            dynArray:=nil;
            DynArrayFromVariant(dynArray,AChild.AsVariant,APropInfo.PropType^);
            SetDynArrayProp(AObj,APropInfo,dynArray);}
            end;
        end;
        end;
      end;
    end;
  end;
begin
if Assigned(AObject) then
  AssignProp(Self,AObject);
end;
{$IFDEF QDAC_RTTI}
procedure TQXMLNode.ToRecord<T>(const ARecord:T);
begin
InternalToRecord(TypeInfo(T),@ARecord);
end;
{$ENDIF}
function TQXMLNode.ToString: string;
begin
Result:=Text;
end;

function TQXMLNode.XMLDecode(const S: QStringW): QStringW;
begin
Result:=XMLDecode(PQCharW(s),Length(S));
end;

function TQXMLNode.XMLDecode(const p: PQCharW; l: Integer): QStringW;
var
  ps,ws,pd:PQCharW;
  c:QCharW;
const
  EscapeEnd:PQCharW=';';
begin
SetLength(Result,l);
ps:=p;
pd:=PQCharW(Result);
while ps-p<l do
  begin
  if ps^='&' then
    begin
    ws:=ps;
    SkipUntilW(ps,EscapeEnd);
    if ps^=';' then
      begin
      Inc(ps);
      c:=PQCharW(HTMLUnescape(StrDupX(ws,ps-ws)))^;
      if c<>#0 then
        pd^:=c
      else
        raise Exception.Create(Format(SUnknownXMLEscape,[StrDupX(ws,ps-ws)]));
      Inc(pd);
      end
    else
      raise Exception.Create(SBadXMLEscape);
    end
  else
    begin
    pd^:=ps^;
    Inc(ps);
    Inc(pd);
    end;
  end;
SetLength(Result,pd-PQCharW(Result));
end;

function TQXMLNode.XMLEncode(const S: QStringW): QStringW;
var
  ps,pd:PQCharW;
  procedure StrCat(var d:PQCharW;s:PQCharW);
  begin
  while s^<>#0 do
    begin
    d^:=s^;
    Inc(d);
    Inc(s);
    end;
  end;
begin
{
&lt;	<	小于
&gt;	>	大于
&amp;	&	和号
&apos;	'	单引号
&quot;	"	引号
}
SetLength(Result,Length(S)*6);
ps:=PQCharW(S);
pd:=PQCharW(Result);
while ps^<>#0 do
  begin
  case ps^ of
    '<':StrCat(pd,'&lt;');
    '>':StrCat(pd,'&gt;');
    '&':StrCat(pd,'&amp;');
    '''':StrCat(pd,'&apos;');
    '"':StrCat(pd,'&quot;')
    else
      begin
      pd^:=ps^;
      Inc(pd);
      end;
  end;
  Inc(ps);
  end;
SetLength(Result,pd-PQCharW(Result));
end;
{ TQXMLAttr }

function TQXMLAttr.GetAsBoolean: Boolean;
begin
if not TryStrToBool(FValue,Result) then
  begin
  try
    Result:=(AsInt64<>0);
  except
    raise Exception.Create(SValueNotBoolean);
  end;
  end;
end;

function TQXMLAttr.GetAsDateTime: TDateTime;
begin
if not ParseDateTime(PQCharW(FValue),Result) then
  Result:=GetAsFloat;
end;

function TQXMLAttr.GetAsFloat: Extended;
var
  p:PQCharW;
begin
p:=PQCharW(FValue);
if not ParseNumeric(p,Result) then
  raise Exception.CreateFmt(SValueNotNumeric,[FValue]);
end;

function TQXMLAttr.GetAsInt64: Int64;
begin
Result:=Trunc(AsFloat);
end;

function TQXMLAttr.GetAsInteger: Integer;
begin
Result:=AsInt64;
end;

procedure TQXMLAttr.SetAsBoolean(const Value: Boolean);
begin
FValue:=BoolToStr(Value,true);
end;

procedure TQXMLAttr.SetAsDateTime(const Value: TDateTime);
begin

end;

procedure TQXMLAttr.SetAsFloat(const Value: Extended);
begin
FValue:=FloatToStr(Value);
end;

procedure TQXMLAttr.SetAsInt64(const Value: Int64);
begin
FValue:=IntToStr(Value);
end;

procedure TQXMLAttr.SetAsInteger(const Value: Integer);
begin
SetAsInt64(Value);
end;

procedure TQXMLAttr.SetName(const Value: QStringW);
begin
if FName <> Value then
  begin
  FName:=Value;
  FNameHash:=0;
  end;
end;

{ TQXMLAttrEnumerator }

constructor TQXMLAttrEnumerator.Create(AList: TQXMLAttrs);
begin
FList:=AList;
FIndex:=-1;
end;

function TQXMLAttrEnumerator.GetCurrent: TQXMLAttr;
begin
Result:=FList[FIndex];
end;

function TQXMLAttrEnumerator.MoveNext: Boolean;
begin
if FIndex<FList.Count-1 then
  begin
  Inc(FIndex);
  Result:=True;
  end
else
  Result:=False;
end;

{ TQXMLNodeEnumerator }

constructor TQXMLNodeEnumerator.Create(AList: TQXMLNode);
begin
inherited Create;
FList:=AList;
FIndex:=-1;
end;

function TQXMLNodeEnumerator.GetCurrent: TQXMLNode;
begin
Result:=FList[FIndex];
end;

function TQXMLNodeEnumerator.MoveNext: Boolean;
begin
if FIndex+1<FList.Count then
  begin
  Inc(FIndex);
  Result:=True;
  end
else
  Result:=False;
end;

{ TQHashedXMLNode }

function TQHashedXMLNode.AddNode(const AName: QStringW): TQXMLNode;
begin
Result:=inherited AddNode(AName);
Result.FNameHash:=HashOf(PQCharW(AName),Length(AName) shl 1);
FHashTable.Add(Pointer(Count-1),Result.FNameHash);
end;

procedure TQHashedXMLNode.Clear;
begin
inherited;
FHashTable.Clear;
end;

constructor TQHashedXMLNode.Create;
begin
inherited;
FHashTable:=TQHashTable.Create();
FHashTable.AutoSize:=True;
end;

function TQHashedXMLNode.CreateNode: TQXMLNode;
begin
if Assigned(OnQXMLNodeCreate) then
  Result:=OnQXMLNodeCreate
else
  Result:=TQHashedXMLNode.Create;
end;

procedure TQHashedXMLNode.Delete(AIndex: Integer);
var
  AItem:TQXMLNode;
begin
AItem:=Items[AIndex];
FHashTable.Delete(Pointer(AIndex),AItem.FNameHash);
inherited;
end;

destructor TQHashedXMLNode.Destroy;
begin
inherited;
FreeObject(FHashTable);
end;

function TQHashedXMLNode.IndexOf(const AName: QStringW): Integer;
var
  AIndex,AHash:Integer;
  AList:PQHashList;
  AItem:TQXMLNode;
begin
AHash:=HashOf(PQCharW(AName),Length(AName) shl 1);
AList:=FHashTable.FindFirst(AHash);
Result:=-1;
while AList<>nil do
  begin
  AIndex:=Integer(AList.Data);
  AItem:=Items[AIndex];
  if AItem.Name=AName then
    begin
    Result:=AIndex;
    Break;
    end
  else
    AList:=FHashTable.FindNext(AList);
  end;
end;

initialization
  XMLDateFormat:='yyyy-mm-dd';
  XMLDateTimeFormat:='yyyy-mm-dd''T''hh:nn:ss.zzz';
  XMLTimeFormat:='hh:nn:ss.zzz';
  XMLCaseSensitive:=True;
  XMLTagShortClose:=True;
  OnQXMLNodeCreate:=nil;
  OnQXMLNodeFree:=nil;
end.
