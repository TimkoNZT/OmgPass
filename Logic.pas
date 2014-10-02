unit Logic;
interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin, ClipBrd, Vcl.Buttons,
	{XML}
	Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
	{MyUnits}
    XMLutils, uFieldFrame, uSmartMethods
  	;
const
	bShowLogAtStart: Boolean = True;
var
	xmlMain: IXMLDocument;          //Основной наш документ
    LogList: TStringList;           //Переменная для логирования
	PageList: IXMLNodeList;      	//Список страниц
    intCurrentPage: Integer;    	//Текущая страничка
    intProgramState: Integer;    	//Состояние программы
    								//0 - нормальная работа
                                    //1 - загрузка страницы
	bLogDocked: Boolean;            //Пристыкован ли Лог к основному окошку
procedure Log(Val: Integer); overload;
procedure Log(Text: String); overload;
procedure Log(Flag: Boolean); overload;
procedure Log(Text: String; Val: variant); overload;
function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; isNew: Boolean = False) : Boolean;
procedure SetButtonImg(Button: TSpeedButton; ImgIndex: Integer);
function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView);
procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView);
procedure InsertFolder(treeNode: TTreeNode);
procedure EditNode(treeNode: TTreeNode);
function EditItem(var Node: IXMLNode; isNew: Boolean = False): Boolean;
procedure EditNodeTitle(Node: IXMLNode; Title: String);
procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
procedure AddPage();
function CreateClearPage(): IXMLNode;
procedure InsertItem(treeNode: TTreeNode);
procedure SetNodeExpanded(treeNode: TTreeNode);
function GetNodeExpanded(Node: IXMLNode): Boolean;
function GeneratePassword(Len: Integer): String;
function DragDropAccept(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode): Boolean;
procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean = False);
procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);

implementation
uses uMain, uLog, uEditItem, uGenerator;

function GeneratePassword(Len: Integer): String;
begin
   if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(nil);
   frmGenerator.UpDown.Position:=Len;
   frmGenerator.btnGenerateClick(nil);
   Result:= frmGenerator.lblResult.Caption;
   FreeAndNil(frmGenerator);
end;

procedure Log(Text: String);
begin
	LogList.Add({TimeToStr(Now) +}'> '+ Text);
    if Assigned(frmLog) then begin
	    frmLog.lbLog.Items.Add({TimeToStr(Now) +}'> '+ Text);
    	frmLog.lbLog.ItemIndex:=frmLog.lbLog.Items.Count-1;
    end;
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

function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
//Очистка панельки
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

procedure SetButtonImg(Button: TSpeedButton; ImgIndex: Integer);
begin
    if Button is TSpeedButton then begin
        frmMain.imlField.GetBitmap(ImgIndex, TSpeedButton(Button).Glyph);
    end;
end;

function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
//Рисуем панельку с полями и всё такое, важное место!
//Внутрь надо подавать ноду формата ntItem c полями Field
var i: Integer;
begin
//Проверяем корректность входящей ноды
	Log('Start: GeneratePanel(' + GetNodeTitle(nItem) + ' in ' + Panel.Name +')');
    Log('IsEdit', isEdit);
    LogNodeInfo(nItem, 'GeneratePanel');
    //Против лагов в изображении
    Panel.Visible:=False;
    //Чистим панельку
    CleaningPanel(Panel);
    if GetNodeType(nItem) <> ntItem then begin
    	result:=false;
    	Log('Error: GeneratePanel: Входная нода не типа ntItem!');
        Log('End: GeneratePanel(' + nItem.NodeName + ', ' + Panel.Name +') = ', result);
        Panel.Visible:=True;
        Exit;
    end;
	// и разбиваем ноду по полям
    for i := nItem.ChildNodes.Count -1 downto 0 do
    	GenerateField(nItem.ChildNodes[i], Panel, IsEdit, IsNew);
    Panel.Visible:=True;
end;

function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
//Рисуем отдельные поля в панельку,
//У ноды должен быть формат поля (ntField)
var
	fieldFormat: eFieldFormat;
