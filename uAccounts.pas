unit uAccounts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  StdCtrls, Vcl.CategoryButtons,
  Vcl.ExtCtrls, Vcl.Buttons, ComCtrls, Vcl.DBCtrls, Vcl.Tabs, Vcl.ImgList,
  Vcl.Imaging.pngimage;

type
  TfrmAccounts = class(TForm)
    pcAccounts: TPageControl;
    tsNew: TTabSheet;
    OpenDialog: TOpenDialog;
    txtPassConfirm: TEdit;
    lblPassConfirm: TLabel;
    Label4: TLabel;
    txtNewPass: TEdit;
    Label2: TLabel;
    chkShowPass: TCheckBox;
    CheckBox1: TCheckBox;
    tsOpen: TTabSheet;
    imlAccounts: TImageList;
    lvFiles: TListView;
    Label1: TLabel;
    chkShowMainPass: TCheckBox;
    Label6: TLabel;
    btnGeneratePass: TSpeedButton;
    btnNewBase: TSpeedButton;
    Image1: TImage;
    txtPass: TEdit;
    btnClose: TButton;
    btnOK: TButton;
    Memo1: TMemo;
    lblNoFiles: TStaticText;
    imgNotShallPass: TImage;
    txtNewBase: TEdit;
    SaveDialog: TSaveDialog;
    btnRemove: TSpeedButton;
    btnAdd: TSpeedButton;
    btnNew: TSpeedButton;
    btnCreateNewBase: TButton;
    constructor Create(AOwner: TComponent; isChange: Boolean = False); reintroduce;
    procedure btnNextClick(Sender: TObject);
    procedure chkShowPassClick(Sender: TObject);
    procedure btnNewBaseClick(Sender: TObject);
    procedure btnGeneratePassClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure chkShowMainPassClick(Sender: TObject);
    procedure lvFilesClick(Sender: TObject);
    procedure lvFilesDblClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure tsOpenShow(Sender: TObject);
    procedure tsNewShow(Sender: TObject);
    procedure btnCreateNewBaseClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure txtPassChange(Sender: TObject);
private
    fIsChange: Boolean;
    procedure LoadLvFiles;
    procedure CheckPreOpenCrypted;
//    FShowHoriz: Boolean;
//    FShowVert: Boolean;
//    FListViewWndProc: TWndMethod;
//    procedure ListViewWndProc(var Msg: TMessage);
protected
    procedure CreateParams(var Params: TCreateParams); override;

public
    FFileName: String;
    FPassword: String;
    fNewFile: Boolean;


end;
var
    frmAccounts: TfrmAccounts;

implementation

{$R *.dfm}

uses uMain, uGenerator, Logic, uSettings, uStrings, md5;

constructor TfrmAccounts.Create(AOwner: TComponent; isChange: Boolean = False);
begin
fIsChange :=IsChange;
inherited Create (AOwner);
if isChange then begin
    Self.Caption:= Application.Title + rsFrmAccountsCaptionChange;
    btnClose.Caption:=rsCancel;
    btnOK.Caption:=rsOK;
end else begin
    Self.Caption:=Application.Title + rsFrmAccountsCaption;
    btnClose.Caption:=rsExit;
    btnOK.Caption:=rsOpen;
end;
end;

procedure TfrmAccounts.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if Self.ModalResult <> mrOK then
        btnClose.Click;
end;

procedure TfrmAccounts.CreateParams(var Params: TCreateParams);
begin
  inherited;
  //Если форма отображается не в первый раз, то у неё не будет кнопки
  if not fIsChange then
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmAccounts.FormCreate(Sender: TObject);
begin
LoadLvFiles;
//if lvFiles.Items.Count = 0 then begin
//    lblNoFiles.Visible:=True;
//    lblNoFiles.Alignment:=taCenter;
//end else lvFiles.Items[0].Selected:=True;

