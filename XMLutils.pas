unit XMLutils;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xmldom, XMLIntf, msxmldom, XMLDoc, ComCtrls, TypInfo, StrUtils,
  uStrings;
type eNodeType = (ntRoot, ntHeader, ntData,
					ntPage, ntFolder, ntDefFolder,
                    ntItem, ntDefItem, ntField, ntNone);
type eFieldFormat = (ffTitle, ffText, ffPass, ffWeb, ffComment, ffDate, ffMail, ffFile, ffNone);

function GetBaseTitle(x:IXMLDocument): String;
function NodeByPath(x:IXMLDocument; const fNodePath: String): IXMLNode;
function GetNodeType(Node: IXMLNode): eNodeType;
function GetFieldFormat(Field: IXMLNode): eFieldFormat;
function GetAttribute(Node: IXMLNode; attrName: String): String;
function SetAttribute(Node: IXMLNode; attrName: String; attrValue: String): Boolean;
function RemoveAttribute(Node: IXMLNode; attrName: String) : Boolean;
function GetNodeTitle(Node:IXMLNode): String;
function SetNodeTitle(Node:IXMLNode; Title: String): Boolean;
procedure LogNodeInfo(Node: IXMLNode; Msg: String='');
function GetNodeValue(Node: IXMLNode): String;
function SetNodeValue(Node: IXMLNode; Value: String): Boolean;


    type
    TTreeToXML = Class
    private
        FDOC: TXMLDocument;
        FRootNode: IXMLNode;
        FTree: TTreeView;
        procedure IterateRoot;
        procedure WriteNode(N: TTreeNode; ParentXN: IXMLNode);
    Public
        Constructor Create(Tree: TTreeView);
        Procedure SaveToFile(const fn: String);
        Destructor Destroy; override;
    End;

    TXMLToTree = Class
    private
        FTree: TTreeView;
        //FNodeList: TNodeList;
        Procedure IterateNodes(xn: IXMLNode; ParentNode: TTreeNode);
    Public
        Procedure XMLToTree(Tree: TTreeView; Const Doc: IXMLDocument);
        Procedure XMLFileToTree(Tree: TTreeView; const FileName: String);
        Procedure XMLStreamToTree(Tree: TTreeView; Const FileStream: TStream);
        //Function XMLNodeFromTreeText(const cText: string): IXMLNode;
    End;

implementation
uses Logic;

{$REGION 'TTreeToXML'}
    { TTreeToXML }

        constructor TTreeToXML.Create(Tree: TTreeView);
           begin
             FTree := Tree;
             FDOC := TXMLDocument.Create(nil);
             FDOC.Options := FDOC.Options + [doNodeAutoIndent];
             FDOC.Active := true;
             FDOC.Encoding := 'UTF-8';
             FRootNode := FDOC.CreateElement('Treeview', '');
             FDOC.DocumentElement := FRootNode;
             IterateRoot;
           end;

           Procedure TTreeToXML.WriteNode(N: TTreeNode; ParentXN: IXMLNode);
           var
             CurrNode: IXMLNode;
             Child: TTreeNode;
           begin
             CurrNode := ParentXN.AddChild(N.Text);
             CurrNode.Attributes['NodeLevel'] := N.Level;
             CurrNode.Attributes['Index'] := N.Index;
             Child := N.getFirstChild;
             while Assigned(Child) do
             begin
               WriteNode(Child, CurrNode);
               Child := Child.getNextSibling;
             end;
           end;

           Procedure TTreeToXML.IterateRoot;
           var
             N: TTreeNode;
           begin
             N := FTree.Items[0];
             while Assigned(N) do
             begin
               WriteNode(N, FRootNode);
               N := N.getNextSibling;
             end;
           end;

           procedure TTreeToXML.SaveToFile(const fn: String);
           begin
             FDOC.SaveToFile(fn);
           end;

           destructor TTreeToXML.Destroy;
           begin
             if Assigned(FDOC) then
               FDOC.Free;

             inherited;
           end;

{$ENDREGION}

