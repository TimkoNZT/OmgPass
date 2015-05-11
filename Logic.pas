unit Logic;
interface

uses Windows, Messages, SysUtils, Variants,TypInfo, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin, ClipBrd, Vcl.Buttons,
  Vcl.Dialogs,
	{XML}
	Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
	{MyUnits}
    XMLutils, uDocument, uFieldFrame, uFolderFrame, uFolderFrameInfo,
    uSmartMethods, uSettings,
    {Themes}
    Styles, Themes, uCrypt
  	;
const
	bShowLogAtStart: Boolean = True;
var
    omgDoc: TOmgDocument;           //Основной наш документ
	  //xmlMain: TXMLDocument;        //Деприкейтед
    xmlCfg: TSettings;
	  //omgDoc.docPages: IXMLNodeList;//Список страниц
    //intCurrentPage: Integer;    	//Текущая страничка
    intThemeIndex: Integer;         //Номер выбранной темы
    intExpandFlag: Integer;    	    //Состояние программы
    								//0 - нормальная работа
                                    //1 - загрузка страницы
    iSelected: Integer;             //Эппл подаст в суд
    bSearchMode: Boolean;           //Режим поиска
	  bLogDocked: Boolean;          //Пристыкован ли Лог к основному окошку
    DragGhostNode: TTreeNode;       //Призрачный узел
    bShowPasswords: Boolean;        //Загадочная переменная
    bWindowsOnTop: Boolean;         //Ещё одна
    bAppSimpleMode: Boolean;        //Углупленный режим программы для смертных
    intTickToExpand: Integer;       //  \
    oldNode: TTreeNode;             //  }Разворачивание узлов при перетаскивании
    nodeToExpand: TTreeNode;        // /
    lsStoredDocs: TStringList;      //Список ранее открывавшихся файлов

function InitGlobal: Boolean;
function DocManager(Reopen: Boolean = False): Boolean;
function CheckVersion: Boolean;
function CheckUpdates: Boolean;
procedure LoadSettings;
procedure LoadDocSettings;
procedure SaveSettings;
procedure SaveDocSettings;
procedure LoadThemes;
procedure SetTheme(Theme: String);
function IsntClipboardEmpty: Boolean;
procedure ClearClipboard;
procedure SetButtonImg(Button: TSpeedButton; List: TImageList; ImgIndex: Integer);
function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False; IsAdvanced: Boolean = False) : Boolean;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; isNew: Boolean = False; IsAdvanced: Boolean = False) : TFieldFrame;
procedure GenerateFolderPanel(nItem: IXMLNode; Panel: TWinControl);
function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView; SearchStr: String = '');
procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView; SearchStr: String = '');
procedure InsertFolder(treeNode: TTreeNode);
procedure EditNode(treeNode: TTreeNode);
function EditItem(var Node: IXMLNode; isNew: Boolean = False; isAdvanced: Boolean = False): Boolean;
procedure EditDefaultItem;
function EditField(var Node: IXMLNode; isNew: Boolean = False): Boolean;
procedure EditNodeTitle(Node: IXMLNode; Title: String);
procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
procedure AddNewPage();
function CreateClearPage(): IXMLNode;
procedure InsertItem(treeNode: TTreeNode);
procedure SetNodeExpanded(treeNode: TTreeNode);
function GetNodeExpanded(Node: IXMLNode): Boolean;
function GeneratePassword(Len: Integer = 8): String;
procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean = False);
procedure DragAndDropVisual(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode);
procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);
procedure CloneNode(treeNode: TTreeNode);
function GetItemTitlesCount(Item: IXMLNode): Integer;
procedure ShowPasswords(Flag: Boolean);
procedure WindowsOnTop(Flag: Boolean; Form: TForm);
function GetFolderInformation(Node: IXMLNode): String;
function CreateNewField(fFmt: eFieldFormat = ffNone; Value: String = ''): IXMLNode;
function CreateNewBase(fPath: String; Password: String): Boolean;

function LoadStoredDocs(): TStringList;
procedure AddReloadStoredDocs(newFile: String);
function SaveStoredDocs: Boolean;
function RemoveStoredDocs(DocPath: String = ''; Index: Integer = -1): Boolean;

function DocumentPreOpenXML(Path: String; AlertMsg: Boolean = False): Boolean;
function DocumentPreOpenCrypted(Path: String; TryPass: String; AlertMsg: Boolean = False): Integer;
function DocumentOpen(Path: String; Pass: String): Boolean;

function CheckBackupFolder(sBackupFolder: String; var FullPath: String; CreateFolder: Boolean = False): Boolean;
procedure MakeDocumentBackup();

procedure DocumentOpenByPass;
procedure DocumentClose;

function MessageIsEmptyDoc: Boolean;
function GetAppVersion:string;
procedure ShowOptionsWindow;


implementation
uses uMain, uConsole, uOptions, uEditItem, uEditField, uGenerator, uAccounts, uStrings, uLog;

function GeneratePassword(Len: Integer = 8): String;
//Генерация пароля в строку нужной длины
//через вызов формы генератора
begin
   if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(nil);
   frmGenerator.UpDown.Position:=Len;
   frmGenerator.btnGenerateClick(nil);
   Result:= frmGenerator.lblResult.Caption;
   FreeAndNil(frmGenerator);
end;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
//Очистка панельки (TScrollBox)
//Используется в основной форме и форме редактирования
var
	i: Integer;
begin
	if realCln then
	    while Panel.ControlCount <> 0 do
    		Panel.Controls[0].Destroy
    else
		for i := 0 to Panel.ControlCount - 1 do
			Panel.Controls[i].Visible:=False;
    result:=true;
    Log('ClearPanel(' + Panel.Name + ') =', result);
end;
procedure SetButtonImg(Button: TSpeedButton; List: TImageList; ImgIndex: Integer);
//Назначение картинки в TSpeedButton из TImageList
begin
    if Button is TSpeedButton then begin
        List.GetBitmap(ImgIndex, TSpeedButton(Button).Glyph);
    end;
end;
function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False; IsAdvanced: Boolean = False) : Boolean;
//Рисуем панельку с полями и всё такое, важное место!
//Внутрь надо подавать ноду формата ntItem или ntDefItem c полями Field
var i: Integer;
begin
//Инфо
	Log('Start: GeneratePanel(' + GetNodeTitle(nItem) + ' in ' + Panel.Name +')');
    Log('IsEdit', isEdit);
    Log('IsNew', isNew);
    Log('IsAdvanced', isAdvanced);
    LogNodeInfo(nItem, 'GeneratePanel');
    //Против лагов в изображении
    //Очень капризная функция
    //Отключать видимость жизненно необходимо
    //Если это не делать, то самописный TEdit криво работает с переносами
    LockWindowUpdate(Panel.Handle);
    Panel.Visible:=False;
    //Чистим панельку
    CleaningPanel(Panel);
    case GetNodeType(nItem) of
        ntFolder, ntPage: begin
            GenerateFolderPanel(nItem, Panel);
        end;
        ntItem, ntDefItem: begin
            //И разбиваем ноду по полям
            for i := nItem.ChildNodes.Count -1 downto 0 do
                GenerateField(nItem.ChildNodes[i], Panel, isEdit, IsNew, IsAdvanced);
            //Установка TabOrder
            if isEdit then
                for i := Panel.ControlCount - 1 downto 0 do begin
                    TFieldFrame(Panel.Controls[i]).TabOrder:= Panel.ControlCount - 1 - i;
                    log('TabOrder: ' + TFieldFrame(Panel.Controls[i]).lblTitle.Caption + ' set to ',  TFieldFrame(Panel.Controls[i]).TabOrder);
                end;
        end;
    end;
    //Сначала возвращаем видимость
    Panel.Visible:=True;
    //Потом выводим панельку из комы
    LockWindowUpdate(0);
    Result:=True;
