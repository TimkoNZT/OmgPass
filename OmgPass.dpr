program OmgPass;











{$R *.dres}

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uAccounts in 'uAccounts.pas' {frmAccounts},
  uMain in 'uMain.pas' {frmMain},
  Logic in 'Logic.pas',
  uOptions in 'uOptions.pas' {frmOptions},
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
  uDocument in 'uDocument.pas',
  uCrypt in 'uCrypt.pas',
  WCrypt2 in 'WCrypt2.pas',
  uLog in 'uLog.pas',
  uPassword in 'uPassword.pas' {frmPassword},
  uCustomSplitter in 'uCustomSplitter.pas',
  RyMenus in 'RyMenus.pas',
  uLocalization in 'uLocalization.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Omg!Pass';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
