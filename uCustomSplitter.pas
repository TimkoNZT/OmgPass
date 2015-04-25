unit uCustomSplitter;
// -----------------------------------------------------------------------------
// TSplitter enhanced with grab bar
// The original author is Anders Melander, anders@melander.dk, http://melander.dk
// Copyright © 2008 Anders Melander
// -----------------------------------------------------------------------------
// License:
// Creative Commons Attribution-Share Alike 3.0 Unported
// http://creativecommons.org/licenses/by-sa/3.0/
// -----------------------------------------------------------------------------

interface

uses
  ExtCtrls, Messages, Classes;

//------------------------------------------------------------------------------
//
//      TSplitter enhanced with grab bar
//
//------------------------------------------------------------------------------
type
TSplitter = class(ExtCtrls.TSplitter)
protected
    procedure Paint; override;
public
    property OnDblClick;
end;

const DotsCount: Integer = 16;

implementation

uses
Windows, Graphics, Controls;

//------------------------------------------------------------------------------
//
//      TSplitter enhanced with grab bar
//
//------------------------------------------------------------------------------
procedure TSplitter.Paint;
var
    R: TRect;
    X, Y: integer;
    DX, DY: integer;
    i: integer;
    Brush: TBitmap;
begin
    R := ClientRect;
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);

    X := (R.Left+R.Right) div 2;
    Y := (R.Top+R.Bottom) div 2;
    if (Align in [alLeft, alRight]) then
    begin
        DX := 0; DY := 4;
    end else begin
        DX := 4; DY := 0;
    end;
    dec(X, DX*(DotsCount div 2));
    dec(Y, DY*(DotsCount div 2));

    Brush := TBitmap.Create;
    try
        Brush.SetSize(2, 2);
        Brush.Canvas.Pixels[1, 1] := clBtnShadow;  //clBtnText
        Brush.Canvas.Pixels[0, 0] := clBtnHighlight;
        Brush.Canvas.Pixels[0, 1] := clBtnShadow;
        Brush.Canvas.Pixels[1, 0] := clBtnShadow;
        for i := 0 to DotsCount do
        begin
          Canvas.Draw(X - 1, Y, Brush);
          Canvas.Draw(X + 2, Y, Brush);
          inc(X, DX);
          inc(Y, DY);
        end;
    finally
        Brush.Free;
    end;
end;


end.