{$REGION 'TXMLToTree'}
    { TXMLToFree }


        Procedure TXMLToTree.XMLFileToTree(Tree: TTreeView; const FileName: String);
            var
                FileStream : TFileStream;
            begin
                try
                    FileStream := TFileStream.Create(FileName, fmOpenReadWrite);
                except
                    FileStream := TFileStream.Create(FileName, fmOpenRead);
                end;
                try
                    XMLStreamToTree(Tree, FileStream);
                finally
                    FileStream.Free;
                end;
            end;

            Procedure TXMLToTree.XMLToTree(Tree: TTreeView; Const Doc: IXMLDocument);
            begin
              FTree:= Tree;
              try IterateNodes(Doc.DocumentElement, FTree.Items.AddFirst(nil, Doc.DocumentElement.NodeName));
              finally end;
            end;

            Procedure TXMLToTree.XMLStreamToTree(Tree: TTreeView; Const FileStream: TStream);
            var
                Doc: TXMLDocument;
            begin
                Doc := TXMLDocument.Create(Application);
                try
                    Doc.LoadFromStream(FileStream, xetUTF_8);
                    Doc.Active := true;
                    XMLToTree(Tree, Doc);
                finally
                    Doc.Free;
                end;
            end;

            Procedure TXMLToTree.IterateNodes(xn: IXMLNode; ParentNode: TTreeNode);
            var
              ChildTreeNode: TTreeNode;
              i: Integer;
            begin
                For i := 0 to xn.ChildNodes.Count - 1 do
                begin
                    ChildTreeNode := FTree.Items.AddChild(ParentNode, xn.ChildNodes[i].NodeName);
                    if xn.IsTextElement then ChildTreeNode.Text:=xn.Text;

                    IterateNodes(xn.ChildNodes[i], ChildTreeNode);
                end;
                for i := 0 to xn.AttributeNodes.Count - 1 do
                begin
                    ChildTreeNode := FTree.Items.AddChild(ParentNode, xn.AttributeNodes[i].NodeName);
                    ChildTreeNode.ImageIndex:=1;
                    ChildTreeNode.SelectedIndex:=1;
                end;
            end;


    //function TXMLToTree.XMLNodeFromTreeText(const cText: string): IXMLNode;
    //var LCount: Integer;
    //    LList: TPointerList;
    //    i:integer;
    //begin
    //  LCount:= FNodeList.Count;
    //  LList :=FNodeList.List;
    //  for i := 0 to LCount - 1 do
    //    begin
    //      if PNodeRecord(LList[i])^.TrNode.Text=cText then
    //        begin
    //          Result:=PNodeRecord(LList[i])^.XMLNode;
    //          break;
    //        end;
    //    end;
    //end;
{$ENDREGION}
function GetNodeValue(Node: IXMLNode): String;
begin
    result:='';
	case GetNodeType(Node) of
    ntNone:
    	Exit;
    ntField: begin
		result:=VarToStr(Node.NodeValue);
    	end;
	else
    	result:= GetNodeTitle(Node);
    end;
end;


function SetNodeValue(Node: IXMLNode; Value: String): Boolean;
begin
    result:=False;
	case GetNodeType(Node) of
    ntNone:
    	Exit;
    ntField: begin
		Node.NodeValue:=Value;
    	end;
	else
    	SetNodeTitle(Node, Value);
    end;
    result:=True;
end;

function GetBaseTitle(x:IXMLDocument): String;
begin
	result:= NodeByPath(x, 'Root\Header\Title').Text;
end;

function GetNodeTitle(Node:IXMLNode): String;
//Возвращает строковое имя ноды
//Использовать для ntPage, ntFolder, ntItem
var i: Integer;
begin
	case GetNodeType(Node) of
    ntNone:
    	result:='';
    ntField:
    	result:=VarToStr(Node.Attributes['name']);
	ntItem,
    ntDefItem:
        for i := 0 to Node.ChildNodes.Count - 1 do begin
        	if GetFieldFormat(Node.ChildNodes[i]) = ffTitle then
            	result:=Node.ChildNodes[i].Text;
                Exit;
    	end;
    ntPage,
    ntFolder,
    ntDefFolder: begin
    if Node.ChildNodes[0].NodeType = ntText then
        result:=Trim(VarToStr(Node.ChildNodes['#text'].NodeValue))
    else
    	result:='Undefined'
    end;
    end;
end;

function SetNodeTitle(Node:IXMLNode; Title: String): Boolean;
var i: Integer;
begin
	Log('SetNodeTitle');
    case GetNodeType(Node) of
    ntField:
    	SetAttribute(Node, 'name', Title);
    ntItem,
    ntDefItem:
        for i := 0 to Node.ChildNodes.Count - 1 do begin
        	if GetFieldFormat(Node.ChildNodes[i]) = ffTitle then
            Node.ChildNodes[i].Text:=Title;
            Result:=True;
            Exit;
    	end;
    ntFolder,
    ntDefFolder,
    ntPage: begin
		LogNodeInfo(Node, 'OldInfo');
		if Node.ChildValues['#text'] = Null then
        	Node.ChildNodes.Insert(0, Node.OwnerDocument.
            CreateNode(Title, ntText))
		else Node.ChildValues['#text']:= Title;
        LogNodeInfo(Node, 'NewInfo:');
    	end;
    end;
    result:=True;
