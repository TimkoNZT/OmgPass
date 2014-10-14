unit uEditField;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc, Vcl.ImgList;

type
  TfrmEditField = class(TForm)
    txtFieldTitle: TEdit;
    lblFieldCaption: TLabel;
    lblFieldType: TLabel;
    cmbFieldType: TComboBoxEx;
    btnOK: TButton;
    btnClose: TButton;
    chkShowButton: TCheckBox;
    CheckBox1: TCheckBox;
    imlTypes: TImageList;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    constructor Create(AOwner: TComponent; var Node: IXMLNode; isNew: Boolean = False); overload;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditField: TfrmEditField;
  fNode: IXMLNode;

implementation
uses Logic, XMLUtils, uStrings;
{$R *.dfm}

procedure TfrmEditField.btnCloseClick(Sender: TObject);
begin
    ModalResult:= mrCancel;
end;

procedure TfrmEditField.btnOKClick(Sender: TObject);
begin
    SetNodeTitle(fNode, txtFieldTitle.Text);
    SetAttribute(fNode, 'format', arrFieldFormats[cmbFieldType.ItemIndex]);
    if chkShowButton.Checked then
        Log(RemoveAttribute(fNode, 'button'))
    else
        setAttribute(fNode, 'button', 'false');

    Self.ModalResult:=mrOk;
end;

constructor TfrmEditField.Create(AOwner: TComponent; var Node: IXMLNode; isNew: Boolean = False);
var i: Integer;
begin
    inherited Create(AOwner);
    if isNew then Self.Caption:= rsFrmEditFieldCaptionNew else Self.Caption:=rsFrmEditFieldCaption;
    fNode:=Node;
    txtFieldTitle.Text:=GetNodeTitle(Node);
//    txtFieldTitle.SetFocus;
    cmbFieldType.Items.Delimiter:='|';
    cmbFieldType.Items.QuoteChar:=#0;
    cmbFieldType.Items.DelimitedText:=rsTypes;
    cmbFieldType.ItemIndex:=Ord(GetFieldFormat(fNode));
    for I := 0 to cmbFieldType.Items.Count - 1 do cmbFieldType.ItemsEx[i].ImageIndex:=i;
    chkShowButton.Checked:= not (LowerCase(GetAttribute(fNode, 'button')) = 'false');
end;

end.
