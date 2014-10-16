object FolderFrame: TFolderFrame
  Left = 0
  Top = 0
  Width = 137
  Height = 330
  Ctl3D = True
  ParentCtl3D = False
  TabOrder = 0
  DesignSize = (
    137
    330)
  object grpDefault: TGroupBox
    Left = 4
    Top = 100
    Width = 130
    Height = 128
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Set default item'
    Constraints.MinWidth = 130
    TabOrder = 0
    Visible = False
    DesignSize = (
      130
      128)
    object lblInfoDef: TLabel
      Left = 11
      Top = 20
      Width = 111
      Height = 98
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'You can configure standart set of fields, what will be created f' +
        'or new items of this page'
      WordWrap = True
    end
    object btnSetDefItem: TButton
      Left = 42
      Top = 83
      Width = 80
      Height = 35
      Anchors = [akRight, akBottom]
      Caption = 'Configure'
      TabOrder = 0
    end
  end
  object grpInfo: TGroupBox
    Left = 4
    Top = 3
    Width = 130
    Height = 94
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Information'
    Constraints.MinWidth = 130
    TabOrder = 1
    DesignSize = (
      130
      94)
    object lblInfo: TLabel
      Left = 11
      Top = 18
      Width = 111
      Height = 68
      Alignment = taRightJustify
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lblInfo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
end
