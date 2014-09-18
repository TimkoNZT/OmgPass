unit VersionUtils;
interface
uses
    SysUtils, Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

const ACTUALVERSION: String = '1.0';

function UpgradeVersion(i: IXMLDocument): Boolean;
function CheckVersion(i: IXMLDocument): Boolean;
function GetVersion(i: IXMLDocument): String;

implementation

function CheckVersion(i: IXMLDocument): Boolean;
begin
	result:= GetVersion(i) = ACTUALVERSION
{$REGION '#Old'} //Версия самостоятельного обновления
    //    if GetVersion(i) = CURRENTVERSION then
    //    	result:= True
    //    else
    //    	result:= UpgradeVersion(i);
{$ENDREGION}
end;

function UpgradeVersion(i: IXMLDocument): Boolean;
begin
	result:=False;
	if GetVersion(i) = '1.0' then begin
    	//Обновление до 0.9
        //Exit             //Неудача
    end;
    if GetVersion(i) = '0.9' then begin
    	//Обновление до след и т д до последней...
    end;
    if GetVersion(i) = ACTUALVERSION then result:=True;
end;

function GetVersion(i: IXMLDocument): String;
begin
    result:=i.DocumentElement.Attributes['version'];
end;

end.
