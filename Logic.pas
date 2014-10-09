unit Logic;
interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin, ClipBrd, Vcl.Buttons,
	{XML}
	Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
	{MyUnits}
    XMLutils, uFieldFrame, uSmartMethods, uSettings,
    {Themes}
    Styles, Themes
  	;
const
	bShowLogAtStart: Boolean = True;
var
	xmlMain: IXMLDocument;          //�������� ��� ��������
    xmlCfg: TSettings;
    LogList: TStringList;           //���������� ��� �����������
	PageList: IXMLNodeList;      	//������ �������
    intCurrentPage: Integer;    	//������� ���������
    intThemeIndex: Integer;         //����� ��������� ����
    intExpandFlag: Integer;    	    //��������� ���������
    								//0 - ���������� ������
                                    //1 - �������� ��������
	bLogDocked: Boolean;            //����������� �� ��� � ��������� ������
    DragGhostNode: TTreeNode;       //���������� ����
    strCurrentBase: String;
    intTickToExpand: Integer;       //  \
    oldNode: TTreeNode;             //  }�������������� ����� ��� ��������������
    nodeToExpand: TTreeNode;        // /

procedure Log(Val: Integer); overload;
procedure Log(Text: String); overload;
procedure Log(Flag: Boolean); overload;
procedure Log(Text: String; Val: variant); overload;
procedure LoadSettings;
procedure SaveSettings;
procedure LoadThemes;
procedure SetTheme(Theme: String);

procedure SetButtonImg(Button: TSpeedButton; List: TImageList; ImgIndex: Integer);
function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; isNew: Boolean = False) : Boolean;
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
procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean = False);
procedure DragAndDropVisual(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode);
procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);
procedure CloneNode(treeNode: TTreeNode);

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
//������� ��������
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
begin
    if Button is TSpeedButton then begin
        List.GetBitmap(ImgIndex, TSpeedButton(Button).Glyph);
    end;
end;

function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
//������ �������� � ������ � �� �����, ������ �����!
//������ ���� �������� ���� ������� ntItem c ������ Field
var i: Integer;
begin
//��������� ������������ �������� ����
	Log('Start: GeneratePanel(' + GetNodeTitle(nItem) + ' in ' + Panel.Name +')');
    Log('IsEdit', isEdit);
    LogNodeInfo(nItem, 'GeneratePanel');
    //������ ����� � �����������
    Panel.Visible:=False;
    //������ ��������
    CleaningPanel(Panel);
    if GetNodeType(nItem) <> ntItem then begin
    	result:=false;
    	Log('Error: GeneratePanel: ������� ���� �� ���� ntItem!');
        Log('End: GeneratePanel(' + nItem.NodeName + ', ' + Panel.Name +') = ', result);
        Panel.Visible:=True;
        Exit;
    end;
	// � ��������� ���� �� �����
    for i := nItem.ChildNodes.Count -1 downto 0 do
    	GenerateField(nItem.ChildNodes[i], Panel, IsEdit, IsNew);
    Panel.Visible:=True;
    Result:=True;
end;

function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
//������ ��������� ���� � ��������,
//� ���� ������ ���� ������ ���� (ntField)
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
		btnSmart.Tag:=NativeInt(textInfo);		//��-�������!
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
                end;
            end;
        end else begin                                 //����� ��������������
        	case fieldFormat of
                ffPass: begin
        			btnAdditional.Visible:=True;
            		OnResize(nil);
                    btnAdditional.OnClick:= clsSmartMethods.Create.GeneratePass;
                    SetButtonImg(btnAdditional, frmMain.imlField, 5);
                    if isNew then textInfo.Text:=GeneratePassword(10);
                end;
            end;
        SetButtonImg(btnSmart, frmMain.imlField, 4);
        btnSmart.OnClick:= clsSmartMethods.Create.EditField;
        end;
    end;
    //Log('--------------------GenerateField:End');
    Result:=True;
end;

