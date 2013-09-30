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
  object pnlTopOperator: TPanel
    Left = 0
    Top = 0
    Width = 654
    Height = 209
    Align = alTop
    Caption = 'pnlTopOperator'
    TabOrder = 0
    object lblaccountID: TLabel
      Left = 65
      Top = 40
      Width = 48
      Height = 13
      Caption = #36873#21462#24080#22871
    end
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
    object mmoSQL: TMemo
      Left = 8
      Top = 64
      Width = 529
      Height = 130
      Lines.Strings = (
        'select top 100 * from bas_Material')
      TabOrder = 4
    end
    object txtAccount: TComboBox
      Left = 119
      Top = 37
      Width = 121
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 5
      Text = 'account2013'
      Items.Strings = (
        'account2013'
        'account2012')
    end
    object btnOpenSQL: TButton
      Left = 543
      Top = 62
      Width = 75
      Height = 25
      Caption = #25171#24320'SQL'
      TabOrder = 6
      OnClick = btnOpenSQLClick
    end
    object Button1: TButton
      Left = 543
      Top = 169
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 7
      OnClick = Button1Click
    end
  end
  object dbgrdMain: TDBGrid
    Left = 0
    Top = 209
    Width = 654
    Height = 119
    Align = alClient
    DataSource = dsMain
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object dbgrdTemp: TDBGrid
    Left = 0
    Top = 328
    Width = 654
    Height = 98
    Align = alBottom
    DataSource = dsTemp
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object IdTCPClient: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 584
    Top = 8
  end
  object cdsMain: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 328
    Top = 264
  end
  object dsMain: TDataSource
    DataSet = cdsMain
    Left = 360
    Top = 264
  end
  object cdsTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 320
    Top = 216
  end
  object dsTemp: TDataSource
    DataSet = cdsTemp
    Left = 352
    Top = 216
  end
end