begin
	//Log('--------------------GenerateField:Start');
    LogNodeInfo(nField, 'GenerateField');
    fieldFormat:= GetFieldFormat(nField);
	With TFieldFrame.CreateParented(Panel.Handle) do begin
		Parent:=Panel;
        Align:=alTop;
        lblTitle.Caption:=GetAttribute(nField, 'name');
        if fieldFormat = ffComment then begin
			textInfo.Height:=70;
            textInfo.Multiline:=True;
            //textInfo.ScrollBars:=ssVertical;
            //textInfo.HideScrollBars:=True;
			textInfo{.Lines}.Text:=StringReplace(VarToStr(nField.NodeValue),'|',#13#10,[rfReplaceAll]);
        end else textInfo{.Lines}.Text:=VarToStr(nField.NodeValue);
        textInfo.ReadOnly:=not IsEdit;
		btnSmart.Tag:=NativeInt(textInfo);		//Та-даааааа!
        btnAdditional.Tag:=NativeInt(textInfo);
		textInfo.Tag:=NativeInt(nField);
		Tag:=NativeInt(nField);
        if IsEdit=False then begin
            if LowerCase(GetAttribute(nField, 'button')) = 'false' then
                btnSmart.Enabled:=false
            else
                case fieldFormat of
                ffWeb: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.OpenURL;
                    SetButtonImg(btnSmart, 1);
                end;
                ffMail: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.OpenMail;
                    SetButtonImg(btnSmart, 2);
                end;
                ffFile: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.AttachedFile;
                    SetButtonImg(btnSmart, 3);
                end;
                else begin
                    btnSmart.OnClick:= clsSmartMethods.Create.CopyToClipboard;
                    SetButtonImg(btnSmart, 0);
                end;
            end;
        end else begin                                 //Режим редактирования
        	case fieldFormat of
                ffPass: begin
        			btnAdditional.Visible:=True;
            		OnResize(nil);
                    btnAdditional.OnClick:= clsSmartMethods.Create.GeneratePass;
                    SetButtonImg(btnAdditional, 5);
                    if isNew then textInfo.Text:=GeneratePassword(10);
                end;
            end;
        SetButtonImg(btnSmart, 4);
        btnSmart.OnClick:= clsSmartMethods.Create.EditField;
        end;
    end;
    //Log('--------------------GenerateField:End');
end;

function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
var i: Integer;
tabList: TStringList;
begin
	Log('--------------------ParsePagesToTabs:Start');
    xmlMain.Active:=False;
	xmlMain.Active:=True;
    intProgramState:=1;
    tabList:=TStringList.Create;
	tabControl.Tabs.Clear;
	PageList:= NodeByPath(x, 'Root/Data').ChildNodes;
    for i := 0 to PageList.Count - 1 do begin
		LogNodeInfo(PageList[i]);
		tabList.Add(GetNodeTitle(PageList[i]));
    end;
    tabControl.Tabs:=tabList;
    if intCurrentPage < tabControl.Tabs.Count then
    	tabControl.TabIndex:=intCurrentPage
    else
       	tabControl.TabIndex:=tabControl.Tabs.Count - 1;
    //frmMain.btnAddPage.Left:=tabControl.TabRect(tabControl.Tabs.Count-1).Width + tabControl.TabRect(tabControl.Tabs.Count-1).Left + 3;
    intProgramState:=0;
    Log('--------------------ParsePagesToTabs:End');
end;

procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView);
var RootNode: TTreeNode;
begin
	Log('--------------------ParsePageToTree:Start');
    intProgramState:=1;
	Tree.Items.Clear;
    RootNode:=Tree.Items.AddChild(nil, GetNodeTitle(PageList[pageIndex]));
    RootNode.Data:=Pointer(PageList[pageIndex]);
	IterateNodesToTree(PageList[pageIndex], RootNode, Tree);
    //log(RootNode.AbsoluteIndex);
    //RootNode.DropTarget:=True;
    RootNode.Expand(False);
    RootNode.Selected:=True;
    intCurrentPage:= pageIndex;
    intProgramState:=0;
    Log('--------------------ParsePageToTree:End');
end;

procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView);
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
        IterateNodesToTree(xn.ChildNodes[i], ChildTreeNode, Tree);
        Case GetNodeType(xn.ChildNodes[i]) of
            ntItem: begin
                ChildTreeNode.ImageIndex:=1;
                ChildTreeNode.SelectedIndex:=1;
                ChildTreeNode.DropTarget:=False;
            end;
            ntFolder: begin
                ChildTreeNode.ImageIndex:= 0;
                ChildTreeNode.SelectedIndex:= 0;
                ChildTreeNode.Expanded:=GetNodeExpanded(xn.ChildNodes[i]);
            end;
        end;
    end;
    Log('--------------------IterateNodesToTree:End');