end;

function NodeByPath(x:IXMLDocument; const fNodePath: String): IXMLNode;
//Отладочная функция
//Возвращает ноду через путь к ней.
//Путь задается через разделители (. \ | /)
//Цифра в скобках указывает индекс атрибута с таким именем
//Примерно так Node:=NodeByPath(MyXML, 'Root\Header\Owner')
// или так 'Root.Data'
//Возвращает nil если не найдет путь.
var
	fNode: IXMLNode;
	pth: TStringList;
begin
	pth:= TStringList.Create();
    //  -Зачем тебе гроб 2х2?
    //  -А захочу так лягу, или вот так лягу..
    pth.AddStrings(fNodePath.Split(['\', '/', '|', '.']));
    fNode:= x.Node;
    while pth.Count<>0 do begin
        fNode:=fNode.ChildNodes[pth[0]];
        pth.Delete(0);
    end;
    pth.Free;
	result:=fNode;
end;

function GetNodeType(Node: IXMLNode): eNodeType;
//Возвращает тип ноды в виде перечисления (Корень, Заголовок, Папка, Данные,
// Запись, Поле)
begin
	//result:=eNodeType(AnsiIndexStr(GetAttribute(Node, 'type'), arrNodeTypes));
    result:=eNodeType(AnsiIndexStr(LowerCase(Node.NodeName), arrNodeTypes));
    //Log('GetNodeType(' + Node.NodeName +') = ', GetEnumName(TypeInfo(eNodeType), Ord(result)));
end;

function GetFieldFormat(Field: IXMLNode): eFieldFormat;
//Возвращает формат поля в виде перечисления eFieldFormat (Заголовок, Текст, Пароль и т.д.)
begin
	result:=eFieldFormat(AnsiIndexStr(GetAttribute(Field, 'format'), arrFieldFormats));
    //Log('GetFieldFormat(' + Field.NodeName +') = ', GetEnumName(TypeInfo(eFieldFormat), Ord(result)));
end;

function GetAttribute(Node: IXMLNode; attrName: String): String;
begin
	//Log('GetAttribute('+ Node.NodeName + ',' + attrName + ')');
	//Log(Node.NodeName + ' всего атрибутов:' , Node.AttributeNodes.Count);
  	//Log(Node.NodeName + ' имеет атрибут ' + attrName + ':', Node.HasAttribute(attrName));
	result:=VarToStr(Node.Attributes[attrName]);
    //Log('GetAttribute('+ Node.NodeName + ',' + attrName + ') =', result);
    //LogNodeInfo(Node, 'GetAttribute');
end;

function SetAttribute(Node: IXMLNode; attrName: String; attrValue: String): Boolean;
begin
    	Node.Attributes[attrName]:=attrValue;
        result:=True;
end;

function RemoveAttribute(Node: IXMLNode; attrName: String) : Boolean;
var
    attr: iXMLNode;
begin
    attr:= Node.AttributeNodes.FindNode(attrName);
    if attr <> nil then begin
        Node.AttributeNodes.Remove(attr);
        result:=True;
    end else result:= False;
end;

procedure LogNodeInfo(Node: IXMLNode; Msg: String='');
var isTVal: iXMLnode;
Vl: String;
begin
isTVal:= Node.ChildNodes.FindNode('#text');
if isTVal <> nil then Vl:=VarToStr(Node.ChildNodes['#text'].NodeValue);
Log(Msg + ': NodeInfo: Title= ' + GetNodeTitle(Node) + ':');
Log('       Value= ' +  Vl);
Log('       Type= ' + GetEnumName(TypeInfo(eNodeType), Ord(GetNodeType(Node))));
Log('       @=' + IntToStr(NativeInt(Node)));
Log('       BasicType=' + GetEnumName(TypeInfo(TNodeType), Ord(Node.NodeType)));
Log('       Childs= ' + IntToStr(Node.ChildNodes.Count));
Log('       isTextElem= ' + BoolToStr(Node.IsTextElement, True));
//Log(Msg + ': NodeInfo: Title= ' + GetNodeTitle(Node) + ':' +
// 	', Value= ' +  Vl +
//   	', Type= ' + GetEnumName(TypeInfo(eNodeType), Ord(GetNodeType(Node))) +
//    ', @=' + IntToStr(NativeInt(Node)) +
//
//    ', BasicType=' + GetEnumName(TypeInfo(TNodeType), Ord(Node.NodeType)) +
//	', Childs= ' + IntToStr(Node.ChildNodes.Count) +
//    ', isTextElem= ' + BoolToStr(Node.IsTextElement, True));
end;

end.

