unit uAccounts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  StdCtrls, Vcl.CategoryButtons, ShellAPI,
  Vcl.ExtCtrls, Vcl.Buttons, ComCtrls, Vcl.DBCtrls, Vcl.Tabs,
  Vcl.ToolWin, Vcl.ImgList, System.ImageList, VirtualTrees;

type
  TfrmAccounts = class(TForm)
    pcAccounts: TPageControl;
    tsNew: TTabSheet;
    OpenDialog: TOpenDialog;
    txtNewPassConfirm: TEdit;
    lblPassConfirm: TLabel;
    Label4: TLabel;
    txtNewPass: TEdit;
    Label2: TLabel;
    chkShowPass: TCheckBox;
    tsOpen: TTabSheet;
    imlAccounts: TImageList;
    lvFiles: TListView;
    lblPassword: TLabel;
    lblStoredDocuments: TLabel;
    btnGeneratePass: TSpeedButton;
    btnNewBasePath: TSpeedButton;
    Image1: TImage;
    txtPass: TEdit;
    btnClose: TButton;
    btnOK: TButton;
    lblNoFiles: TStaticText;
    imgNotShallPass: TImage;
    txtNewBase: TEdit;
    SaveDialog: TSaveDialog;
    btnRemove: TSpeedButton;
    btnAdd: TSpeedButton;
    btnNew: TSpeedButton;
    btnCreateNewBase: TButton;
    btnDelete: TSpeedButton;
    chkShowMainPass: TCheckBox;
    tmrEnter: TTimer;
    constructor Create(AOwner: TComponent; isChange: Boolean = False); reintroduce;
    procedure chkShowPassClick(Sender: TObject);
    procedure btnNewBasePathClick(Sender: TObject);
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
    procedure btnDeleteClick(Sender: TObject);
    procedure tmrEnterTimer(Sender: TObject);
    procedure btnOKExit(Sender: TObject);
private
    fIsChange: Boolean;
    procedure LoadLvFiles;
    function OpenPreCheck(AlertMsg: Boolean = False): Boolean;

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

uses uMain, uGenerator, Logic, uSettings, uStrings, uLog;

constructor TfrmAccounts.Create(AOwner: TComponent; isChange: Boolean = False);
begin
fIsChange :=IsChange;
inherited Create (AOwner);
if isChange then begin
    Self.Caption:= Application.Title + appLoc.Strings('rsFrmAccountsCaptionChange', rsFrmAccountsCaptionChange);
    btnClose.Caption:= appLoc.Strings('rsCancel', rsCancel) ;
    btnOK.Caption:= appLoc.Strings('rsOK', rsOK) ;
end else begin
    Self.Caption:=Application.Title + appLoc.Strings('rsFrmAccountsCaption', rsFrmAccountsCaption);;
    btnClose.Caption:= appLoc.Strings('rsExit', rsExit);
    btnOK.Caption:= appLoc.Strings('rsOpen', rsOpen);
end;
end;

procedure TfrmAccounts.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Self.BorderIcons:=[];
    Self.Caption:='';
    //Это жжж неспроста, по нажатию кнопки Exit
    //главная форма мимимизируется, чтобы не мимимигать
    if Self.ModalResult <> mrOK then btnClose.Click;
end;

procedure TfrmAccounts.CreateParams(var Params: TCreateParams);
    //Если форма отображается для смены баз, то у неё не будет кнопки
    //И наоборот, призапуске программы, будет значок приложения
begin
    inherited;
    if not fIsChange then
        Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmAccounts.FormCreate(Sender: TObject);
begin
    appLoc.TranslateForm(Self);
    LoadLvFiles;
    if lvFiles.Items.Count > 5 then
        lvFiles.Column[0].Width:=(lvFiles.ClientRect.Width - 17);

    Logic.SetButtonImg(btnNewBasePath, imlAccounts, 3);
    Logic.SetButtonImg(btnGeneratePass, imlAccounts, 1);
    Logic.SetButtonImg(btnAdd, imlAccounts, 5);
    Logic.SetButtonImg(btnRemove, imlAccounts, 6);
    Logic.SetButtonImg(btnNew, imlAccounts, 4);
    Logic.SetButtonImg(btnDelete, imlAccounts, 10);
    chkShowPass.Checked:=xmlCfg.GetValue('ShowPasswordsInManager', True);
