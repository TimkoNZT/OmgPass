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
    tbtnSplit1: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    constructor Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False); reintroduce;
    procedure StartEditField(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbtnFieldUndoClick(Sender: TObject);
    procedure tbtnFieldRedoClick(Sender: TObject);
    procedure tbtnFieldDownClick(Sender: TObject);
    procedure tbtnFieldUpClick(Sender: TObject);
  private
    FItem: IXMLNode;
    UndoList: IXMLNodeList;
    UndoDoc: IXMLDocument;
    intUndo: Integer;
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
uses Logic, uFieldFrame, XMLUtils, uEditField;
{$R *.dfm}

constructor TfrmEditItem.Create(AOwner: TComponent; nItem: IXMLNode; isNew: Boolean = False);
begin
    inherited Create(AOwner);
    //Передаем управление временной нодой на локальную ссылку
    fItem:=nItem;
    //Рисуем
    GeneratePanel(fItem, fpEdit, True, IsNew);
    if isNew then self.Caption:= 'Новая запись'
    else Self.Caption:='Редактирование записи';
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
        //Log(StringReplace(textInfo.Text, #13#10, '|', [rfReplaceAll]));
            if GetNodeValue(IXMLNode(Tag)) <> StringReplace(textInfo.Text, #13#10, '|', [rfReplaceAll]) then begin
                //MakeUndoPoint;
                SetNodeValue(IXMLNode(Tag), StringReplace(textInfo.Text, #13#10, '|', [rfReplaceAll]));
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
begin
    //
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
        GeneratePanel(Node.ParentNode, frmEditItem.fpEdit, True);
    end else Log('EditField: False');
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
GeneratePanel(fItem, fpEdit, True);
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
GeneratePanel(fItem, fpEdit, True);
end;

procedure TfrmEditItem.tbtnFieldUpClick(Sender: TObject);
begin
    Log(UndoDoc.XML);
end;

procedure TfrmEditItem.tbtnFieldDownClick(Sender: TObject);
begin
SaveValues;
end;

{$ENDREGION '#Ундо-редо'}
end.
