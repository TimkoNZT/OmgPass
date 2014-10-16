object frmEditItem: TfrmEditItem
  Left = 530
  Top = 326
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
  ClientHeight = 359
  ClientWidth = 339
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    339
    359)
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 148
    Top = 315
    Width = 81
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 0
    OnClick = btnCloseClick
  end
  object btnOK: TButton
    Left = 237
    Top = 315
    Width = 81
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object fpEdit: TScrollBox
    Left = 0
    Top = 0
    Width = 339
    Height = 303
    VertScrollBar.Increment = 26
    VertScrollBar.Tracking = True
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    Padding.Left = 15
    Padding.Top = 10
    Padding.Right = 15
    TabOrder = 2
    OnMouseWheel = fpEditMouseWheel
  end
end
