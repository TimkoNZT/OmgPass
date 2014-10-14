unit uCustomEdit;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, StdCtrls, Vcl.Mask, Vcl.ComCtrls;

type
  TEditMultiLine = class(TEdit)
private
	FMultiline: Boolean;
    FEnabled: Boolean;
    procedure SetEnabled(Value: Boolean);
protected
    procedure CreateParams(var Params:TCreateParams);override;
public
published
  	property Multiline: Boolean read FMultiline write FMultiline;
    property Enabled: Boolean read FEnabled write SetEnabled;
end;

implementation

procedure TEditMultiLine.CreateParams(var Params: TCreateParams);
begin
inherited createParams(Params);
//Params.Style:=Params.Style + WS_BORDER;
//Params.ExStyle:=Params.ExStyle or WS_EX_CLIENTEDGE ;
if FMultiline then
	Params.Style:=Params.Style
		or ES_MULTILINE {or WS_VSCROLL};
end;

procedure TEditMultiLine.SetEnabled(Value: Boolean);
begin
    //inherited;
    if Value then
        SetWindowLongPtr(Handle, GWL_STYLE, GetWindowLongPtr(Handle, GWL_STYLE) and not WS_DISABLED)
    else
        SetWindowLongPtr(Handle, GWL_STYLE, GetWindowLongPtr(Handle, GWL_STYLE) or WS_DISABLED);
    FEnabled:=Value;
end;

end.
