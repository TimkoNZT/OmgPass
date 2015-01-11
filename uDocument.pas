unit uDocument;
interface

uses SysUtils, Windows, Classes, XMLIntf, XMLDoc, uStrings, XMLUtils;

type cOmgDocument = class
    type tOmgDocType = (dtXML, dtCrypted);
    type TCryFileHeader = record
        Magic: array[0..3] of AnsiChar;
        docVersion: Byte;
        rsrvdByte1: Byte;
        rsrvdByte2: Byte;
        rsrvdByte3: Byte;
        firstHeader: array[0..$3F] of Byte;
        secondHeader: array[0..63] of Byte;
    end;
const
    ActualDocVersion: Byte = 1;
    cryMagicSig: String = 'OMG!';
var
    FilePath: String;
    DocumentType: tOmgDocType;
    XML: iXMLDocument;
    Pages: IXMLNodeList;
    docPassword: String;
    CurrentPage: Integer;                   //Текущая страничка
    CurrentRecord: Integer;                 //...и запись
private
    fileStream: TFileStream;
    //xmlStream: TMemoryStream;
    //cryStream: TMemoryStream;
    procedure LoadPosition;
    procedure SavePosition;
    function OpenXMLfromStream(xmlMainStream: TStream): Boolean;
    function OpenCrypted(Password: String): Boolean;
    function SaveCrypted(): Boolean;
public
    constructor Create;
    destructor Destroy; override;
    function Open(Path: String; Pass: String): Boolean;
    //static function Enrypt(_in: TStream, _out:)
    function Save: Boolean;
    function Close: Boolean;
    function GetProperty(PropertyName: String; DefValue: Variant): Variant;
    function SetProperty(PropertyName: String; Value: Variant): Boolean;
    function IsEmpty: Boolean;
    class function CreateHeader(sPassword: String): TCryFileHeader;
    procedure SaveAsCrypted;
//published
//  	property IsDocEmpty: Boolean read IsEmpty;
end;

implementation
uses uLog, uCrypt;

constructor cOmgDocument.Create;
begin
    inherited Create;
    XML:=TXMLDocument.Create(nil);
    XML.Options :=[doAttrNull, doAutoSave];
    XML.ParseOptions:=[poValidateOnParse];
end;

function cOmgDocument.Open(Path: String; Pass: String): Boolean;
begin
try
    fileStream:= TFileStream.Create(Path, fmOpenReadWrite);
    Self.FilePath:= Path;
    if ExtractFileExt(Path) = strDefaultExt then begin
        Self.OpenXMLfromStream(fileStream);
        DocumentType:= dtXML;
    end else begin
        Self.OpenCrypted(Pass);
        DocumentType:=dtCrypted;
    end;
    Result:=True;
    except
        Result:=False;
    end;
end;

function cOmgDocument.OpenXMLfromStream(xmlMainStream: TStream): Boolean;
begin
try
    XML.LoadFromStream(xmlMainStream);
    Pages:= NodeByPath(XML, 'Root|Data').ChildNodes;
    LoadPosition;
    Result:=True;
    except
        on e: Exception do begin
        ErrorLog(e, 'DocumentOpen');
        Result:=False;
    end;
end;
end;

function cOmgDocument.OpenCrypted(Password: String): Boolean;
var
cryHeader: TCryFileHeader;
cryStream, xmlStream: TMemoryStream;
begin
    try
        fileStream.Read(cryHeader, SizeOf(cryHeader));
        cryStream:=TMemoryStream.Create;
        xmlStream:=TMemoryStream.Create;
        cryStream.CopyFrom(fileStream, fileStream.Size - SizeOf(cryHeader));
        Log(cryStream, 50, '>');
        UnCryptStream(cryStream, xmlStream, Password, 1024);
        Self.OpenXmlfromStream(xmlStream);
    finally
        FreeAndNil(cryStream);
        FreeAndNil(xmlStream);
    end;
end;

function cOmgDocument.SaveCrypted(): Boolean;
begin
    //
end;

procedure cOmgDocument.SaveAsCrypted;
var fName: String;
    Header: TCryFileHeader;
    fStream: TFileStream;
    cStream, xStream: TMemoryStream;
