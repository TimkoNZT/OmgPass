{На каждый чекбокс или другой элемент опций вешается процедура,
которая записывает его состояние во временный конфиг
Запись имён опций ведется по хинту с валидным для ini именем опции}

unit uOptions;

interface

uses
Windows, SysUtils, Classes, FileCtrl, Controls, Forms, StdCtrls, Vcl.ComCtrls,
uSettings, uLog, System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.Menus,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls,uLocalization;

type
  TfrmOptions = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnOK: TButton;
    chkMakeBackups: TCheckBox;
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
    CheckBox1: TCheckBox;
    Label1: TLabel;
    udAutoLoginTime: TUpDown;
    txtAutoLoginCount: TEdit;
    lblBackupsCount: TLabel;
    udBackupsCount: TUpDown;
    txtBackupsCount: TEdit;
    txtBackupFolder: TEdit;
    lblBackupFolder: TLabel;
    btnSelBackupFolder: TSpeedButton;
    btnBackupNow: TButton;
    Label2: TLabel;
    imgBackup: TImage;
    chkTreeRowSelect: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    UpDown1: TUpDown;
    Label3: TLabel;
    chkMakeBackupsCh: TCheckBox;
    bhBackup: TBalloonHint;
    btnAssociateFiles: TButton;
    Label4: TLabel;
    cmbLanguages: TComboBox;
    lblLanguages: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    constructor Create(AOwner: TComponent; tempSettings: TSettings); reintroduce;
    procedure ChangeValue(Sender: TObject);
    procedure udBackupsCountClick(Sender: TObject; Button: TUDBtnType);
    procedure btnSelBackupFolderClick(Sender: TObject);
    procedure chkMakeBackupsClick(Sender: TObject);
    procedure btnBackupNowClick(Sender: TObject);
    procedure txtBackupFolderExit(Sender: TObject);
    procedure txtBackupFolderChange(Sender: TObject);
    procedure imgBackupClick(Sender: TObject);
    procedure btnAssociateFilesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Cfg: TSettings;
    procedure ReadConfiguration;
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation
uses Logic, uStrings, RyMenus;
{$R *.dfm}

procedure TfrmOptions.btnSelBackupFolderClick(Sender: TObject);
var
    ChosenDir: String;
begin
    //ChosenDir:= ExtractFilePath(Application.ExeName);
    if SelectDirectory(rsSelectBackupDirectoryDialog, '', ChosenDir) then
        txtBackupFolder.Text:=ChosenDir;
end;

procedure TfrmOptions.ChangeValue(Sender: TObject);
begin
    if not Self.Visible then Exit;
    if (Sender is TCheckBox) then
        with (Sender as TCheckBox) do Cfg.SetValue(Hint, BoolToStr(Checked, True));
    if (Sender is TEdit) then
        with (Sender as TEdit) do Cfg.SetValue(Hint, Text);
    if (Sender is TUpDown) then
        with (Sender as TUpDown) do Cfg.SetValue(Hint, Position);
    if (Sender is TComboBox) then
        with (Sender as TComboBox) do begin
            if Hint = 'Language' then                                           //Особый случай, нужен не индекс а имя
                Cfg.SetValue(Hint, appLoc.Languages[ItemIndex].ShortName)
            else
                Cfg.SetValue(Hint, ItemIndex);
        end;
end;

procedure TfrmOptions.chkMakeBackupsClick(Sender: TObject);
begin
    txtBackupFolder.Enabled:= chkMakeBackups.Checked or chkMakeBackupsCh.Checked;
    btnSelBackupFolder.Enabled:= chkMakeBackups.Checked or chkMakeBackupsCh.Checked;
    txtBackupsCount.Enabled:= chkMakeBackups.Checked or chkMakeBackupsCh.Checked;
    udBackupsCount.Enabled:= chkMakeBackups.Checked or chkMakeBackupsCh.Checked;
    lblBackupFolder.Enabled:= chkMakeBackups.Checked or chkMakeBackupsCh.Checked;
    lblBackupsCount.Enabled:= chkMakeBackups.Checked or chkMakeBackupsCh.Checked;
    ChangeValue(Sender);
end;

constructor TfrmOptions.Create(AOwner: TComponent; tempSettings: TSettings);
begin
    inherited Create(AOwner);
    Cfg:= tempSettings;
    ReadConfiguration;
end;

procedure TfrmOptions.ReadConfiguration;

procedure ReadValues(Com: TComponent);

//(RootNode.ChildNodes.FindNode(Section) <> nil)
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

procedure TfrmOptions.txtBackupFolderChange(Sender: TObject);
var
    fullPath: String;
begin
    CheckBackupFolder(txtBackupFolder.Text, fullPath);
    //btnSelBackupFolder.Hint:= 'Current path: ' + fullPath;
    bhBackup.Description := fullPath;
end;

procedure TfrmOptions.txtBackupFolderExit(Sender: TObject);
var
    fullPath: String;
begin
    if not CheckBackupFolder(txtBackupFolder.Text, fullPath, True) then
        case MessageBox(Self.Handle,
                        PWideChar(Format(rsWrongBackupFolder, [fullPath])),
                        PWideChar(rsWrongBackupFolderTitle),
                        MB_YESNOCANCEL + MB_ICONWARNING) of
        ID_NO: begin
            txtBackupFolder.Show;
            txtBackupFolder.SetFocus;
        end;
        ID_YES: begin
            txtBackupFolder.Text:=strDefaultBackupFolder;
//            txtBackupFolder.Show;
//            txtBackupFolder.SetFocus;
        end;
        ID_CANCEL:begin
            txtBackupFolder.Text:=xmlCfg.GetValue('BackupFolder', strDefaultBackupFolder);
//            txtBackupFolder.Show;
//            txtBackupFolder.SetFocus;
        end;
        end;


    ChangeValue(Sender);
end;

procedure TfrmOptions.udBackupsCountClick(Sender: TObject; Button: TUDBtnType);
begin
    ChangeValue(Sender);
end;

procedure TfrmOptions.btnAssociateFilesClick(Sender: TObject);
begin
    AssociateFileTypes(True);
end;

procedure TfrmOptions.btnBackupNowClick(Sender: TObject);
begin
    MakeDocumentBackup;
    Beep;
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

procedure TfrmOptions.FormCreate(Sender: TObject);
var
    Lng:TLocalization.TLanguage;
begin
    for Lng in appLoc.Languages do
        cmbLanguages.Items.Add(Lng.Name);
    cmbLanguages.ItemIndex:= appLoc.Languages.IndexOf(appLoc.CurrentLanguage);
end;

procedure TfrmOptions.FormShow(Sender: TObject);
begin
    WindowsOnTop(bWindowsOnTop, Self);
    appLoc.TranslateForm(Self);
    SetButtonImg(btnSelBackupFolder, imlOptions, 4);
    chkMakeBackupsClick(nil);                                                   //Для enable-disable зависимых контролов
    txtBackupFolderChange(nil);                                                 //Для заполнения bhBackup
end;

procedure TfrmOptions.imgBackupClick(Sender: TObject);
var
    Point:TPoint;
begin
//    if bhBackup.ShowingHint then begin                                        //Нестабильно
//        bhBackup.HideHint;
//        Exit;
//    end;
    bhBackup.Title := rsBackupHintTitle;
    bhBackup.ImageIndex:= 5;
    point.X := txtBackupFolder.Width div 2;
    point.Y := txtBackupFolder.Height;
    bhBackup.ShowHint(txtBackupFolder.ClientToScreen(point));

end;

end.
