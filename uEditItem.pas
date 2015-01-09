unit uEditItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, ClipBrd,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.ToolWin,

  uStrings, Vcl.Menus, Vcl.ExtCtrls;

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
    tbtnSplit1: TToolButton;
    popupFastField: TPopupMenu;
    mnuFastField0: TMenuItem;
    mnuFastField1: TMenuItem;
    mnuFastField3: TMenuItem;
    mnuFastField2: TMenuItem;
    ToolButton1: TToolButton;
    tbtnAdvanced: TToolButton;
    pnlLine: TPanel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    constructor Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False; isAdvanced: Boolean = False); reintroduce;
    procedure StartEditField(Sender: TObject);
    procedure ClipboardToEdit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbtnFieldUndoClick(Sender: TObject);
    procedure tbtnFieldRedoClick(Sender: TObject);
    procedure tbtnFieldDownClick(Sender: TObject);
    procedure tbtnFieldUpClick(Sender: TObject);
    procedure tbtnAddFieldClick(Sender: TObject);
    procedure tbtnDelFieldClick(Sender: TObject);
    procedure mnuFastFieldClick(Sender: TObject);
    procedure tbtnAdvancedClick(Sender: TObject);
  private
    FItem: IXMLNode;
    UndoList: IXMLNodeList;
    UndoDoc: IXMLDocument;
    intFocused: Integer;
    intUndo: Integer;
    bAdvancedEdit: Boolean;
    procedure SaveValues;
    procedure MakeUndoPoint;
    function GetActiveField(): IXMLNode;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditItem: TfrmEditItem;

implementation
uses Logic, uLog, uFieldFrame, XMLUtils, uEditField;
{$R *.dfm}

constructor TfrmEditItem.Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False; isAdvanced: Boolean = False);
begin
    inherited Create(AOwner);
    //Передаем управление временной нодой на локальную ссылку
    fItem:=nItem;
    bAdvancedEdit:=isAdvanced;
    tbtnAdvanced.Down:=bAdvancedEdit;
    //Рисуем
    GeneratePanel(fItem, fpEdit, True, IsNew, bAdvancedEdit);
    if isNew then
        Self.Caption:= rsFrmEditItemCaptionNew
    else if GetNodeType(nItem) = ntDefItem then
        Self.Caption:=rsFrmEditItemCaptionDef
    else
        Self.Caption:=rsFrmEditItemCaption;
    //Ундо-лист
    UndoDoc:=TXMLDocument.Create(nil);
    UndoDoc.Active:=True;
    UndoList:=UndoDoc.AddChild('Undo').ChildNodes;
    //Запоминаем первоначальное состояние входящей ноды
    MakeUndoPoint;
end;

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
        //Log(GetNodeValue(IXMLNode(Tag)));
        //Log(StringReplace(textInfo.Text, CrLf, '|', [rfReplaceAll]));
            if GetNodeValue(IXMLNode(Tag)) <> StringReplace(textInfo.Text, CrLf , '|', [rfReplaceAll]) then begin
                SetNodeValue(IXMLNode(Tag), StringReplace(textInfo.Text, CrLf, '|', [rfReplaceAll]));
                //MakeUndoPoint;
            end;
        end;
    end;
   //После сохранения делаем копию
end;

procedure TfrmEditItem.fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
fpEdit.VertScrollBar.Position:= fpEdit.VertScrollBar.Position - WheelDelta div 5;
end;

function TfrmEditItem.GetActiveField(): IXMLNode;
var i: Integer;
begin
    for i := 0 to fpEdit.ControlCount - 1 do begin
		With (fpEdit.Controls[i] as TFieldFrame) do begin
            if textInfo.Focused then begin
                result:=IXMLNode(Tag);
                intFocused:=i;
            end;
        end;
    end;
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
    if EditField(Node) then begin
        GeneratePanel(Node.ParentNode, frmEditItem.fpEdit, True, False, frmEditItem.bAdvancedEdit);
    end else Log('EditField: False');
end;

procedure TfrmEditItem.ClipboardToEdit(Sender: TObject);
begin
    (TSpeedButton(Sender).Parent as TFieldFrame).textInfo.Text:= Clipboard.AsText;
end;

procedure TfrmEditItem.tbtnAddFieldClick(Sender: TObject);
var
    newField: IXMLNode;
begin
    Self.SaveValues;
    newField:=CreateNewField;
    if not EditField(newField, True) then Exit;
    fItem.ChildNodes.Add(newField);
    if GetFieldFormat(newField) = ffPass then
        SetNodeValue(newField, GeneratePassword());
    GeneratePanel(fItem, frmEditItem.fpEdit, True, False, frmEditItem.bAdvancedEdit);
