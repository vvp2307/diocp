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
    object Label2: TLabel
      Left = 119
      Top = 169
      Width = 164
      Height = 13
      Caption = #35201#26356#26032#30340#34920#21517#20027#38190'('#29992#36887#21495#20998#24320')'
    end
    object Label1: TLabel
      Left = 8
      Top = 169
      Width = 72
      Height = 13
      Caption = #35201#26356#26032#30340#34920#21517
    end
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
    object edtPort: TEdit
      Left = 145
      Top = 8
      Width = 85
      Height = 21
      TabOrder = 2
      Text = '9983'
    end
    object mmoSQL: TMemo
      Left = 5
      Top = 37
      Width = 724
      Height = 87
      Lines.Strings = (
        'select top 100 * from B_Material')
      TabOrder = 3
    end
    object btnOpenSQL: TButton
      Left = 4
      Top = 130
      Width = 75
      Height = 25
      Caption = #25171#24320'SQL'
      TabOrder = 4
      OnClick = btnOpenSQLClick
    end
    object edtUpdateTable: TEdit
      Left = 8
      Top = 184
      Width = 105
      Height = 21
      TabOrder = 5
      Text = 'bas_Items'
    end
    object edtKeyFields: TEdit
      Left = 119
      Top = 184
      Width = 89
      Height = 21
      TabOrder = 6
      Text = 'FKey'
    end
    object btnPost: TButton
      Left = 237
      Top = 181
      Width = 151
      Height = 25
      Caption = #20445#23384#20462#25913#21040#25968#25454#24211
      TabOrder = 7
      OnClick = btnPostClick
    end
    object btnOpenScript: TButton
      Left = 528
      Top = 130
      Width = 75
      Height = 25
      Caption = #25171#24320#36828#31243#33050#26412
      TabOrder = 8
      OnClick = btnOpenScriptClick
    end
    object edtCode: TEdit
      Left = 392
      Top = 132
      Width = 121
      Height = 21
      TabOrder = 9
    end
    object cbbHost: TComboBox
      Left = 8
      Top = 8
      Width = 131
      Height = 21
      ItemHeight = 13
      TabOrder = 10
      Text = '127.0.0.1'
      Items.Strings = (
        '127.0.0.1'
        '220.249.115.130')
    end
    object btnZipTester: TButton
      Left = 448
      Top = 181
      Width = 75
      Height = 25
      Caption = 'btnZipTester'
      TabOrder = 11
      OnClick = btnZipTesterClick
    end
    object btnZipTester2: TButton
      Left = 584
      Top = 178
      Width = 75
      Height = 25
      Caption = 'btnZipTester2'
      TabOrder = 12
      OnClick = btnZipTester2Click
    end
    object btnGetServerINfo: TButton
      Left = 133
      Top = 130
      Width = 97
      Height = 25
      Caption = 'btnGetServerINfo'
      TabOrder = 13
      OnClick = btnGetServerINfoClick
    end
    object Button1: TButton
      Left = 632
      Top = 130
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 14
      OnClick = Button1Click
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 209
    Width = 740
    Height = 251
    ActivePage = tsTester
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
    object tsTester: TTabSheet
      Caption = 'tsTester'
      ImageIndex = 2
      object mmoTestLog: TMemo
        Left = 0
        Top = 81
        Width = 732
        Height = 142
        Align = alClient
        TabOrder = 0
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 732
        Height = 81
        Align = alTop
        BevelOuter = bvNone
        Caption = 'pnlTop'
        TabOrder = 1
        object Label3: TLabel
          Left = 4
          Top = 11
          Width = 24
          Height = 13
          Caption = #25968#37327
        end
        object lblThreadCount: TLabel
          Left = 4
          Top = 38
          Width = 73
          Height = 13
          Caption = 'lblThreadCount'
        end
        object lblBytesINfo: TLabel
          Left = 4
          Top = 57
          Width = 58
          Height = 13
          Caption = 'lblBytesINfo'
        end
        object edtNum: TEdit
          Left = 34
          Top = 7
          Width = 121
          Height = 21
          TabOrder = 0
          Text = '10'
        end
        object btnDoTester: TButton
          Left = 165
          Top = 5
          Width = 75
          Height = 25
          Caption = 'btnDoTester'
          TabOrder = 1
          OnClick = btnDoTesterClick
        end
        object btnStopTester: TButton
          Left = 246
          Top = 5
          Width = 75
          Height = 25
          Caption = 'btnStopTester'
          TabOrder = 2
          OnClick = btnStopTesterClick
        end
      end
    end
  end
  object cdsMain: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 328
    Top = 136
  end
  object dsMain: TDataSource
    DataSet = cdsMain
    Left = 360
    Top = 136
  end
  object cdsData2: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 544
    Top = 184
  end
  object dsData2: TDataSource
    DataSet = cdsData2
    Left = 584
    Top = 184
  end
  object tmrThread: TTimer
    OnTimer = tmrThreadTimer
    Left = 408
    Top = 232
  end
end
