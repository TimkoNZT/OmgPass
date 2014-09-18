unit uEditItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmEditItem = class(TForm)
    btnClose: TButton;
    btnGenerate: TButton;
    fpEdit: TScrollBox;
    procedure btnCloseClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditItem: TfrmEditItem;

implementation

{$R *.dfm}

procedure TfrmEditItem.btnCloseClick(Sender: TObject);
begin
	ModalResult:=mrCancel;
end;

procedure TfrmEditItem.btnGenerateClick(Sender: TObject);
begin
	ModalResult:=mrOK;
end;

procedure TfrmEditItem.fpEditMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
fpEdit.VertScrollBar.Position:= fpEdit.VertScrollBar.Position - WheelDelta div 5;
end;

end.
