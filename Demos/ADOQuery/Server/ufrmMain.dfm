object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'IOCP'#26381#21153#22120
  ClientHeight = 393
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 636
    Height = 393
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
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
      object btnConnectConfig: TButton
        Left = 8
        Top = 112
        Width = 129
        Height = 25
        Caption = #25968#25454#24211#36830#25509#37197#32622
        TabOrder = 3
        OnClick = btnConnectConfigClick
      end
    end
    object tsIOCPINfo: TTabSheet
      Caption = 'tsIOCPINfo'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 281
      ExplicitHeight = 165
    end
    object tsTester: TTabSheet
      Caption = 'tsTester'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object btnADOQueryTester: TButton
        Left = 16
        Top = 136
        Width = 137
        Height = 25
        Caption = 'btnADOQueryTester'
        TabOrder = 0
        OnClick = btnADOQueryTesterClick
      end
    end
  end
  object qryMain: TADOQuery
    LockType = ltBatchOptimistic
    Parameters = <>
    Left = 24
    Top = 96
  end
end