end;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False; IsAdvanced: Boolean = False) : TFieldFrame;
//Рисуем отдельные поля в панельку,
//У ноды должен быть формат поля (ntField)
var
	fieldFormat: eFieldFormat;
begin
	//Log('--------------------GenerateField:Start');
    //LogNodeInfo(nField, 'GenerateField');
    fieldFormat:= GetFieldFormat(nField);
    Result:= TFieldFrame.CreateParented(Panel.Handle{, isEdit});
    //Погнали
	With Result do begin
		Parent:=Panel;
        Align:=alTop;
        //Заполняем метку
        lblTitle.Caption:=GetNodeTitle(nField);
        //Заполняем текст, в комментариях поле выше и требует обработки текста
        if fieldFormat = ffComment then begin
            textInfo.AutoSize:=False;
            textInfo.Height:=62;
            textInfo.BevelEdges:=[beTop];
            textInfo.BevelKind:= bkNone;
            textInfo.Multiline:=True;
			textInfo.Text:=
                StringReplace(VarToStr(nField.NodeValue),'|', sLineBreak, [rfReplaceAll]);
        end
            else textInfo.Text:=VarToStr(nField.NodeValue);
        //Присваивание указателей
		btnSmart.Tag:=NativeInt(textInfo);		        //Кнопки ссылаются на текстовое поле
        btnAdditional.Tag:=NativeInt(textInfo);
		textInfo.Tag:=NativeInt(nField);                //Текст и рамка ссылаются на поле
		Tag:=NativeInt(nField);
        //разная отрисовка при редактировании и обычной работе
        if not IsEdit then begin
            //Показаны или скрыты пароли
            if (fieldFormat = ffPass) then
                if bShowPasswords then
                    textInfo.PasswordChar:=#0
                else
                    textInfo.PasswordChar:=#149;
            //Или скрываетм кнопку или присваиваем ей обработчики
            if LowerCase(GetAttribute(nField, 'button')) = 'false' then
                btnSmart.Enabled:=false
            else
                case fieldFormat of
                ffWeb: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.OpenURL;
                    SetButtonImg(btnSmart, frmMain.imlField, 1);
                end;
                ffMail: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.OpenMail;
                    SetButtonImg(btnSmart, frmMain.imlField, 2);
                end;
                ffFile: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.AttachedFile;
                    SetButtonImg(btnSmart, frmMain.imlField, 3);
                end;
                else begin
                    btnSmart.OnClick:= clsSmartMethods.Create.CopyToClipboard;
                    SetButtonImg(btnSmart, frmMain.imlField, 0);
                end; //case
            end; //if
            //Доступность текста для редактирования
            textInfo.ReadOnly:=not IsEdit;
            textInfo.Enabled:=isEdit;
        end else begin                                 //Режим редактирования
        	case fieldFormat of
                ffPass: begin
        			btnAdditional.Visible:=True;
            		OnResize(nil);
                    btnAdditional.OnClick:= clsSmartMethods.Create.GeneratePass;
                    SetButtonImg(btnAdditional, frmMain.imlField, 5);
                    if isNew then
                        if Boolean(xmlCfg.GetValue('GenerateNewPasswords', True)) then
                            textInfo.Text:=GeneratePassword;
                end;
                ffTitle: lblTitle.Font.Color:=clHotLight;
            end;
            //
            if isAdvanced then begin
                SetButtonImg(btnSmart, frmMain.imlField, 4);
                //btnSmart.OnClick:= clsSmartMethods.Create.EditField;
                //Загадочное сука место
                btnSmart.OnClick:= frmEditItem.StartEditField;
            end else begin
                SetButtonImg(btnSmart, frmMain.imlField, 0);
                //btnSmart.OnClick:= clsSmartMethods.Create.EditField;
                //Загадочное сука место
                btnSmart.OnClick:= frmEditItem.ClipboardToEdit;
            end;
        end;
    end;
    //Result.Visible:=True;
    //Log('--------------------GenerateField:End');
end;
procedure GenerateFolderPanel(nItem: IXMLNode; Panel: TWinControl);
//Рисование TFolderFrame c выбором записи по умолчанию
begin
if (GetNodeType(nItem) = ntPage) then
    with TFolderFrame.CreateParented(Panel.Handle) do begin
        Parent:=Panel;
        Align:=alTop;
        Tag:=NativeInt(nItem);
    end;
    with TFolderFrameInfo.CreateParented(Panel.Handle) do begin
    Align:=alTop;
        Parent:=Panel;
        lblInfo.Caption:=GetFolderInformation(nItem);
    end;
end;
function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
//Рисование страниц из документа в TtabControl
var i: Integer;
tabList: TStringList;
//RootNode: IXMLNode;
begin
    intExpandFlag:=1;
    //intCurrentPage:=-1;
    tabList:=TStringList.Create;
	tabControl.Tabs.Clear;
    tabControl.Visible:= (omgDoc.docPages.Count<>0);
    for i := 0 to omgDoc.docPages.Count - 1 do begin
		LogNodeInfo(omgDoc.docPages[i]);
		tabList.Add(GetNodeTitle(omgDoc.docPages[i]));
    end;
    tabControl.Tabs:=tabList;
    if omgDoc.CurrentPage < tabControl.Tabs.Count then
    	tabControl.TabIndex:= omgDoc.CurrentPage
    else
       	tabControl.TabIndex:=tabControl.Tabs.Count - 1;
    intExpandFlag:=0;
    tabControl.Tabs.Add('');
    Log('--------------------ParsePagesToTabs:End');
end;
procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView; SearchStr: String = '');
//Рисование папок из страницы в дерево
var RootNode: TTreeNode;
begin
	Log('--------------------ParsePageToTree:Start---------------------------');
    if omgDoc.docPages.Count = 0 then begin
        Log('Warning! There is no pages in document');
        Exit;
    end;
    intExpandFlag:=1;
	Tree.Items.Clear;
    RootNode:=Tree.Items.AddChild(nil, GetNodeTitle(omgDoc.docPages[pageIndex]));
    RootNode.ImageIndex:=2;
    RootNode.SelectedIndex:=2;
    RootNode.Data:=Pointer(omgDoc.docPages[pageIndex]);
    Tree.Items.BeginUpdate;
	IterateNodesToTree(omgDoc.docPages[pageIndex], RootNode, Tree, SearchStr);
    Tree.Items.EndUpdate;
    RootNode.Expand(False);
    omgDoc.CurrentPage:= pageIndex;
    intExpandFlag:=0;
    Log('--------------------ParsePageToTree:End-----------------------------');
