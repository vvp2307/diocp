object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'IOCP'#26381#21153#22120
  ClientHeight = 376
  ClientWidth = 719
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
    Width = 409
    Height = 274
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
      Top = 114
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
      Top = 168
      Width = 97
      Height = 13
      Caption = 'lblClientContextINfo'
    end
    object lblSendAndRecvBytes: TLabel
      Left = 8
      Top = 224
      Width = 104
      Height = 13
      Caption = 'lblSendAndRecvBytes'
    end
    object lblSendBytes: TLabel
      Left = 8
      Top = 200
      Width = 104
      Height = 13
      Caption = 'lblSendAndRecvBytes'
    end
    object btnReset: TButton
      Left = 295
      Top = 11
      Width = 75
      Height = 25
      Caption = 'btnReset'
      TabOrder = 0
      OnClick = btnResetClick
    end
  end
  object chkHttpSvr: TCheckBox
    Left = 303
    Top = 12
    Width = 97
    Height = 17
    Caption = 'Http'#26381#21153#22120
    TabOrder = 4
  end
  object btnCloseAllConnection: TButton
    Left = 480
    Top = 115
    Width = 201
    Height = 25
    Caption = 'btnCloseAllConnection'
    TabOrder = 5
    OnClick = btnCloseAllConnectionClick
  end
  object tmrTestINfo: TTimer
    Enabled = False
    OnTimer = tmrTestINfoTimer
    Left = 447
    Top = 32
  end
end
