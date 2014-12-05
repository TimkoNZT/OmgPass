unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin,
  Vcl.DBCtrls, Vcl.Mask, Vcl.Samples.Spin, ShellApi,
  Vcl.ButtonGroup, Vcl.Buttons,
  {XML}
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
  {My modules}
  Logic, uCustomEdit, Vcl.Dialogs;
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
    mnuService: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    mnuOptions: TMenuItem;
    mnuGenerator: TMenuItem;
    N14: TMenuItem;
    mnuExport: TMenuItem;
    mnuPrint: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    mnuShowPass: TMenuItem;
    mnuClearClip: TMenuItem;
    N21: TMenuItem;
    mnuTop: TMenuItem;
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
    fpMain: TScrollBox;
    mnuBaseProperties: TMenuItem;
    sbMain: TStatusBar;
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
    tmrTreeExpand: TTimer;
    btnAddPage: TSpeedButton;
    btnDeletePage: TSpeedButton;
    tmrRenameTab: TTimer;
    tbtnLog: TToolButton;
    mnuPopupCloneItem: TMenuItem;
    mnuCloneItem: TMenuItem;
    btnTheme: TSpeedButton;
    Splitter: TSplitter;
    pnlTree: TPanel;
    tvMain: TTreeView;
    txtSearch: TButtonedEdit;
    imlSearch: TImageList;
    tmrSearch: TTimer;
    mnuInsertPage: TMenuItem;
    lblEmpty: TLabel;
    TaskDialog1: TTaskDialog;
    mnuEditDefault: TMenuItem;
    Advancedmode1: TMenuItem;
    N2: TMenuItem;
    procedure mnuAccountsClick(Sender: TObject);
    procedure tbtnAccountsClick(Sender: TObject);
    procedure mnuGeneratorClick(Sender: TObject);
    procedure mnuOptionsClick(Sender: TObject);
    procedure tbtnOptionsClick(Sender: TObject);
    procedure fpMainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
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
    procedure tbtnLogClick(Sender: TObject);
    procedure OnMove(var Msg: TWMMove); message WM_MOVE;
    procedure tvMainStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure tvMainDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tvMainDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tmrTreeExpandTimer(Sender: TObject);
    procedure mnuPopupCloneItemClick(Sender: TObject);
    procedure mnuCloneItemClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ThemeMenuClick(Sender: TObject);
    procedure btnThemeClick(Sender: TObject);
    procedure txtSearchEnter(Sender: TObject);
    procedure txtSearchRightButtonClick(Sender: TObject);
    procedure txtSearchChange(Sender: TObject);
    procedure tmrSearchTimer(Sender: TObject);
    procedure txtSearchExit(Sender: TObject);
    procedure txtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure mnuShowPassClick(Sender: TObject);
    procedure mnuClearClipClick(Sender: TObject);
    procedure mnuTopClick(Sender: TObject);
    procedure mnuInsertPageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure mnuServiceClick(Sender: TObject);
    procedure mnuEditDefaultClick(Sender: TObject);

private
	{ Private declarations }
public
	{ Public declarations }
end;

var
    frmMain: TfrmMain;
resourcestring
    rsAppname = 'OmgPass';

implementation

{$R *.dfm}

