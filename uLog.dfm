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
    Height = 380
    Align = alClient
    Pen.Color = clBtnShadow
    ExplicitLeft = 104
    ExplicitTop = -120
    ExplicitHeight = 400
  end
  object lbLog: TListBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 394
    Height = 374
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
  object StatusBar1: TStatusBar
    AlignWithMargins = True
    Left = 3
    Top = 380
    Width = 394
    Height = 17
    Margins.Top = 0
    Panels = <
      item
        Text = 'Esc - Close, Right Click - Clear'
        Width = 200
      end
      item
        Alignment = taRightJustify
        Text = 'Lines Count:'
        Width = 90
      end>
  end
  object tmrLog: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tmrLogTimer
    Left = 131
    Top = 232
  end
end