function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
var i: Integer;
tabList: TStringList;
begin
	Log('--------------------ParsePagesToTabs:Start');
    xmlMain.Active:=False;
	xmlMain.Active:=True;
    intExpandFlag:=1;
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
    intExpandFlag:=0;
    Log('--------------------ParsePagesToTabs:End');
end;

procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView);
var RootNode: TTreeNode;
begin
	Log('--------------------ParsePageToTree:Start---------------------------');
    intExpandFlag:=1;
	Tree.Items.Clear;
    RootNode:=Tree.Items.AddChild(nil, GetNodeTitle(PageList[pageIndex]));
    RootNode.Data:=Pointer(PageList[pageIndex]);
	IterateNodesToTree(PageList[pageIndex], RootNode, Tree);
    //log(RootNode.AbsoluteIndex);
    //RootNode.DropTarget:=True;
    RootNode.Expand(False);
    //RootNode.Selected:=True;
    intCurrentPage:= pageIndex;
    intExpandFlag:=0;
    Log('--------------------ParsePageToTree:End-----------------------------');
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
    //���� ���� � ������ �������������� �� ������ ��������� ���������
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
    	msg:='��������!' + #10#13 + '�� ������������� ������ ������� ������ ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?';
    ntFolder:
    	msg:='��������!' + #10#13 + '�� ������������� ������ ������� ����� ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?' +
        					#10#13 + '��� �������� � �������� ���� ��������� ����� � �������!';
    ntPage: begin
    	if PageList.Count = 1 then begin
        	MessageBox(Application.Handle, '������ ������� ��������� ��������!', '�������� ������', MB_ICONINFORMATION);
        	Exit;
        end;
    	msg:='��������!' + #10#13 + '�� ������������� ������ ������� �������� ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?' +
        					#10#13 + '��� �������� � �������� ���� ��������� ����� � �������!!!' +
                            #10#13 + '����������?';
    	end;
    end;
    if not withoutConfirm then
    if MessageBox(Application.Handle, PWideChar(Msg), '�������� ������',
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
    newPageNode.Text:='����_' + DateToStr(now) + '_' + TimeToStr(now);
    newPageNode.SetAttributeNS('type', '', 'page');
    dItem:= newPageNode.AddChild('DefItem');
    dItem.SetAttributeNS('type', '' , 'defitem');
    dItem.SetAttributeNS('picture', '' , 'item');
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', '��������');
    tField.SetAttributeNS('format', '', 'title');
    //tField.Text:='����� ������';
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', '�����');
    tField.SetAttributeNS('format', '', 'text');
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', '������');
    tField.SetAttributeNS('format', '', 'pass');
    tField:= dItem.AddChild('Field');
    tField.SetAttributeNS('name', '', '�����������');
    tField.SetAttributeNS('format', '', 'comment');
    SetNodeTitle(dItem, '����� ������');
    result:=newPageNode;
    //i like spagetti
end;

procedure InsertFolder(treeNode: TTreeNode);
var
	newFolderNode: IXMLNode;
	//newTreeNode: TTreeNode;
begin
	if GetNodeType(IXMLNode(treeNode.Data))=ntItem then begin
        treeNode:=treeNode.Parent;
    end;
    newFolderNode:= IXMLNode(treeNode.Data).AddChild('Folder');
    newFolderNode.Text:='����� �����';
    newFolderNode.SetAttributeNS('type', '', 'folder');
    newFolderNode.SetAttributeNS('picture', '', 'folder');
    if (not treeNode.Expanded) then treeNode.Expand(False);
	With TTreeView(treeNode.TreeView).Items.AddChild(treeNode, '����� �����') do begin
		Data:=Pointer(newFolderNode);
        ImageIndex:=0;
        SelectedIndex:=0;
        //Expanded:=True;             //���������� ��� �������� �����
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
var
	Node: IXMLNode;
begin
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

procedure SetNodeExpanded(treeNode: TTreeNode);
begin
	if intExpandFlag <> 0 then Exit;
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

procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean=False);
//����� ���, ����� ����� ���� �����, �� ����� �������.
var
	selNode, trgNode, newNode: IXMLNode;
