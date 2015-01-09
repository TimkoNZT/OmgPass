unit uLog;
interface
uses SysUtils, Classes, Variants, Vcl.Forms, Windows;

var
LogList: TStringList;           //Переменная для логирования

procedure Log(Val: Integer); overload;
procedure Log(Text: String); overload;
procedure Log(Flag: Boolean); overload;
procedure Log(Text: String; Val: variant); overload;
procedure Log(Strs: TStrings); overload;
procedure Log(Arr: array of byte; Count: Integer = 0; Msg: String = ''); overload;
procedure Log(Stream: TStream; Count: Integer = 0; Msg: String = ''); overload;
function ErrorLog(e: Exception; Method: String = ''; isFatal: Boolean = False): Boolean;

implementation
uses uConsole;

{$REGION 'Логирование'}
procedure Log(Text: String);
var myThread: TThread;
begin
	LogList.Add({TimeToStr(Now) +}'> '+ Text);
    if Assigned(frmLog) then begin
        LockWindowUpdate(frmLog.Handle);
	    frmLog.lbLog.Items.Add({TimeToStr(Now) +}'> '+ Text);
    	frmLog.lbLog.ItemIndex:=frmLog.lbLog.Items.Count-1;
        frmLog.StatusBar1.Panels[1].Text:= 'Lines Count: ' + IntToStr(LogList.Count);
        LockWindowUpdate(0);
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
procedure Log(Strs: TStrings);
begin
    LogList.AddStrings(Strs);
    if Assigned(frmLog) then begin
	    frmLog.lbLog.Items.AddStrings(Strs);
    	frmLog.lbLog.ItemIndex:=frmLog.lbLog.Items.Count-1;
        frmLog.StatusBar1.Panels[1].Text:= 'Lines Count: ' + IntToStr(LogList.Count);
    end;
end;
procedure Log(Arr: array of byte; Count: Integer = 0; Msg: String = '');
var
    s: string;
    i, imx: integer;
begin
    if Msg <> '' then begin
        Log('Array: ' + Msg);
        Log('Count:'+ IntToStr(Count) + ', size:' +IntToStr(SizeOf(arr)));
    end;
    if (Count <= 0) or (Count > SizeOf(arr) ) then imx:= SizeOf(arr)
    else imx:= Count;
    if imx > 100 then imx:= 100;
    for i := 0 to imx do s:=s + arr[i].ToHexString(2) + ' ';
    Log(s);
end;
procedure Log(Stream: TStream; Count: Integer = 0; Msg: String = '');
var
    s: string;
    i, imx: integer;
    h: Byte;
    p: Dword;
begin
    p:=Stream.Position;
    Stream.Position:=0;
    if Msg <> '' then begin
        Log('Stream: ' + Msg);
        Log('Count:'+ IntToStr(Count) + ', size:' +IntToStr(Stream.Size));
    end;
    if (Count <= 0) or (Count > Stream.Size) then imx:= Stream.Size
    else imx:=Count;
    if imx > 100 then imx:= 100;
    for i := 0 to imx do begin
            Stream.Read(h, 1);
            s:= s + h.ToHexString(2) + ' ';
    end;
    Stream.Position:=p;
    Log(s);
end;
procedure Log(Text: String; Val: variant);
begin
	Log(Text + ' ' + VarToStr(Val));
end;
function ErrorLog(e: Exception; Method: String = ''; isFatal: Boolean = False): Boolean;
//Логирование ошибок
//Параметр isFatal немедленно завершает программу
begin
    Log('Error : ' + e.ClassName);
    if Method<>'' then Log('    Procedure: ' + Method);
    Log('    Error Message: ' + e.Message);
    Log('    Except Address: ', IntToHex(Integer(ExceptAddr), 8));
    LogList.SaveToFile('log.txt');
    if isFatal then Application.Terminate;
end;
{$ENDREGION}
end.
