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
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 719
    Height = 376
    ActivePage = tsBase
    Align = alClient
    TabOrder = 0
    object tsBase: TTabSheet
      Caption = #22522#26412#25805#20316
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
      object edtBasePath: TEdit
        Left = 8
        Top = 128
        Width = 417
        Height = 21
        TabOrder = 3
      end
      object btnSetBase: TButton
        Left = 448
        Top = 126
        Width = 105
        Height = 25
        Caption = #35774#32622#25991#20214#36335#24452
        TabOrder = 4
        OnClick = btnSetBaseClick
      end
    end
    object tsMoniter: TTabSheet
      Caption = #30417#35270#22120
      ImageIndex = 1
    end
  end
end
