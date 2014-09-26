unit uFieldFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, uCustomEdit;

type
  TFieldFrame = class(TFrame)
    lblTitle: TLabel;
    btnSmart: TSpeedButton;
    btnAdditional: TSpeedButton;
    textInfo: TEditMultiLine;
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
	constructor Create(AOwner: TComponent); override;
    { Public declarations }
  end;

implementation

{$R *.dfm}
constructor TFieldFrame.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
end;

procedure TFieldFrame.FrameResize(Sender: TObject);
begin
    if btnAdditional.Visible=False then
    	textInfo.Width:=btnSmart.Left - 3
    else
		textInfo.Width:=btnAdditional.Left - 3;
end;

end.
