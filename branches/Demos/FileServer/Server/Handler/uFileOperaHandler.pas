unit uFileOperaHandler;

interface

uses
  JSonStream, SysUtils, Windows, Classes, uFrameConfig, Math, uCRCTools;

type
  TFileOperaHandler = class(TObject)
  private
    class function getBasePath():String;
  private
    class function BigFileSize(const AFileName: string): Int64;
    
    /// <summary>TFileOperaHandler.FileRename
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="pvSrcFile"> 完整文件名 </param>
    /// <param name="pvNewFileName"> 不带路径文件名 </param>
    class function FileRename(pvSrcFile:String; pvNewFileName:string): Boolean;

    class procedure downFileData(pvDataObject:TJsonStream);

    class procedure uploadFileData(pvDataObject:TJsonStream);

    //获取文件信息
    class procedure readFileINfo(pvDataObject:TJsonStream);

    //删除文件
    class procedure FileDelete(pvDataObject:TJsonStream);
  public
    class procedure Execute(pvDataObject:TJsonStream);
  end;

implementation

{ TFTPWrapper_ProgressBar }

class function TFileOperaHandler.BigFileSize(const AFileName: string): Int64;
var
  sr: TSearchRec;
begin
  try
    if SysUtils.FindFirst(AFileName, faAnyFile, sr) = 0 then
      result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
    else
      result := -1;
  finally
    SysUtils.FindClose(sr);
  end;
end;

class procedure TFileOperaHandler.Execute(pvDataObject: TJsonStream);
var
  lvCMDIndex:Integer;
begin
  lvCMDIndex := pvDataObject.Json.I['cmd.index'];
  case lvCMDIndex of
    1:       // 下载文件
      begin
        downFileData(pvDataObject);
      end;
    2:       //上传文件
      begin
        self.uploadFileData(pvDataObject);
      end;
    3:      //读取文件信息
      begin
        self.readFileINfo(pvDataObject);
      end;
  end;
  
end;

class procedure TFileOperaHandler.FileDelete(pvDataObject: TJsonStream);
begin
  
end;

class function TFileOperaHandler.FileRename(pvSrcFile:String;
    pvNewFileName:string): Boolean;
var
  lvNewFile:String;
begin
  lvNewFile := ExtractFilePath(pvSrcFile) + ExtractFileName(pvNewFileName);
  Result := MoveFile(pchar(pvSrcFile), pchar(lvNewFile));
end;

class function TFileOperaHandler.getBasePath: String;
begin
   Result := TFrameConfig.getBasePath;
end;

class procedure TFileOperaHandler.readFileINfo(pvDataObject: TJsonStream);
const
  SEC_SIZE = 1024 * 4;
var
  lvFileStream:TFileStream;
  lvFileName, lvRealFileName:String;
  lvCrc, lvSize:Cardinal;
begin
  lvFileName:= getBasePath;
  if lvFileName = '' then
  begin
    raise Exception.Create('服务端没有设定文件服务器目录!');
  end;

  lvFileName := lvFileName + '\' + pvDataObject.Json.S['fileName'];

  pvDataObject.Json.Delete('info');
  
  //删除原有文件
  if not FileExists(lvFileName) then
  begin
    pvDataObject.Json.I['info.exists'] := 0;  //不存在
    exit;
  end;

  pvDataObject.Json.I['info.size'] := BigFileSize(lvFileName);

end;

class procedure TFileOperaHandler.downFileData(pvDataObject:TJsonStream);
const
  SEC_SIZE = 1024 * 4;
var
  lvFileStream:TFileStream;
  lvFileName, lvRealFileName:String;
  lvCrc, lvSize:Cardinal;
begin
  lvFileName:= getBasePath;
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
    pvDataObject.Json.I['crc']:= TCRCTools.crc32Stream(pvDataObject.Stream);
  finally
    lvFileStream.Free;
  end;
  lvCrc := TCRCTools.crc32Stream(pvDataObject.Stream);
end;

class procedure TFileOperaHandler.uploadFileData(pvDataObject:TJsonStream);
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
  if FileExists(lvFileName) then SysUtils.DeleteFile(lvFileName);
  lvRealFileName := lvFileName;
  
  lvFileName := lvFileName + '.temp';

  //第一传送
  if pvDataObject.Json.I['start'] = 0 then
  begin
    if FileExists(lvFileName) then SysUtils.DeleteFile(lvFileName);
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
