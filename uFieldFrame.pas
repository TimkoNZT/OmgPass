unit uFieldFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls;

type
  TFieldFrame = class(TFrame)
    lblTitle: TLabel;
    textInfo: TRichEdit;
    btnSmart: TSpeedButton;
    btnAdditional: TSpeedButton;
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

FieldType = (ftText, ftPass, ftComment);

//var


implementation

{$R *.dfm}

procedure TFieldFrame.FrameResize(Sender: TObject);
begin
    if btnAdditional.Visible=False then
    	textInfo.Width:=btnSmart.Left - 3
    else
		textInfo.Width:=btnAdditional.Left - 3;
end;

end.
