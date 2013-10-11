object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 212
  ClientWidth = 684
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTopOperator: TPanel
    Left = 0
    Top = 0
    Width = 684
    Height = 209
    Align = alTop
    Caption = 'pnlTopOperator'
    TabOrder = 0
    ExplicitTop = -5
    object btnC_01: TButton
      Left = 8
      Top = 8
      Width = 105
      Height = 25
      Caption = #25171#24320#23458#25143#31471#36830#25509
      TabOrder = 0
      OnClick = btnC_01Click
    end
    object btnCloseSocket: TButton
      Left = 407
      Top = 8
      Width = 145
      Height = 25
      Caption = #20851#38381#23458#25143#31471
      TabOrder = 1
      OnClick = btnCloseSocketClick
    end
    object edtIP: TEdit
      Left = 119
      Top = 10
      Width = 121
      Height = 21
      TabOrder = 2
      Text = '127.0.0.1'
    end
    object edtPort: TEdit
      Left = 259
      Top = 10
      Width = 121
      Height = 21
      TabOrder = 3
      Text = '9983'
    end
    object Button1: TButton
      Left = 543
      Top = 169
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 4
    end
    object btnTestSendMyObject: TButton
      Left = 8
      Top = 62
      Width = 105
      Height = 25
      Caption = 'SendMyObject'
      TabOrder = 5
      OnClick = btnTestSendMyObjectClick
    end
  end
  object IdTCPClient: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 584
    Top = 8
  end
end
