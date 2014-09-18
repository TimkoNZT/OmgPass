object FieldFrame: TFieldFrame
  Left = 0
  Top = 0
  Width = 170
  Height = 42
  AutoSize = True
  Padding.Bottom = 3
  TabOrder = 0
  OnResize = FrameResize
  DesignSize = (
    170
    42)
  object lblTitle: TLabel
    AlignWithMargins = True
    Left = 1
    Top = 0
    Width = 166
    Height = 13
    Margins.Left = 1
    Margins.Top = 0
    Align = alTop
    Caption = #1055#1088#1080#1074#1077#1090' '#1083#1091#1085#1072#1090#1080#1082#1072#1084'!'
    ExplicitWidth = 98
  end
  object btnSmart: TSpeedButton
    Left = 144
    Top = 13
    Width = 26
    Height = 26
    Anchors = [akTop, akRight]
    Flat = True
  end
  object btnAdditional: TSpeedButton
    Left = 115
    Top = 13
    Width = 26
    Height = 26
    Anchors = [akTop, akRight]
    Flat = True
    Visible = False
  end
  object textInfo: TRichEdit
    Left = 0
    Top = 15
    Width = 112
    Height = 22
    BorderWidth = 1
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    WantTabs = True
  end
end
