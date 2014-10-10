unit uEditField;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

type
  TfrmEditField = class(TForm)
    txtFieldTitle: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    cmbFieldType: TComboBoxEx;
    btnOK: TButton;
    btnClose: TButton;
    chkShowButton: TCheckBox;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
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
uses Logic, XMLUtils;
{$R *.dfm}

procedure TfrmEditField.btnCloseClick(Sender: TObject);
begin
    ModalResult:= mrCancel;
end;

procedure TfrmEditField.btnOKClick(Sender: TObject);
begin
    SetNodeTitle(fNode, txtFieldTitle.Text);
    Self.ModalResult:=mrOk;
end;

procedure TfrmEditField.FormCreate(Sender: TObject);
begin
self.cmbFieldType.ItemIndex:=0;
end;

constructor TfrmEditField.Create(AOwner: TComponent; var Node: IXMLNode; isNew: Boolean = False);
begin
    inherited Create(AOwner);
    if isNew then Self.Caption:= 'Новое поле' else Self.Caption:='Редактирование поля';
    fNode:=Node;
    txtFieldTitle.Text:=GetNodeTitle(Node);
//    txtFieldTitle.SetFocus;
end;

end.