begin
    selNode:=IXMLNode(selTreeNode.Data);
	//trgNode:=IXMLNode(trgTreeNode.Data);  //���� ��� �� �����, ������ ���� � ��������
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

    //�����, ������ ��� ��������� ������������� ������
    //  IterateTree ������ �� �����... ���������� � ������...
    {Logic.ParsePageToTree(Logic.intCurrentPage, frmMain.tvMain);
	rootTreeNode:=selTreeNode.Parent;
    while rootTreeNode.Parent<> nil do rootTreeNode:=rootTreeNode.Parent;
    IterateTree(rootTreeNode, Pointer(newNode));}
end;

procedure DragAndDropVisual(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode);
var
//selNode: IXMLNode;
trgNode: IXMLNode;
begin
    if trgTreeNode = DragGhostNode then Exit;
    if DragGhostNode<> nil then frmMain.tvMain.Items.Delete(DragGhostNode);
    if (selTreeNode= nil) or (trgTreeNode=nil) then Exit;
    //selNode:=IXMLNode(selTreeNode.Data);
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
    //��������! � ������� �������� ��������� ������ ����, � �� ���������!
    DragGhostNode.Data:=Pointer(trgNode);
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

procedure LoadSettings;
begin
    xmlCfg:=TSettings.Create('..\..\config.xml');
    frmMain.WindowState:= xmlCfg.GetValue('Window', 0, 'Position');
    if frmMain.WindowState = wsMinimized then frmMain.WindowState:= wsNormal;
    if frmMain.WindowState = wsNormal then begin
        frmMain.SetBounds(xmlCfg.GetValue('Left', 0, 'Position'),
            xmlCfg.GetValue('Top', 0, 'Position'),
            xmlCfg.GetValue('Width', 0, 'Position'),
            xmlCfg.GetValue('Height', 0, 'Position'));
        if Boolean(xmlCfg.GetValue('ShowLog', False)) then frmMain.tbtnLogClick(nil);
    end;
    if xmlCfg.GetValue('Page', 0) < PageList.Count then
        frmMain.tabMain.TabIndex := xmlCfg.GetValue('Page', 0);
    //frmMain.tabMainChange(nil);
    ParsePageToTree(frmMain.tabMain.TabIndex, frmMain.tvMain);

    if xmlCfg.GetValue('Selected', 0, 'Position') < frmMain.tvMain.Items.Count  then
        frmMain.tvMain.Items[xmlCfg.GetValue('Selected', 0, 'Position')].Selected:=True;

    if xmlCfg.GetValue('Theme', 0) < frmMain.mnuThemes.Count  then
        frmMain.mnuThemes.Items[xmlCfg.GetValue('Theme', 0)].Click;

//    if xmlCfg.GetValue('TreeWidth', 0) <> 0 then
        frmMain.tvMain.Width:= xmlCfg.GetValue('TreeWidth', 100);
end;

procedure SaveSettings;
begin
    if xmlCfg = nil then Exit;
    xmlCfg.SetValue('Selected', frmMain.tvMain.Selected.AbsoluteIndex, 'Position');
    if frmMain.WindowState = wsNormal then begin
         xmlCfg.SetValue('Left', frmMain.Left, 'Position');
         xmlCfg.SetValue('Top', frmMain.Top, 'Position');
         xmlCfg.SetValue('Width', frmMain.Width, 'Position');
         xmlCfg.SetValue('Height', frmMain.Height, 'Position');
         xmlCfg.SetValue('ShowLog', BoolToStr(Assigned(frmLog), True));
    end;
    xmlCfg.SetValue('Window', frmMain.WindowState, 'Position');
    xmlCfg.SetValue('Page', intCurrentPage);
    xmlCfg.SetValue('Theme', intThemeIndex);
    xmlCfg.SetValue('TreeWidth', frmMain.tvMain.Width);

    xmlCfg.Save;
end;

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
end;
finally end;
end;

procedure SetTheme(Theme: String);
//����� ����� ����������
begin
  TStyleManager.TrySetStyle(Theme, true);
end;

end.
