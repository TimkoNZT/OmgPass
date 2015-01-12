object frmLog: TfrmLog
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1051#1086#1075
  ClientHeight = 422
  ClientWidth = 544
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
    Width = 544
    Height = 402
    Align = alClient
    Pen.Color = clBtnShadow
    ExplicitLeft = 104
    ExplicitTop = -120
    ExplicitWidth = 400
    ExplicitHeight = 400
  end
  object lbLog: TListBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 538
    Height = 396
    Align = alClient
    Color = clHotLight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindow
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    TabOrder = 0
    StyleElements = [seFont, seClient]
    OnMouseDown = lbLogMouseDown
    ExplicitWidth = 576
    ExplicitHeight = 374
  end
  object StatusBar1: TStatusBar
    AlignWithMargins = True
    Left = 3
    Top = 402
    Width = 538
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
    ExplicitTop = 380
    ExplicitWidth = 576
  end
  object tmrLog: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tmrLogTimer
    Left = 131
    Top = 232
  end
end
