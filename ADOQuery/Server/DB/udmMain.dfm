object dmMain: TdmMain
  OldCreateOrder = False
  Height = 284
  Width = 402
  object conMain: TADOConnection
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 16
    Top = 24
  end
  object qryMain: TADOQuery
    Connection = conMain
    Parameters = <>
    SQL.Strings = (
      'select *  from YesoulChenYu')
    Left = 16
    Top = 96
  end
  object adsMain: TADODataSet
    Connection = conMain
    CursorType = ctStatic
    CommandText = 'select *  from YesoulChenYu'
    Parameters = <>
    Left = 112
    Top = 96
  end
end