end;

procedure EditNode(treeNode: TTreeNode);
var
	trgNode: IXMLNode;
    //tmpNode: IXMLNode;
begin
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
        end;
    end;
    ntFolder, ntPage:
    	treeNode.EditText;
    end;

end;

function EditItem(var Node: IXMLNode; isNew: Boolean = False): Boolean;
var
	//trgNode: IXMLNode;
    tmpNode: IXMLNode;
begin
	Log('EditItem, isNew=' + BoolToStr(isNew,True));
    LogNodeInfo(Node, 'EditItem:InputNode');
	tmpNode:= Node.CloneNode(True);
    LogNodeInfo(tmpNode, 'EditItem:Temp');
    if (not Assigned(frmEditItem)) then
        frmEditItem:= TfrmEditItem.Create(frmMain, tmpNode, isNew);
    if frmEditItem.ShowModal=mrOK then begin
        Log('frmEditItem: mrOK');
        LogNodeInfo(Node, 'EditItem:OutNode');
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

procedure EditNodeTitle(Node: IXMLNode; Title: String);
begin
	SetNodeTitle(Node, Title);
    case GetNodeType(Node) of
    ntItem:
		GeneratePanel(Node, frmMain.fpMain);
    ntFolder:
		Exit;
    ntPage:
        frmMain.tabMain.Tabs[intCurrentPage]:=Title;
    end;
end;

procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
var
	Msg: String;
    Node: IXMLNode;
begin
	Log('DeleteNode:' + treeNode.Text);
	Node:=IXMLNode(treeNode.Data);
    case GetNodeType(Node) of
    ntItem:
    	msg:='Внимание!' + #10#13 + 'Вы действительно хотите удалить запись ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?';
    ntFolder:
    	msg:='Внимание!' + #10#13 + 'Вы действительно хотите удалить папку ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?' +
        					#10#13 + 'Это приведет к удалению всех вложенных папок и записей!';
    ntPage: begin
    	if PageList.Count = 1 then begin
        	MessageBox(Application.Handle, 'Нельзя удалить последнюю страницу!', 'Удаление записи', MB_ICONINFORMATION);
        	Exit;
        end;
    	msg:='ВНИМАНИЕ!' + #10#13 + 'Вы действительно хотите удалить страницу ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?' +
        					#10#13 + 'Это приведет к удалению всех вложенных папок и записей!!!' +
                            #10#13 + 'Продолжить?';
    	end;
    end;
    if not withoutConfirm then
    if MessageBox(Application.Handle, PWideChar(Msg), 'Удаление записи',
    	 MB_ICONQUESTION + MB_OKCANCEL + MB_DEFBUTTON2)	= ID_CANCEL then Exit;
    Log('Deleting confirmed...');
    Node.ParentNode.ChildNodes.Remove(Node);           //returns thmthng
    if GetNodeType(Node) = ntPage then begin
        ParsePagesToTabs(xmlMain, frmMain.tabMain);
        frmMain.tabMainChange(nil);
    end else treeNode.Delete;
end;

procedure AddPage();
begin
	inc(intCurrentPage);
    PageList.Insert(intCurrentPage, CreateClearPage);
    ParsePagesToTabs(xmlMain, frmMain.tabMain);
    frmMain.tabMainChange(nil);
end;

function CreateClearPage(): IXMLNode;
var
	newPageNode: IXMLNode; //okay?
    dItem: IXMLNode;       //defitem
    tField: IXMLNode;      //tempfield..okay?
begin
    newPageNode:=xmlMain.CreateNode('Page');
    newPageNode.Text:='Лист_' + DateToStr(now) + '_' + TimeToStr(now);
    newPageNode.SetAttributeNS('type', '', 'page');
    dItem:= newPageNode.AddChild('DefItem');
    dItem.SetAttributeNS('type', '' , 'defitem');
    dItem.SetAttributeNS('picture', '' , 'item');
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', 'Название');
    tField.SetAttributeNS('format', '', 'title');
    //tField.Text:='Новая запись';
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', 'Логин');
    tField.SetAttributeNS('format', '', 'text');
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', 'Пароль');
    tField.SetAttributeNS('format', '', 'pass');
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', 'Комментарий');
    tField.SetAttributeNS('format', '', 'comment');
    SetNodeTitle(dItem, 'Новая запись');
    result:=newPageNode;
    //i like spagetti
