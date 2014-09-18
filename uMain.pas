unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin,
  Styles, Themes, Vcl.DBCtrls, Vcl.Mask, Vcl.Samples.Spin,
  Vcl.ButtonGroup, Vcl.Buttons,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
  {My modules}
  XMLutils, VersionUtils, Logic, Data.Bind.EngExt, Vcl.Bind.DBEngExt,
  System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors, Data.Bind.Components
  ;
type
TfrmMain = class(TForm)
    menuMain: TMainMenu;
    N1: TMenuItem;
    mnuAccounts: TMenuItem;
    mnuPass: TMenuItem;
    N4: TMenuItem;
    mnuInsertItem: TMenuItem;
    mnuDelete: TMenuItem;
    mnuInsertFolder: TMenuItem;
    mnuEditItem: TMenuItem;
    N9: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    mnuOptions: TMenuItem;
    mnuGenerator: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N24: TMenuItem;
    ToolBarMain: TToolBar;
    imlToolBar: TImageList;
    tbtnAccounts: TToolButton;
    ToolButton2: TToolButton;
    tbtnInsertItem: TToolButton;
    tbtnInsertFolder: TToolButton;
    tbtnEdit: TToolButton;
    tbtnDelete: TToolButton;
    tbtnOptions: TToolButton;
    tbtnHelp: TToolButton;
    ToolButton9: TToolButton;
    tabMain: TTabControl;
    N29: TMenuItem;
    mnuThemes: TMenuItem;
    tvMain: TTreeView;
    Splitter: TSplitter;
    fpMain: TScrollBox;
    mnuBaseProperties: TMenuItem;
    sbMain: TStatusBar;
    tmrBar: TTimer;
    lbLog: TListBox;
    imlField: TImageList;
    imlTree: TImageList;
    imlTab: TImageList;
    menuTreePopup: TPopupMenu;
    mnuPopupInsertItem: TMenuItem;
    mnuPopupInsertFolder: TMenuItem;
    mnuPopupEditItem: TMenuItem;
    mnuPopupDelete: TMenuItem;
    imlPopup: TImageList;
    N23: TMenuItem;
    Timer1: TTimer;
    btnAddPage: TSpeedButton;
    btnDeletePage: TSpeedButton;
    tmrRenameTab: TTimer;
    procedure mnuAccountsClick(Sender: TObject);
    procedure tbtnAccountsClick(Sender: TObject);
    procedure mnuGeneratorClick(Sender: TObject);
    procedure mnuOptionsClick(Sender: TObject);
    procedure tbtnOptionsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure fpMainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure tmrBarTimer(Sender: TObject);
    procedure mnuBasePropertiesClick(Sender: TObject);
    procedure tabMainChange(Sender: TObject);
    procedure tvMainChange(Sender: TObject; Node: TTreeNode);
    procedure tvMainDblClick(Sender: TObject);
    procedure mnuEditItemClick(Sender: TObject);
    procedure mnuPopupEditItemClick(Sender: TObject);
    procedure menuTreePopupPopup(Sender: TObject);
    procedure tbtnEditClick(Sender: TObject);
    procedure mnuPopupInsertFolderClick(Sender: TObject);
    procedure tbtnInsertFolderClick(Sender: TObject);
    procedure mnuInsertFolderClick(Sender: TObject);
    procedure tbtnHelpClick(Sender: TObject);
    procedure tvMainEdited(Sender: TObject; Node: TTreeNode; var Title: string);
    procedure tvMainEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure tbtnDeleteClick(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure mnuPopupDeleteClick(Sender: TObject);
    procedure btnAddPageClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnDeletePageClick(Sender: TObject);
    procedure tbtnInsertItemClick(Sender: TObject);
    procedure tabMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrRenameTabTimer(Sender: TObject);
    procedure tabMainMouseLeave(Sender: TObject);
    procedure mnuPopupInsertItemClick(Sender: TObject);
    procedure mnuInsertItemClick(Sender: TObject);
    procedure tvMainCollapsed(Sender: TObject; Node: TTreeNode);
    procedure tvMainExpanded(Sender: TObject; Node: TTreeNode);
    procedure tvMainCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);


