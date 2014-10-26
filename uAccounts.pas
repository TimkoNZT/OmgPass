unit uAccounts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  StdCtrls, Vcl.CategoryButtons,
  Vcl.ExtCtrls, Vcl.Buttons, ComCtrls, Vcl.DBCtrls, Vcl.Tabs, Vcl.ImgList,
  Vcl.Imaging.pngimage;

type
  TfrmAccounts = class(TForm)
    pcAccounts: TPageControl;
    tsNew: TTabSheet;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    txtPassConfirm: TEdit;
    lblPassConfirm: TLabel;
    Label4: TLabel;
    txtNewBase: TRichEdit;
    txtNewPass: TEdit;
    Label2: TLabel;
    chkShowPass: TCheckBox;
    CheckBox1: TCheckBox;
    tsOpen: TTabSheet;
    imlAccounts: TImageList;
    lvFiles: TListView;
    Label1: TLabel;
    chkShowMainPass: TCheckBox;
    Label6: TLabel;
    btnGeneratePass: TSpeedButton;
    btnNewBase: TSpeedButton;
    Image1: TImage;
    txtPass: TEdit;
    btnClose: TButton;
    btnOK: TButton;
    Memo1: TMemo;
    lblNoFiles: TStaticText;
    Image2: TImage;
    constructor Create(AOwner: TComponent; isChange: Boolean = False); reintroduce;
    procedure btnNextClick(Sender: TObject);
    procedure chkShowPassClick(Sender: TObject);
    procedure btnNewBaseClick(Sender: TObject);
    procedure btnGeneratePassClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure chkShowMainPassClick(Sender: TObject);
    procedure lvFilesClick(Sender: TObject);
private
    fIsChange: Boolean;
    procedure CleanFiles;
//    FShowHoriz: Boolean;
//    FShowVert: Boolean;
//    FListViewWndProc: TWndMethod;
//    procedure ListViewWndProc(var Msg: TMessage);

public
    FFileName: String;
    FPassword: String;
end;
var
    frmAccounts: TfrmAccounts;

implementation

{$R *.dfm}

uses uMain, uGenerator, Logic, uSettings, uStrings;

constructor TfrmAccounts.Create(AOwner: TComponent; isChange: Boolean = False);
begin
inherited Create (AOwner);
fIsChange :=IsChange;
if isChange then begin
    Self.Caption:= Application.Title + ' - '+ rsFrmAccountsCaption;
    btnClose.Caption:=rsCancel;
    btnOK.Caption:=rsOK;
end else begin
    Self.Caption:=Application.Title + ' - '+ rsFrmAccountsCaption;
    btnClose.Caption:=rsExit;
    btnOK.Caption:=rsOpen;
end;
end;

procedure TfrmAccounts.FormCreate(Sender: TObject);
var i: Integer;
begin
CleanFiles;
for i := 1 to Integer(xmlCfg.GetValue('Count', '0', 'Files')) do begin
       lvFiles.AddItem(xmlCfg.GetValue('File_' + IntToStr(i), '', 'Files'), nil);
end;
if lvFiles.Items.Count = 0 then begin
    lblNoFiles.Visible:=True;
    lblNoFiles.Alignment:=taCenter;
end else lvFiles.Items[0].Selected:=True;

if lvFiles.Items.Count > 5 then
    lvFiles.Column[0].Width:=(lvFiles.ClientRect.Width - 20);

Logic.SetButtonImg(btnNewBase, imlAccounts, 34);
Logic.SetButtonImg(btnGeneratePass, imlAccounts, 1);

end;

procedure TfrmAccounts.CleanFiles;
begin
    lvFiles.Items.Clear;
    lblNoFiles.Visible:=False;
end;

procedure TfrmAccounts.FormShow(Sender: TObject);
begin
WindowsOnTop(bWindowsOnTop, Self);
txtPass.SetFocus;
end;

procedure TfrmAccounts.lvFilesClick(Sender: TObject);
begin
if lvFiles.Items.Count <> 0 then
    lvFiles.Items[0].Selected:=True;
end;

//Кнопка Далее, или ОК, возвращение модального результата
procedure TfrmAccounts.btnCloseClick(Sender: TObject);
begin
if not fIsChange then begin
    frmMain.WindowState:=wsMinimized;
end;
Self.ModalResult:=mrCancel;
end;

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
  Self.Close;
end;

procedure TfrmAccounts.btnOKClick(Sender: TObject);
begin
FFileName:=lvFiles.Selected.Caption;
Self.ModalResult:=mrOK;
end;

procedure TfrmAccounts.chkShowMainPassClick(Sender: TObject);
begin
chkShowPass.Checked:= chkShowMainPass.Checked;
end;

procedure TfrmAccounts.chkShowPassClick(Sender: TObject);
begin
chkShowMainPass.Checked:= chkShowPass.Checked;
txtPassConfirm.Visible:= not chkShowPass.Checked;
lblPassConfirm.Visible:= not chkShowPass.Checked;
if chkShowPass.Checked then begin
  txtPassConfirm.PasswordChar:= #0;
  txtNewPass.PasswordChar:= #0;
  txtPass.PasswordChar:=#0;
end else begin
  txtPassConfirm.PasswordChar:= #149;
  txtNewPass.PasswordChar:= #149;
  txtPass.PasswordChar:=#149;
end;

end;

end.