end;
procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView; SearchStr: String = '');
//Рекурсивная доп.функция к ParsePageToTree
var
	ChildTreeNode: TTreeNode;
   	i: Integer;
begin
	Log('--------------------IterateNodesToTree:Start');
    LogNodeInfo(xn);
    For i := 0 to xn.ChildNodes.Count - 1 do
    if (GetNodeType(xn.ChildNodes[i]) = ntFolder) or
       (GetNodeType(xn.ChildNodes[i]) = ntItem) then begin
        ChildTreeNode := Tree.Items.AddChild(ParentNode, GetNodeTitle(xn.ChildNodes[i]));
        ChildTreeNode.Data:=Pointer(xn.ChildNodes[i]);
        IterateNodesToTree(xn.ChildNodes[i], ChildTreeNode, Tree, SearchStr);
        Case GetNodeType(xn.ChildNodes[i]) of
            ntItem: begin
                ChildTreeNode.ImageIndex:=1;
                ChildTreeNode.SelectedIndex:=1;
                ChildTreeNode.DropTarget:=False;
                if (Pos(LowerCase(SearchStr), LowerCase(GetNodeTitle(xn.ChildNodes[i]))) = 0) and
                    (SearchStr <> '') then
                    ChildTreeNode.Delete
                else
                    ChildTreeNode.MakeVisible;
            end;
            ntFolder: begin
                ChildTreeNode.ImageIndex:= 0;
                ChildTreeNode.SelectedIndex:= 0;
                if SearchStr = '' then
                    ChildTreeNode.Expanded:=GetNodeExpanded(xn.ChildNodes[i])
                else
                    if not ChildTreeNode.HasChildren then
                        ChildTreeNode.Delete;
            end;
        end;
    end;
    Log('--------------------IterateNodesToTree:End');
end;
procedure EditNode(treeNode: TTreeNode);
//Запуск редактирования узла (ntItem)
var
	trgNode: IXMLNode;
    //tmpNode: IXMLNode;
begin
    if treeNode = nil then
            if MessageIsEmptyDoc then Exit     //Во избежание
            else treeNode:=frmMain.tvMain.Selected;

	if treeNode.Data = nil then Exit;
    //Если узел в режиме редактирования то просто применяем изменения
    if TTreeView(treeNode.TreeView).IsEditing then begin
    		TTreeView(treeNode.TreeView).Selected.EndEdit(False);
            Log('EditItem: EndEdit');
            Exit;
    end;
    trgNode:= IXMLNode(treeNode.Data);
    LogNodeInfo(TrgNode, 'EditItem:Target');
	case GetNodeType(TrgNode) of
    ntItem: begin
    	if EditItem(trgNode) then begin
        	treeNode.Data:=Pointer(trgNode);
            treeNode.Text:=GetNodeTitle(trgNode);
            GeneratePanel(trgNode, frmMain.fpMain, False);
            frmMain.tvMain.Selected.Text:=GetNodeTitle(trgNode);
        end;
    end;
    ntFolder, ntPage:
    	treeNode.EditText;
    end;
end;
function EditItem(var Node: IXMLNode; isNew: Boolean = False; isAdvanced: Boolean = False): Boolean;
//Редактирование записи через вызов формы редактирования
var
	//trgNode: IXMLNode;
    tmpNode: IXMLNode;
begin
	Log('EditItem, isNew=' + BoolToStr(isNew, True));
    LogNodeInfo(Node, 'EditItem:InputNode');
	tmpNode:= Node.CloneNode(True);
    LogNodeInfo(tmpNode, 'EditItem:Temp     ');
    if (not Assigned(frmEditItem)) then
        frmEditItem:= TfrmEditItem.Create(frmMain, tmpNode, isNew, isAdvanced);
    if frmEditItem.ShowModal=mrOK then begin
        Log('frmEditItem: mrOK');
        LogNodeInfo(tmpNode, 'EditItem:OutNode  ');
        if not isNew then
            Node.ParentNode.ChildNodes.ReplaceNode(Node, tmpNode);
        Node:= tmpNode;
        Result:=True;
    end else begin
        Log('frmEditItem: mrCancel');
        Result:=False;
    end;
    FreeAndNil(frmEditItem);
end;
function EditField(var Node: IXMLNode; isNew: Boolean = False): Boolean;
//Редактирование отдельного поля
var
    tmpNode: IXMLNode;
begin
	Log('EditField, isNew=' + BoolToStr(isNew, True));
    LogNodeInfo(Node, 'EditField:InputNode');
	tmpNode:= Node.CloneNode(True);
    LogNodeInfo(tmpNode, 'EditField:Temp     ');
    if (not Assigned(frmEditField)) then
        frmEditField:= TfrmEditField.Create(frmEditItem, tmpNode, isNew);
    if GetFieldFormat(Node) = ffTitle then
        if GetItemTitlesCount(Node.ParentNode) = 1 then begin
            frmEditField.cmbFieldType.Enabled:=False;
            frmEditField.lblTitleWarningInfo.Visible:=True;
        end;
    if frmEditField.ShowModal=mrOK then begin
        Log('frmEditField: mrOK');
        LogNodeInfo(tmpNode, 'EditField:OutNode  ');
        if not isNew then
            Node.ParentNode.ChildNodes.ReplaceNode(Node, tmpNode);
        Node:= tmpNode;
        Result:=True;
    end else begin
        Log('frmEditField: mrCancel');
        Result:=False;
    end;
    FreeAndNil(frmEditField);
end;
procedure EditNodeTitle(Node: IXMLNode; Title: String);
//Редактирование заголовка записи или папки
//Вызывается при редатировании TTreeView
begin
	SetNodeTitle(Node, Title);
    case GetNodeType(Node) of
    ntItem:
		GeneratePanel(Node, frmMain.fpMain);
    ntFolder:
		Exit;
    ntPage:
        frmMain.tabMain.Tabs[omgDoc.CurrentPage]:=Title;
    end;
end;
procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
//Удаление любого узла
var
	Msg: String;
    Node: IXMLNode;
