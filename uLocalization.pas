unit uLocalization;

interface
uses
Windows, Messages,Menus, StdCtrls, SysUtils, Variants, Classes, Controls, Forms,
 Generics.Collections, Buttons, ComCtrls, StrUtils, Vcl.ExtCtrls,
{XML}
Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

type TLocalization = class
    private const
        RootNodeName = 'Language';
        HeadNodeName = 'Header';
        FormsNodeName = 'Forms';
        StringsNodeName = 'Strings';
        HintSuffix = 'Hint';
        SelfCaptionName = 'FormCaption';
        strDefaultLanguageName = 'By default (English)';
        strDefaultLanguageSName = 'Default';
    public type TLanguage = class
        Name: string;
        ShortName: string;
        Author: string;
        FileName: string;
        Date: string;
        Version: string;
        public
            constructor Create(Name: String = strDefaultLanguageName;
                                shortName: String = strDefaultLanguageSName); overload;
    end;
    private
        LocXML: IXMLDocument;
        RootNode: iXMLNode;
        HeadNode: iXMLNode;
        FormsNode: iXMLNode;
        StringsNode: iXMLNode;
        FLanguages: TList<TLanguage>;
        FCurLanguage: TLanguage;
        constructor Create; overload;
        //FFileList: TDictionary <string, string>;
        function ListLanguages(LocFolderPath: string): TList<TLanguage>;
        function ValidateLanguageXML(XML: IXMLDocument): boolean;
        function GetLanguage(LocFileName: string): TLanguage;
        procedure ApplyLanguage;
    protected
    //
    public
        //constructor Create(const XMLLocFilePath: string); overload;
        constructor Create(LocFolderPath: string); overload;
        property Languages: TList<TLanguage> read FLanguages;
        property CurrentLanguage: TLanguage read FCurLanguage write FCurLanguage;
        function Strings(StringId: string; Default: string): string;
        function SetLanguage(ByShortName: string): boolean; overload;
        function SetLanguage(ByIndex: integer): boolean; overload;
        function FindLanguage(lngShortName: string): Integer;
        function HaveTranslation(FormName: String; ComponentName: String): Boolean;
        function GetTranslation(FormName: String; ComponentName: String): String;
        procedure TranslateForm(Form: TForm);
    //published
        //
end;

implementation

uses uLog;
constructor TLocalization.TLanguage.Create(Name: String = strDefaultLanguageName;
                                shortName: String = strDefaultLanguageSName);
begin
    Self.Name:= Name;
    Self.ShortName:=shortName;
    Self.FileName:= 'Default.xml';
end;
constructor TLocalization.Create();
begin
    inherited Create;
    LocXML:=TXMLDocument.Create(nil);
    LocXML.Options :=[doNodeAutoIndent, doAttrNull];
    LocXML.Active:=True;
end;

constructor TLocalization.Create(LocFolderPath: string);
begin
    Self.Create;
    if ExtractFileDrive(LocFolderPath) = '' then
        //LocFolderPath := ExtractFilePath(Application.ExeName) + LocFolderPath;
        LocFolderPath:= ExpandFileName(LocFolderPath);
    LocFolderPath := IncludeTrailingPathDelimiter(LocFolderPath);
    if not DirectoryExists(LocFolderPath) then raise Exception.Create('Directory not found: ' + LocFolderPath);
    FLanguages:= ListLanguages(LocFolderPath);
    Log('Languages found: ', Flanguages.Count);
end;

function TLocalization.ListLanguages(LocFolderPath: string): TList<TLanguage>;
var
    fs: TSearchRec;
    tempLng: TLanguage;
begin
    Result:= TList<TLanguage>.Create;
//    Result.Add(TLanguage.Create());                                             //язык по умолчанию
    if FindFirst(LocFolderPath + '*.xml', faAnyFile - faDirectory, fs) = 0 then repeat
        tempLng:= GetLanguage(LocFolderPath + fs.Name);
        if tempLng<> nil then Result.Add(tempLng);
    until FindNext(fs) <> 0;
    FindClose(fs);
end;

function TLocalization.GetLanguage(LocFileName: String): TLanguage;
var
    tXML: IXMLDocument;
    HeaderNode: IXMLNode;                                                       //temporary xml
begin
    Result:= TLanguage.Create;
    tXML:=TXMLDocument.Create(nil);
    tXML.LoadFromFile(LocFileName);
    tXML.Active:=True;
    if ValidateLanguageXML(tXML) then begin;
        HeaderNode:= tXML.ChildNodes[RootNodeName].ChildNodes[HeadNodeName];
        Result.Name:= HeaderNode.ChildNodes['Name'].Text;
        Result.ShortName:= HeaderNode.ChildValues['SName'];
        Result.Author:= HeaderNode.ChildNodes['Author'].Text;
        Result.Date:= HeaderNode.ChildNodes['Date'].Text;
        Result.Version:= HeaderNode.ChildNodes['Version'].Text;
        Result.FileName:= LocFileName;
    end else FreeAndNil(Result);
    tXML._Release;