end;

procedure InsertFolder(treeNode: TTreeNode);
var
	newFolderNode: IXMLNode;
	newTreeNode: TTreeNode;
begin
	if GetNodeType(IXMLNode(treeNode.Data))=ntItem then begin
        treeNode:=treeNode.Parent;
    end;
    newFolderNode:= IXMLNode(treeNode.Data).AddChild('Folder');
    newFolderNode.Text:='Новая папка';
    newFolderNode.SetAttributeNS('type', '', 'folder');
    newFolderNode.SetAttributeNS('picture', '', 'folder');
    if (not treeNode.Expanded) then treeNode.Expand(False);
	With TTreeView(treeNode.TreeView).Items.AddChild(treeNode, 'Новая папка') do begin
		Data:=Pointer(newFolderNode);
        ImageIndex:=0;
        SelectedIndex:=0;
		Selected:=True;
		EditText;
	end;
end;

procedure InsertItem(treeNode: TTreeNode);
var
	i: integer;
	defItem: IXMLNode;
	newItem: IXMLNode;
    destNode: IXMLNode;     //ntFolder;
    newTreeNode: TTreeNode;
begin
	destNode:=IXMLNode(treeNode.Data);
	LogNodeInfo(destNode, 'InsertItem');
	if GetNodeType(destNode) = ntItem then begin
    	destNode:=destNode.ParentNode;
        treeNode:=treeNode.Parent;
    end;
    Log(destNode.NodeName);
	defItem:=PageList[intCurrentPage].ChildNodes.FindNode('DefItem');
	newItem:=destNode.OwnerDocument.CreateNode('Item');
	for i := 0 to defItem.ChildNodes.Count - 1 do
        newItem.ChildNodes.Add(defItem.ChildNodes[i].CloneNode(True));
    for i := 0 to defItem.AttributeNodes.Count - 1 do
        newItem.AttributeNodes.Add(defItem.AttributeNodes[i].CloneNode(True));
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

procedure SetNodeExpanded(treeNode: TTreeNode);
begin
	if intProgramState <> 0 then Exit;
    if treeNode.IsFirstNode then Exit;
	SetAttribute(IXMLNode(treeNode.Data), 'expand',
                BoolToStr(treeNode.Expanded, True));
end;

function GetNodeExpanded(Node: IXMLNode): Boolean;
var
	tmp: String;
begin
	tmp:= GetAttribute(Node, 'expand');
    if tmp='' then
    	result:=False
    else
    	result:=StrToBool(tmp);
end;

function DragDropAccept(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode): Boolean;
var
selNode, trgNode: IXMLNode;
begin
//Пока заглушка, надо разобраться с логикой
//selNode:=IXMLNode(selTreeNode.Data);
//trgNode:=IXMLNode(trgTreeNode.Data);
Result:=True;
end;

procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean=False);
//Попой чую, здесь можно было проще, но проще глючило.
var
	rootTreeNode: TTreeNode;
	selNode, trgNode, newNode: IXMLNode;
begin
    selNode:=IXMLNode(selTreeNode.Data);
	trgNode:=IXMLNode(trgTreeNode.Data);
    newNode:= selNode.CloneNode(True);
    LogNodeInfo(selNode);
    LogNodeInfo(trgNode);
    LogNodeInfo(newNode);
    case GetNodeType(trgNode) of
    ntPage, ntFolder:
    	trgNode.ChildNodes.Add(newNode);
    ntItem:
    	trgNode.ParentNode.ChildNodes.Insert(trgNode.ParentNode.ChildNodes.IndexOf(trgNode), newNode);
    end;
    if not isCopy then selNode.ParentNode.ChildNodes.Remove(selNode);
    Logic.ParsePageToTree(Logic.intCurrentPage, frmMain.tvMain);
	rootTreeNode:=selTreeNode.Parent;
    while rootTreeNode.Parent<> nil do rootTreeNode:=rootTreeNode.Parent;
    IterateTree(rootTreeNode, Pointer(newNode));
end;

procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);
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

end.