begin
    if treeNode = nil then begin
            MessageIsEmptyDoc;
            Exit;
    end;

	Log('DeleteNode:' + treeNode.Text);
	Node:=IXMLNode(treeNode.Data);
    case GetNodeType(Node) of
    ntItem:
    	msg:= Format(rsDelItem, [AnsiQuotedStr(GetNodeTitle(Node), '"')]);
    ntFolder:
    	msg:= Format(rsDelFolder, [AnsiQuotedStr(GetNodeTitle(Node), '"')]);
    ntPage: begin
    	if omgDoc.docPages.Count = 1 then begin
        	MessageBox(Application.Handle,
                        PWideChar(rsCantDelPage),
                        PWideChar(rsDelNodeTitle),
                        MB_ICONWARNING + MB_SYSTEMMODAL);
        	Exit;
        end;
    	msg:= Format(rsDelPage, [AnsiQuotedStr(GetNodeTitle(Node), '"')]);
   	    end;
    end;
    if not withoutConfirm then
    if MessageBox(Application.Handle, PWideChar(Msg), PWideChar(rsDelNodeTitle),
    	 MB_ICONQUESTION + MB_OKCANCEL + MB_DEFBUTTON2 + MB_SYSTEMMODAL) = ID_CANCEL then Exit;
    Log('Deleting confirmed...');
    Node.ParentNode.ChildNodes.Remove(Node);           //returns thmthng
    if GetNodeType(Node) = ntPage then begin
        ParsePagesToTabs(omgDoc.XML, frmMain.tabMain);
        frmMain.tabMainChange(nil);
    end else treeNode.Delete;
end;
procedure AddNewPage();
//Новая страничка
begin
if omgDoc.docPages.Count <> 0 then inc(omgDoc.CurrentPage);
omgDoc.docPages.Insert(omgDoc.CurrentPage, CreateClearPage);

//    ParsePagesToTabs(xmlMain, frmMain.tabMain);
//    frmMain.tabMainChange(nil);
end;
function CreateClearPage(): IXMLNode;
//Непосредственно генератор чистой странички
var
    newPageNode: IXMLNode; //okay?
    dItem: IXMLNode;       //defitem
begin
    newPageNode:=omgDoc.XML.CreateNode('Page');
    newPageNode.Text:=rsNewPageTitle +'_'+ DateToStr(now);
    newPageNode.SetAttributeNS('type', '', 'page');
    dItem:= newPageNode.AddChild('DefItem');
    dItem.ChildNodes.Add(CreateNewField(ffTitle, rsNewItemTitle));
    dItem.ChildNodes.Add(CreateNewField(ffText));
    dItem.ChildNodes.Add(CreateNewField(ffPass));
    dItem.ChildNodes.Add(CreateNewField(ffWeb));
    dItem.ChildNodes.Add(CreateNewField(ffComment));
    result:=newPageNode;
end;
procedure InsertFolder(treeNode: TTreeNode);
//Добавление новой папки
//В параметре - родитель
var
	newFolderNode: IXMLNode;
	//newTreeNode: TTreeNode;
begin
    if treeNode = nil then
            if MessageIsEmptyDoc then Exit     //Во избежание
            else treeNode:=frmMain.tvMain.Selected;

	if GetNodeType(IXMLNode(treeNode.Data))=ntItem then begin
        treeNode:=treeNode.Parent;
    end;
    newFolderNode:= IXMLNode(treeNode.Data).AddChild('Folder');
    newFolderNode.Text:= rsNewFolderTitle;
    newFolderNode.SetAttributeNS('type', '', 'folder');
    newFolderNode.SetAttributeNS('picture', '', 'folder');
    if (not treeNode.Expanded) then treeNode.Expand(False);
	With TTreeView(treeNode.TreeView).Items.AddChild(treeNode, rsNewFolderTitle) do begin
		Data:=Pointer(newFolderNode);
        ImageIndex:=0;
        SelectedIndex:=0;
        //Expanded:=True;             //Бесполезно без дочерних узлов
        Selected:=True;
		EditText;
	end;
end;
procedure InsertItem(treeNode: TTreeNode);
//Добавление новой записи
//Вызывается форма редактирования
var
	i: integer;
	defItem: IXMLNode;
	newItem: IXMLNode;
    destNode: IXMLNode;     //ntFolder;
    newTreeNode: TTreeNode;

function LimitItems(Node: IXMLNode; Full: Boolean): Integer;
var i: Integer;
begin
    Result:=0;
    for i:= 0 to Node.ChildNodes.Count - 1 do begin
        if GetNodeType(Node.ChildNodes[i]) = ntItem then
            inc(result);
        if ((GetNodeType(Node.ChildNodes[i]) = ntFolder) or (GetNodeType(Node.ChildNodes[i]) = ntPage)) and Full then
            result:= result + LimitItems(Node.ChildNodes[i], true);
    end;
end;

begin
    if treeNode = nil then
            if MessageIsEmptyDoc then Exit     //Во избежание
            else treeNode:=frmMain.tvMain.Selected;

//    if LimitItems(NodeByPath(omgDoc.XML, 'Root|Data'), true) >= (Byte.MaxValue div 10) then begin
//        MessageBox(frmMain.Handle, PWideChar(rsDemo), PWideChar(Application.Title), MB_ICONERROR + MB_APPLMODAL);
//        Exit;
//    end;

	destNode:=IXMLNode(treeNode.Data);
	LogNodeInfo(destNode, 'InsertItem');
	if GetNodeType(destNode) = ntItem then begin
    	destNode:=destNode.ParentNode;
        treeNode:=treeNode.Parent;
    end;
    Log(destNode.NodeName);
	defItem:=omgDoc.docPages[omgDoc.CurrentPage].ChildNodes.FindNode('DefItem');
    //
	newItem:=destNode.OwnerDocument.CreateNode('Item');
	for i := 0 to defItem.ChildNodes.Count - 1 do
        newItem.ChildNodes.Add(defItem.ChildNodes[i].CloneNode(True));
    for i := 0 to defItem.AttributeNodes.Count - 1 do
        newItem.AttributeNodes.Add(defItem.AttributeNodes[i].CloneNode(True));
    //
    if EditItem(newItem, True) = True then begin
		destNode.ChildNodes.Add(newItem);
		if (not treeNode.Expanded) then treeNode.Expand(False);
    	newTreeNode:=TTreeView(treeNode.TreeView).Items.AddChild(treeNode, GetNodeTitle(newItem));
    	with newTreeNode do begin
            Data:= Pointer(newItem);
            ImageIndex:=1;
            SelectedIndex:=1;
            Selected:=True;
        end;
        //EditText;
    end else newItem._Release;
end;
procedure CloneNode(treeNode: TTreeNode);
//Клонирование овечек
var
	Node: IXMLNode;
begin
    if treeNode = nil then begin
        MessageIsEmptyDoc;
        Exit;
    end;
    Node:=IXMLNode(treeNode.Data);
    case GetNodeType(Node) of
    ntPage:
        Log('Page clone not realised yet...');
    ntFolder: begin
            Log('Clone folder');
            DragAndDropVisual(treeNode.Parent, treeNode);
            DragAndDrop(treeNode.Parent, treeNode, True);
        end;
    ntItem: begin
            Log('Clone item');
            {newNode:= Node.CloneNode(True);
            Node.ParentNode.ChildNodes.Insert(
            Node.ParentNode.ChildNodes.IndexOf(Node), newNode);
            newTreeNode:= TTreeView(TreeNode.TreeView).Items.Insert(
            TreeNode, TreeNode.Text);
            With newTreeNode do begin
                Data:=Pointer(newNode);
                Enabled:=True;
                ImageIndex:=treeNode.ImageIndex;
                SelectedIndex:=treeNode.SelectedIndex;
                Selected:=True;
            end;}
            DragAndDropVisual(treeNode, treeNode);
            DragAndDrop(treeNode, treeNode, True);
        end;
    end;

