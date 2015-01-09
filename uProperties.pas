unit uProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.StdCtrls, uLog;

type
  TfrmProperties = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    vleProp: TValueListEditor;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProperties: TfrmProperties;

implementation

{$R *.dfm}
uses Logic;
//Закрыть свойства
procedure TfrmProperties.btnCancelClick(Sender: TObject);
begin
	//frmProperties.Close;
	ModalResult:=mrCancel;
end;
//Сохранить и закрыть свойства
procedure TfrmProperties.btnOKClick(Sender: TObject);
var i: Integer;
begin
	log('Пытаемся изменить свойства');
	//Проверочка на валидность ввода

    {......................}

	With omgDoc.XML.DocumentElement.ChildNodes['Header'] do begin
    	for i := 0 to ChildNodes.Count - 1 do begin
//        	log(ChildNodes[i].NodeName);log(ChildNodes[i].Text); log(vleProp.Values[ChildNodes[i].NodeName]);
    		ChildNodes[i].Text:=vleProp.Values[ChildNodes[i].NodeName];
        end;
    end;
    //frmProperties.Close;
    ModalResult:=mrOK;
end;
//Заполнить свойства
//Сигнатура и версия БД берутся из атрибутов корня
//Изменяемые данные хранятся в элементе Header
procedure TfrmProperties.FormCreate(Sender: TObject);
var i: Integer;
begin
    vleProp.InsertRow('Сигнатура*', omgDoc.XML.DocumentElement.AttributeNodes['signature'].Text, True);
    vleProp.InsertRow('Версия БД*', omgDoc.XML.DocumentElement.AttributeNodes['version'].Text, True);
    vleProp.InsertRow('Путь файла*', omgDoc.XML.FileName, True);
    vleProp.InsertRow('Размер файла*', '42kB', True);
    With omgDoc.XML.DocumentElement.ChildNodes['Header'] do begin
        for i := 0 to ChildNodes.Count - 1 do
            vleProp.InsertRow(ChildNodes[i].NodeName, ChildNodes[i].Text, True);
    //	Старые методы
    //		vleProp.InsertRow('Заголовок', ChildNodes['Title'].Text, True);
    //  	vleProp.InsertRow('Автор', ChildNodes['Author'].Text, True);
    //  	vleProp.InsertRow('Владелец', ChildNodes['Owner'].Text, True);
    //  	vleProp.InsertRow('Дата', ChildNodes['Date'].Text, True);
    //    	vleProp.InsertRow('Пароль', ChildNodes['Password'].Text, True);
    end;
end;


procedure TfrmProperties.FormShow(Sender: TObject);
begin
WindowsOnTop(bWindowsOnTop, Self);
end;

end.
