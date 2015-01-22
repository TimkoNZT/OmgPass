unit uSettings;

interface

uses
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin,
{XML}
Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

const
    strDefConfigSection = 'Main';
    //strPosConfigSection = 'Position';

type TSettings = class(TPersistent)
private
//    FXMLFilePath: string;
//    FVersion: byte;
    sXML: IXMLDocument;
    RootNode: IXMLNode;
protected
    //
public
    constructor Create(const XMLFilePath: string = 'Config.xml'; RootNodeName: string = 'Config');

    function GetValue(OptionName: String; Default: Variant; Section: String = strDefConfigSection): Variant;
    procedure SetValue(OptionName: String; Value: Variant; Section: String = strDefConfigSection);

    function DeleteSection(SectionName: String = strDefConfigSection): Boolean;
    function DeleteOption(OptionName: String; Section: String = strDefConfigSection): Boolean;
    function ClearSection(SectionName: String = strDefConfigSection): Boolean;

    function HasOption(OptionName: String; Section: String = 'Main'): Boolean;
    function HasSection(Section: String): Boolean;
    procedure Save;
end;

implementation

uses uLog;

constructor TSettings.Create(const XMLFilePath: string = 'Config.xml'; RootNodeName: string = 'Config');
begin
    sXML:=TXMLDocument.Create(nil);
    sXML.Options :=[doNodeAutoIndent, doAttrNull];
    sXML.Active:=True;
    try
        if FileExists(XMLFilePath) then begin
            sXML.LoadFromFile(XMLFilePath);
            RootNode:=sXML.ChildNodes[RootNodeName];
        end else begin
            //sXML.Encoding := 'UTF-8';
            //sXML.Version := '1.0';
            sXML.FileName:= XMLFilePath;
            RootNode:=sXML.Node.AddChild(RootNodename);
        end;
    except
        on e: Exception do ErrorLog(e)
    end;
end;

function TSettings.GetValue(OptionName: String; Default: Variant; Section: String = 'Main'): Variant;
begin
    if (RootNode.ChildNodes.FindNode(Section) = nil) or
    (RootNode.ChildNodes[Section].ChildNodes.FindNode(OptionName) = nil)
        then Result:=Default
    else Result:=RootNode.ChildNodes[Section].ChildValues[OptionName];
end;

procedure TSettings.SetValue(OptionName: String; Value: Variant; section: String = 'Main');
var SectionNode: IXMLNode;
begin
    SectionNode:= RootNode.ChildNodes.FindNode(Section);
    if SectionNode = nil then SectionNode:=RootNode.AddChild(Section);
    if SectionNode.ChildNodes.FindNode(OptionName) = nil then
        SectionNode.AddChild(OptionName);
    RootNode.ChildNodes[Section].ChildValues[OptionName]:=Value;
end;

function TSettings.HasSection(Section: String): Boolean;
begin
    Result:= (RootNode.ChildNodes.FindNode(Section) <> nil);
end;


function TSettings.HasOption(OptionName: String; Section: String = 'Main'): Boolean;
begin
    Result:= (RootNode.ChildNodes.FindNode(Section) <> nil) and
    (RootNode.ChildNodes[Section].ChildNodes.FindNode(OptionName) <> nil);
end;


procedure TSettings.Save;
begin
    sXML.SaveToFile(sXML.FileName);
end;

function TSettings.DeleteSection(SectionName: String = strDefConfigSection): Boolean;
begin
    if RootNode.ChildNodes.FindNode(SectionName) = nil then Exit;
    Result:= (RootNode.ChildNodes.Remove(RootNode.ChildNodes.FindNode(SectionName)) <> -1);
end;

function TSettings.ClearSection(SectionName: String = strDefConfigSection): Boolean;
begin
    if RootNode.ChildNodes.FindNode(SectionName) = nil then Exit;
    RootNode.ChildNodes.FindNode(SectionName).ChildNodes.Clear;
end;

function TSettings.DeleteOption(OptionName: String; Section: String = strDefConfigSection): Boolean;
begin
    if not HasOption(OptionName, Section) then Exit;
    Result:= (RootNode.ChildNodes[Section].ChildNodes.Remove
    (
        RootNode.ChildNodes[Section].ChildNodes.FindNode(OptionName)
    ) <> -1)
end;
end.