end;

procedure TfrmAccounts.LoadLvFiles;
var i: Integer;
begin
    lvFiles.Items.Clear;
    lblNoFiles.Visible:=(lsStoredDocs.Count = 0);
    for i := 0 to lsStoredDocs.Count - 1 do
        lvFiles.AddItem(lsStoredDocs[i], nil);
    if lsStoredDocs.Count <> 0 then lvFiles.ItemIndex:=0;
    if Self.Visible then
        OpenPreCheck;
end;

procedure TfrmAccounts.FormShow(Sender: TObject);
begin
//Self.Show;
WindowsOnTop(bWindowsOnTop, Self);
OpenPreCheck;
end;
//Precheck
function TfrmAccounts.OpenPreCheck(AlertMsg: Boolean = False): Boolean;
begin
    Result:= False;
    txtPass.Enabled:=False;
    txtPass.Text:='';
    txtPass.PasswordChar:=#0;
    txtPass.Font.Style:= [fsItalic];
    imgNotShallPass.Visible:=True;
    if lvFiles.Selected = nil then begin
        txtPass.Text:= appLoc.Strings('rsTxtPassFileNotSelected', rsTxtPassFileNotSelected);
        Exit;
    end;

    FFileName:=lvFiles.Selected.Caption;
    if not FileExists(FFileName) then begin      //Where is the file?
        txtPass.Text:= appLoc.Strings('rsTxtPassFileNotFound', rsTxtPassFileNotFound);
        lvFiles.Selected.ImageIndex:=8;
        Exit;
    end;

    if omgDoc<> nil then
        if FFilename = omgDoc.docFilePath then begin
            txtPass.Text := appLoc.Strings('rsTxtPassAlrOpened', rsTxtPassAlrOpened);
            imgNotShallPass.Visible:=False;
            Result:=False;
            if AlertMsg then Self.Close;
            Exit;
        end;
    if ExtractFileExt(FFileName) = strDefaultExt {*.xml?} then
        if DocumentPreOpenXML(FFileName, AlertMsg) then begin
            txtPass.Text:= appLoc.Strings('rsTxtPassPassNotReq', rsTxtPassPassNotReq);
            imgNotShallPass.Visible:=False;
            Result:=True;
        end else begin
            txtPass.Text:= appLoc.Strings('rsTxtPassFileIsBad', rsTxtPassFileIsBad);
            lvFiles.Selected.ImageIndex:=8;
        end
    else
        case DocumentPreOpenCrypted(FFileName, fPassword, AlertMsg) of
        idOk: begin
            if txtPass.Text = '' then begin
                txtPass.Text:= appLoc.Strings('rsTxtPassPassEmpty', rsTxtPassPassEmpty);
            end else begin
                txtPass.Enabled:=True;
                if not chkShowMainPass.Checked then txtPass.PasswordChar:=#149;
                txtPass.Font.Style:= [fsBold];
                if Self.Visible = True then txtPass.SetFocus;
            end;
            imgNotShallPass.Visible:=False;
            Result:=True;
            end;
        idTryAgain: begin
            txtPass.Enabled:=True;
            if not chkShowMainPass.Checked then txtPass.PasswordChar:=#149;
            txtPass.Font.Style:= [fsBold];
            if Self.Visible = True then txtPass.SetFocus;
            end;
        idCancel: begin
            txtPass.Text:= appLoc.Strings('rsTxtPassFileIsBad', rsTxtPassFileIsBad);
            lvFiles.Selected.ImageIndex:=8;
        end;
    end;
end;

