unit Logic;
interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin, ClipBrd, Vcl.Buttons,
	{XML}
	Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
	{MyUnits}
    XMLutils, uFieldFrame, uSmartMethods
  	;
var
	PageList: IXMLNodeList;      	//Список страниц
    intCurrentPage: Integer;    	//Текущая страничка
    intProgramState: Integer;    	//Состояние программы
    								//0 - нормальная работа
                                    //1 - загрузка страницы

function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False) : Boolean;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False) : Boolean;
procedure SetButtonImg(Button: TSpeedButton; ImgIndex: Integer);
function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView);
procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView);
procedure InsertFolder(treeNode: TTreeNode);
procedure EditItem(treeNode: TTreeNode);
procedure EditNodeTitle(Node: IXMLNode; Title: String);
procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
procedure AddPage();
function CreateClearPage(): IXMLNode;
procedure InsertItem(treeNode: TTreeNode);
procedure SetNodeExpanded(treeNode: TTreeNode);
function GetNodeExpanded(Node: IXMLNode): Boolean;

implementation
uses uMain, uEditItem;

function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
//Очистка панельки
var
	i: Integer;
begin
	if realCln then
	    while Panel.ControlCount <> 0 do
    		Panel.Controls[0].Free
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

function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False) : Boolean;
//Рисуем панельку с полями и всё такое, важное место!
//Внутрь надо подавать ноду формата ntItem c полями Field
var i: Integer;
begin
//Проверяем корректность входящей ноды
	Log('Start: GeneratePanel(' + nItem.NodeName + ', ' + Panel.Name +')');
    LogNodeInfo(nItem, 'GeneratePanel');
    //Чистим панельку
    CleaningPanel(Panel);
    if GetNodeType(nItem) <> ntItem then begin
    	result:=false;
    	Log('Error: GeneratePanel: Входная нода не типа ntItem!');
        Log('End: GeneratePanel(' + nItem.NodeName + ', ' + Panel.Name +') = ', result);
        Exit;
    end;
    //Против лагов в изображении
    Panel.Visible:=False;
	// и разбиваем ноду по полям
    for i := nItem.ChildNodes.Count - 1 downto 0  do begin
        GenerateField(nItem.ChildNodes[i], Panel, IsEdit);
    end;
    Panel.Visible:=True;
    result:=True;
end;

function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False) : Boolean;
//Рисуем отдельные поля в панельку,
//У ноды должен быть формат поля (ntField)
var
	fieldFormat: eFieldFormat;
begin
	//Log('--------------------GenerateField:Start');
    //LogNodeInfo(nField, 'GenerateField');
    fieldFormat:= GetFieldFormat(nField);
	With TFieldFrame.CreateParented(Panel.Handle) do begin
		Parent:=Panel;
        Align:=alTop;
        lblTitle.Caption:=GetAttribute(nField, 'name');
        if fieldFormat = ffComment then begin
			textInfo.Height:=60;
            textInfo.ScrollBars:=ssVertical;
            textInfo.HideScrollBars:=True;
			textInfo.Lines.Text:=StringReplace(VarToStr(nField.NodeValue),'|',#13#10,[rfReplaceAll]);
        end else textInfo.Lines.Text:=VarToStr(nField.NodeValue);
        textInfo.ReadOnly:=not IsEdit;
		btnSmart.Tag:=NativeInt(textInfo);		//Та-даааааа!
        btnAdditional.Tag:=LongInt(textInfo);
		textInfo.Tag:=Long(nField);
		Tag:=LongInt(nField);

        if IsEdit=False then begin
            if UpperCase(GetAttribute(nField, 'button')) = 'FALSE' then
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
        end else begin
        	case fieldFormat of
                ffPass: begin
        			btnAdditional.Visible:=True;
            		OnResize(nil);
                    btnAdditional.OnClick:= clsSmartMethods.Create.GeneratePass;
                    SetButtonImg(btnAdditional, 5);
                end
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
    log(RootNode.AbsoluteIndex);
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

procedure EditItem(treeNode: TTreeNode);
var
	TrgNode: IXMLNode;
begin
	if treeNode.Data = nil then Exit;
    if TTreeView(treeNode.TreeView).IsEditing then begin
    		TTreeView(treeNode.TreeView).Selected.EndEdit(False);
            Log('EditItem: EndEdit');
            Exit;
    end;
    TrgNode:= IXMLNode(treeNode.Data);
    LogNodeInfo(TrgNode, 'EditItem');
	case GetNodeType(TrgNode) of
    ntItem: begin
        if (not Assigned(frmEditItem)) then frmEditItem:= TfrmEditItem.Create(frmMain);
        GeneratePanel(TrgNode, frmEditItem.fpEdit, True);
        frmEditItem.Hide;
        frmEditItem.ShowModal;
        FreeAndNil(frmEditItem);
    end;
    ntFolder:
    	Exit;
    ntPage:
    	treeNode.EditText;
    end;

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
	if GetNodeType(IXMLNode(treeNode.Data))=ntItem then Exit;
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
	destNode.ChildNodes.Add(newItem);
	if (not treeNode.Expanded) then treeNode.Expand(False);
    with TTreeView(treeNode.TreeView).Items.AddChild(treeNode, GetNodeTitle(newItem)) do begin
        Data:= Pointer(newItem);
        ImageIndex:=1;
        SelectedIndex:=1;
        Selected:=True;
        EditText;
    end;

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

end.
