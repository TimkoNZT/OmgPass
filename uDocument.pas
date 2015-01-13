unit uDocument;
interface

uses SysUtils, Windows, Classes, XMLIntf, XMLDoc, uStrings, XMLUtils;

type TOmgDocument = class
    type tOmgDocType = (dtUnknown, dtXML, dtCrypted);
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
    EmptyXML: AnsiString = '<?xml version="1.0" encoding="UTF-8"?>'
                  + CrLf + '<Root><Header/><Data/></Root>';
var
    docFilePath: String;
    docType: tOmgDocType;
    XML: iXMLDocument;
    docPages: IXMLNodeList;
    CurrentPage: Integer;                   //Текущая страничка
    CurrentRecord: Integer;                 //...и запись
private
    docHeader: TCryFileHeader;
    docPassword: String;
    fileStream: TFileStream;
    procedure LoadPosition;
    procedure SavePosition;
    function OpenXMLfromStream(xmlMainStream: TStream): Boolean;
    function OpenCrypted(Password: String): Boolean;
    function SaveCrypted(): Boolean;
public
    constructor Create; overload;
    constructor Create(FilePath: String; Password: String); overload;
    constructor CreateNew(FilePath: String; dType: tOmgDocType; Password: String = ''); overload;
    destructor Destroy; override;
    function Open(Path: String; Password: String): Boolean;
    function OpenByPass(FilePath: String): Boolean;
    function Save: Boolean;
    function Close: Boolean;
    function GetProperty(PropertyName: String; DefValue: Variant): Variant;
    function SetProperty(PropertyName: String; Value: Variant): Boolean;
    function IsEmpty: Boolean;
    class function CreateHeader(sPassword: String): TCryFileHeader;
    procedure SaveAsCrypted;
    procedure SaveAs(FilePath: String; dType: tOmgDocType);
    function CheckThisPassword(Password: String): Boolean;
    function ChangePassword(Password: String): Boolean;
end;

implementation
uses uLog, uCrypt;

constructor TOmgDocument.Create;
begin
    //inherited Create;
    XML:=TXMLDocument.Create(nil);
    XML.Options :=[doAttrNull, doAutoSave];
    XML.ParseOptions:=[poValidateOnParse];
end;

constructor TOmgDocument.Create(FilePath: String; Password: String);
begin
    Self.Create;
    if not Self.Open(filePath, Password) then raise Exception.Create('Error opening file');
end;

constructor TOmgDocument.CreateNew(filePath: String; dType: tOmgDocType; Password: String = '');
//var
//    fStream: TFileStream;
begin
try
    Self.Create;
    fileStream:= TFileStream.Create(FilePath, fmOpenReadWrite or fmCreate);
    Self.docFilePath:= filePath;
    Self.docType:= dType;
    if dType = dtCrypted then begin
        docPassword:=Password;
        docHeader:=CreateHeader(Password);
    end;
    XML.LoadFromXML(EmptyXML);
    XML.Active:=True;
except
    on e: Exception do ErrorLog(e, 'Document.CreateNew');
end;
end;

function TOmgDocument.Open(Path: String; Password: String): Boolean;
begin
try
    fileStream:= TFileStream.Create(Path, fmOpenReadWrite);
    Self.docFilePath:= Path;
    docPassword:=Password;
    if ExtractFileExt(Path) = strDefaultExt then begin
        Self.OpenXMLfromStream(fileStream);
        docType:= dtXML;
    end else begin
        Self.OpenCrypted(Password);
        docType:=dtCrypted;
    end;
    XML.Active:=True;
    Result:=True;
    except
        Result:=False;
    end;
end;

function TOmgDocument.OpenXMLfromStream(xmlMainStream: TStream): Boolean;
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

function TOmgDocument.OpenCrypted(Password: String): Boolean;
var
cryStream, xmlStream: TMemoryStream;
begin
    try
        try
            fileStream.Read(docHeader, SizeOf(TCryFileHeader));
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

function TOmgDocument.SaveCrypted(): Boolean;
begin
    //
end;

procedure TOmgDocument.SaveAsCrypted();
var fName: String;
    Header: TCryFileHeader;
    fStream: TFileStream;
    cStream, xStream: TMemoryStream;
