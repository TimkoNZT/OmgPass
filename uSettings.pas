unit uSettings;

interface

uses
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin,
{XML}
Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

type TSettings = class(TPersistent)
private
//    FXMLFilePath: string;
//    FVersion: byte;
    sXML: IXMLDocument;
    RootNode: IXMLNode;
protected
    //
public
    constructor Create(const XMLFilePath: string; RootNodeName: string = 'Config');
    function GetValue(OptionName: String; Default: Variant; Section: String = 'Main'): Variant;
    procedure SetValue(OptionName: String; Value: Variant; Section: String = 'Main');
    procedure Save;
end;

implementation

constructor TSettings.Create(const XMLFilePath: string; RootNodeName: string = 'Config');
begin
    sXML:=TXMLDocument.Create(nil);
    sXML.Options :=[doNodeAutoIndent, doAttrNull, doAutoSave];
    sXML.Active:=True;
    if FileExists(XMLFilePath) then begin
    	sXML.LoadFromFile(XMLFilePath);
        RootNode:=sXML.ChildNodes[RootNodeName];
    end else begin
        sXML.Encoding := 'UTF-8';
        sXML.Version := '1.0';
        sXML.FileName:= XMLFilePath;
        RootNode:=sXML.Node.AddChild(RootNodename);
    end;
end;

function TSettings.GetValue(OptionName: String; Default: Variant; Section: String = 'Main'): Variant;
begin
    if (RootNode.ChildNodes.FindNode(Section) = nil)
    or (RootNode.ChildNodes[Section].ChildNodes.FindNode(OptionName) = nil)
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

procedure TSettings.Save;
begin
    sXML.SaveToFile(sXML.FileName);
end;

end.
