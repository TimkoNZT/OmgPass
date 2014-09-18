object frmProperties: TfrmProperties
  Left = 480
  Top = 323
  BorderStyle = bsDialog
  Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1072#1082#1082#1072#1091#1085#1090#1072
  ClientHeight = 272
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  DesignSize = (
    409
    272)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 239
    Width = 113
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '* '#1053#1077' '#1080#1079#1084#1077#1085#1103#1077#1084#1099#1077' '#1087#1086#1083#1103
    ExplicitTop = 184
  end
  object btnOK: TButton
    Left = 317
    Top = 228
    Width = 80
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 231
    Top = 228
    Width = 80
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object vleProp: TValueListEditor
    Left = 11
    Top = 11
    Width = 386
    Height = 205
    Anchors = [akLeft, akTop, akRight, akBottom]
    Strings.Strings = (
      '')
    TabOrder = 2
    TitleCaptions.Strings = (
      #1050#1083#1102#1095
      #1047#1085#1072#1095#1077#1085#1080#1077)
    ColWidths = (
      150
      230)
  end
end
