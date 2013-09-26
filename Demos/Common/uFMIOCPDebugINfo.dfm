object FMIOCPDebugINfo: TFMIOCPDebugINfo
  Left = 0
  Top = 0
  Width = 475
  Height = 312
  TabOrder = 0
  object lblClientINfo: TLabel
    Left = 8
    Top = 16
    Width = 58
    Height = 13
    Caption = 'lblClientINfo'
  end
  object lblRecvINfo: TLabel
    Left = 8
    Top = 46
    Width = 55
    Height = 13
    Caption = 'lblRecvINfo'
  end
  object lblSendINfo: TLabel
    Left = 8
    Top = 75
    Width = 55
    Height = 13
    Caption = 'lblSendINfo'
  end
  object lblWorkCount: TLabel
    Left = 8
    Top = 105
    Width = 64
    Height = 13
    Caption = 'lblWorkCount'
  end
  object lblMemINfo: TLabel
    Left = 8
    Top = 135
    Width = 53
    Height = 13
    Caption = 'lblMemINfo'
  end
  object lblClientContextINfo: TLabel
    Left = 8
    Top = 165
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
    Top = 194
    Width = 104
    Height = 13
    Caption = 'lblSendAndRecvBytes'
  end
  object lblRunTimeINfo: TLabel
    Left = 8
    Top = 280
    Width = 72
    Height = 13
    Caption = 'lblRunTimeINfo'
  end
  object btnReset: TButton
    Left = 279
    Top = 16
    Width = 75
    Height = 25
    Caption = #37325#32622
    TabOrder = 0
    OnClick = btnResetClick
  end
  object tmrTestINfo: TTimer
    Enabled = False
    OnTimer = tmrTestINfoTimer
    Left = 247
    Top = 16
  end
end