begin
    if Self.docType = dtCrypted then Exit; //Already crypted
    try
        fName:=  ChangeFileExt(Self.docFilePath, strCryptedExt);
        Header:= TOmgDocument.CreateHeader(String.Empty);
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

procedure TOmgDocument.SaveAs(FilePath: String; dType: tOmgDocType);
begin
    //
end;

function TOmgDocument.Save: Boolean;
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
        fileStream.WriteBuffer(docHeader, sizeOf(TCryFileHeader));
        cryptStream(xStream, cStream, docPassword, $100);
        fileStream.CopyFrom(cStream, cStream.Size);
        fileStream.Size:= cStream.Size + sizeOf(TCryFileHeader);
    end else begin
        xStream.SaveToStream(fileStream);
        fileStream.Size:= xStream.Size;
    end;
end;

function TOmgDocument.Close: Boolean;
begin
    docFilePath:='';
    docType:=dtXML;
    docPages:=nil;
    XML.XML.Clear;
    XML.Active:=False;
    docPassword:='';
    CurrentPage:=0;                   //Текущая страничка
    CurrentRecord:=0;
    ZeroMemory(@docHeader, SizeOf(TCryFileHeader));
    FreeAndNil(fileStream);
end;

destructor TOmgDocument.Destroy;
begin
    //Self.Close;
    inherited Destroy;
end;

procedure TOmgDocument.LoadPosition;
begin
    Self.CurrentPage:= Self.GetProperty('SelectedPage', 0);
    Self.CurrentRecord:= Self.GetProperty('Selected', 0);
end;

procedure TOmgDocument.SavePosition;
begin
    Self.SetProperty('SelectedPage', Self.CurrentPage);
    Self.SetProperty('Selected', Self.CurrentRecord);
end;

function TOmgDocument.IsEmpty: Boolean;
begin
    Result:= (Self.docPages.Count= 0);
end;

class function TOmgDocument.CreateHeader(sPassword: String): TCryFileHeader;
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

function TOmgDocument.CheckThisPassword(Password: String): Boolean;
begin
    try
        Result:= CompareMem(GetHeader(Password).Memory, @docHeader.firstHeader[0], $40);
    except
        on e: Exception do ErrorLog(e, 'CheckPassword');
    end;
end;

function TOmgDocument.ChangePassword(Password: String): Boolean;
begin
try
    Self.docHeader:=CreateHeader(Password);
    Self.docPassword:=Password;
    Self.Save;
except
    on e: Exception do ErrorLog(e, 'ChangePassword');
end;
end;

function TOmgDocument.OpenByPass(FilePath: String): Boolean;
var
    tempStream: TFileStream;
    cStream, xStream: TMemoryStream;
begin
try
    tempStream:= TFileStream.Create(FilePath, fmOpenReadWrite);
    tempStream.Read(docHeader, SizeOf(TCryFileHeader));
    cStream:=TMemoryStream.Create;
    xStream:=TMemoryStream.Create;
    cStream.CopyFrom(tempStream, tempStream.Size - SizeOf(TCryFileHeader));
    UnCryptStreamByKey(cStream, xStream, docHeader.secondHeader, $400);
    Result:= Self.OpenXmlfromStream(xStream);
    docFilePath:=ChangeFileExt(FilePath, strDefaultExt);
    fileStream:= TFileStream.Create(docFilePath, fmCreate);
    docType:=dtXML;
    Self.Save;
    XML.Active:=True;
    except
        on e: exception do begin ErrorLog(e, 'Document.OpenByPass');
        Result:=False;
        end;
    end;
end;
{$REGION '#DocProperty'}
function TOmgDocument.GetProperty(PropertyName: String; DefValue: Variant): Variant;
//Установка и чтение свойств документа
//Все свойства хранятся в ntHeader
//Функции удаления нет.. нужна
begin
if (xml.ChildNodes[strRootNode].ChildNodes.FindNode(strHeaderNode) = nil)
or (xml.ChildNodes[strRootNode].ChildNodes[strHeaderNode].ChildNodes.FindNode(PropertyName) = nil)
        then Result:=DefValue
    else Result:=xml.ChildNodes[strRootNode].ChildNodes[strHeaderNode].ChildValues[PropertyName];;
end;
function TOmgDocument.SetProperty(PropertyName: String; Value: Variant): Boolean;
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
