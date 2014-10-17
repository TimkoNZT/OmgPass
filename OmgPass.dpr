program OmgPass;



uses
  Vcl.Forms,
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
  Vcl.Themes,
  Vcl.Styles,
  uLog in 'uLog.pas' {frmLog},
  uEditField in 'uEditField.pas' {frmEditField},
  uCustomEdit in 'uCustomEdit.pas',
  uSettings in 'uSettings.pas',
  uStrings in 'uStrings.pas',
  uFolderFrame in 'uFolderFrame.pas' {FolderFrame: TFrame},
  uFolderFrameInfo in 'uFolderFrameInfo.pas' {FolderFrameInfo: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
