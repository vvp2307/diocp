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
  object lblFile: TLabel
    Left = 8
    Top = 357
    Width = 48
    Height = 13
    Caption = #36828#31243#25991#20214
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
  object btnCloseSocket: TButton
    Left = 407
    Top = 8
    Width = 145
    Height = 25
    Caption = #20851#38381#23458#25143#31471
    TabOrder = 2
    OnClick = btnCloseSocketClick
  end
  object edtPort: TEdit
    Left = 259
    Top = 10
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '9983'
  end
  object mmoLog: TMemo
    Left = 8
    Top = 39
    Width = 564
    Height = 155
    TabOrder = 4
  end
  object edtRFile: TEdit
    Left = 8
    Top = 376
    Width = 234
    Height = 21
    TabOrder = 5
  end
  object btnGetFile: TButton
    Left = 264
    Top = 374
    Width = 121
    Height = 25
    Caption = #33719#21462#19968#20010#36828#31243#25991#20214
    TabOrder = 6
    OnClick = btnGetFileClick
  end
  object btnUpload: TButton
    Left = 8
    Top = 254
    Width = 121
    Height = 25
    Caption = #19978#20256#19968#20010#25991#20214
    TabOrder = 7
    OnClick = btnUploadClick
  end
  object chkZip: TCheckBox
    Left = 192
    Top = 258
    Width = 228
    Height = 17
    Caption = #19978#20256'/'#19979#36733#26102#26159#21542#36827#34892#21387#32553#65311
    TabOrder = 8
  end
  object IdTCPClient: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 584
    Top = 8
  end
  object tmrEchoTester: TTimer
    Left = 616
    Top = 80
  end
  object dlgOpen: TOpenDialog
    Left = 208
    Top = 144
  end
end
