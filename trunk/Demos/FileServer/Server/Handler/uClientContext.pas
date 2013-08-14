unit uClientContext;

interface

uses
  Windows, JwaWinsock2, uBuffer, SyncObjs, Classes, SysUtils,
  uIOCPCentre, JSonStream;

type
  TClientContext = class(TIOCPClientContext)
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoOnWriteBack; override;

    procedure wirteFileData(pvDataObject:TJsonStream);
    procedure readFileData(pvDataObject:TJsonStream);
  public
    /// <summary>
    ///   数据处理
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure dataReceived(const pvDataObject:TObject); override;
    /// <summary>TClientContext.FileRename
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="pvSrcFile"> 完整文件名 </param>
    /// <param name="pvNewFileName"> 不带路径文件名 </param>
    class function FileRename(pvSrcFile:String; pvNewFileName:string): Boolean;


  end;

implementation

uses
  uFrameConfig, uCRCTools, Math;





procedure TClientContext.dataReceived(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile:String;
  lvCmdIndex:Cardinal;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvCmdIndex := lvJsonStream.JSon.I['cmdIndex'];

    //上传文件
    if lvCmdIndex= 1001 then
    begin
      //写入文件
      wirteFileData(lvJsonStream);

      lvJsonStream.Clear();
      lvJsonStream.setResult(True);

      //回写数据
      writeObject(lvJsonStream);
    end else if lvCmdIndex= 1002 then
    begin
      //获取文件块
      readFileData(lvJsonStream);

      //回写数据
      writeObject(lvJsonStream);
    end else
    begin
      //返回数据
      writeObject(lvJsonStream);
    end;
  except
    on E:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.setResultMsg(e.Message);
      writeObject(lvJsonStream);
    end;

  end;
end;

procedure TClientContext.DoConnect;
begin
  inherited;
end;

procedure TClientContext.DoDisconnect;
begin
  inherited;
end;



procedure TClientContext.DoOnWriteBack;
begin
  inherited;
end;

class function TClientContext.FileRename(pvSrcFile:String;
    pvNewFileName:string): Boolean;
var
  lvNewFile:String;
begin
  lvNewFile := ExtractFilePath(pvSrcFile) + ExtractFileName(pvNewFileName);
  Result := MoveFile(pchar(pvSrcFile), pchar(lvNewFile));
end;

procedure TClientContext.readFileData(pvDataObject: TJsonStream);
const
  SEC_SIZE = 1024 * 4;
var
  lvFileStream:TFileStream;
  lvFileName, lvRealFileName:String;
  lvCrc, lvSize:Cardinal;
begin
  lvFileName:= TFrameConfig.getBasePath;
  if lvFileName = '' then
  begin
    raise Exception.Create('服务端没有设定文件服务器目录!');
  end;
  lvFileName := lvFileName + '\' + pvDataObject.Json.S['fileName'];

  //删除原有文件
  if not FileExists(lvFileName) then raise Exception.CreateFmt('(%s)文件不存在!', [pvDataObject.Json.S['fileName']]);


  lvFileStream := TFileStream.Create(lvFileName, fmOpenRead or fmShareDenyWrite);
  try
    lvFileStream.Position := pvDataObject.Json.I['start'];
    pvDataObject.Clear();
    pvDataObject.Json.I['fileSize'] := lvFileStream.Size;
    lvSize := Min(SEC_SIZE, lvFileStream.Size-lvFileStream.Position);
    pvDataObject.Stream.CopyFrom(lvFileStream, lvSize);
    pvDataObject.Json.I['blockSize'] := lvSize;
    pvDataObject.Json.I['crc']:=TCRCTools.crc32Stream(pvDataObject.Stream);
  finally
    lvFileStream.Free;
  end;
  lvCrc := TCRCTools.crc32Stream(pvDataObject.Stream);

end;

procedure TClientContext.wirteFileData(pvDataObject: TJsonStream);
var
  lvFileStream:TFileStream;
  lvFileName, lvRealFileName:String;
  lvCrc:Cardinal;
begin
  lvCrc := TCRCTools.crc32Stream(pvDataObject.Stream);
  if lvCrc <> pvDataObject.Json.I['crc'] then
  begin
    raise Exception.CreateFmt('文件crc校验失败' + sLineBreak + '文件块信息' + sLineBreak + '开始位置:%d, 块大小:%d',
      [pvDataObject.Json.I['start'], pvDataObject.Json.I['size']]);
  end;

//  if pvDataObject.Json.I['size'] <> pvDataObject.Stream.Size then
//  begin
//    raise Exception.Create('接收文件失败');
//  end;


  lvFileName:= TFrameConfig.getBasePath;
  if lvFileName = '' then
  begin
    raise Exception.Create('服务端没有设定文件服务器目录!');
  end;
  lvFileName := lvFileName + '\' + pvDataObject.Json.S['fileName'];

  //删除原有文件
  if FileExists(lvFileName) then DeleteFile(lvFileName);
  lvRealFileName := lvFileName;
  
  lvFileName := lvFileName + '.temp';

  //第一传送
  if pvDataObject.Json.I['start'] = 0 then
  begin
    if FileExists(lvFileName) then DeleteFile(lvFileName);
  end;

  if FileExists(lvFileName) then
  begin
    lvFileStream := TFileStream.Create(lvFileName, fmOpenReadWrite);
  end else
  begin
    lvFileStream :=  TFileStream.Create(lvFileName, fmCreate);
  end;
  try
    lvFileStream.Position := pvDataObject.Json.I['start'];
    pvDataObject.Stream.Position := 0;
    lvFileStream.CopyFrom(pvDataObject.Stream, pvDataObject.Stream.Size);

  finally
    lvFileStream.Free;
  end;

  if pvDataObject.Json.B['eof'] then
  begin
    FileRename(lvFileName, lvRealFileName);
  end;
end;

end.
