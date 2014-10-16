unit uFolderFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFolderFrame = class(TFrame)
    grpDefault: TGroupBox;
    btnSetDefItem: TButton;
    lblInfoDef: TLabel;
    grpInfo: TGroupBox;
    lblInfo: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses Logic;
{$R *.dfm}

end.