end;
function GetItemTitlesCount(Item: IXMLNode): Integer;
var i: Integer;
begin
    Result:=0;
    for i := 0 to Item.ChildNodes.Count - 1 do begin
		if GetNodeType(Item.ChildNodes[i]) = ntField then
            if GetFieldFormat(Item.ChildNodes[i]) = ffTitle then
                inc(Result);
    end;
    Log('GetTitlesCount', Result);
end;
procedure SetNodeExpanded(treeNode: TTreeNode);
//Запись состояния папок в дереве
begin
	if intExpandFlag <> 0 then Exit;
    if treeNode.IsFirstNode then Exit;
	SetAttribute(IXMLNode(treeNode.Data), 'expand',
                BoolToStr(treeNode.Expanded, True));
end;
function GetNodeExpanded(Node: IXMLNode): Boolean;
//Чтение состояния папок в дереве
var
	tmp: String;
begin
	tmp:= GetAttribute(Node, 'expand');
    if tmp='' then
    	result:=False
    else
    	result:=StrToBool(tmp);
end;
procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean=False);
//Перетаскивание мышкой в дереве
var
	selNode, trgNode, newNode: IXMLNode;
begin
    selNode:=IXMLNode(selTreeNode.Data);
    //Цель уже не нужна, данные есть в призраке
	//trgNode:=IXMLNode(trgTreeNode.Data);
    trgNode:=IXMLNode(DragGhostNode.Data);
    newNode:= selNode.CloneNode(True);
    intExpandFlag:=1;
    case GetNodeType(trgNode) of
    ntPage, ntFolder:
    	trgNode.ChildNodes.Add(newNode);
    ntItem:
    	trgNode.ParentNode.ChildNodes.Insert(trgNode.ParentNode.ChildNodes.IndexOf(trgNode), newNode);
    end;
    if GetNodeType(newNode) <> ntItem then begin
        TTreeView(DragGhostNode.TreeView).Items.BeginUpdate;
        IterateNodesToTree(newNode, DragGhostNode, TTreeView(DragGhostNode.TreeView));
        TTreeView(DragGhostNode.TreeView).Items.EndUpdate;
    end;
    With DragGhostNode do begin
        Data:=Pointer(newNode);
        Enabled:=True;
        Selected:=True;
        Expanded:=GetNodeExpanded(newNode);
    end;
    if not isCopy then begin
        selNode.ParentNode.ChildNodes.Remove(selNode);
        selTreeNode.Delete;
    end;
    DragGhostNode:=nil;
    intExpandFlag:=0;

    //Жалко, старый код полностью перерисовывал дерево
    //  IterateTree теперь не нужна... используем в поиске...
    {Logic.ParsePageToTree(Logic.intCurrentPage, frmMain.tvMain);
	rootTreeNode:=selTreeNode.Parent;
    while rootTreeNode.Parent<> nil do rootTreeNode:=rootTreeNode.Parent;
    IterateTree(rootTreeNode, Pointer(newNode));}
end;
procedure DragAndDropVisual(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode);
//Визуальное представление перетаскивания мышкой
var
    trgNode: IXMLNode;
begin
    if trgTreeNode = DragGhostNode then Exit;
    if DragGhostNode <> nil then FreeAndNil(DragGhostNode);                     //Логичное использование Delete не обнуляет ссылку
    if (selTreeNode= nil) or (trgTreeNode=nil) then Exit;
    trgNode:=IXMLNode(trgTreeNode.Data);
    //if (selNode= nil) or (trgNode=nil) then Exit;
    case GetNodeType(trgNode) of
    ntPage, ntFolder:
        DragGhostNode:= TTreeView(trgTreeNode.TreeView).Items.AddChild(trgTreeNode, selTreeNode.Text);
    ntItem: 
        DragGhostNode:= TTreeView(trgTreeNode.TreeView).Items.Insert(trgTreeNode, selTreeNode.Text);
    end;
    DragGhostNode.Enabled:=False;
    DragGhostNode.ImageIndex:=selTreeNode.ImageIndex;
    DragGhostNode.SelectedIndex:=selTreeNode.SelectedIndex;
    //Внимание! В призрак временно заносятся данные цели, а не источника!
    DragGhostNode.Data:=Pointer(trgNode);
end;
procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);
//Функция ищет в дереве узел соответствующий ссылке на ноду и выделяет его
var
   	i: Integer;
begin
	Log('IterateTree: Start: '+ ParentNode.Text );
    For i := 0 to ParentNode.Count - 1 do
        if ParentNode.Item[i].Data = Data then
        	ParentNode.Item[i].Selected:=True
        else IterateTree(ParentNode.Item[i], Data);
    Log('IterateTree: End');
end;
{$REGION 'Настройки'}
procedure LoadSettings;
//Загрузка настроек программы
begin
    bShowPasswords:= xmlCfg.GetValue('ShowPasswords', True);
    bWindowsOnTop:= xmlCfg.GetValue('WindowOnTop', False);
    frmMain.mnuShowPass.Checked:= bShowPasswords;
    frmMain.mnuTop.Checked:= bWindowsOnTop;
    //if frmMain.WindowState = wsNormal then begin
        //И задаем положение
        frmMain.SetBounds(xmlCfg.GetValue('Left', 200, 'Position'),
        xmlCfg.GetValue('Top', 200, 'Position'),
        xmlCfg.GetValue('Width', 520, 'Position'),
        xmlCfg.GetValue('Height', 500, 'Position'));
        bLogDocked:= Boolean(xmlCfg.GetValue('DockLog', True));
            frmMain.WindowState:= xmlCfg.GetValue('Window', 0, 'Position');
    if frmMain.WindowState = wsMinimized then frmMain.WindowState:= wsNormal;
    //if Boolean(xmlCfg.GetValue('ShowLog', False)) then frmMain.tbtnLogClick(nil);
    //    end;
        //if xmlCfg.GetValue('TreeWidth', 0, 'Position') <> 0 then
        frmMain.pnlTree.Width:= xmlCfg.GetValue('TreeWidth', 200, 'Position');
    //end;
end;
procedure LoadDocSettings;
//А здесь грузятся настройки документа и заодно документ выводится в форму
begin
    ParsePagesToTabs(omgDoc.XML, frmMain.tabMain);
    if omgDoc.CurrentPage < omgDoc.docPages.Count then
        frmMain.tabMain.TabIndex := omgDoc.CurrentPage;
    //Эта строчка необходима тУт!
    ParsePageToTree(frmMain.tabMain.TabIndex, frmMain.tvMain);
    if omgDoc.CurrentRecord < frmMain.tvMain.Items.Count  then
        frmMain.tvMain.Items[omgDoc.CurrentRecord].Selected:=True;
