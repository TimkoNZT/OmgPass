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
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 400
    Height = 400
    Align = alClient
    Pen.Color = clBtnShadow
    ExplicitLeft = 344
    ExplicitTop = 376
    ExplicitWidth = 65
    ExplicitHeight = 65
  end
  object lbLog: TListBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 394
    Height = 394
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    TabOrder = 0
    StyleElements = [seFont, seClient]
    OnMouseDown = lbLogMouseDown
  end
  object tmrLog: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tmrLogTimer
    Left = 131
    Top = 232
  end
end
