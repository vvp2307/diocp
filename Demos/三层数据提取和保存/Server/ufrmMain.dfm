object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'IOCP'#26381#21153#22120
  ClientHeight = 350
  ClientWidth = 632
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object edtPort: TEdit
    Left = 143
    Top = 10
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '9983'
  end
  object btnIOCPAPIRun: TButton
    Left = 8
    Top = 8
    Width = 129
    Height = 25
    Caption = #36816#34892#26381#21153
    TabOrder = 1
    OnClick = btnIOCPAPIRunClick
  end
  object btnStopSevice: TButton
    Left = 8
    Top = 48
    Width = 129
    Height = 25
    Caption = #20572#27490#26381#21153
    TabOrder = 2
    OnClick = btnStopSeviceClick
  end
  object pnlINfo: TPanel
    Left = 8
    Top = 79
    Width = 392
    Height = 241
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 3
    object lblClientINfo: TLabel
      Left = 8
      Top = 16
      Width = 58
      Height = 13
      Caption = 'lblClientINfo'
    end
    object lblRecvINfo: TLabel
      Left = 8
      Top = 48
      Width = 55
      Height = 13
      Caption = 'lblRecvINfo'
    end
    object lblSendINfo: TLabel
      Left = 8
      Top = 80
      Width = 55
      Height = 13
      Caption = 'lblSendINfo'
    end
    object lblWorkCount: TLabel
      Left = 8
      Top = 112
      Width = 64
      Height = 13
      Caption = 'lblWorkCount'
    end
    object lblMemINfo: TLabel
      Left = 8
      Top = 141
      Width = 53
      Height = 13
      Caption = 'lblMemINfo'
    end
    object lblClientContextINfo: TLabel
      Left = 8
      Top = 184
      Width = 97
      Height = 13
      Caption = 'lblClientContextINfo'
    end
  end
  object btnConnectConfig: TButton
    Left = 400
    Top = 8
    Width = 129
    Height = 25
    Caption = #25968#25454#24211#36830#25509#37197#32622
    TabOrder = 4
    OnClick = btnConnectConfigClick
  end
  object Button1: TButton
    Left = 456
    Top = 112
    Width = 75
    Height = 25
    Caption = #35843#35797#21387#32553
    TabOrder = 5
    OnClick = Button1Click
  end
  object tmrTestINfo: TTimer
    Enabled = False
    OnTimer = tmrTestINfoTimer
    Left = 159
    Top = 256
  end
end
