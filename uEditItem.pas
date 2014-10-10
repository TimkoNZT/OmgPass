unit uEditItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc, Vcl.ComCtrls;

type
  TfrmEditItem = class(TForm)
    btnClose: TButton;
    btnOK: TButton;
    fpEdit: TScrollBox;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    constructor Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False); overload;
    procedure FormActivate(Sender: TObject);
    procedure StartEditField(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditItem: TfrmEditItem;

implementation
uses Logic, uFieldFrame, XMLUtils, uEditField;
{$R *.dfm}
//var
//	editedItem: IXMLNode;
procedure TfrmEditItem.btnCloseClick(Sender: TObject);
begin
	ModalResult:=mrCancel;
end;

procedure TfrmEditItem.btnOKClick(Sender: TObject);
var
	i: Integer;
begin
	for i := 0 to fpEdit.ControlCount - 1 do begin
		With (fpEdit.Controls[i] as TFieldFrame) do begin
            Log(Tag);
            SetNodeValue(IXMLNode(Tag), StringReplace(textInfo.Text, #13#10, '|', [rfReplaceAll]));
        end;
    end;
	ModalResult:=mrOK;
end;

procedure TfrmEditItem.Button1Click(Sender: TObject);
begin
    TfrmEditField.Create(self).ShowModal;
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

procedure TfrmEditItem.FormActivate(Sender: TObject);
begin
TFieldFrame(fpEdit.Controls[fpEdit.ControlCount - 1]).textInfo.SetFocus;
end;

procedure TfrmEditItem.StartEditField(Sender: TObject);
var
    Node: IXMLNode;
begin
    Node:= IXMLNode(TSpeedButton(Sender).Parent.Tag);
    if EditField(Node) then
        GeneratePanel(Node.ParentNode, frmEditItem.fpEdit, True)
    else Log ('EditField = False');
end;

end.