if lvFiles.Items.Count > 5 then
    lvFiles.Column[0].Width:=(lvFiles.ClientRect.Width - 20);

Logic.SetButtonImg(btnNewBase, imlAccounts, 3);
Logic.SetButtonImg(btnGeneratePass, imlAccounts, 1);
Logic.SetButtonImg(btnAdd, imlAccounts, 5);
Logic.SetButtonImg(btnRemove, imlAccounts, 6);
Logic.SetButtonImg(btnNew, imlAccounts, 4);

end;

procedure TfrmAccounts.LoadLvFiles;
var i: Integer;
begin
    lvFiles.Items.Clear;
    lblNoFiles.Visible:=(lsStoredDocs.Count = 0);
    if lsStoredDocs.Count = 0 then Exit;
    for i := 0 to lsStoredDocs.Count - 1 do
        lvFiles.AddItem(lsStoredDocs[i], nil);
    lvFiles.ItemIndex:=0;

end;

procedure TfrmAccounts.FormShow(Sender: TObject);
begin
WindowsOnTop(bWindowsOnTop, Self);
//ShowWindow(Application.Handle, SW_HIDE);
try
    txtPass.SetFocus;
except
    Log('Same error');
end;
end;

procedure TfrmAccounts.CheckPreOpenCrypted;
begin
    imgNotShallPass.Visible:= DocumentPreOpenCrypted(FFileName, txtPass.Text);
end;

procedure TfrmAccounts.lvFilesClick(Sender: TObject);
{$J+}
const LastSelected: Integer = 0;
{$J-}
begin
if lvFiles.Items.Count <> 0 then
    if lvFiles.Selected = nil then
        lvFiles.Items[lvFiles.Items.Count - 1].Selected:=True;
    FFileName:=lvFiles.Selected.Caption;
    if lvFiles.ItemIndex <> LastSelected then
        txtPass.Text:='';
    LastSelected:= lvFiles.ItemIndex;
    txtPass.Enabled:=True;
    if not FileExists(FFileName) then
//        if MessageBox(Self.Handle,
//            PWideChar(Format(rsFileNotFoundMsg,[FFileName])),
//            'Title',
//            MB_ICONWARNING + MB_OKCANCEL + MB_DEFBUTTON2 + MB_SYSTEMMODAL) = ID_CANCEL
//            then
                begin
                    txtPass.Text:=rsTxtPassFileNotFound;
                    txtPass.Enabled:=False;
                    lvFiles.Selected.ImageIndex:=8;
                    Exit;
                end;
    if ExtractFileExt(FFileName) = 'xml' then
        DocumentPreOpenXML(FFileName)
    else
        DocumentPreOpenCrypted(FFileName, txtPass.Text);

end;

procedure TfrmAccounts.lvFilesDblClick(Sender: TObject);
begin
if lvFiles.Items.Count = 0 then Exit;
if lvFiles.Selected = nil then
    lvFiles.Items[lvFiles.Items.Count - 1].Selected:=True;
    btnOk.Click;
end;

procedure TfrmAccounts.tsNewShow(Sender: TObject);
begin
    //
    btnCreateNewBase.Visible:=True;
    btnOK.Visible:=False;
end;

procedure TfrmAccounts.tsOpenShow(Sender: TObject);
begin
    //
    btnCreateNewBase.Visible:=False;
    btnOK.Visible:=True;
end;

procedure TfrmAccounts.txtPassChange(Sender: TObject);
begin
Log(md5.MD5String(txtPass.Text).ToHexString);
CheckPreOpenCrypted;
end;

procedure TfrmAccounts.btnAddClick(Sender: TObject);
begin
    With OpenDialog do begin
        DefaultExt:=strDefaultExt;
        Title:=rsOpenDialogTitle;
        Filter:=rsOpenDialogFilter;
        if Execute then begin;
            ReloadStoredDocs(FileName);
            LoadLvFiles;
        end;
    end;
end;

