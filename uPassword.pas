unit uPassword;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.ImgList,
  uDocument;

type
  TfrmPassword = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    txtOldPass: TButtonedEdit;
    txtNewPass: TButtonedEdit;
    txtConfirmPass: TButtonedEdit;
    btnOK: TButton;
    btnClose: TButton;
    pnlLine: TPanel;
    imlPassword: TImageList;
    procedure txtEnter(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure txtOldPassChange(Sender: TObject);
    procedure txtNewPassChange(Sender: TObject);
    procedure txtConfirmPassChange(Sender: TObject);
  private
    fDoc: TOmgDocument;
    function CheckOldPass(Msg: Boolean): Boolean;
    function CheckNewPass(Msg: Boolean): Boolean;
    function CheckConfirmPass(Msg: Boolean): Boolean;
  public
    newPassword: String;
    constructor Create(AOwner: TComponent; Document: TOmgDocument); reintroduce;
  end;

var
  frmPassword: TfrmPassword;

implementation
uses uStrings;

{$R *.dfm}
constructor TfrmPassword.Create(AOwner: TComponent; Document: TOmgDocument);
begin
    inherited Create(AOwner);
    fDoc:=Document;
end;

{проверка соответствия старого пароля}
function TfrmPassword.CheckOldPass(Msg: Boolean): Boolean;
begin
    Result:= fDoc.CheckThisPassword(txtOldPass.Text);
    if not Result and Msg then
        MessageBox(Self.Handle,
        PWideChar(rsWrongOldPassword),
        PWideChar(rsWrongOldPasswordTitle),
        MB_ICONERROR + MB_OK + MB_APPLMODAL);
    //if Result then txtNewPass.SetFocus;
end;
{новый пароль должен отличаться}
function TfrmPassword.CheckNewPass(Msg: Boolean): Boolean;
begin
    Result:= (txtOldPass.Text <> txtNewPass.Text);
    if not Result and Msg then
        MessageBox(Self.Handle,
        PWideChar(rsWrongNewPassword),
        PWideChar(rsWrongNewPasswordTitle),
        MB_ICONWARNING + MB_OK + MB_APPLMODAL);
    if Result and Msg and (txtNewPass.Text = '') then
        if MessageBox(Self.Handle,
        PWideChar(rsNewPasswordEmpty),
        PWideChar(rsNewPasswordEmptyTitle),
        MB_ICONQUESTION + MB_OK + MB_YESNO + MB_APPLMODAL) = mrNo then
            Result:=False;

end;
{подтверждение должно совпадать}
function TfrmPassword.CheckConfirmPass(Msg: Boolean): Boolean;
begin
    Result:= (txtConfirmPass.Text = txtNewPass.Text);
    if not Result and Msg then
        MessageBox(Self.Handle,
        PWideChar(rsWrongConfirmPassword),
        PWideChar(rsWrongConfirmPasswordTitle),
        MB_ICONWARNING + MB_OK + MB_APPLMODAL);
end;

procedure TfrmPassword.btnCloseClick(Sender: TObject);
begin
    Self.ModalResult:=mrCancel;
end;

procedure TfrmPassword.btnOKClick(Sender: TObject);
begin
    if not CheckOldPass(True) then begin
        txtOldPass.SetFocus;
        Exit;
    end;
    if not CheckNewPass(True) then begin
        txtNewPass.SetFocus;
        Exit;
    end;
    if not CheckConfirmPass(True) then Exit;
    if fDoc.ChangePassword(txtNewPass.Text) then;
        MessageBox(Self.Handle,
        PWideChar(rsPasswordChanged),
        PWideChar(rsPasswordChangedTitle),
        MB_ICONINFORMATION + MB_OK + MB_APPLMODAL);
    Self.ModalResult:=mrOk;
end;

procedure TfrmPassword.txtEnter(Sender: TObject);
begin
    With (Sender as TButtonedEdit) do begin
        if Font.Color = clGrayText then begin
            RightButton.Visible:=True;
            Font.Style:=[];
            Font.Color:=clWindowText;
            Text:='';
        end;
    end;
end;

procedure TfrmPassword.txtOldPassChange(Sender: TObject);
begin
    txtOldPass.RightButton.ImageIndex:= CheckOldPass(False).ToInteger;
    txtNewPassChange(nil);
end;

procedure TfrmPassword.txtNewPassChange(Sender: TObject);
begin
    txtNewPass.RightButton.ImageIndex:= CheckNewPass(False).ToInteger;
    txtConfirmPassChange(nil);
end;

procedure TfrmPassword.txtConfirmPassChange(Sender: TObject);
begin
    txtConfirmPass.RightButton.ImageIndex:=CheckConfirmPass(False).ToInteger;
end;

end.