end;

procedure TfrmEditItem.tbtnAdvancedClick(Sender: TObject);
begin
SaveValues;
bAdvancedEdit:=tbtnAdvanced.Down;
GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
end;

procedure TfrmEditItem.tbtnDelFieldClick(Sender: TObject);
var
    delField: IXMLNode;
begin
    delField:=GetActiveField;
    if delField = nil then begin
        Log ('Deleting field: Field not selected');
        Exit;
    end;
    if (GetFieldFormat(delField) = ffTitle) and
    (GetItemTitlesCount(delField.ParentNode) = 1) then begin
        MessageBox(Self.Handle,
        PWideChar(rsCantDelTitleField),
        PWideChar(rsDelFieldConfirmationCaption),
        MB_ICONEXCLAMATION + MB_OK + MB_SYSTEMMODAL);
        Exit;
    end;
    if MessageBox(Self.Handle,
        PWideChar(Format(rsDelFieldConfirmationText,[GetNodeTitle(delField)])),
        PWideChar(rsDelFieldConfirmationCaption),
        MB_ICONQUESTION + MB_OKCANCEL + MB_DEFBUTTON2 + MB_SYSTEMMODAL)
        = ID_CANCEL then Exit;
    Log('Deleting field: Confirmed');
    fItem.ChildNodes.Remove(delField);
    GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
end;

procedure TfrmEditItem.mnuFastFieldClick(Sender: TObject);
var
    newField: IXMLNode;
begin
    Self.SaveValues;
    newField:=CreateNewField(eFieldFormat(TMenuItem(Sender).GroupIndex));
    fItem.ChildNodes.Add(newField);
    GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
end;

procedure TfrmEditItem.tbtnFieldUpClick(Sender: TObject);
var
    nField: IXMLNode;
begin
    Self.SaveValues;
    nField:=GetActiveField;
    if nField = nil then begin
        Log ('Field up: Field not selected');
        Exit;
    end;
    if intFocused = fpEdit.ControlCount - 1 then begin
        Beep;
        Exit;
    end;
    nField.ParentNode.ChildNodes.Insert(nField.ParentNode.ChildNodes.IndexOf(nField.PreviousSibling), nField.CloneNode(True));
    nField.ParentNode.ChildNodes.Remove(nField);
    GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
    (fpEdit.Controls[intFocused + 1] as TFieldFrame).textInfo.SetFocus;
end;

procedure TfrmEditItem.tbtnFieldDownClick(Sender: TObject);
var
    nField: IXMLNode;
begin
    Self.SaveValues;
    nField:=GetActiveField;
    if nField = nil then begin
        Log ('Field up: Field not selected');
        Exit;
    end;
    if intFocused = 0 then begin
        Beep;
        Exit;
    end;
    nField.ParentNode.ChildNodes.Insert(nField.ParentNode.ChildNodes.IndexOf(nField.NextSibling) + 1, nField.CloneNode(True));
    nField.ParentNode.ChildNodes.Remove(nField);
    GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
    (fpEdit.Controls[intFocused - 1] as TFieldFrame).textInfo.SetFocus;
end;

{$REGION '#Ундо-редо'}
procedure TfrmEditItem.MakeUndoPoint;
var i: integer;
begin
    Log('Make undo point...');
    //Чистим всё, что в ундо-листе после текущей позиции
    for i := intUndo + 1 to UndoList.Count - 1 do
        UndoList.Delete(i);
    //Сохраняем новый вид записи
    UndoList.Add(fItem.CloneNode(True));
    //Ставим указатель списка ундо на последний элемент
    intUndo:=UndoList.Count - 1;
    Log('Make undo Ok. Undo count = ', UndoList.Count);
end;

procedure TfrmEditItem.tbtnFieldRedoClick(Sender: TObject);
begin
Log('btnRedo!');
Log ('intUndo: ', intUndo);
Log ('UndoCount = ', UndoList.Count);
if intUndo <> UndoList.Count - 1 then begin;
    Inc(intUndo);
    fItem:= UndoList[intUndo];
end;
GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
end;

procedure TfrmEditItem.tbtnFieldUndoClick(Sender: TObject);
begin
Log ('btnUndo!');
Log ('intUndo: ', intUndo);
Log ('UndoCount = ', UndoList.Count);
//if intUndo = UndoList.Count - 1 then
//    SaveValues;
if intUndo <> 0 then begin
    Dec(intUndo);
    fItem:= UndoList[intUndo];
end;
GeneratePanel(fItem, fpEdit, True, False, bAdvancedEdit);
end;

{$ENDREGION '#Ундо-редо'}
end.
