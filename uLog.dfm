object frmLog: TfrmLog
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1051#1086#1075
  ClientHeight = 400
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbLog: TListBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 394
    Height = 394
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
    StyleElements = [seFont, seClient]
    OnMouseDown = lbLogMouseDown
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 400
    ExplicitHeight = 400
  end
  object tmrLog: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tmrLogTimer
    Left = 232
    Top = 208
  end
end
