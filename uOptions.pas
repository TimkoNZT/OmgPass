unit uOptions;

interface

uses
Windows, SysUtils, Classes, Controls, Forms, StdCtrls;

type
  TfrmOptions = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation
uses Logic;
{$R *.dfm}

procedure TfrmOptions.FormShow(Sender: TObject);
begin
WindowsOnTop(bWindowsOnTop, Self);
end;

end.
