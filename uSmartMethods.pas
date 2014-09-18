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
    procedure EditField(Sender: TObject);
End;

function GetEditFromTag(Sender: TObject): String;

implementation
uses uMain, uGenerator;

procedure clsSmartMethods.CopyToClipboard(Sender: TObject);
begin
	//Beep();
	Clipboard.Clear;
	Clipboard.AsText:=GetEditFromTag(Sender);
    log(Clipboard.AsText, (Sender as TSpeedButton).Tag);
	sndPlaySound('..\..\Sounds\Zoom2.wav', SND_ASYNC or SND_NODEFAULT);
end;
procedure clsSmartMethods.OpenURL(Sender: TObject);
begin
log(GetEditFromTag(Sender));
	try
    ShellExecute(frmMain.Handle, 'open', PwideChar(GetEditFromTag(Sender)), nil, nil, SW_SHOW);
    sndPlaySound('..\..\Sounds\Link2.wav', SND_ASYNC or SND_NODEFAULT );
    except
    on E : Exception do
    MessageBox(frmMain.Handle, PWideChar(E.ClassName+' поднята ошибка, с сообщением : '+E.Message), 'Ошибка выполнения', MB_ICONERROR);
    end;
end;
procedure clsSmartMethods.OpenMail(Sender: TObject);
begin
	try
    ShellExecute(frmMain.Handle, '', PwideChar('mailto:'+ GetEditFromTag(Sender)), nil, nil, SW_SHOW);
    except
    on E : Exception do
      MessageBox(frmMain.Handle, PWideChar(E.ClassName+' поднята ошибка, с сообщением : '+E.Message), 'Ошибка выполнения', MB_ICONERROR);
    end;
end;
procedure clsSmartMethods.AttachedFile(Sender: TObject);
begin
    //
end;
procedure clsSmartMethods.GeneratePass(Sender: TObject);
begin
    if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(nil);
	if frmGenerator.ShowModal = mrOk then begin
  	TRichEdit(Pointer((Sender as TSpeedButton).Tag)).Lines.Text:= frmGenerator.lblResult.Caption;
end;
FreeAndNil(frmGenerator);
end;
procedure clsSmartMethods.EditField(Sender: TObject);
begin
    //
end;
function GetEditFromTag(Sender: TObject): String;
begin
    result:=TRichEdit(Pointer((Sender as TSpeedButton).Tag)).Lines.Text
end;

end.