procedure TfrmAccounts.lvFilesClick(Sender: TObject);
{$J+}
const LastSelected: String = '';                                                //Сохраняем имя ранее выбраного файла
{$J-}                                                                           //Сохранять позицию бесполезно
begin
    if lvFiles.Items.Count <> 0 then begin                                      
        if lvFiles.Selected = nil then 
            lvFiles.Items[lvFiles.Items.Count - 1].Selected:=True;
    
        if lvFiles.Selected.Caption = LastSelected then begin
            if txtPass.Enabled then txtPass.SetFocus;                           //Чтобы не стереть ранее введенный пароль
            Exit;                                                               //Пречек не выполняется
        end;
        LastSelected:= lvFiles.Selected.Caption;
    end;
    fPassword:='';                                                              //Через эту переменную передается пароль
    OpenPreCheck;                                                               //Обнуляем её перед проверкой для проверки 
end;                                                                            //файлов с пустыми паролями

procedure TfrmAccounts.lvFilesDblClick(Sender: TObject);
begin
if lvFiles.Items.Count = 0 then Exit;
if lvFiles.Selected = nil then
    lvFiles.Items[lvFiles.Items.Count - 1].Selected:=True
else
    btnOk.Click;
end;

procedure TfrmAccounts.tmrEnterTimer(Sender: TObject);
begin
    tmrEnter.Tag:= tmrEnter.Tag - 1;
    if tmrEnter.Tag = 0 then
        btnOk.Click
    else
        btnOk.Caption:= rsOpen + '[' + IntToStr(tmrEnter.Tag) + ']';
end;

procedure TfrmAccounts.tsNewShow(Sender: TObject);
//Две кнопочки, чтобы не вешать на одну кучу условий
//Соответственно прячем одну или другую см. TfrmAccounts.tsOpenShow
begin
    btnCreateNewBase.Visible:=True;
    btnOK.Visible:=False;
end;

procedure TfrmAccounts.tsOpenShow(Sender: TObject);
begin
    btnCreateNewBase.Visible:=False;
    btnOK.Visible:=True;
end;

procedure TfrmAccounts.txtPassChange(Sender: TObject);
var
    RightPass: Boolean;
begin
    if not txtPass.Enabled then Exit;
    RightPass:= (DocumentPreOpenCrypted(FFileName, txtPass.Text) = idOk);
    imgNotShallPass.Visible:= not RightPass;
    if RightPass and xmlCfg.GetValue('AutoLogin', True) then begin
        tmrEnter.Tag:= xmlCfg.GetValue('AutoLoginTime', 5);
        if tmrEnter.Tag = 0 then
            btnOk.Click
        else
            btnOk.Caption:= rsOpen + '[' + IntToStr(tmrEnter.Tag) + ']';
        btnOk.SetFocus;
        tmrEnter.Enabled:= True;
    end;
end;

procedure TfrmAccounts.btnAddClick(Sender: TObject);
begin
    With OpenDialog do begin
        DefaultExt:=strCryptedExt;
        Title:=rsOpenDialogTitle;
        Filter:=rsOpenDialogFilter;
        if Execute then begin;
            AddReloadStoredDocs(FileName);
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
begin
    if txtNewBase.Text = '' then begin
        MessageBox(Self.Handle,
            PWideChar(rsCreateNewNeedFile),
            PWideChar(rsCreateNewNeedFileTitle),
            MB_OK + MB_ICONWARNING);
        btnNewBasePath.Click;
        Exit;
    end;
    if not chkShowPass.Checked and (txtNewPass.Text <> txtNewPassConfirm.Text) then begin
        MessageBox(Self.Handle,
            PWideChar(rsCreateNewWrongConfirm),
            PWideChar(rsCreateNewWrongConfirmTitle),
            MB_OK + MB_ICONWARNING);
        txtNewPassConfirm.SetFocus;
        Exit;
    end;

    if not CreateNewBase(txtNewBase.Text, txtNewPass.Text) then Exit;
    AddReloadStoredDocs(txtNewBase.Text);
    txtNewBase.Clear;
    txtNewPass.Clear;
    Beep;
    pcAccounts.Pages[tsOpen.PageIndex].Show;
    LoadLvFiles;
end;

procedure TfrmAccounts.btnDeleteClick(Sender: TObject);
function Del2RecycleBin(FileName: string; Wnd: HWND = 0): Boolean;
var
  FileOp: TSHFileOpStruct;
