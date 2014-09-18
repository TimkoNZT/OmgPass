unit uAccounts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VCLTee.TeCanvas, VCLTee.TeePenDlg, Vcl.StdCtrls, Vcl.CategoryButtons,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ComCtrls, Vcl.Mask, Unit1, Vcl.DBCtrls;

type
  TfrmAccounts = class(TForm)
    btnNext: TSpeedButton;
    lblInfo: TLabel;
    pcWizard: TPageControl;
    TabSheet1: TTabSheet;
    tabOpen: TTabSheet;
    TabSheet3: TTabSheet;
    RadioButton3: TRadioButton;
    radNewBase: TRadioButton;
    radOpenBase: TRadioButton;
    btnCancel: TSpeedButton;
    txtOpenBase: TRichEdit;
    txtOpenPass: TRichEdit;
    Label1: TLabel;
    btnOpenBase: TSpeedButton;
    Label3: TLabel;
    SpeedButton4: TSpeedButton;
    Label4: TLabel;
    Label5: TLabel;
    RadioButton4: TRadioButton;
    radOpenDefault: TRadioButton;
    lblDefaultExt: TLabel;
    lblRecentFiles: TLabel;
    lblRecentFile1: TLabel;
    lblRecentFile2: TLabel;
    lblRecentFile3: TLabel;
    Label10: TLabel;
    RadioButton1: TRadioButton;
    OpenDialog: TOpenDialog;
    btnNewBase: TSpeedButton;
    txtNewBase: TRichEdit;
    Label2: TLabel;
    lblPassConfirm: TLabel;
    CheckBox1: TCheckBox;
    RichEdit6: TRichEdit;
    chkShowPass: TCheckBox;
    btnGeneratePass: TSpeedButton;
    txtNewPass: TEdit;
    txtPassConfirm: TEdit;
    SaveDialog: TSaveDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNextClick(Sender: TObject);
    procedure radOpenBaseClick(Sender: TObject);
    procedure radNewBaseClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tabOpenShow(Sender: TObject);
    procedure lblDefaultExtClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkShowPassClick(Sender: TObject);
    procedure btnOpenBaseClick(Sender: TObject);
    procedure btnNewBaseClick(Sender: TObject);
    procedure btnGeneratePassClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  intNextPage: Integer = 1;          //Номер страницы для кнопки Далее
  frmAccounts: TfrmAccounts;
  const infoText: array[0..4] of string =  ('Что вы хотите сделать?',
                                            'Открытие файла базы паролей',
                                            'Создание новой базы паролей',
                                            'Работа в облаке',
                                            'Резервные копии');
  currentDatabase: String = 'Default.opwd';

implementation

{$R *.dfm}

uses uMain, uGenerator;

procedure TfrmAccounts.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//Application.Terminate;
end;

procedure TfrmAccounts.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//CanClose:=False;
end;

procedure TfrmAccounts.lblDefaultExtClick(Sender: TObject);
begin
radOpenDefault.Checked:=True;
end;

//Радиокнопки через переменную указывают на выбираемую страницу
procedure TfrmAccounts.radOpenBaseClick(Sender: TObject);
begin
    intNextPage:=1;
end;

procedure TfrmAccounts.radNewBaseClick(Sender: TObject);
begin
    intNextPage:=2;
end;

//Обработка страницы открытия базы tsOpen
procedure TfrmAccounts.tabOpenShow(Sender: TObject);
begin
if not True then begin     // Посмотреть в настройках недавние файлы
  lblRecentFiles.Visible:=True;
  lblRecentFile1.Visible:=True;
  lblRecentFile2.Visible:=True;
  lblRecentFile3.Visible:=True;
  end;

end;

//Кнопка Далее, или ОК, возвращение модального результата
procedure TfrmAccounts.btnGeneratePassClick(Sender: TObject);
begin
if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(Self);
//frmGenerator.formType:= 0;
if frmGenerator.ShowModal = mrOk then begin
  txtNewPass.Text:= frmGenerator.lblResult.Caption;
  txtPassConfirm.Text:= frmGenerator.lblResult.Caption;
end;
FreeAndNil(frmGenerator);
end;

procedure TfrmAccounts.btnNewBaseClick(Sender: TObject);
begin
If not SaveDialog.Execute then Exit;
txtNewBase.Text:=SaveDialog.FileName;
end;

procedure TfrmAccounts.btnNextClick(Sender: TObject);
begin

case pcWizard.ActivePageIndex of
0:begin
    lblInfo.Caption:=infoText[intNextPage];
    btnCancel.Caption:='Назад';
    btnNext.Caption:='OK';
    pcWizard.ActivePageIndex:=intNextPage;
    end;
1: frmAccounts.Close;
2: frmAccounts.Close;
end;

end;

procedure TfrmAccounts.btnOpenBaseClick(Sender: TObject);
begin
if not openDialog.Execute then Exit;
txtOpenBase.Text:=OpenDialog.FileName;

end;

procedure TfrmAccounts.chkShowPassClick(Sender: TObject);
begin
txtPassConfirm.Visible:= not chkShowPass.Checked;
lblPassConfirm.Visible:= not chkShowPass.Checked;
if chkShowPass.Checked then begin
  txtPassConfirm.PasswordChar:= #0;
  txtNewPass.PasswordChar:= #0;
end else begin
  txtPassConfirm.PasswordChar:= #35;
  txtNewPass.PasswordChar:= #35;
end;

end;

// Кнопка назад, если назад некуда, то закрытие формы
procedure TfrmAccounts.btnCancelClick(Sender: TObject);
begin
if pcWizard.ActivePageIndex = 0 then Close
else begin
    lblInfo.Caption:=infoText[0];
    btnCancel.Caption:='Отмена';
    btnNext.Caption:='Далее';
    pcWizard.ActivePageIndex:=0;
end;
end;

end.
