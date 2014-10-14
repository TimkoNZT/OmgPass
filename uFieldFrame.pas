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
    procedure FrameResize(Sender: TObject);
    constructor CreateParented(ParentWindow: HWnd); overload;

  private
    { Private declarations }
  public
    textInfo: TEditMultiline;
    procedure DisableTextFrame;
    procedure SetTextMultiline;
    { Public declarations }
  end;

implementation

{$R *.dfm}
constructor TFieldFrame.CreateParented(ParentWindow: HWnd);
begin
    inherited CreateParented(ParentWindow);
    textInfo:= TEditMultiline.Create(Self);
    textInfo.SetParentComponent(Self);
    btnSmart.SetBounds(Self.Width - lblTitle.Height * 2,
                       lblTitle.Height,
                       lblTitle.Height * 2,
                       lblTitle.Height * 2);
    btnAdditional.SetBounds(Self.Width - lblTitle.Height * 4 - 3,
                       lblTitle.Height,
                       lblTitle.Height * 2,
                       lblTitle.Height * 2);
    textInfo.AutoSize:=False;
    textInfo.Height:=lblTitle.Height + 9;
    textInfo.Top:= lblTitle.Height + 2;
    //textInfo.BevelEdges:= [beTop, beLeft];
    textInfo.BevelInner:=bvSpace;
    textInfo.BevelOuter:=bvSpace;
    textInfo.BevelKind:=bkTile;
end;

procedure TFieldFrame.FrameResize(Sender: TObject);
begin
    if btnAdditional.Visible=False then
    	textInfo.Width:=btnSmart.Left - 3
    else
		textInfo.Width:=btnAdditional.Left - 3;
end;

procedure TFieldFrame.DisableTextFrame;
begin
    SetWindowLongPtr(textInfo.Handle, GWL_STYLE,
    GetWindowLongPtr(textInfo.Handle, GWL_STYLE) or WS_DISABLED);
end;

procedure TFieldFrame.SetTextMultiline;
begin
    SetWindowLongPtr(textInfo.Handle, GWL_STYLE,
    GetWindowLongPtr(textInfo.Handle, GWL_STYLE) or ES_MULTILINE);
end;
end.