begin
  FillChar(FileOp, SizeOf(FileOp), 0);
  if Wnd = 0 then
    Wnd := Application.Handle;
  FileOp.Wnd := Wnd;
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PChar(FileName + #0#0);
  FileOp.fFlags := FOF_ALLOWUNDO or FOF_NOERRORUI or FOF_SILENT;
  Result := (SHFileOperation(FileOp) = 0) and (not
    FileOp.fAnyOperationsAborted);
end;

begin
try
    if lvFiles.Selected = nil then Exit;
//    if MessageBox(Self.Handle,
//       PWideChar(Format(rsDeletingDocument, [lvFiles.Selected.Caption])),
//       PWideChar(rsDeletingDocumentTitle),
//       MB_OKCANCEL + MB_DEFBUTTON3 + MB_APPLMODAL + MB_ICONWARNING) = idOK then
            if Del2RecycleBin(lvFiles.Selected.Caption, Self.Handle) then begin
                RemoveStoredDocs(lvFiles.Selected.Caption);
                LoadLvFiles;
            end;
except
    on e: Exception do ErrorLog(e, 'DeletingDocument');
end;

end;

procedure TfrmAccounts.btnGeneratePassClick(Sender: TObject);
begin
if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(Self);
//frmGenerator.formType:= 0;
if frmGenerator.ShowModal = mrOk then begin
  txtNewPass.Text:= frmGenerator.lblResult.Caption;
  txtNewPassConfirm.Text:= frmGenerator.lblResult.Caption;
end;
FreeAndNil(frmGenerator);
end;

procedure TfrmAccounts.btnNewBasePathClick(Sender: TObject);
var Accept: Boolean;
begin
With SaveDialog do begin
    DefaultExt:=strDefaultExt;
    Title:= rsSaveDialogTitle;
    Filter:= rsSaveDialogFilter;
    FileName:=strSaveDialogDefFileName;
    Accept:=False;
    while not Accept do begin
        if not SaveDialog.Execute then exit;
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

procedure TfrmAccounts.chkShowMainPassClick(Sender: TObject);
begin
chkShowPass.Checked:= chkShowMainPass.Checked;
end;

procedure TfrmAccounts.chkShowPassClick(Sender: TObject);
begin
chkShowMainPass.Checked:= chkShowPass.Checked;
txtNewPassConfirm.Visible:= not chkShowPass.Checked;
lblPassConfirm.Visible:= not chkShowPass.Checked;
if chkShowPass.Checked then begin
  txtNewPassConfirm.PasswordChar:= #0;
  txtNewPass.PasswordChar:= #0;
  txtPass.PasswordChar:=#0;
end else begin
  txtNewPassConfirm.PasswordChar:= #149;
  txtNewPass.PasswordChar:= #149;
  if txtPass.Enabled then txtPass.PasswordChar:=#149;
end;
xmlCfg.SetValue('ShowPasswordsInManager', chkShowPass.Checked);

end;

//OK!
procedure TfrmAccounts.btnOKClick(Sender: TObject);
begin
    if lvFiles.Selected = nil then begin
        Beep;
        Exit;
    end;
    FFileName:=lvFiles.Selected.Caption;
    if txtPass.Enabled then FPassword:=txtPass.Text;
    if not FileExists(FFileName) then
        if MessageBox(Self.Handle,
            PWideChar(Format(rsFileNotFoundMsg,[FFileName])),
            PWideChar(rsFileNotFoundMsgTitle),
            MB_ICONWARNING + MB_OKCANCEL + MB_DEFBUTTON2 + MB_APPLMODAL) = ID_CANCEL
            then Exit
            else CreateNewBase(FFileName, '');
    if OpenPrecheck(True) then begin
        AddReloadStoredDocs(FFileName);
        Self.ModalResult:=mrOK;
    end;
end;

procedure TfrmAccounts.btnOKExit(Sender: TObject);
begin
    btnOK.Caption:= rsOpen;
    tmrEnter.Enabled:= False;
end;

procedure TfrmAccounts.btnRemoveClick(Sender: TObject);
begin
    if lvFiles.Selected = nil then Exit;
    RemoveStoredDocs(lvFiles.Selected.Caption);
    LoadLvFiles;
end;

end.
