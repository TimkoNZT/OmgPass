//
//
//События вызываемые по нажатию кнопочек
//
//
unit uSmartMethods;
interface
uses  Windows, SysUtils, ClipBrd, Vcl.Buttons, Vcl.ComCtrls,
	Vcl.Controls, ShellApi,
    mmsystem;

type clsSmartMethods= Class
public
    procedure CopyToClipboard(Sender: TObject);
	procedure OpenURL(Sender: TObject);
	procedure OpenMail(Sender: TObject);
	procedure AttachedFile(Sender: TObject);
    procedure GeneratePass(Sender: TObject);
//    procedure EditField(Sender: TObject);
End;

function GetEditFromTag(Sender: TObject): String;

implementation
{$R sounds.res}

uses uMain, uLog, uGenerator, Logic, uEditField, uEditItem, uCustomEdit;

procedure clsSmartMethods.CopyToClipboard(Sender: TObject);
begin
    try
        if GetEditFromTag(Sender) = '' then Exit;
        Clipboard.Clear;
        Clipboard.AsText:=GetEditFromTag(Sender);
        PlaySound('zoom', hInstance, SND_ASYNC or SND_NODEFAULT or SND_RESOURCE);
    except
        on E : Exception do ErrorLog(e, 'SmartMethodCopyToClipboard');
    end;
end;

procedure clsSmartMethods.OpenURL(Sender: TObject);
var
    url: String;
begin
log(GetEditFromTag(Sender));
    try
        url:= GetEditFromTag(Sender);
        if url = '' then Exit;
        if not ((Pos('www', url) = 1) or
                (Pos('http', url) = 1)) then url:= 'www.' + Url;
        ShellExecute(frmMain.Handle, '', PWideChar(url), nil, nil, SW_SHOW);
        PlaySound('link', hInstance, SND_ASYNC or SND_NODEFAULT or SND_RESOURCE);
    except
        on E : Exception do ErrorLog(e, 'SmartMethodOpenURL');
    end;
end;

procedure clsSmartMethods.OpenMail(Sender: TObject);
begin
    try
        if GetEditFromTag(Sender) = '' then Exit;
        ShellExecute(frmMain.Handle, '', PwideChar('mailto:'+ GetEditFromTag(Sender)), nil, nil, SW_SHOW);
    except
        on E : Exception do ErrorLog(e, 'SmartMethodOpenMail');
    end;
end;

procedure clsSmartMethods.AttachedFile(Sender: TObject);
begin
    //
end;

procedure clsSmartMethods.GeneratePass(Sender: TObject);
begin
    try
        if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(nil);
        if frmGenerator.ShowModal = mrOk then
            TEditMultiline(Pointer((Sender as TSpeedButton).Tag)).Text:= frmGenerator.lblResult.Caption;
    finally
        FreeAndNil(frmGenerator);
    end;
end;

function GetEditFromTag(Sender: TObject): String;
begin
    result:=TEditMultiline(Pointer((Sender as TSpeedButton).Tag)).Text
end;

end.
