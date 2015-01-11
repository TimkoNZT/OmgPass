unit uPassword;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.ImgList;

type
  TfrmPassword = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    txtOldPass: TButtonedEdit;
    txtNewPass: TButtonedEdit;
    txtNewPassConfirm: TButtonedEdit;
    btnOK: TButton;
    btnClose: TButton;
    pnlLine: TPanel;
    imlPassword: TImageList;
    procedure txtEnter(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPassword: TfrmPassword;

implementation

{$R *.dfm}

procedure TfrmPassword.btnCloseClick(Sender: TObject);
begin
    Self.ModalResult:=mrCancel;
end;

procedure TfrmPassword.btnOKClick(Sender: TObject);
begin
    Self.ModalResult:=mrOk;
end;

procedure TfrmPassword.txtEnter(Sender: TObject);
begin
    With (Sender as TButtonedEdit) do begin
        if Font.Color = clGrayText then begin
            Font.Style:=[];
            Font.Color:=clWindowText;
            Text:='';
        end;
    end;
end;

end.
