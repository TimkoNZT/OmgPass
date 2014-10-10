object frmEditField: TfrmEditField
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1087#1086#1083#1103
  ClientHeight = 233
  ClientWidth = 272
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    272
    233)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 50
    Height = 13
    Caption = #1048#1084#1103' '#1087#1086#1083#1103':'
  end
  object Label2: TLabel
    Left = 16
    Top = 64
    Width = 49
    Height = 13
    Caption = #1058#1080#1087' '#1087#1086#1083#1103':'
  end
  object txtFieldTitle: TEdit
    Left = 16
    Top = 33
    Width = 236
    Height = 21
    BevelWidth = 2
    TabOrder = 0
  end
  object cmbFieldType: TComboBoxEx
    Left = 16
    Top = 80
    Width = 236
    Height = 22
    ItemsEx = <
      item
        Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
      end
      item
        Caption = #1058#1077#1082#1089#1090
      end
      item
        Caption = #1055#1072#1088#1086#1083#1100
      end
      item
        Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
      end
      item
        Caption = #1057#1089#1099#1083#1082#1072
      end
      item
        Caption = #1044#1072#1090#1072
      end
      item
        Caption = #1055#1086#1095#1090#1072
      end
      item
        Caption = #1060#1072#1081#1083
      end>
    Style = csExDropDownList
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 171
    Top = 189
    Width = 81
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnClose: TButton
    Left = 82
    Top = 189
    Width = 81
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object chkShowButton: TCheckBox
    Left = 24
    Top = 119
    Width = 217
    Height = 18
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1082#1085#1086#1087#1082#1091' '#1076#1077#1081#1089#1090#1074#1080#1103
    TabOrder = 4
  end
  object CheckBox1: TCheckBox
    Left = 24
    Top = 144
    Width = 217
    Height = 18
    Caption = #1045#1097#1105' '#1095#1090#1086'-'#1085#1080#1073#1091#1076#1100
    TabOrder = 5
  end
end