begin
    try
        if Self.DocumentType = dtCrypted then Exit; //Already crypted
        fName:=  ChangeFileExt(Self.FilePath, strCryptedExt);
        Header:= cOmgDocument.CreateHeader(String.Empty);
        fStream:=TFileStream.Create(fName, fmOpenWrite or fmCreate);
        xStream:=TMemoryStream.Create;
        cStream:=TMemoryStream.Create;
        fStream.Write(Header, SizeOf(Header));
        XML.SaveToStream(xStream);
        CryptStream(xStream, cStream, String.Empty, $100);
        fStream.CopyFrom(cStream, cStream.Size);
    finally
        FreeAndNil(fStream);
        FreeAndNil(xStream);
        FreeAndNil(cStream);
    end;
end;

function cOmgDocument.Save: Boolean;
var
    xmlStream: TMemoryStream;
begin
    Self.SavePosition;
    //XML.Active:=False;
    xmlStream:=TMemoryStream.Create; //Position:=0; xmlStream.Size:=0;
    Self.XML.SaveToStream(xmlStream);
    xmlStream.Position:=0;
    fileStream.Position:=0;
    if Self.DocumentType = dtCrypted then begin
        //
    end else begin
        //fileStream.CopyFrom(xmlStream, xmlStream.Size);
        xmlStream.SaveToStream(fileStream);
        fileStream.Size:= xmlStream.Size;
    end;
end;

function cOmgDocument.Close: Boolean;
begin
    //Self.Save;
//    FreeAndNil(xmlStream);
//    FreeAndNil(cryStream);
    FreeAndNil(fileStream);
end;

destructor cOmgDocument.Destroy;
begin
    XML._Release;
//    xmlStream.Free;
//    cryStream.Free;
    inherited Destroy;
end;

procedure cOmgDocument.LoadPosition;
begin
    Self.CurrentPage:= Self.GetProperty('SelectedPage', 0);
    Self.CurrentRecord:= Self.GetProperty('Selected', 0);
end;

procedure cOmgDocument.SavePosition;
begin
    Self.SetProperty('SelectedPage', Self.CurrentPage);
    Self.SetProperty('Selected', Self.CurrentRecord);
end;

function cOmgDocument.IsEmpty: Boolean;
begin
    Result:= (Self.Pages.Count= 0);
end;

class function cOmgDocument.CreateHeader(sPassword: String): TCryFileHeader;
var
    Head: TCryFileHeader;
    Data: array of byte;
begin
    with Result do begin
        Magic:= 'OMG!';
        rsrvdByte1:=$00;
        rsrvdByte2:=$00;
        rsrvdByte3:=$00;
        docVersion := ActualDocVersion;
        getHeader(sPassword).ReadBuffer(firstHeader, $40);
        getSecondHeader(sPassword).ReadBuffer(secondHeader, $40);
//        Log(firstHeader, 0, 'HirstHeader');
//        Log(secondHeader, 0, 'SecondHeader');
    end;
end;

{$REGION '#DocProperty'}
function cOmgDocument.GetProperty(PropertyName: String; DefValue: Variant): Variant;
//Установка и чтение свойств документа
//Все свойства хранятся в ntHeader
//Функции удаления нет.. нужна
begin
if (xml.ChildNodes[strRootNode].ChildNodes.FindNode(strHeaderNode) = nil)
or (xml.ChildNodes[strRootNode].ChildNodes[strHeaderNode].ChildNodes.FindNode(PropertyName) = nil)
        then Result:=DefValue
    else Result:=xml.ChildNodes[strRootNode].ChildNodes[strHeaderNode].ChildValues[PropertyName];;
end;
function cOmgDocument.SetProperty(PropertyName: String; Value: Variant): Boolean;
var hNode: IXMLNode;
begin
    hNode:= xml.ChildNodes[strRootNode].ChildNodes.FindNode(strHeaderNode);
    if hNode = nil then
        hNode:=xml.ChildNodes[strRootNode].AddChild(strHeaderNode);
    if hNode.ChildNodes.FindNode(PropertyName) = nil then
        hNode.AddChild(PropertyName);
    hNode.ChildValues[PropertyName]:=Value;
end;
{$ENDREGION}

end.
