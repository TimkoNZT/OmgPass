program OmgPass;



uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uMain in 'uMain.pas' {frmMain},
  Logic in 'Logic.pas',
  uOptions in 'uOptions.pas' {frmOptions},
  uAccounts in 'uAccounts.pas' {frmAccounts},
  uGenerator in 'uGenerator.pas' {frmGenerator},
  XMLutils in 'XMLutils.pas',
  VersionUtils in 'VersionUtils.pas',
  uProperties in 'uProperties.pas' {frmProperties},
  uFieldFrame in 'uFieldFrame.pas' {FieldFrame: TFrame},
  uSmartMethods in 'uSmartMethods.pas',
  uEditItem in 'uEditItem.pas' {frmEditItem},
  uConsole in 'uConsole.pas' {frmLog},
  uEditField in 'uEditField.pas' {frmEditField},
  uCustomEdit in 'uCustomEdit.pas',
  uSettings in 'uSettings.pas',
  uStrings in 'uStrings.pas',
  uFolderFrame in 'uFolderFrame.pas' {FolderFrame: TFrame},
  uFolderFrameInfo in 'uFolderFrameInfo.pas' {FolderFrameInfo: TFrame},
  uMD5 in 'uMD5.pas',
  uDocument in 'uDocument.pas',
  uCrypt in 'uCrypt.pas',
  WCrypt2 in 'WCrypt2.pas',
  uLog in 'uLog.pas',
  uPassword in 'uPassword.pas' {frmPassword};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPassword, frmPassword);
  Application.Run;
end.