end;
procedure SaveSettings;
//Сохраняем всё в файл перед выходом из программы
begin
    if xmlCfg = nil then Exit;
    //Прочие настройки сохраняются в файл настроек
    if frmMain.Visible then begin
        if frmMain.WindowState = wsNormal then begin
             xmlCfg.SetValue('Left', frmMain.Left, 'Position');
             xmlCfg.SetValue('Top', frmMain.Top, 'Position');
             xmlCfg.SetValue('Width', frmMain.Width, 'Position');
             xmlCfg.SetValue('Height', frmMain.Height, 'Position');
             xmlCfg.SetValue('ShowLog', BoolToStr(Assigned(frmLog), True));
        end;
        xmlCfg.SetValue('Window', frmMain.WindowState, 'Position');
        //xmlCfg.SetValue('Page', intCurrentPage, 'Position');
        xmlCfg.SetValue('TreeWidth', frmMain.pnlTree.Width, 'Position');
        xmlCfg.SetValue('Theme', intThemeIndex);
    end;
    xmlCfg.SetValue('ShowPasswords', BoolToStr(bShowPasswords, True));
    xmlCfg.SetValue('WindowOnTop', BoolToStr(bWindowsOnTop, True));
    //SaveStoredDocs;
    xmlCfg.Save;
end;
procedure SaveDocSettings;
begin
    //Номер выбранного элемента и страницы сохраняется в документ
    //Если вдруг режим поиска, то записываем сохраненное значение
    if bSearchMode then
        omgDoc.CurrentRecord:= iSelected
    //Иначе если нормальный режим, то записываем номер выделенного узла
    //Если узла нет, то записывается ноль
    else if frmMain.tvMain.Selected <> nil then
        omgDoc.CurrentRecord:= frmMain.tvMain.Selected.AbsoluteIndex
    else
        omgDoc.CurrentRecord:= 0;
end;
{$ENDREGION 'Настройки'}
procedure LoadThemes;
var
  	i:Integer;
	newMenuItem: TmenuItem;
begin
try
With TStyleManager.Create do begin
    for i := 0 to Length(StyleNames)-1 do begin
        newMenuItem:= TMenuItem.Create(frmMain.mnuThemes);
        newMenuItem.Caption:= StyleNames[i];
        newMenuItem.RadioItem:=True;
        newMenuItem.OnClick:= frmMain.ThemeMenuClick;
        frmMain.mnuThemes.Insert(i, newMenuItem);
    end;
    if xmlCfg.GetValue('Theme', 0) < frmMain.mnuThemes.Count  then
        frmMain.mnuThemes.Items[xmlCfg.GetValue('Theme', 0)].Click;
end;
finally end;
end;
procedure SetTheme(Theme: String);
//Выбор стиля оформления
begin
try
    if bSearchMode then frmMain.txtSearchRightButtonClick(nil);
    TStyleManager.TrySetStyle(Theme, False);
finally end;
end;
procedure ShowPasswords(Flag: Boolean);
//Переключение показа паролей по F5
var
  i: Integer;
  Frame: TFieldFrame;
begin
    Log('ShowPasswords:', Flag);
    Beep;
    for i := 0 to frmMain.fpMain.ControlCount - 1 do begin
        if not (frmMain.fpMain.Controls[i] is TFieldFrame) then Continue;
        Frame:= TFieldFrame(frmMain.fpMain.Controls[i]);
        if GetFieldFormat(IXMLNode(Frame.Tag)) = ffPass then begin
            LogNodeInfo(IXMLNode(Frame.Tag), 'Found password field');
            Frame.textInfo.Visible:=False;
            if Flag then
                Frame.textInfo.PasswordChar:=#0
            else
                Frame.textInfo.PasswordChar:=#149;
            Frame.textInfo.Enabled:=False;
            Frame.textInfo.Visible:=True;
        end;
    end;
end;
function IsntClipboardEmpty: Boolean;
begin
    Result:=(Clipboard.AsText <> String.Empty);
end;
procedure ClearClipboard;
begin
    Clipboard.Clear;
    Beep;
    Log ('Clearing clipboard');
