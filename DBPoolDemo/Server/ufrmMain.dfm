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
    end
    object tsMoniter: TTabSheet
      Caption = #30417#35270#22120
      ImageIndex = 1
    end
    object tsConfig: TTabSheet
      Caption = #24080#22871#37197#32622
      ImageIndex = 2
      object lblAccountID: TLabel
        Left = 16
        Top = 16
        Width = 24
        Height = 13
        Caption = #24080#22871
      end
      object btnConnectionConfig: TButton
        Left = 56
        Top = 40
        Width = 137
        Height = 25
        Caption = #37197#32622#24080#22871#25968#25454#24211#36830#25509
        TabOrder = 0
        OnClick = btnConnectionConfigClick
      end
      object txtAccount: TComboBox
        Left = 56
        Top = 13
        Width = 185
        Height = 21
        ItemIndex = 0
        TabOrder = 1
        Text = 'account2013'
        Items.Strings = (
          'account2013'
          'account2012')
      end
    end
    object tsTester: TTabSheet
      Caption = 'tsTester'
      ImageIndex = 3
      object mmoSQL: TMemo
        Left = 3
        Top = 3
        Width = 342
        Height = 124
        Lines.Strings = (
          '/* scriptkey = 20101002, scriptstep = 1 */'
          'DECLARE @mm_Kind int'
          'DECLARE @mm_POSStartTime datetime'
          'DECLARE @mm_Key uniqueidentifier'
          'DECLARE @mm_DepotKey uniqueidentifier'
          'DECLARE @mm_State int'
          ''
          ' SELECT @mm_Kind=10200'
          ' SELECT @mm_POSStartTime='#39'2013-01-29 16:24:00'#39
          ' SELECT @mm_Key=NULL'
          ' SELECT @mm_DepotKey='#39'{130EB5A0-5124-4C87-BC8D-8E00506077A1}'#39
          ' SELECT @mm_State='#39#39
          '------------------------------------------------'
          ''
          ''
          'SELECT'
          '  COUNT(1)'
          '  FROM sto_Stock f_m'
          
            '    LEFT JOIN com_BillInfo c_bf ON f_m.FFormKey = c_bf.FFormKey ' +
            '   '
          '  WHERE c_bf.FSyncFlag = 0          '
          ''
          '      AND f_m.FBillDate >= @mm_POSStartTime'
          '      AND f_m.FDepotKey = @mm_DepotKey'
          '      AND c_bf.FApproveState = 1    '
          ''
          '      AND f_m.FBillKind = @mm_Kind  '
          ''
          ''
          ''
          'GOTO _OK_END'
          '_ERR_END:'
          '_OK_END:')
        TabOrder = 0
        WordWrap = False
      end
      object mmoSQL2: TMemo
        Left = 3
        Top = 133
        Width = 342
        Height = 124
        Lines.Strings = (
          '/* scriptkey = 20101001, scriptstep = 1 */'
          'DECLARE @mm_Version bigint'
          'DECLARE @mm_UpdateVer varchar(50)'
          'DECLARE @mm_DepotKey uniqueidentifier'
          ''
          ' SELECT @mm_Version='#39#39
          ' SELECT @mm_UpdateVer='#39#39
          ' SELECT @mm_DepotKey='#39'{A283C971-5CC9-4DA4-8688-6FFF1F6E9C0A}'#39
          '------------------------------------------------'
          ''
          ''
          ''
          ''
          ''
          'DECLARE @MAXVER BIGINT'
          ''
          ''
          ''
          'SELECT @MAXVER = cast(FUpdateVer as bigint) '
          '  FROM sys_updateTable '
          '  WHERE FTableName = '#39'KhKind'#39
          '       AND FDepotKey = @mm_DepotKey'
          '  '
          'IF @MAXVER IS NULL'
          '  SET @MAXVER = 0'
          ''
          'SELECT TOP 100'
          '     *, CAST(FUpdateTime AS INT) AS __UpdateVer'
          '  FROM KhKind'
          '  WHERE FUpdateTime > @MAXVER '
          '  ORDER BY FUpdateTime   '
          ''
          ''
          'GOTO _OK_END'
          '_ERR_END:'
          '_OK_END:')
        TabOrder = 1
        WordWrap = False
      end
      object btnOpen: TButton
        Left = 351
        Top = 3
        Width = 75
        Height = 25
        Caption = 'btnOpen'
        TabOrder = 2
        OnClick = btnOpenClick
      end
    end
  end
end
