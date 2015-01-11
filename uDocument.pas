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
    docFilePath: String;
    docType: tOmgDocType;
    XML: iXMLDocument;
    docPages: IXMLNodeList;
    docPassword: String;
    CurrentPage: Integer;                   //Текущая страничка
    CurrentRecord: Integer;                 //...и запись
private
    curHeader: TCryFileHeader;
    fileStream: TFileStream;
    procedure LoadPosition;
    procedure SavePosition;
    function OpenXMLfromStream(xmlMainStream: TStream): Boolean;
    function OpenCrypted(Password: String): Boolean;
    function SaveCrypted(): Boolean;
public
    constructor Create; overload;
    constructor Create(FilePath: String; Password: String); overload;
    constructor CreateNew(FilePath: String; docType: tOmgDocType; Password: String = '');
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
    procedure SaveAs(FilePath: String; dType: tOmgDocType);

//published
//  	property IsDocEmpty: Boolean read IsEmpty;
end;

implementation
uses uLog, uCrypt;

constructor cOmgDocument.Create;
begin
    //inherited Create;
    XML:=TXMLDocument.Create(nil);
    XML.Options :=[doAttrNull, doAutoSave];
    XML.ParseOptions:=[poValidateOnParse];
end;

constructor cOmgDocument.Create(FilePath: String; Password: String);
begin
    Self.Create;
    if not Self.Open(filePath, Pass) then raise Exception.Create('Error opening file');
end;

constructor cOmgDocument.CreateNew(FilePath: String; docType: tOmgDocType; Password: String = '');
begin
    //
end;

function cOmgDocument.Open(Path: String; Pass: String): Boolean;
begin
try
    fileStream:= TFileStream.Create(Path, fmOpenReadWrite);
    Self.docFilePath:= Path;
    docPassword:=Pass;
    if ExtractFileExt(Path) = strDefaultExt then begin
        Self.OpenXMLfromStream(fileStream);
        docType:= dtXML;
    end else begin
        Self.OpenCrypted(Pass);
        docType:=dtCrypted;
    end;
    XML.Active:=True;
    Result:=True;
    except
        Result:=False;
    end;
end;

function cOmgDocument.OpenXMLfromStream(xmlMainStream: TStream): Boolean;
begin
try
    XML.LoadFromStream(xmlMainStream);
    docPages:= NodeByPath(XML, 'Root|Data').ChildNodes;
    LoadPosition;
    Result:=True;
    except
        on e: Exception do begin
        ErrorLog(e, 'OpenXMLfromStream');
        Result:=False;
    end;
end;
end;

function cOmgDocument.OpenCrypted(Password: String): Boolean;
var
cryStream, xmlStream: TMemoryStream;
begin
    try
        try
            fileStream.Read(curHeader, SizeOf(TCryFileHeader));
            cryStream:=TMemoryStream.Create;
            xmlStream:=TMemoryStream.Create;
            cryStream.CopyFrom(fileStream, fileStream.Size - SizeOf(TCryFileHeader));
            //Log(cryStream, 50, '>');
            UnCryptStream(cryStream, xmlStream, Password, 1024);
            Result:= Self.OpenXmlfromStream(xmlStream);
        except
            on e: Exception do begin
            ErrorLog(e, 'OpenCrypted');
            Result:=False;
            end;
        end;
    finally
        FreeAndNil(cryStream);
        FreeAndNil(xmlStream);
    end;
end;

function cOmgDocument.SaveCrypted(): Boolean;
begin
    //
end;

procedure cOmgDocument.SaveAsCrypted();
var fName: String;
    Header: TCryFileHeader;
    fStream: TFileStream;
    cStream, xStream: TMemoryStream;
begin
    if Self.docType = dtCrypted then Exit; //Already crypted
    try
        fName:=  ChangeFileExt(Self.docFilePath, strCryptedExt);
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

procedure cOmgDocument.SaveAs(FilePath: String; dType: tOmgDocType);
begin
    //
end;

function cOmgDocument.Save: Boolean;
var
    xStream, cStream: TMemoryStream;
begin
    Self.SavePosition;
    xStream:=TMemoryStream.Create; //Position:=0; xmlStream.Size:=0;
    Self.XML.SaveToStream(xStream);
    xStream.Position:=0;
    fileStream.Position:=0;
    if Self.docType = dtCrypted then begin
        cStream:=TMemoryStream.Create;
        fileStream.WriteBuffer(curHeader, sizeOf(TCryFileHeader));
        cryptStream(xStream, cStream, docPassword, $100);
        fileStream.CopyFrom(cStream, cStream.Size);
        fileStream.Size:= cStream.Size + sizeOf(TCryFileHeader);
    end else begin
        xStream.SaveToStream(fileStream);
        fileStream.Size:= xStream.Size;
    end;
end;

function cOmgDocument.Close: Boolean;
begin
    docFilePath:='';
    docType:=dtXML;
    docPages:=nil;
    XML.XML.Clear;
    XML.Active:=False;
    docPassword:='';
    CurrentPage:=0;                   //Текущая страничка
    CurrentRecord:=0;
    ZeroMemory(@curHeader, SizeOf(TCryFileHeader));
    FreeAndNil(fileStream);
end;

destructor cOmgDocument.Destroy;
begin
    //Self.Close;
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
    Result:= (Self.docPages.Count= 0);
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
