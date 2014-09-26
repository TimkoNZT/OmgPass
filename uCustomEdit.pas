unit uCustomEdit;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, StdCtrls, Vcl.Mask, Vcl.ComCtrls;

type
  TEditMultiLine = class(TEdit)
private
	FMultiline: Boolean;
protected
    procedure CreateParams(var Params:TCreateParams);override;
public
published
  	property Multiline: Boolean read FMultiline write FMultiline;
  end;

implementation

procedure TEditMultiLine.CreateParams(var Params: TCreateParams);
begin
inherited createParams(Params);
//Params.Style:=Params.Style + WS_BORDER;
//Params.ExStyle:=Params.ExStyle or WS_EX_CLIENTEDGE ;
if FMultiline then
	Params.Style:=Params.Style
		or ES_MULTILINE or WS_VSCROLL;
end;

end.
