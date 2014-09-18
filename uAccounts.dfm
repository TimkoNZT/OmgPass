object frmAccounts: TfrmAccounts
  Left = 480
  Top = 269
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'OmgPass ['#1054#1092#1092#1083#1072#1081#1085' '#1088#1077#1078#1080#1084']'
  ClientHeight = 373
  ClientWidth = 349
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 40
  GlassFrame.Bottom = 60
  OldCreateOrder = True
  Position = poDesigned
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object btnNext: TSpeedButton
    Left = 257
    Top = 331
    Width = 80
    Height = 33
    Caption = #1044#1072#1083#1077#1077
    OnClick = btnNextClick
  end
  object lblInfo: TLabel
    Left = 8
    Top = 8
    Width = 329
    Height = 25
    AutoSize = False
    Caption = #1063#1090#1086' '#1074#1099' '#1093#1086#1090#1080#1090#1077' '#1089#1076#1077#1083#1072#1090#1100'?'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlue
    Font.Height = -16
    Font.Name = 'Verdana'
    Font.Style = []
    GlowSize = 5
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object btnCancel: TSpeedButton
    Left = 171
    Top = 331
    Width = 80
    Height = 33
    Caption = #1054#1090#1084#1077#1085#1072
    OnClick = btnCancelClick
  end
  object Label1: TLabel
    Left = 25
    Top = 80
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object pcWizard: TPageControl
    Left = 8
    Top = 47
    Width = 329
    Height = 257
    ActivePage = TabSheet3
    MultiLine = True
    Style = tsFlatButtons
    TabOrder = 0
    object TabSheet1: TTabSheet
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label5: TLabel
        Left = 3
        Top = 211
        Width = 112
        Height = 13
        Caption = #1057#1077#1081#1095#1072#1089' '#1080#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103':'
        WordWrap = True
      end
      object Label10: TLabel
        Left = 3
        Top = 230
        Width = 221
        Height = 13
        Caption = 'c:\Program Files\OmgPass\Data\Default.opwd'
        WordWrap = True
      end
      object RadioButton3: TRadioButton
        Left = 3
        Top = 56
        Width = 313
        Height = 22
        Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100'  '#1073#1072#1079#1091' '#1074' '#1086#1073#1083#1072#1082#1077
        Enabled = False
        TabOrder = 0
      end
      object radNewBase: TRadioButton
        Left = 3
        Top = 28
        Width = 313
        Height = 22
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1091#1102' '#1073#1072#1079#1091
        TabOrder = 1
        OnClick = radNewBaseClick
      end
      object radOpenBase: TRadioButton
        Left = 3
        Top = 0
        Width = 313
        Height = 22
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1073#1072#1079#1091' '#1087#1072#1088#1086#1083#1077#1081
        Checked = True
        TabOrder = 2
        TabStop = True
        OnClick = radOpenBaseClick
      end
      object RadioButton1: TRadioButton
        Left = 3
        Top = 84
        Width = 313
        Height = 22
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088#1077#1090#1100' '#1088#1077#1079#1077#1088#1074#1085#1099#1077' '#1082#1086#1087#1080#1080
        Enabled = False
        TabOrder = 3
      end
    end
    object tabOpen: TTabSheet
      ImageIndex = 1
      TabVisible = False
      OnShow = tabOpenShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object btnOpenBase: TSpeedButton
        Left = 278
        Top = 84
        Width = 41
        Height = 21
        Caption = '...'
        OnClick = btnOpenBaseClick
      end
      object Label3: TLabel
        Left = 19
        Top = 199
        Width = 41
        Height = 13
        Caption = #1055#1072#1088#1086#1083#1100':'
      end
      object lblDefaultExt: TLabel
        Left = 19
        Top = 22
        Width = 233
        Height = 13
        Caption = '('#1092#1072#1081#1083' \Data\Default.opwd '#1074' '#1087#1072#1087#1082#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099')'
        OnClick = lblDefaultExtClick
      end
      object lblRecentFiles: TLabel
        Left = 19
        Top = 111
        Width = 91
        Height = 13
        Caption = #1053#1077#1076#1072#1074#1085#1080#1077' '#1092#1072#1081#1083#1099':'
        Visible = False
      end
      object lblRecentFile1: TLabel
        Left = 19
        Top = 130
        Width = 300
        Height = 13
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'file #1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHotLight
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        Visible = False
      end
      object lblRecentFile2: TLabel
        Left = 19
        Top = 150
        Width = 300
        Height = 13
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'file #2'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHotLight
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        Visible = False
      end
      object lblRecentFile3: TLabel
        Left = 19
        Top = 170
        Width = 300
        Height = 13
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'file #3'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHotLight
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        Visible = False
      end
      object txtOpenBase: TRichEdit
        Left = 19
        Top = 84
        Width = 253
        Height = 21
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        WordWrap = False
      end
      object txtOpenPass: TRichEdit
        Left = 19
        Top = 218
        Width = 253
        Height = 21
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object RadioButton4: TRadioButton
        Left = 3
        Top = 58
        Width = 249
        Height = 24
        Caption = #1042#1099#1073#1088#1072#1090#1100' '#1092#1072#1081#1083' '#1073#1072#1079#1099
        TabOrder = 2
      end
      object radOpenDefault: TRadioButton
        Left = 3
        Top = 0
        Width = 249
        Height = 22
        Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1073#1072#1079#1091' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102'                   '
        Checked = True
        TabOrder = 3
        TabStop = True
        WordWrap = True
      end
    end
    object TabSheet3: TTabSheet
      ImageIndex = 2
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object SpeedButton4: TSpeedButton
        Left = 336
        Top = 27
        Width = 41
        Height = 23
        Caption = '...'
      end
      object Label4: TLabel
        Left = 19
        Top = 4
        Width = 178
        Height = 13
        Caption = #1055#1086#1078#1072#1083#1091#1081#1089#1090#1072' '#1091#1082#1072#1078#1080#1090#1077' '#1092#1072#1081#1083' '#1089' '#1073#1072#1079#1086#1081
      end
      object btnNewBase: TSpeedButton
        Left = 278
        Top = 25
        Width = 41
        Height = 21
        Caption = '...'
        OnClick = btnNewBaseClick
      end
      object Label2: TLabel
        Left = 19
        Top = 68
        Width = 41
        Height = 13
        Caption = #1055#1072#1088#1086#1083#1100':'
      end
      object lblPassConfirm: TLabel
        Left = 19
        Top = 116
        Width = 87
        Height = 13
        Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077':'
      end
      object btnGeneratePass: TSpeedButton
        Left = 278
        Top = 87
        Width = 41
        Height = 21
        Caption = '...'
        OnClick = btnGeneratePassClick
      end
      object txtNewBase: TRichEdit
        Left = 19
        Top = 25
        Width = 253
        Height = 21
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        WordWrap = False
      end
      object CheckBox1: TCheckBox
        Left = 19
        Top = 178
        Width = 134
        Height = 13
        Caption = #1055#1086#1076#1089#1082#1072#1079#1082#1072' '#1076#1083#1103' '#1087#1072#1088#1086#1083#1103
        Enabled = False
        TabOrder = 1
      end
      object RichEdit6: TRichEdit
        Left = 19
        Top = 197
        Width = 253
        Height = 40
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 2
      end
      object chkShowPass: TCheckBox
        Left = 192
        Top = 68
        Width = 80
        Height = 13
        Alignment = taLeftJustify
        Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100
        TabOrder = 3
        OnClick = chkShowPassClick
      end
      object txtNewPass: TEdit
        Left = 19
        Top = 87
        Width = 253
        Height = 21
        PasswordChar = '#'
        TabOrder = 4
      end
      object txtPassConfirm: TEdit
        Left = 19
        Top = 135
        Width = 253
        Height = 21
        PasswordChar = '#'
        TabOrder = 5
      end
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'OmgPass Database|*.opwd|All files|*.*'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 20
    Top = 325
  end
  object SaveDialog: TSaveDialog
    Filter = 'OmgPass Database|*.opwd'
    Left = 120
    Top = 312
  end
end
