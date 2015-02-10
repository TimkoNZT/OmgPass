unit uOptions;

interface

uses
Windows, SysUtils, Classes, Controls, Forms, StdCtrls, Vcl.ComCtrls, Vcl.ImgList,
uSettings, uLog;

type
  TfrmOptions = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnOK: TButton;
    chkMakeBackups: TCheckBox;
    udBackupsCount: TUpDown;
    lblBackups: TLabel;
    txtBackupsCount: TEdit;
    lblBackupsCount: TLabel;
    chkGenNewPass: TCheckBox;
    chkPlaySounds: TCheckBox;
    TabSheet3: TTabSheet;
    chkReaskPass: TCheckBox;
    chkClearClipOnMin: TCheckBox;
    chkMinOnCopy: TCheckBox;
    chkMinOnLink: TCheckBox;
    chkAnvansedEdit: TCheckBox;
    imlOptions: TImageList;
    chkResizeTree: TCheckBox;
    TabSheet4: TTabSheet;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    constructor Create(AOwner: TComponent; tempSettings: TSettings); reintroduce;
    procedure ChangeValue(Sender: TObject);
    procedure udBackupsCountClick(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
    Cfg: TSettings;
    function ReadConfiguration: Boolean;
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation
uses Logic;
{$R *.dfm}

procedure TfrmOptions.ChangeValue(Sender: TObject);
begin
    if not Self.Visible then Exit;
    if (Sender is TCheckBox) then
        with (Sender as TCheckBox) do Cfg.SetValue(Hint, BoolToStr(Checked, True));
    if (Sender is TEdit) then
        with (Sender as TEdit) do Cfg.SetValue(Hint, Text);
    if (Sender is TUpDown) then
        with (Sender as TUpDown) do Cfg.SetValue(Hint, Position);
end;

constructor TfrmOptions.Create(AOwner: TComponent; tempSettings: TSettings);
begin
    inherited Create(AOwner);
    Cfg:= tempSettings;
    ReadConfiguration;
end;

function TfrmOptions.ReadConfiguration: Boolean;
procedure ReadValues(Com: TComponent);
begin
    if Com is TCheckBox then with (Com as TCheckBox) do
        if Cfg.HasOption(Hint) then
            Checked:= Boolean(Cfg.GetValue(Hint, False));
    if Com is TEdit then with (Com as TEdit) do
        if Cfg.HasOption(Hint) then
            Text:= String(Cfg.GetValue(Hint, ''));
    if Com is TUpDown then with (Com as TUpDown) do
        if Cfg.HasOption(Hint) then
            Position:= Integer(Cfg.GetValue(Hint, Min));
end;
var i: Integer;
begin
    //Заполняем чекбоксы в соответствии с текущими настройками.
    for i := 0 to Self.ComponentCount - 1 do ReadValues(Self.Components[i]);
end;

procedure TfrmOptions.udBackupsCountClick(Sender: TObject; Button: TUDBtnType);
begin
    ChangeValue(Sender);
end;

procedure TfrmOptions.btnOKClick(Sender: TObject);
begin
    Self.ModalResult:=mrOk;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Self.BorderIcons:=[];
    Self.Caption:='';
end;

procedure TfrmOptions.FormShow(Sender: TObject);
begin
    WindowsOnTop(bWindowsOnTop, Self);
end;

end.