procedure TfrmAccounts.btnCloseClick(Sender: TObject);
begin
if not fIsChange then begin
    frmMain.WindowState:=wsMinimized;
end;
Self.ModalResult:=mrCancel;
end;

procedure TfrmAccounts.btnCreateNewBaseClick(Sender: TObject);
var i: Integer;
begin
    if txtNewBase.Text = '' then Exit;
    if FileExists(txtNewBase.Text) then DeleteFile(txtNewBase.Text);
    CreateNewBase(txtNewBase.Text);
    ReloadStoredDocs(txtNewBase.Text);
    LoadLvFiles;
    pcAccounts.Pages[tsOpen.PageIndex].Show;
end;

procedure TfrmAccounts.btnGeneratePassClick(Sender: TObject);
begin
if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(Self);
//frmGenerator.formType:= 0;
if frmGenerator.ShowModal = mrOk then begin
  txtNewPass.Text:= frmGenerator.lblResult.Caption;
  txtPassConfirm.Text:= frmGenerator.lblResult.Caption;
end;
FreeAndNil(frmGenerator);
end;

procedure TfrmAccounts.btnNewBaseClick(Sender: TObject);
var Accept: Boolean;
begin
With SaveDialog do begin
    DefaultExt:=strDefaultExt;
    Title:= rsSaveDialogTitle;
    Filter:= rsSaveDialogFilter;
    Accept:=False;
    while not Accept do begin
        SaveDialog.Execute;
        if FileExists(FileName) then
            case MessageBox(Self.Handle,
                            PWideChar(Format(rsSaveDialogFileExists, [FileName])),
                            PWideChar(Application.Title),
                            MB_YESNOCANCEL + MB_DEFBUTTON3 + MB_APPLMODAL + MB_ICONWARNING) of
            ID_YES: Accept:=True;
            ID_CANCEL: Exit;
            end
        else Accept:=True;
    end;
    txtNewBase.Text:=FileName;
end;
end;

procedure TfrmAccounts.btnNewClick(Sender: TObject);
begin
    pcAccounts.Pages[tsNew.TabIndex].Show;
end;

procedure TfrmAccounts.btnNextClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmAccounts.chkShowMainPassClick(Sender: TObject);
begin
chkShowPass.Checked:= chkShowMainPass.Checked;
end;

procedure TfrmAccounts.chkShowPassClick(Sender: TObject);
begin
chkShowMainPass.Checked:= chkShowPass.Checked;
txtPassConfirm.Visible:= not chkShowPass.Checked;
lblPassConfirm.Visible:= not chkShowPass.Checked;
if chkShowPass.Checked then begin
  txtPassConfirm.PasswordChar:= #0;
  txtNewPass.PasswordChar:= #0;
  txtPass.PasswordChar:=#0;
end else begin
  txtPassConfirm.PasswordChar:= #149;
  txtNewPass.PasswordChar:= #149;
  txtPass.PasswordChar:=#149;
end;

end;

procedure TfrmAccounts.btnOKClick(Sender: TObject);
begin
    if lvFiles.Selected = nil then Exit;
    FFileName:=lvFiles.Selected.Caption;
    if not FileExists(FFileName) then
        if MessageBox(Self.Handle,
            PWideChar(Format(rsFileNotFoundMsg,[FFileName])),
            'Title',
            MB_ICONWARNING + MB_OKCANCEL + MB_DEFBUTTON2 + MB_SYSTEMMODAL) = ID_CANCEL
            then Exit
            else CreateNewBase(FFileName);
    if DocumentPreOpenXML(FFileName) then begin
        ReloadStoredDocs(FFileName);
        Self.ModalResult:=mrOK;
    end;
end;

procedure TfrmAccounts.btnRemoveClick(Sender: TObject);
begin
    if lvFiles.Selected = nil then Exit;
    RemoveStoredDocs(lvFiles.Selected.Caption);
    LoadLvFiles;
end;

end.
