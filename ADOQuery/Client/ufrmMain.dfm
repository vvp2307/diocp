object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 460
  ClientWidth = 740
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 740
    Height = 209
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnOpen: TButton
      Left = 237
      Top = 6
      Width = 105
      Height = 25
      Caption = #25171#24320#23458#25143#31471#36830#25509
      TabOrder = 0
      OnClick = btnOpenClick
    end
    object btnCloseSocket: TButton
      Left = 348
      Top = 6
      Width = 107
      Height = 25
      Caption = #20851#38381#23458#25143#31471
      TabOrder = 1
      OnClick = btnCloseSocketClick
    end
    object edtIP: TEdit
      Left = 5
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 2
      Text = '127.0.0.1'
    end
    object edtPort: TEdit
      Left = 145
      Top = 8
      Width = 85
      Height = 21
      TabOrder = 3
      Text = '9983'
    end
    object mmoSQL: TMemo
      Left = 5
      Top = 37
      Width = 724
      Height = 87
      Lines.Strings = (
        'select *  from YesoulChenYu')
      TabOrder = 4
    end
    object btnOpenSQL: TButton
      Left = 5
      Top = 130
      Width = 75
      Height = 25
      Caption = #25171#24320'SQL'
      TabOrder = 5
      OnClick = btnOpenSQLClick
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 209
    Width = 740
    Height = 251
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      object DBGrid1: TDBGrid
        Left = 0
        Top = 0
        Width = 732
        Height = 223
        Align = alClient
        DataSource = dsMain
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object mmoData: TMemo
        Left = 0
        Top = 0
        Width = 732
        Height = 223
        Align = alClient
        Lines.Strings = (
          'mmoData')
        TabOrder = 0
      end
    end
  end
  object dsMain: TDataSource
    DataSet = qryMain
    Left = 48
    Top = 280
  end
  object qryMain: TADOQuery
    Parameters = <>
    Left = 16
    Top = 280
  end
end