uses uAccounts, uGenerator, uOptions, uProperties, uEditItem, uLog, uStrings;
{//////////////////////////////////////////////////////////////////////////////}

{$REGION '#Форма логирования'}
//Открытие формы Логирования.
//Код логирования переехал в Logic
procedure TfrmMain.tbtnLogClick(Sender: TObject);
begin
	if Assigned(frmLog) and frmLog.Visible then begin
          	FreeAndNil(frmLog);
        	tbtnLog.Down:=False;
        end
    else begin
        frmLog:=  TfrmLog.Create(nil);
                frmLog.SetBounds(
        				frmMain.Left + frmMain.Width,
        				frmMain.Top,
						400,
        				frmMain.Height);
//        frmLog.Left:=frmMain.Left + frmMain.Width +3;
//        frmLog.Top:=frmMain.Top;
//        frmLog.Height:=frmMain.Height;

        frmLog.lbLog.Items:=LogList;
        frmLog.lbLog.ItemIndex:=frmLog.lbLog.Items.Count-1;
        frmLog.Show;
        bLogDocked:=True;
        tbtnLog.Down:=True;
        frmLog.tmrLog.OnTimer(nil);
    end;
end;
{$ENDREGION}

{$REGION '#Прилипание формы лога к краю основной'}
procedure TfrmMain.OnMove(var Msg: TWMMove);
begin
    if Assigned(frmLog) {and bLogDocked} then
      frmLog.tmrLog.OnTimer(nil);
end;
{$ENDREGION}

{$REGION '#Открытие модальных окошек'}
procedure TfrmMain.tbtnAccountsClick(Sender: TObject);
begin
mnuAccounts.Click;
end;
procedure TfrmMain.mnuAccountsClick(Sender: TObject);
begin
    DocManager(True);
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
	if not tvMain.Selected.HasChildren or tvMain.Selected.IsFirstNode then
		EditNode(tvMain.Selected);
end;
procedure TfrmMain.mnuEditDefaultClick(Sender: TObject);
begin
    EditDefaultItem;
end;

procedure TfrmMain.mnuEditItemClick(Sender: TObject);
begin
	EditNode(tvMain.Selected);
end;
procedure TfrmMain.mnuPopupEditItemClick(Sender: TObject);
//А тут не так всё просто
var selNode: TTreeNode;
begin
	selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
    						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
    if selNode = nil then selNode:=tvMain.Selected;
    selNode.Selected:=True;
	EditNode(selNode);
end;
procedure TfrmMain.tbtnEditClick(Sender: TObject);
begin
	EditNode(tvMain.Selected);
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
procedure TfrmMain.mnuInsertPageClick(Sender: TObject);
begin
    AddNewPage();
    ParsePagesToTabs(xmlMain, frmMain.tabMain);
    frmMain.tabMainChange(nil);
end;

procedure TfrmMain.tbtnInsertItemClick(Sender: TObject);
begin
	InsertItem(tvMain.Selected);
end;
procedure TfrmMain.btnAddPageClick(Sender: TObject);
begin
    AddNewPage();
    ParsePagesToTabs(xmlMain, frmMain.tabMain);
    frmMain.tabMainChange(nil);
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
    	   	{case GetNodeType(IXMLNode(selNode.Data)) of
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
        end; }
    end;

{$ENDREGION}

{$REGION '#Удаление'}
procedure TfrmMain.btnDeletePageClick(Sender: TObject);
begin
    DeleteNode(tvMain.Selected, True);
end;
procedure TfrmMain.btnThemeClick(Sender: TObject);
begin
    if intThemeIndex <> mnuThemes.Count - 1 then
        mnuThemes.Items[intThemeIndex + 1].Click
    else
        mnuThemes.Items[0].Click;
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

{$REGION '#Клонирование овечек'}
procedure TfrmMain.mnuPopupCloneItemClick(Sender: TObject);
    var selNode: TTreeNode;
    begin
  	selNode:= tvMain.GetNodeAt(tvMain.ScreenToClient(menuTreePopup.PopupPoint).X,
      						tvMain.ScreenToClient(menuTreePopup.PopupPoint).Y);
    if selNode = nil then selNode:=tvMain.Selected;
    selNode.Selected:=True;
  	CloneNode(selNode);
end;

procedure TfrmMain.mnuCloneItemClick(Sender: TObject);
begin
    CloneNode(tvMain.Selected);
end;
{$ENDREGION}

{$REGION '#Переименование таба по щелчку с задержкой'}
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
    GeneratePanel(IXMLNode(Node.Data), fpMain);
    if not bSearchMode then iSelected:=tvMain.Selected.AbsoluteIndex;
end;
procedure TfrmMain.tabMainChange(Sender: TObject);
begin
  		tmrRenameTab.Tag:=1;
        iSelected:=0;
    	CleaningPanel(fpMain, True);
        if bSearchMode then        
        	ParsePageToTree(tabMain.TabIndex, tvMain, txtSearch.Text)
        else
            ParsePageToTree(tabMain.TabIndex, tvMain);
        tvMain.Items[0].Selected:=True;
end;
{$ENDREGION}

{$REGION '#Запись состояния дерева'}
procedure TfrmMain.tvMainCollapsed(Sender: TObject; Node: TTreeNode);
begin
if Node.Selected then SetNodeExpanded(Node);
Log('Collapsing ' + Node.Text);
end;
procedure TfrmMain.tvMainExpanded(Sender: TObject; Node: TTreeNode);
begin
if Node.Selected then SetNodeExpanded(Node);
Log('Expanding ' + Node.Text);
end;
procedure TfrmMain.tvMainCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
//Запрет сворачивания первой записи
begin
if Node.IsFirstNode then AllowCollapse:= False;
end;
{$ENDREGION}

{$REGION '#Драг&Дроп у дерева'}
procedure TfrmMain.tvMainStartDrag(Sender: TObject;
var DragObject: TDragObject);
begin
    Log('Drag!');
end;

procedure TfrmMain.tvMainDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  trgNode, selNode: TTreeNode;
begin
Log('Drop!');
  	trgNode := tvMain.GetNodeAt(X, Y);
  	selNode := tvMain.Selected;
    //if trgNode = DragGhostNode then trgNode:= DragGhostNode.getNextSibling;
    
  	if (trgNode = nil) or (trgNode=selNode) then Exit;
	DragAndDrop(trgNode, selNode,(GetKeyState(VK_CONTROL) AND 128) = 128);
    tmrTreeExpand.Enabled:=False;
    intTickToExpand:= 0;
end;

procedure TfrmMain.tvMainDragOver(Sender, Source: TObject; X, Y: Integer;
State: TDragState; var Accept: Boolean);
const
  crDragCopy: Integer = -23;          //Кто бы мог подумать, уроды криворукие
var
  trgNode, selNode, tmpNode: TTreeNode;
begin
    if (GetKeyState(VK_CONTROL) AND 128) = 128 then
        tvMain.DragCursor:= crDragCopy
    else
        tvMain.DragCursor:= crDrag;
  	trgNode := tvMain.GetNodeAt(x, y);
  	selNode := tvMain.Selected;
    nodeToExpand:=trgNode;                             
    tmrTreeExpand.Enabled:=True;
    
    if (trgNode=nil) or
    (trgNode = selNode) or
    //(trgNode = selNode.Parent) or
    (selNode = nil) then begin
        Accept:=False;
        DragAndDropVisual(nil, nil);
        Exit;
    end;
    
    //Маленькая проверка на временные парадоксы
    tmpNode:=trgNode;
    while (tmpNode.Parent <> nil) do begin
        tmpNode := tmpNode.Parent;
        if tmpNode = SelNode then begin
            Accept := False;
            DragAndDropVisual(nil, nil);
            Exit;
        end;
    end;
    
    //Здесь!
    DragAndDropVisual(trgNode, selNode);
end;

procedure TfrmMain.tmrTreeExpandTimer(Sender: TObject);
//Кривовато
begin
    if (oldNode <> nil) and (nodeToExpand <> nil) then
    Log('Expand timer: ' + IntToStr(intTickToExpand) +
        ', OldNode: ' + oldNode.Text + 
        ', ActualNode: ' + nodeToExpand.Text);
        
    if (nodeToExpand = oldNode) then
        if intTickToExpand = 5 then begin
            //nodeToExpand.Expanded:= not nodeToExpand.Expanded;
            if nodeToExpand<>nil then nodeToExpand.Expand(False);
            tmrTreeExpand.Enabled:=False;
            Exit;
        end else 
              inc(intTickToExpand)
    else begin
        intTickToExpand:= 0;
        oldNode:= nodeToExpand;
    end;
end;
{$ENDREGION}

{$Region '#Поиск'}
procedure TfrmMain.tmrSearchTimer(Sender: TObject);
begin
    //Beep;
    ParsePageToTree(intCurrentPage, tvMain, txtSearch.Text);
    with txtSearch do begin
        if Text = '' then
            tvMain.Items[iSelected].Selected:=True
        else    
            tvMain.Items[0].Selected:=True;
        SetFocus;
        RightButton.ImageIndex:=1;
        RightButton.Enabled:=True;
    end;
    tmrSearch.Enabled:=False;
end;

procedure TfrmMain.txtSearchChange(Sender: TObject);
begin
    with txtSearch do begin
        if (Font.Color = clGrayText) then Exit;
        RightButton.ImageIndex:=2;
        tmrSearch.Enabled:=False;
        tmrSearch.Enabled:=True;
    end;

end;

procedure TfrmMain.txtSearchEnter(Sender: TObject);
begin
    bSearchMode:=True;
    with txtSearch do begin
        if (Font.Color = clGrayText) then begin
            iSelected:=tvMain.Selected.AbsoluteIndex;
            Text:= String.Empty;
            Font.Color:=clWindowText;
            Font.Style:= [];
        end;
    end;
end;

procedure TfrmMain.txtSearchExit(Sender: TObject);
begin
    if (txtSearch.Text = String.Empty) then txtSearchRightButtonClick(nil);
end;

procedure TfrmMain.txtSearchRightButtonClick(Sender: TObject);
begin
    with txtSearch do begin
        Font.Color:=clGrayText;
        Font.Style:= [fsItalic];
        RightButton.ImageIndex:=0;
        RightButton.Enabled:=False;
        if Text <> '' then begin
            ParsePageToTree(intCurrentPage, tvMain);
            tvMain.Items[iSelected].Selected:=True;
            tvMain.SetFocus;
        end;
        Text:=rsSearchText;
        bSearchMode:=False;
    end;
end;

procedure TfrmMain.txtSearchKeyPress(Sender: TObject; var Key: Char);
begin
if Ord(Key) = vk_Escape then begin
    txtSearchRightButtonClick(nil);
    tvMain.SetFocus;
end;
end;
{$Endregion}

{$REGION '#Всякая хрень'}
procedure TfrmMain.FormResize(Sender: TObject);
begin
	//tvMain.Width:= frmMain.ClientWidth div 5 * 2;
    //tvMain.Align:=alLeft;
    Splitter.Left:=tvMain.Width;
    lblEmpty.SetBounds((Width - lblEmpty.Width) div 2,
                        (Height - lblEmpty.Height) div 2,
                         lblEmpty.Width,
                         lblEmpty.Height);
    //Log(Sender.ToString);
    if Assigned(frmLog) and bLogDocked then
    	frmLog.tmrLog.OnTimer(nil);
end;

procedure TfrmMain.fpMainMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
//Скролирование панели
begin
fpMain.VertScrollBar.Position:= fpMain.VertScrollBar.Position - WheelDelta div 5;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//Action:=caFree;
    //if not XMLMain.IsEmptyDoc then
    DocumentClose;
    SaveSettings;
    //DeleteFile(xmlMain.FileName);   //
    Application.Terminate;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
    if not InitGlobal then
        frmMain.Close;
//        Application.Terminate;
end;

procedure TfrmMain.ThemeMenuClick(Sender: TObject);
begin
    With TMenuItem(Sender) do begin
        SetTheme(Caption);
        Checked:=True;
        intThemeIndex:=MenuIndex;
    end;
end;
//Скрыть-показать пароли
procedure TfrmMain.mnuShowPassClick(Sender: TObject);
begin
    mnuShowPass.Checked:= not mnuShowPass.Checked;
    bShowPasswords:= mnuShowPass.Checked;
    ShowPasswords(bShowPasswords);
end;
//Поверх всех окон
procedure TfrmMain.mnuTopClick(Sender: TObject);
begin
    Beep;
    mnuTop.Checked:= not mnuTop.Checked;
    bWindowsOnTop:= mnuTop.Checked;
    Log('Forms on top:', bWindowsOnTop);
    WindowsOnTop(bWindowsOnTop, frmMain);
    //Для формы лога не работает
    //if Assigned(frmLog) then WindowsOnTop(bWindowsOnTop, frmLog);
end;
procedure TfrmMain.N12Click(Sender: TObject);
begin
    ShellExecute(frmMain.Handle, 'open', PwideChar(strLink), nil, nil, SW_SHOW);
end;

procedure TfrmMain.mnuServiceClick(Sender: TObject);
begin
Log('MenuDraw');
mnuClearClip.Enabled:= IsntClipboardEmpty;
end;

//Очистка буфера
procedure TfrmMain.mnuClearClipClick(Sender: TObject);
begin
    ClearClipboard;
end;
{$ENDREGION}

procedure TfrmMain.tbtnHelpClick(Sender: TObject);
//var i: Integer;
begin
//
end;

end.
