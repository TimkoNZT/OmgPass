unit uEditItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.ToolWin;

type
  TfrmEditItem = class(TForm)
    btnClose: TButton;
    btnOK: TButton;
    fpEdit: TScrollBox;
    ToolBarEdit: TToolBar;
    tbtnAddField: TToolButton;
    imlToolBarEdit: TImageList;
    tbtnDelField: TToolButton;
    tbtnFieldUp: TToolButton;
    tbtnFieldDown: TToolButton;
    tbtnFieldUndo: TToolButton;
    tbtnFieldRedo: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    constructor Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False); reintroduce;
    procedure StartEditField(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure SaveValues;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditItem: TfrmEditItem;

implementation
uses Logic, uFieldFrame, XMLUtils, uEditField;
{$R *.dfm}

procedure TfrmEditItem.btnCloseClick(Sender: TObject);
begin
	ModalResult:=mrCancel;
end;

procedure TfrmEditItem.btnOKClick(Sender: TObject);
begin
	Self.SaveValues;
	ModalResult:=mrOK;
end;

procedure TfrmEditItem.SaveValues;
var
	i: Integer;
begin
    Log('frmEditItem: SaveValues');
    for i := 0 to fpEdit.ControlCount - 1 do begin
		With (fpEdit.Controls[i] as TFieldFrame) do begin
            SetNodeValue(IXMLNode(Tag), StringReplace(textInfo.Text, #13#10, '|', [rfReplaceAll]));
        end;
    end;
    for i := 0 to Application.ComponentCount - 1 do
        Log(Application.Components[i].ToString);
end;

procedure TfrmEditItem.fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
fpEdit.VertScrollBar.Position:= fpEdit.VertScrollBar.Position - WheelDelta div 5;
end;

constructor TfrmEditItem.Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False);
begin
    inherited Create(AOwner);
    GeneratePanel(nItem, fpEdit, True, IsNew);
    if isNew then self.Caption:= 'Новая запись'
    else Self.Caption:='Редактирование записи';
end;

procedure TfrmEditItem.FormShow(Sender: TObject);
begin
WindowsOnTop(bWindowsOnTop, Self);
if fpEdit.ControlCount<>0 then
    TFieldFrame(fpEdit.Controls[fpEdit.ControlCount - 1]).textInfo.SetFocus;
end;

procedure TfrmEditItem.StartEditField(Sender: TObject);
var
    Node: IXMLNode;
begin
    Node:= IXMLNode(TSpeedButton(Sender).Parent.Tag);
    frmEditItem.SaveValues;
    if EditField(Node) then
        GeneratePanel(Node.ParentNode, frmEditItem.fpEdit, True)
    else Log('EditField: False');
end;


end.