end;
procedure WindowsOnTop(Flag: Boolean; Form: TForm);
//Поверх всех окон
begin
    Log('Form ' + Form.Name + ' topmost:', Flag);
    with Form do
        if Flag then
            SetWindowPos(Form.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE)
        else
            SetWindowPos(Form.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;
function GetFolderInformation(Node: IXMLNode): String;
//Формирование строки информации о папке или странице
//Осторожно!Вложенные функции!
function IterateFolders(Node: IXMLNode; Full: Boolean): Integer;
var i: Integer;
begin
    Result:=0;
    for i:= 0 to Node.ChildNodes.Count - 1 do
        if GetNodeType(Node.ChildNodes[i]) = ntFolder then begin
            inc(result);
            if Full then result:= result + IterateFolders(Node.ChildNodes[i], true);
        end;
end;

function IterateItems(Node: IXMLNode; Full: Boolean): Integer;
var i: Integer;
begin
    Result:=0;
    for i:= 0 to Node.ChildNodes.Count - 1 do begin
        if GetNodeType(Node.ChildNodes[i]) = ntItem then
            inc(result);
        if (GetNodeType(Node.ChildNodes[i]) = ntFolder) and Full then
            result:= result + IterateItems(Node.ChildNodes[i], true);
    end;
end;

begin
    result:= rsInfoTitle  + GetNodeTitle(Node) + CrLf +
            rsInfoSubfolders + IntToStr(IterateFolders(Node, False)) + CrLf +
            rsInfoTotalFolders + IntToStr(IterateFolders(Node, True)) + CrLf +
            rsInfoSubItems + IntToStr(IterateItems(Node, False)) +  CrLf +
            rsInfoTotalItems + IntToStr(IterateItems(Node, True));
end;
procedure EditDefaultItem;
//Вызов формы редактирования для записи по умолчанию
var
    defItem: IXMLNode;
begin
    if MessageIsEmptyDoc then Exit;     //Во избежание
    LogNodeInfo(omgDoc.docPages[omgDoc.CurrentPage], 'EditDefaultItem, Page = ');
    defItem:= omgDoc.docPages[omgDoc.CurrentPage].ChildNodes.FindNode(strDefItemNode);
    LogNodeInfo(defItem, 'EditDefaultItem, DefItem = ');
    if EditItem(defItem, False, True) then
        Log ('EditDefaultItem: Ok') else Log ('EditDefaultItem: Cancel');
end;
function CreateNewField(fFmt: eFieldFormat = ffNone; Value: String = ''): IXMLNode;
//Функция возвращает новое поле
begin
    Result:=omgDoc.XML.CreateNode('Field');
    if fFmt = ffNone then begin
        SetAttribute(Result, 'name', arrDefFieldNames[Ord(fFmt)]);
        SetAttribute(Result, 'format', arrFieldFormats[Ord(ffText)]);
    end else begin
        SetAttribute(Result, 'name', arrDefFieldNames[Ord(fFmt)]);
        SetAttribute(Result, 'format', arrFieldFormats[Ord(fFmt)]);
    end;
    if Value <> '' then SetNodeValue(Result, Value);
end;
function CheckUpdates: Boolean;
begin
    result:=true;
end;
function CheckVersion: Boolean;
begin
    result:=true;
end;
function InitGlobal: Boolean;
//Запуск программы
begin
	LogList:= TStringList.Create;
    xmlCfg:=TSettings.Create(strConfigFile);
    lsStoredDocs:= LoadStoredDocs;
	Log('Инициализация...');
    uCrypt.EnumProviders;
    LoadSettings;
    LoadThemes;
    if not DocManager then begin
        Result:=False;
        Exit
    end;
    //Принудительно показываем форму
    frmMain.Show;
    CheckVersion;
    CheckUpdates;
    Result:=True;

//    with frmMain do begin
//    SetButtonImg(btnAddPage, imlField, 10);
//    SetButtonImg(btnDeletePage, imlField, 12);
//    SetButtonImg(btnTheme, imlTab, 41);
//    end;
end;
function CreateNewBase(fPath: String; Password: String): Boolean;
//Новый документ с нуля
//Формируется файл по заданому пути с заданным паролем
var
    newDoc: TOmgDocument;
    docType: TOmgDocument.tOmgDocType;
begin
newDoc:=nil;
try
    try
        if ExtractFileExt(fPath) = strDefaultExt then
            docType:=dtXML
        else
            docType:=dtCrypted;
        newDoc:=TOmgDocument.CreateNew(fPath, docType, Password);
        newDoc.Save;
        newDoc.Close;
        Result:=True;
    except
        on e: Exception do begin
            ErrorLog(e, 'CreateNewDocument');
            Result:=False;
        end;
    end;
finally
    newDoc.Free;
end;
end;
{$REGION '#StoredDocs'}
function LoadStoredDocs(): TStringList;
//Загружаем список известных файлов из конфига в список
var i: Integer;
begin
    Result:=TStringList.Create;
    for i := 0 to Integer(xmlCfg.GetValue('Count', 0, 'Files')) - 1 do begin
        Result.Add(xmlCfg.GetValue('File_' + IntToStr(i), '', 'Files'));
        Log(Format('Stored Documents: Index %d = %s ', [i, Result[i]]));
    end;
end;
procedure AddReloadStoredDocs(newFile: String);
//Добавляем файл в начало списка известных
//Поднимаем его из середины списка если он там уже был
var i: Integer;
begin
    //Изящно ёпт! Но не работает для несортированого списка.
    //if lsStoredDocs.Find(newFile, i) then lsStoredDocs.Delete(i);
    for i := lsStoredDocs.Count - 1 downto 0 do begin
        if lsStoredDocs.Strings[i] = newFile then
            lsStoredDocs.Delete(i);
    end;
    lsStoredDocs.Insert(0, newFile);
    SaveStoredDocs;
end;
function SaveStoredDocs: Boolean;
//Сохраняем список файлов в конфиг
var i: Integer;
begin
    xmlCfg.ClearSection('Files');
    xmlCfg.SetValue('Count', lsStoredDocs.Count, 'Files');
    for i := 0 to lsStoredDocs.Count - 1 do begin
        xmlCfg.SetValue('File_' + IntToStr(i), lsStoredDocs.Strings[i], 'Files');
    end;
    Result:=True;
end;
function RemoveStoredDocs(DocPath: String = ''; Index: Integer = -1): Boolean;
//Удаление файла из списка сохраненных по индексу или имени
begin
    if Index = -1 then
        //Find - Только для сортированных списков
        //if lsStoredDocs.Find(DocPath, Index) then
        Index := lsStoredDocs.IndexOf(DocPath);
    if (Index > -1) and (Index < lsStoredDocs.Count) then begin
        lsStoredDocs.Delete(Index);
        Result:= not (Index = -1);
    end else Result:=False;
    SaveStoredDocs;
end;
{$ENDREGION}
function MessageIsEmptyDoc: Boolean;
//Возвращаем True если документ пустой и
//пользователь не захотел добавлять страничку

begin
    Result:= omgDoc.IsEmpty;
    if Result then begin
        if not frmMain.Visible then frmMain.Show;

        if (MessageBox(frmMain.Handle,
                PWideChar(rsDocumentIsEmpty),
                PWideChar(rsDocumentIsEmptyTitle),
                MB_YESNO + MB_APPLMODAL + MB_ICONINFORMATION)
                = ID_YES)
                then begin
                    AddNewPage;
                    ParsePagesToTabs(omgDoc.XML, frmMain.tabMain);
                    ParsePageToTree(0, frmMain.tvMain);
                    frmMain.tvMain.Items[0].Selected:=True;
                    Result:=False;
                end;
    end;
end;
function DocManager(Reopen: Boolean = False): Boolean;
//Загрузка документа
//Вызывается менеджер документов
begin
    if (not Assigned(frmAccounts)) then
        frmAccounts:=  TfrmAccounts.Create(frmMain, Reopen);
    if frmAccounts.ShowModal = mrOK then begin
        Log ('frmAccounts: mrOK');
        if DocumentOpen(frmAccounts.FFileName, frmAccounts.FPassword) then begin
            Result:=True;
            if not Reopen then frmMain.Show;    //Принудительно
        end else Result:=False;
    end else begin
        Log ('frmAccounts: mrCancel');
        Result:=False;
    end;
    FreeAndNil(frmAccounts);
end;
function DocumentOpen(Path: String; Pass: String): Boolean;
var
    tmpDoc: TOmgDocument;
begin
    try
        tmpDoc:=TOmgDocument.Create(Path, Pass);
        DocumentClose;
        omgDoc:=tmpDoc;
        frmMain.Caption:= Application.Title +' [' + omgDoc.docFilePath + ']';
        LoadDocSettings;
        MessageIsEmptyDoc;
        if Boolean(xmlCfg.GetValue('MakeBackups', False)) then
            MakeDocumentBackup();
        Result:=True;
    except
        on e: Exception do begin
            ErrorLog(e, 'DocumentOpen');
            Result:=False;
        end;
    end;
    //tmpDoc:=nil;
end;
procedure DocumentOpenByPass;
var
    OpenDialog: TOpenDialog;
    tempDoc: TOmgDocument;
begin
try
    OpenDialog:=TOpenDialog.Create(Application.MainForm);
    With OpenDialog do begin
        DefaultExt:=strDefaultExt;
        Title:=rsOpenDialogTitle;
        Filter:=rsOpenDialogFilterCryptedOnly;
        if not Execute then Exit;
        tempDoc:=TOmgDocument.Create;
        if tempDoc.OpenByPass(FileName) then begin
            omgDoc.Save;
            omgDoc.Close;
            omgDoc.Free;
            omgDoc:=tempDoc;
            //tempDoc:=nil;
            frmMain.Caption:= Application.Title +' [' + omgDoc.docFilePath + ']';
            LoadDocSettings;
            MessageIsEmptyDoc;
        end;
    end;
except
    on e: Exception do ErrorLog(e, 'The gods were overthrown!');
end;
end;
function CheckBackupFolder(sBackupFolder: String; var FullPath: String; CreateFolder: Boolean = False): Boolean;
//Проверка папки для бэкапов
//sBackupFolder передается по значению в виде полного или относительного пути
//FullPath передается по ссылке для возврата полного пути папки
//CreateFolder разрешает создать эту папку для проверки правильности имени
begin
    if ExtractFileDrive(sBackupFolder) = '' then
        sBackupFolder:= GetCurrentDir() +'\' + sBackupFolder;
    sBackupFolder:= ExpandFileName(sBackupFolder);
    FullPath:=IncludeTrailingBackslash(sBackupFolder);
    if CreateFolder then
        if not DirectoryExists(FullPath) then
            Result:= ForceDirectories(FullPath)
        else
            Result:=True;
end;
procedure MakeDocumentBackup();
//Делаем бэкап в папку из настроек
//Удаляем лишние бэкапы согласно настройкам
function GetFileCount(Dir: String; var OldestFile : String): integer;
//Подфункция выдаёт на выходе количество файлов в папке
//а заодно, в параметре OldestFile вытаскивает самый старый файл из списка по дате изменения
var
    fs: TSearchRec;
begin
    Result:=0;
    if FindFirst(Dir + '\Backup_*.*', faAnyFile - faDirectory - faVolumeID, fs) = 0 then begin
        OldestFile := Dir + fs.Name;
        repeat
            inc(Result);
            if FileAge(Dir + fs.Name) < FileAge(OldestFile)  then
                OldestFile := Dir + fs.Name;
        until FindNext(fs) <> 0;
    end;
    FindClose(fs);
end;

var
    sBackupFolder, sBackupFile, formattedDT, sOldestFile: String;
begin
try
    sBackupFolder:= xmlCfg.GetValue('BackupFolder', constDefaultBackupFolder);
    if not CheckBackupFolder(sBackupFolder, sBackupFolder, True) then           //Разворачиваем путь и проверяем что папка существует
        raise Exception.Create(rsCantCreateBackupFolder + sBackupFolder);

    DateTimeToString(formattedDT, strBackupDTformat, Now);                      //Формируем строчку из даты-времени для названия бэкапа
    sBackupFile:= sBackupFolder + strBackupFilePrefix + formattedDT + ExtractFileName(omgDoc.docFilePath);
    if not omgDoc.Save(sBackupFile) then                                        //Сохранение силами класса TOmgDocument
        raise Exception.Create(rsCantCreateBackup + sBackupFile);

    while GetFileCount(sBackupFolder, sOldestFile) > xmlCfg.GetValue('BackupsCount', 5) do
        DeleteFile(sOldestFile);                                                //Пока в папке лишние файлы, удаляем по одному самые старые

except
        on e: Exception do begin
            ErrorLog(e, 'DocumentBackup');
        end;
end;
end;
procedure DocumentClose;
begin
    if omgDoc = nil then Exit;
    omgDoc.Save;
    omgDoc.Close;
    omgDoc.Free;
end;
function DocumentPreOpenXML(Path: String; AlertMsg: Boolean = False): Boolean;
//функция ддолжна попытаться открыть файл XML
//и проверить его на валидность
var
    xmlTemp: TXMLDocument;
begin
    Result:=False;
    try
        try
            xmlTemp:=TXMLDocument.Create(Application);
            xmlTemp.LoadFromFile(Path);
        //    xmlTemp.Options :=[doNodeAutoIndent, doAttrNull, doAutoSave];
        //    xmlTemp.ParseOptions:=[poValidateOnParse];
            xmlTemp.Active:=True;
            xmlTemp.Options :=[doAttrNull];                     //!!!
            if xmlTemp.ChildNodes[strRootNode] <> nil then
                if xmlTemp.ChildNodes[strRootNode].ChildNodes[strHeaderNode] <> nil then
                    if xmlTemp.ChildNodes[strRootNode].ChildNodes[strDataNode] <> nil then
                        Result:=True;
        except
            on e: Exception do begin
                ErrorLog(e, 'DocumentPreOpen', False);       //It's not error, it's bad document
                if AlertMsg then
                    MessageBox(frmAccounts.Handle,
                    PWideChar(Format(rsOpenDocumentError, [frmAccounts.FFileName, e.ClassName])),
                    PWideChar(rsOpenDocumentErrorTitle),
                    MB_APPLMODAL + MB_ICONWARNING);
                Result:=False;
                Exit;
            end;
        end;
    finally
        FreeAndNil(xmlTemp);
    end;
end;
function DocumentPreOpenCrypted(Path: String; TryPass: String; AlertMsg: Boolean = False): Integer;
var
    //H: TCryFileHeader;
    fStream: TFileStream;
    cryHeader: TOmgDocument.TCryFileHeader;
begin
    Result:= idCancel;
    try
        try
            fStream:=nil;
            fStream:=TFileStream.Create(Path, fmOpenRead);
            fStream.ReadBuffer(cryHeader, SizeOf(CryHeader));
            if cryHeader.Magic <> 'OMG!' then
                raise Exception.Create('Wrong file signature');
            if CompareMem(GetHeader(TryPass).Memory, @CryHeader.firstHeader[0], $40) then
                Result:=idOk
            else begin
                Result:=idTryAgain;
                if AlertMsg then
                    MessageBox(frmAccounts.Handle,
                    PWideChar(rsWrongPasswordError),
                    PWideChar(rsWrongPasswordErrorTitle),
                    MB_APPLMODAL + MB_ICONWARNING);
            end;
        except
            on e: Exception do begin
                ErrorLog(e, 'DocumentPreOpenCrypted', False);
                if AlertMsg then
                    MessageBox(frmAccounts.Handle,
                    PWideChar(Format(rsOpenDocumentError, [frmAccounts.FFileName, e.ClassName])),
                    PWideChar(rsOpenDocumentErrorTitle),
                    MB_APPLMODAL + MB_ICONWARNING);
                Result:=idCancel;
                Exit;
            end;
        end;
    finally
        FreeAndNil(fStream);
    end;
end;
function GetAppVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte; // ненужные нам 48 байт
    Minor,Major,Build,Release: word; // а тут версия
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // достаём ресурс
    if s.Size>0 then begin
      s.Read(v,SizeOf(v)); // читаем нужные нам байты
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // вот и версия...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
   s.Free;
  except; end;
end;
procedure ShowOptionsWindow;
var
    tempCfg: TSettings;
begin
    tempCfg:= TSettings.Create;
    tempCfg.Assign(xmlCfg);
    if (not Assigned(frmOptions)) then frmOptions:= TfrmOptions.Create(frmMain, tempCfg);
    if frmOptions.ShowModal = mrOk then
        xmlCfg.Assign(tempCfg);     //Вариант с копированием
//    begin                         //Вариант с присвоением ссылки
//        xmlCfg.Free;
//        xmlCfg:=tempCfg;
//    end else
//        tempCfg.Free;
    tempCfg.Free;
    FreeAndNil(frmOptions);
end;

end.
