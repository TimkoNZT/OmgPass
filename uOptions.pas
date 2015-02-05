unit uOptions;

interface

uses
Windows, SysUtils, Classes, Controls, Forms, StdCtrls, Vcl.ComCtrls, Vcl.ImgList;

type
  TfrmOptions = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnOK: TButton;
    CheckBox1: TCheckBox;
    UpDown1: TUpDown;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    TabSheet3: TTabSheet;
    CheckBox5: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    ImageList1: TImageList;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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

procedure TfrmOptions.btnOKClick(Sender: TObject);
begin
Self.BorderIcons:=[];
Self.Caption:='';
Self.ModalResult:=mrOk;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    //Self.ModalResult:=mrCancel;
end;

procedure TfrmOptions.FormShow(Sender: TObject);
begin
WindowsOnTop(bWindowsOnTop, Self);
end;

end.
