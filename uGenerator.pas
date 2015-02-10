unit uGenerator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Clipbrd,
  Vcl.ImgList,

  Logic, uStrings;

type
  TfrmGenerator = class(TForm)
    GroupBox1: TGroupBox;
    chkCap: TCheckBox;
    chkLett: TCheckBox;
    chkNum: TCheckBox;
    chkSpec: TCheckBox;
    GroupBox2: TGroupBox;
    lblLength: TLabel;
    UpDown: TUpDown;
    txtPassLenght: TEdit;
    chkDntRe: TCheckBox;
    GroupBox3: TGroupBox;
    btnModal: TButton;
    btnClose: TButton;
    btnGenerate: TButton;
    lblResult: TLabel;
    chkDntDouble: TCheckBox;
    chkBadSymbols: TCheckBox;
    chkOwn: TCheckBox;
    txtOwn: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure btnModalClick(Sender: TObject);
    procedure CheckMe(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    function IncString(Index: Integer): String;
    function CheckForExrac(newChar: Char; oldPass: String): Boolean;
    procedure chkDntReClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
private
    { Private declarations }
public
    formType: Integer;            // 0 - по умолчанию модальная форма с кнопкой ОК,
                                  // которая закрывает форму с возвратом mrOK
    { Public declarations }       // 1 - генератор вызван из меню, кнопка копирует
                                  // пароль в буфер обмена
                                  // 2 - форма создана как генератор и
                                  // не отображается пользователю
end;

var
  frmGenerator: TfrmGenerator;

implementation

{$R *.dfm}
var
  ResString: String;
  const ResArray: array [0..3] of  String = ( 'ABCDEFGHIGKLMNOPQRSTUVWXYZ',
                                              'abcdefghijklmnopqrstuvwxyz',
                                              '0123456789',
                                              '!@#$%^&*()"''\\/|~`?<>,.;:{}[]');
  const BadSymbols: array [0..9] of Char = ('1', 'i', 'l', 'I', 'S', '5', 's', '0', 'O', 'o');

procedure TfrmGenerator.btnCloseClick(Sender: TObject);
begin
//frmGenerator.Close;
ModalResult:= mrCancel;
end;
//Сука магия творится здесь
procedure TfrmGenerator.btnGenerateClick(Sender: TObject);
var
    i: Integer;
    Pass: String;
    len: Integer;
    newChar: Char;
begin
i:=0;
lblResult.Caption:= Application.Title;
Pass:='';
CheckMe(nil);
Randomize;
While i < UpDown.Position do
begin
    len:= length(resString);
    if len=0 then begin
        MessageBox(Handle, PWideChar(rsGeneratorError), PWideChar(rsGeneratorErrorTitle), MB_ICONWARNING);
        chkDntRe.Checked:=False;
        btnGenerateClick(nil);
        Exit;
    end;
    NewChar:= ResString[random(len)+1];
    if CheckForExrac(newChar, Pass) then begin
        Pass:=Pass + newChar;
        inc(i);
    end;
end;
lblResult.Caption:= Pass;
end;

procedure TfrmGenerator.btnModalClick(Sender: TObject);
begin
if formType = 0 then begin
  //frmGenerator.Close;
  ModalResult:= mrOK;
end else begin
  Clipboard.asText:=lblResult.Caption;
end;
//Clipboard.AsText:=lblResult.Caption;
end;

//Инициализация базовой строки
//Эта же функция привязана к чекбоксам
procedure TfrmGenerator.CheckMe(Sender: TObject);
Var
  i, j: Integer;
  Sres: String;
begin
Randomize;
ResString:='';
//Логика переключения галок
    chkCap.Enabled:= not chkOwn.Checked;
    chkLett.Enabled:= not chkOwn.Checked;
    chkNum.Enabled:= not chkOwn.Checked;
    chkSpec.Enabled:= not chkOwn.Checked;
    txtOwn.Enabled:= chkOwn.Checked;
//Наращиваем базовую строку в зависимости от выбранных словарей
if chkOwn.Checked then begin
    ResString := txtOwn.Text;
end else begin
    txtOwn.Enabled:= false;
    if chkCap.Checked then ResString := ResString + IncString(0);
    if chkLett.Checked then ResString := ResString + IncString(1);
    if chkNum.Checked then ResString := ResString + IncString(2);
    if chkSpec.Checked then ResString := ResString + IncString(3);
    if chkOwn.Checked then ResString := txtOwn.Text;
end;
if ResString = '' then begin
  MessageBox(Handle, 'Выберите символы для пароля', 'Внимание', MB_ICONWARNING);
  if txtOwn.Text='' then txtOwn.Text:=ResArray[2];
  chkCap.Checked:= True;
  CheckMe(nil);
  Exit;
  //CheckMe(nil);
end;
//Для полной гармонии перемешаем в ней символы, хотя это и не обязательно //
for i:=1 to Length(ResString) do begin                                    //
  j:=random(Length(ResString))+1;                                         //
  Sres:=Sres+ResString[j];                                                //
  Delete(ResString, j, 1);                                                //
end;                                                                      //
ResString:=Sres;                                                          //
//Удалим нечеткие символы если нужно
if chkBadSymbols.Checked then begin
    for i := 0 to Length(BadSymbols) do
    ResString:= StringReplace(ResString, BadSymbols[i], '', [rfReplaceAll]);
end;
end;

procedure TfrmGenerator.chkDntReClick(Sender: TObject);
begin
    chkDntDouble.Enabled:=not chkDntRe.Checked;
end;

procedure TfrmGenerator.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Self.BorderIcons:=[];
    Self.Caption:='';
end;

procedure TfrmGenerator.FormCreate(Sender: TObject);
begin
btnGenerateClick(nil);
end;

procedure TfrmGenerator.FormShow(Sender: TObject);
begin
    WindowsOnTop(bWindowsOnTop, Self);
    if formType = 0 then begin
      btnModal.Caption:=rsOk;
      btnClose.Caption:=rsClose;
    end else begin
      btnModal.Caption:=rsCopy;
      btnClose.Caption:=rsClose;
    end;
end;

{Функция делает длинные строки фиксированной длины для равномерного
распределения символов в паролях независимо от длины строк словаря.
Иначе цифры в паролях получаются реже, чем буквы}
function TfrmGenerator.IncString(Index: Integer): String;
var
  i: Integer;
  len: Integer;
begin
  Randomize;
  result:= '';
  len:= Length(ResArray[Index]);
  for i := 1 to 1024 do result:= result + ResArray[Index][Random(len)+1];
end;

procedure TfrmGenerator.UpDownClick(Sender: TObject; Button: TUDBtnType);
begin
btnGenerateClick(nil);
end;

function TfrmGenerator.CheckForExrac(newChar: Char; oldPass: String): Boolean;
begin
    result:=true;
    if chkDntRe.Checked then begin
        ResString:= StringReplace(ResString, newChar, '', [rfReplaceAll]);
        Exit;
    end;
    if chkDntDouble.Checked then begin
        if oldPass = '' then Exit; 
//        if ResString.Length < 2 then begin
//           MessageBox(Handle, 'Текущий набор символов и настройки несовместимы', 'Внимание', MB_ICONWARNING);
//           Exit;
//        end;
        if oldPass[oldPass.Length] = newChar then result:=false;
    end;
end;

end.