end;

function TLocalization.SetLanguage(ByShortName: string): boolean;
var
    Lang: TLanguage;
begin
    Result:= False;
    for Lang in fLanguages do
        if Lang.ShortName = ByShortName then
            Result:= SetLanguage(Languages.IndexOf(Lang));
end;

function TLocalization.SetLanguage(ByIndex: integer): boolean;
begin
    Result:= (ByIndex < FLanguages.Count);
    if Result then begin
        FCurLanguage:= FLanguages[ByIndex];
        ApplyLanguage;
    end;
end;

procedure TLocalization.ApplyLanguage;
begin
    //if Languages.IndexOf(FCurLanguage) = 0 then Exit;
    LocXML.LoadFromFile(FCurLanguage.FileName);
    RootNode:= LocXML.ChildNodes[RootNodeName];
    HeadNode:= LocXML.ChildNodes[RootNodeName].ChildNodes[HeadNodeName];
    FormsNode:= LocXML.ChildNodes[RootNodeName].ChildNodes[FormsNodeName];
    StringsNode:= LocXML.ChildNodes[RootNodeName].ChildNodes[StringsNodeName];
end;

function TLocalization.ValidateLanguageXML(XML: IXMLDocument): boolean;
begin;
    Result:=True;
    //Result:= (XML.Node.NodeName = RootNodeName);
    //Result:= Result and (XML.ChildNodes[RootNodeName].ChildNodes.First.NodeName = HeaderNodeName);
    //
end;

function TLocalization.Strings(StringId: string; Default: string): string;
begin
    if (StringsNode.ChildNodes.FindNode(StringId) = nil)
        then Result:=Default
    else Result:= StringReplace(StringsNode.ChildValues[StringId], '|', sLineBreak, [rfReplaceAll] );
end;

function TLocalization.FindLanguage(lngShortName: string): integer;
var
    tempLng: TLanguage;
begin
    Result:=-1;
    for tempLng in FLanguages do begin
        if tempLng.ShortName = lngShortName then
            Result:= FLanguages.IndexOf(tempLng);
    end;
end;

procedure TLocalization.TranslateForm(Form: TForm);
var
    i: integer;
    Com: TComponent;
begin
    if HaveTranslation(Form.Name, SelfCaptionName) then
        Form.Caption:= GetTranslation(Form.Name, SelfCaptionName);
    for i := 0 to Form.ComponentCount - 1 do begin
        Com:= Form.Components[i];
        if (Com is TMenuItem) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TMenuItem).Caption:= GetTranslation(Form.Name, Com.Name);
        if (Com is TCheckBox) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TCheckBox).Caption:= GetTranslation(Form.Name, Com.Name);
        if (Com is TLabel) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TLabel).Caption:= StringReplace(GetTranslation(Form.Name, Com.Name), '|', sLineBreak, [rfReplaceAll]);
        if (Com is TEdit) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TEdit).Text:= GetTranslation(Form.Name, Com.Name);
        if (Com is TButtonedEdit) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TButtonedEdit).Text:= GetTranslation(Form.Name, Com.Name);
        if (Com is TTabSheet) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TTabSheet).Caption:= GetTranslation(Form.Name, Com.Name);
        if (Com is TStaticText) then
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TStaticText).Caption:= GetTranslation(Form.Name, Com.Name);
        if (Com is TSpeedButton) then begin
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TSpeedButton).Caption:= GetTranslation(Form.Name, Com.Name);
            if HaveTranslation(Form.Name, Com.Name + HintSuffix) then
                (Com as TSpeedButton).Hint:= GetTranslation(Form.Name, Com.Name + HintSuffix);
        end;
        if (Com is TButton) then begin
            if HaveTranslation(Form.Name, Com.Name) then
                (Com as TButton).Caption:= GetTranslation(Form.Name, Com.Name);
            if HaveTranslation(Form.Name, Com.Name + HintSuffix) then
                (Com as TButton).Hint:= GetTranslation(Form.Name, Com.Name + HintSuffix);
        end;
    end;
end;

function TLocalization.HaveTranslation(FormName: String; ComponentName: String): Boolean;
begin
    Result:= (FormsNode.ChildNodes.FindNode(FormName) <> nil) and
    (FormsNode.ChildNodes[FormName].ChildNodes.FindNode(ComponentName) <> nil);
end;

function TLocalization.GetTranslation(FormName: String; ComponentName: String): String;
begin
    Result:=VarToStr(FormsNode.ChildNodes[FormName].ChildValues[ComponentName]);
end;

end.