private
    procedure ThemeMenuClick(Sender: TObject);
    procedure InitGlobal();
	{ Private declarations }
public
	{ Public declarations }
end;

var
	xmlMain: IXMLDocument;
    frmMain: TfrmMain;
    LogList: TStringList;
    strCurrentBase: String;
procedure Log(Val: Integer); overload;
procedure Log(Text: String); overload;
procedure Log(Flag: Boolean); overload;
procedure Log(Text: String; Val: variant); overload;

implementation

{$R *.dfm}

uses uAccounts, uGenerator, uOptions, uProperties, uEditItem;
{//////////////////////////////////////////////////////////////////////////////}

{$REGION '#Логирование'}
//Логирование
procedure Log(Text: String);
begin
	LogList.Add(TimeToStr(Now) +': '+ Text);
    frmMain.lbLog.Items.Insert(0, TimeToStr(Now) +': '+ Text);
end;
procedure Log(Val: Integer);
begin
	Log(IntToStr(Val));
end;
procedure Log(Flag: Boolean);
begin
    if Flag then Log('True') else Log('False');
end;
procedure Log(Text: String; Val: variant);
begin
	Log(Text + ' ' + VarToStr(Val));
end;
//Таймер для логирования в статусбар
procedure TfrmMain.tmrBarTimer(Sender: TObject);
{$WriteableConst ON}
    const i: Integer = 0;
begin
//	sbMain.Panels[0].Text:=LogList[i];
//    if i<LogList.Count - 1 then inc(i);
{$WriteableConst OFF}
end;
{$ENDREGION}

{$REGION '#Открытие модальных окошек'}
procedure TfrmMain.tbtnAccountsClick(Sender: TObject);
begin
mnuAccounts.Click;
end;
procedure TfrmMain.mnuAccountsClick(Sender: TObject);
begin
if (not Assigned(frmAccounts)) then frmAccounts:=  TfrmAccounts.Create(Self);
frmAccounts.ShowModal;
FreeAndNil(frmAccounts);
end;
procedure TfrmMain.mnuBasePropertiesClick(Sender: TObject);
begin
if (not Assigned(frmProperties)) then frmProperties:= TfrmProperties.Create(Self);
if frmProperties.ShowModal = mrOK then log('Изменены свойства БД');
FreeAndNil(frmProperties);
end;
procedure TfrmMain.mnuGeneratorClick(Sender: TObject);
begin
if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(Self);
frmGenerator.formType:= 1;
frmGenerator.ShowModal;
FreeAndNil(frmGenerator);
end;
procedure TfrmMain.tbtnOptionsClick(Sender: TObject);
begin
mnuOptionsClick(nil);
end;
procedure TfrmMain.mnuOptionsClick(Sender: TObject);
begin
if (not Assigned(frmOptions)) then frmOptions:= TfrmOptions.Create(Self);
frmOptions.ShowModal;
FreeAndNil(frmOptions);
end;
{$ENDREGION}

{$REGION '#Запуск редактирования записи в т.ч. через менюшки и TreeView'}
procedure TfrmMain.tvMainDblClick(Sender: TObject);
//Здесь просто
begin
	EditItem(tvMain.Selected);
end;
procedure TfrmMain.mnuEditItemClick(Sender: TObject);
begin
	EditItem(tvMain.Selected);
end;
procedure TfrmMain.mnuPopupEditItemClick(Sender: TObject);
//А тут не так всё просто
var selNode: TTreeNode;
begin
	selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
    						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
    if selNode = nil then selNode:=tvMain.Selected;
    selNode.Selected:=True;
	EditItem(selNode);
end;
procedure TfrmMain.tbtnEditClick(Sender: TObject);
begin
	EditItem(tvMain.Selected);
end;
procedure TfrmMain.tvMainEdited(Sender: TObject; Node: TTreeNode;
  var Title: string);
begin
	Log('TreeView_onEdited');
	if Title ='' then begin
        Beep;
		Log('tvMainEdited: Empty names r not allowed!');
        Title:=Node.Text;
        Exit;
    end;
	EditNodeTitle(IXMLNode(Node.Data), Title);
end;
procedure TfrmMain.tvMainEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
	Log('TreeView_onEditing');
end;
{$ENDREGION}

{$REGION '#Добавление новой страницы, папки или записи'}
procedure TfrmMain.mnuPopupInsertFolderClick(Sender: TObject);
var selNode: TTreeNode;
begin
	selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
    						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
    if selNode = nil then selNode:=tvMain.Selected;
    selNode.Selected:=True;
	InsertFolder(selNode);
end;
procedure TfrmMain.tbtnInsertFolderClick(Sender: TObject);
begin
	InsertFolder(tvMain.Selected);
end;
procedure TfrmMain.mnuInsertFolderClick(Sender: TObject);
begin
	InsertFolder(tvMain.Selected);
end;
procedure TfrmMain.mnuPopupInsertItemClick(Sender: TObject);
var selNode: TTreeNode;
begin
	selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
    						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
    if selNode = nil then selNode:=tvMain.Selected;
    selNode.Selected:=True;
	InsertItem(selNode);
end;
procedure TfrmMain.mnuInsertItemClick(Sender: TObject);
begin
	InsertItem(tvMain.Selected);
end;
procedure TfrmMain.tbtnInsertItemClick(Sender: TObject);
begin
	InsertItem(tvMain.Selected);
end;
procedure TfrmMain.btnAddPageClick(Sender: TObject);
begin
    AddPage();
end;
{$ENDREGION}

{$REGION '#Правокнопное меню'}
    procedure TfrmMain.menuTreePopupPopup(Sender: TObject);
    //Изменнение виде правокнопной менюшки на дереве. Лапша.
    var selNode: TTreeNode;
    begin
        selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
        						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
        if selNode = nil then selNode:=tvMain.Selected;
   	log('menuTreePopup: Выбраная нода: ' + selNode.Text + ', Sender:' + Sender.UnitName);
        //От этой лапши стоит отказаться, бо расширить кейсы для все пунктов.
    	   	case GetNodeType(IXMLNode(selNode.Data)) of
            	ntItem: begin
        			mnuPopupInsertItem.Enabled:=False;
                    mnuPopupInsertFolder.Enabled:=False;
                    mnuPopupEditItem.Enabled:=True;
                    mnuPopupDelete.Enabled:=True;
                    end;
                ntFolder: begin
                	mnuPopupInsertItem.Enabled:=True;
                    mnuPopupInsertFolder.Enabled:=True;
                    mnuPopupEditItem.Enabled:=False;
                    mnuPopupDelete.Enabled:=True;
                    end;
                ntPage: begin
                	mnuPopupInsertItem.Enabled:=True;
                    mnuPopupInsertFolder.Enabled:=True;
                    mnuPopupEditItem.Enabled:=True;
                    mnuPopupDelete.Enabled:=True;
           	end;
        end;
    end;

{$ENDREGION}

{$REGION '#Удаление'}
procedure TfrmMain.btnDeletePageClick(Sender: TObject);
begin
    DeleteNode(tvMain.Selected, True);
end;
procedure TfrmMain.tbtnDeleteClick(Sender: TObject);
begin
	DeleteNode(tvMain.Selected);
end;
procedure TfrmMain.mnuDeleteClick(Sender: TObject);
begin
	DeleteNode(tvMain.Selected);
end;
procedure TfrmMain.mnuPopupDeleteClick(Sender: TObject);
var selNode: TTreeNode;
begin
	selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
    						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
    if selNode = nil then selNode:=tvMain.Selected;
    selNode.Selected:=True;
	DeleteNode(selNode);
end;
{$ENDREGION}

{$REGION '#Переименование таба по щелчку с ожиданием'}
procedure TfrmMain.tabMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//Запуск таймера для переименования
//Если в таймере выставлена единица, значит была смена табов
//см. tabMainChange
begin
	if tmrRenameTab.Tag=1 then
        tmrRenameTab.Tag:=0
	else
    	tmrRenameTab.Enabled:=True;
end;
procedure TfrmMain.tabMainMouseLeave(Sender: TObject);
//Если мышь уведена, то переименования не будет
begin
	tmrRenameTab.Enabled:=False;
end;
procedure TfrmMain.tmrRenameTabTimer(Sender: TObject);
//Таймер срабатывает через секунду, если не уводить с таба мышь
//Выделяется и редактируется нода соотв. странице.
begin
with tvMain.Items[0] do begin
	Selected:=True;
	EditText;
end;
tmrRenameTab.Enabled:=False;
end;
{$ENDREGION}

{$REGION '#Основы'}
procedure TfrmMain.tvMainChange(Sender: TObject; Node: TTreeNode);
begin
    if Node.Data = nil then Exit;
    log(Integer(Node.Data));
    log(IXMLNode(Node.Data).NodeName);
    //ClearPanel(fpMain);
    GeneratePanel(IXMLNode(Node.Data), fpMain);
end;
procedure TfrmMain.tabMainChange(Sender: TObject);
begin
		tmrRenameTab.Tag:=1;
    	CleaningPanel(fpMain, True);
    	ParsePageToTree(tabMain.TabIndex, tvMain);
end;
{$ENDREGION}

{$REGION '#Запись состояния дерева'}
procedure TfrmMain.tvMainCollapsed(Sender: TObject; Node: TTreeNode);
begin
SetNodeExpanded(Node);
end;
procedure TfrmMain.tvMainExpanded(Sender: TObject; Node: TTreeNode);
begin
SetNodeExpanded(Node);
end;
procedure TfrmMain.tvMainCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
//Запрет сворачивания первой записи
begin
if Node.IsFirstNode then AllowCollapse:= False;
end;
{$ENDREGION}

{$REGION '#Всякая хрень'}
procedure TfrmMain.FormResize(Sender: TObject);
begin
	tvMain.Width:= frmMain.ClientWidth div 5 * 2;
end;
procedure TfrmMain.fpMainMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
//Скролирование панели
begin
fpMain.VertScrollBar.Position:= fpMain.VertScrollBar.Position - WheelDelta div 5;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
//Создание окна. Вся инициализация вынесена в InitGlobal()
var
  	i:Integer;
	newM: TmenuItem;
begin

try
With TStyleManager.Create do begin
for i := 0 to Length(StyleNames)-1 do begin
    newM:= TMenuItem.Create(self);
    newM.Caption:= StyleNames[i];
    newM.RadioItem:=True;
    newM.OnClick:= ThemeMenuClick;
    mnuThemes.Insert(i, NewM);
end;
end;
mnuThemes.Items[0].Checked:= True;
finally end;
InitGlobal();
end;
procedure TfrmMain.ThemeMenuClick(Sender: TObject);
//Выбор стиля оформления
begin
  With TMenuItem(Sender) do begin
  TStyleManager.TrySetStyle(Caption, true);
  Checked:=True;
  end;
end;
{$ENDREGION}

//Инициализация всего
procedure TfrmMain.InitGlobal();
begin
	LogList:= TStringList.Create;
    tmrBar.Enabled:=True;
	Log('Инициализация...');
	xmlMain:=TXMLDocument.Create(frmMain);
	xmlMain.LoadFromFile('../../omgpass.xml');
	xmlMain.Active:=True;
    SetButtonImg(frmMain.btnAddPage, 10);
    SetButtonImg(frmMain.btnDeletePage, 12);
    Log('Проверка версии');
    if CheckVersion(xmlMain) then Log('Версия базы актуальна')
    else begin
        log('Версия устарела. Обновляем.');
		if UpgradeVersion(xmlMain) then
			log('Обновление успешно')
        else log('Обновление завершилось ошибкой. Всё пропало.');
    end;
    xmlMain.Options :=[doNodeAutoIndent, doAttrNull, doAutoSave];
	frmMain.Caption:= frmMain.Caption +' ['+ GetBaseTitle(xmlMain)+']';
    //log(GetEnumName(TypeInfo(eNodeType), Ord(GetNodeType(NodeByPath(xmlMain, 'Root.Data.Page.Folder.Item')))));
    ParsePagesToTabs(xmlMain, tabMain);
    tabMainChange(nil);

end;

procedure TfrmMain.tbtnHelpClick(Sender: TObject);
begin
//xmlMain.SaveToFile('temp.txt');
end;

end.
