object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 370
  ClientWidth = 803
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblFCount: TLabel
    Left = 272
    Top = 99
    Width = 45
    Height = 13
    Caption = 'lblFCount'
  end
  object btnStart: TButton
    Left = 8
    Top = 17
    Width = 233
    Height = 25
    Caption = #24320#21551#26381#21153'<9933/8083>'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnOpenOnce: TButton
    Left = 272
    Top = 200
    Width = 75
    Height = 25
    Caption = #25171#24320#19968#27425
    TabOrder = 1
    OnClick = btnOpenOnceClick
  end
  object btnCloseOnce: TButton
    Left = 272
    Top = 231
    Width = 75
    Height = 25
    Caption = #20851#38381
    TabOrder = 2
    OnClick = btnCloseOnceClick
  end
  object edtCount: TEdit
    Left = 272
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '100'
  end
  object btnDoTester: TButton
    Left = 272
    Top = 17
    Width = 249
    Height = 25
    Caption = #29992#32447#31243#24320#21551#23458#25143#31471'Tcp'#26292#21147#27979#35797'<'#25171#24320'/'#20851#38381'>'
    TabOrder = 4
    OnClick = btnDoTesterClick
  end
  object btnDoStop: TButton
    Left = 399
    Top = 70
    Width = 75
    Height = 25
    Caption = #20572#27490#27979#35797#32447#31243
    TabOrder = 5
    OnClick = btnDoStopClick
  end
  object btnDoHttpTester: TButton
    Left = 272
    Top = 41
    Width = 249
    Height = 25
    Caption = #29992#32447#31243#24320#21551#23458#25143#31471'Http'#26292#21147#27979#35797'<'#25171#24320'/'#20851#38381'>'
    TabOrder = 6
    OnClick = btnDoHttpTesterClick
  end
  object btnHttpStart: TButton
    Left = 272
    Top = 161
    Width = 249
    Height = 25
    Caption = 'btnHttpStart'
    TabOrder = 7
    OnClick = btnHttpStartClick
  end
  object btnOpenUrl: TButton
    Left = 496
    Top = 132
    Width = 75
    Height = 25
    Caption = 'btnOpenUrl'
    TabOrder = 8
    OnClick = btnOpenUrlClick
  end
  object btnTesterStop: TButton
    Left = 544
    Top = 163
    Width = 105
    Height = 25
    Caption = 'btnTesterStop'
    TabOrder = 9
    OnClick = btnTesterStopClick
  end
  object edtUrl: TComboBox
    Left = 272
    Top = 134
    Width = 193
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 10
    Text = 'http://127.0.0.1:8083/'
    Items.Strings = (
      'http://127.0.0.1:8083/'
      'http://127.0.0.1:9983/'
      'http://localhost:19001/')
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <
      item
        IP = '0.0.0.0'
        Port = 9933
      end>
    DefaultPort = 0
    OnExecute = IdTCPServer1Execute
    Left = 24
    Top = 64
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    Host = '127.0.0.1'
    IPVersion = Id_IPv4
    Port = 9933
    ReadTimeout = -1
    Left = 96
    Top = 64
  end
  object tmr1: TTimer
    OnTimer = tmr1Timer
    Left = 216
    Top = 104
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8083
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 24
    Top = 96
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 96
    Top = 96
  end
end
