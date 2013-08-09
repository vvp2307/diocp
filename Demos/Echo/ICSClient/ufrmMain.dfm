object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 426
  ClientWidth = 654
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblEchoINfo: TLabel
    Left = 16
    Top = 264
    Width = 54
    Height = 13
    Caption = 'lblEchoINfo'
  end
  object edtIP: TEdit
    Left = 119
    Top = 10
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object btnC_01: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = #25171#24320#23458#25143#31471#36830#25509
    TabOrder = 1
    OnClick = btnC_01Click
  end
  object btnSendJSonStreamObject: TButton
    Left = 8
    Top = 39
    Width = 161
    Height = 25
    Caption = #21457#36865#19968#20010'JSonStream'#23545#35937
    TabOrder = 2
    OnClick = btnSendJSonStreamObjectClick
  end
  object btnCloseSocket: TButton
    Left = 259
    Top = 39
    Width = 145
    Height = 25
    Caption = #20851#38381#23458#25143#31471
    TabOrder = 3
    OnClick = btnCloseSocketClick
  end
  object edtPort: TEdit
    Left = 259
    Top = 10
    Width = 121
    Height = 21
    TabOrder = 4
    Text = '9983'
  end
  object mmoLog: TMemo
    Left = 8
    Top = 70
    Width = 564
    Height = 171
    TabOrder = 5
  end
  object btnSend100: TButton
    Left = 175
    Top = 39
    Width = 75
    Height = 25
    Caption = #29378#28857'100'#27425
    TabOrder = 6
    OnClick = btnSend100Click
  end
  object btnClearINfo: TButton
    Left = 497
    Top = 39
    Width = 75
    Height = 25
    Caption = #28165#31354#26085#24535
    TabOrder = 7
    OnClick = btnClearINfoClick
  end
  object tmrEchoTester: TTimer
    OnTimer = tmrEchoTesterTimer
    Left = 536
    Top = 264
  end
  object FICSSocket: TWSocket
    LineMode = False
    LineLimit = 65536
    LineEnd = #13#10
    LineEcho = False
    LineEdit = False
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalPort = '0'
    MultiThreaded = False
    MultiCast = False
    MultiCastIpTTL = 1
    FlushTimeout = 60
    SendFlags = wsSendNormal
    LingerOnOff = wsLingerOn
    LingerTimeout = 0
    KeepAliveOnOff = wsKeepAliveOff
    KeepAliveTime = 0
    KeepAliveInterval = 0
    SocksLevel = '5'
    SocksAuthentication = socksNoAuthentication
    LastError = 0
    ReuseAddr = False
    ComponentOptions = []
    ListenBacklog = 5
    ReqVerLow = 1
    ReqVerHigh = 1
    OnDataAvailable = FICSSocketDataAvailable
    Left = 496
    Top = 8
  end
end
