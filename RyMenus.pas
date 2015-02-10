{***********************************************************************}
{                         Класс TRyMenu.                                }
{ Описание:                                                             }
{   * Принимает на себя отрисовку меню в стиле OfficeXP.                }
{                                                                       }
{ Версия  : 1.10, 15 апреля 2002 г.                                     }
{ Автор   : Алексей Румянцев.                                           }
{ E-mail  : skitl@mail.ru                                               }
{-----------------------------------------------------------------------}
{    Специально для Королевства Дельфи http://www.delphikingdom.com     }
{-----------------------------------------------------------------------}
{ Написано на Delphi5. Тестировалось на Win98. WinXP.                   }
{ В случае обнаружения ошибки или несовместимости с другими версиями    }
{ Delphi и Windows, просьба сообщить автору.                            }
{-----------------------------------------------------------------------}
{ P.S. Создавал для личной цели, потом решил адаптировать(привести      }
{ к читабельному виду) и прислать в Королевство, может кому-нибудь      }
{ понравится.                                                           }
{ Естественно не перекрываются никакие процедуры и функции стандартного }
{ меню, так что при необходимости легко будет от него отказаться.       }
{-----------------------------------------------------------------------}
{ HISTORY.                                                              }
{ 13.01.2002 - Появились первые пользователи - выплыли первые недочеты. }
{              Недочеты пока мелкие и их легче исправить чем описывать  }
{              здесь.                                                   }
{ 14.01.2002 - Сообщение о проблеме перерисовки верхней полоски         }
{              TMainMenu. Загвоздка в том, что непонятно от куда ноги у }
{              этой проблемы растут.                                    }
{   Описание : При RunTime'овом изменении OwnerDraw к положительному    }
{              значению, при любом из условий :                         }
{                а. нет ImageList'а                                     }
{                б. создании PageControl'а на форме                     }
{                в. в НЕ основных формах                                }
{              меню отказывается перерисовывать верхнюю полоску         }
{              TMainMenu, при чем без вопросов отрисовывая подменю.     }
{              При выставлении этого свойства в DesignTime,             }
{              проблем не возникает.                                    }
{   Вопрос :   Где искать причину ?                                     }
{ 15.01.2002 - Послана обновленная версия в Королевство.                }
{                                - - -                                  }
{ --.01.2002 - Смог разлядеть новый оффис. Стал сомневаться, что Office }
{              и WindowsXP в общем и Explorer6 в часности делала одна   }
{              компания.                                                }
{              А я еще хотел купить лицензионный WinXP, но пока         }
{              не выпустят как минимум вторую редакцию я остаюсь        }
{              в стареньком Win98.                                      }
{ --.01.2002 - Видел Delphi6. Ну надо же! оказалось без патчей в ней не }
{              всё работает. Пока остаюсь в 5-ой.                       }
{                                - - -                                  }
{ --.--.---- - Ответов на вопрос от 14.01.2002 не поступало,            }
{              но и вопросов на этот счет больше не было.               }
{ --.--.---- - Недавно видел платную библиотеку с компонентой типа      }
{              TMenu, но со стилем, поведением и отрисовкой как у       }
{              OfficeXP - красиво, основана видимо не на TMenu.         }
{              Остается надеяться что в ближайшее время какой-нибудь    }
{              умелец сообразит что-то подобное (бесплатно :o),         }
{              потому что, на то безобразие которое сделали в Delphi6   }
{              без тоски глядеть невозможно.                            }
{ 29.01.2002 - послана обновленная версия в Королевство.                }
{ 02.02.2002 - подправлена прорисовка картиночек в меню.                }
{ 03.02.2002 - послана обновленная версия в Королевство.                }
{ --.--.2002 - делал какие-то исправления, надеялся history написать    }
{              позже... позже оказалось, что лучше бы писал сразу :o)   }
{              короче говоря, по возможности, старался приблизиться к   }
{              оригиналу.                                               }
{ --.--.2002 - добавлено                                                }
{              property  MinHeight: Integer;                            }
{              property  MinWidth : Integer;                            }
{              если хочется чтобы пункты меню были не менее какой-то    }
{              определенной ширины и длинны                             }
{***********************************************************************}

unit RyMenus;

interface

{.$DEFINE RY}{<- не обращайте внимание и не изменяйте - это для личных целей}

uses Windows, SysUtils, Classes, Messages, Graphics, ImgList, Menus,
     Forms, Controls, Commctrl, uMain;

type
  TRyMenu = class(TObject)
  private
    FFont: TFont;
    FGutterColor: TColor;
    FMenuColor: TColor;
    FSelectedColor: TColor;
    FSelLightColor: TColor;
    FMinWidth: Integer;       
    FMinHeight: Integer;
    procedure SetFont(const Value: TFont);
    procedure SetSelectedColor(const Value: TColor);
    procedure SetMinHeight(const Value: Integer);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Menu: TMenu; Item: TMenuItem);
    procedure MeasureItem(Sender: TObject; ACanvas: TCanvas;
              var Width, Height: Integer);
    procedure AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
              ARect: TRect; State: TOwnerDrawState);
  public
    property  MenuColor: TColor read FMenuColor write FMenuColor;
    property  GutterColor: TColor read FGutterColor write FGutterColor;
    property  SelectedColor: TColor read FSelectedColor write SetSelectedColor;
    property  Font: TFont read FFont write SetFont; {можете поменять фонт у меню}
    property  MinHeight: Integer read FMinHeight write SetMinHeight;
    property  MinWidth: Integer read FMinWidth write FMinWidth;
  end;

var
  RyMenu: TRyMenu; {это чтобы вам не мучиться - для каждого меню создавать
  свой TRyMenu. он инициализируется сам и рисует все в стандартные цвета.}

implementation

{$IFDEF RY}
uses RyUtils, RyClassesUtils;
{$ELSE}
type
  TRGB = packed record
    R, G, B: Byte;
  end;
{$ENDIF RY}

var
{$IFNDEF RY}
  FMonoBitmap : TBitmap;
{$ENDIF RY}
  BmpCheck: array[Boolean] of TBitmap; {две bmp 12x12 для чекнутых пунктов меню}

{$IFNDEF RY}
function Max(A, B: Integer): Integer;
begin
  if A < B then Result := B
  else Result := A
end;

{Раскладывает колор на составные части}
function GetRGB(const Color: TColor): TRGB;
var
  iColor: TColor;
begin
  iColor := ColorToRGB(Color);
  Result.R := GetRValue(iColor);
  Result.G := GetGValue(iColor);
  Result.B := GetBValue(iColor);
end;

{получаем бледный цвет}
function GetLightColor(const Color: TColor; const Light: Byte) : TColor;
var
  fFrom: TRGB;
begin
  FFrom := GetRGB(Color);

  Result := RGB(
    Round(FFrom.R + (255 - FFrom.R) * (Light / 100)),
    Round(FFrom.G + (255 - FFrom.G) * (Light / 100)),
    Round(FFrom.B + (255 - FFrom.B) * (Light / 100))
  );
end;
{$ENDIF RY}

{ TRyMenuItem }

constructor TRyMenu.Create;
begin
  FGutterColor := clBtnFace; {серая полоска}
  FMenuColor := GetLightColor(clBtnFace, 85);
  FSelectedColor := GetLightColor(clHighlight, 65);{выделенный пункт меню}
  FSelLightColor := GetLightColor(clHighlight, 75);
  FMinWidth := 0;
  FMinHeight:= 18;
  FFont := TFont.Create;
  Font := Screen.MenuFont;{получает фонт стандартного меню}
end;

destructor TRyMenu.Destroy;
begin
  FFont.Free;
  inherited;
end;

{
  чтобы самому не перичислять все итемы меню, вызовите эту процедуру,
  передав в качестве параметра  либо само меню  либо какой либо итем,
  указав в качестве другого параметра NIL
}
procedure TRyMenu.Add(Menu: TMenu; Item: TMenuItem);

  procedure InitItem(Item : TMenuItem);
  begin
    Item.OnAdvancedDrawItem := Self.AdvancedDrawItem;
    if not (Item.GetParentComponent is TMainMenu) then
      Item.OnMeasureItem := Self.MeasureItem;
  end;

  procedure InitItems(Item : TMenuItem);
  {бежит по всем пунктам, при случае заглядывая в подпункты}
  var
    I: Word;
  begin
    I := 0;
    while I < Item.Count do
    begin
      InitItem(Item[I]);
      if Item[I].Count > 0 then InitItems(Item[I]);
      Inc(I);
    end;
  end;

begin
  if Assigned(Menu) then
  begin
    InitItems(Menu.Items);
    Menu.OwnerDraw := True; {Прошу знающих людей обратить на этот момент внимание
    и помоч разобраться. описание проблемы в History от 14.01.2002.}
  end;
  if Assigned(Item) then
  begin
    InitItem(Item);
    InitItems(Item);
  end;
end;

{собственно отрисовка-c}
procedure TRyMenu.AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
          ARect: TRect; State: TOwnerDrawState);

  {$IFNDEF RY}
  procedure GetBmpFromImgList(ABmp: TBitmap; AImgList: TCustomImageList;
            const ImageIndex: Word);
  begin
    with ABmp do
    begin
      Width := AImgList.Width;
      Height := AImgList.Height;
      Canvas.Brush.Color := clWhite;
      Canvas.FillRect(Rect(0, 0, Width, Height));
      ImageList_DrawEx(AImgList.Handle, ImageIndex,
        Canvas.Handle, 0, 0, 0, 0, CLR_DEFAULT, 0, ILD_NORMAL);
    end
  end;

  procedure DoDrawMonoBmp(ACanvas: TCanvas; const AMonoColor: TColor;
            const ALeft, ATop: Integer);
  const
    ROP_DSPDxax = $00E20746;{<-- скопировано из ImgList.TCustomImageList.DoDraw()}
  begin
    with ACanvas do
    begin
      Brush.Color := AMonoColor;
      Windows.SetTextColor(Handle, clWhite);
      Windows.SetBkColor(Handle, clBlack);
      BitBlt(Handle, ALeft, ATop, FMonoBitmap.Width, FMonoBitmap.Height,
             FMonoBitmap.Canvas.Handle, 0, 0, ROP_DSPDxax);
    end
  end;
  {$ENDIF RY}

const
  {текстовые флаги}
  _Flags: LongInt = DT_NOCLIP or DT_VCENTER or DT_END_ELLIPSIS or DT_SINGLELINE;
  _FlagsTopLevel: array[Boolean] of Longint = (DT_LEFT, DT_CENTER);
  _FlagsShortCut: {array[Boolean] of} Longint = (DT_RIGHT);
  _RectEl: array[Boolean] of Byte = (0, 6);{закругленный прямоугольник}
var
  TopLevel: Boolean;
  Gutter: Integer; {ширина серой полоски}
  ImageList: TCustomImageList;
begin
  with TMenuItem(Sender), ACanvas do
  begin
    TopLevel := GetParentComponent is TMainMenu;

    ImageList := GetImageList; {интиресуемся есть ли у меню ImageList}

    Font := FFont; {указываем канве каким фонтом пользоваться}

    if Assigned(ImageList) then
      Gutter := ImageList.Width + 9 {четыре точки до картинки + картинка + пять после}
    else
    if IsLine then
      Gutter := Max(TextHeight('W'), FMinHeight) + 4
    else
      Gutter := ARect.Bottom - ARect.Top + 4; {ширина = высоте + 2 + 2 точки}

    Pen.Color := clBlack;
    if (odSelected in State) then {если пункт меню выделен}
    begin
      Brush.Color := SelectedColor;
      Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
    end else
    if TopLevel then {если это полоска основного меню}
    begin
      if (odHotLight in State) then {если мышь над пунктом меню}
      begin
        Pen.Color := clBtnShadow;
        Brush.Color := FSelectedColor;
        Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
      end else
      begin
        Brush.Color := clBtnFace;
        FillRect(ARect);
      end
    end else
      begin {ничем не примечательный пункт меню}
        Brush.Color := GutterColor; {полоска}
        FillRect(Rect(ARect.Left, ARect.Top, Gutter, ARect.Bottom));
        Brush.Color := MenuColor;
        FillRect(Rect(Gutter, ARect.Top, ARect.Right, ARect.Bottom));
      end;

    if Checked then
    begin {подсвечиваем чекнутый пункт меню}
      Brush.Color := FSelLightColor;
      if Assigned(ImageList) and (ImageIndex > -1) then
         {если имеется картинка то рисуем квадратик вокруг нее}
        RoundRect(ARect.Left + 2, ARect.Top, Gutter - 2 - 1,
          ARect.Bottom, _RectEl[RadioItem], _RectEl[RadioItem])
      else {рисуем просто галочку}
      begin
        Rectangle((ARect.Left + 2 + Gutter - 1 - 2) div 2 - 8,
          (ARect.Top + ARect.Bottom) div 2 - 8,
          (ARect.Left + 2 + Gutter - 1 - 2) div 2 + 8,
          (ARect.Top + ARect.Bottom) div 2 + 8);
        Draw((ARect.Left + 2 + Gutter - 1 - 2 - BmpCheck[RadioItem].Width) div 2,
          (ARect.Top + ARect.Bottom - BmpCheck[RadioItem].Height) div 2,
          BmpCheck[RadioItem]);
      end
    end;

    if Assigned(ImageList) and ((ImageIndex > -1) and (not TopLevel)) then
      if Enabled then
        ImageList.Draw(ACanvas, ARect.Left + 4,
          (ARect.Top + ARect.Bottom - ImageList.Height) div 2,
          ImageIndex, True) {рисуем цветную картинку}
      else begin {рисуем погасшую картинку}
        GetBmpFromImgList(FMonoBitmap, ImageList, ImageIndex);
        DoDrawMonoBmp(ACanvas, clBtnShadow, ARect.Left + 4,
          (ARect.Top + ARect.Bottom - ImageList.Height) div 2);
      end;

    with Font do
    begin
      if (odDefault in State) then Style := [fsBold];
      if (odDisabled in State) then Color := clGray
      else Color := clBlack;
    end;

    Brush.Style := bsClear;
    if TopLevel then {пусто}
    else Inc(ARect.Left, Gutter + 5); {отступ для текста}

    if IsLine then {если разделитель}
    begin
      Pen.Color := clBtnShadow;
      MoveTo(ARect.Left, ARect.Top + (ARect.Bottom - ARect.Top) div 2);
      LineTo(ARect.Right, ARect.Top + (ARect.Bottom - ARect.Top) div 2);
    end else
    begin {текст меню}
      Windows.DrawText(Handle, PChar(Caption), Length(Caption), ARect,
        _Flags or _FlagsTopLevel[TopLevel]);
      if ShortCut <> 0 then {разпальцовка}
      begin
        Dec(ARect.Right, 5);
        Windows.DrawText(Handle, PChar(ShortCutToText(ShortCut)),
          Length(ShortCutToText(ShortCut)), ARect,
          _Flags or _FlagsShortCut);
      end
    end
  end
end;

{размеры меню}
procedure TRyMenu.MeasureItem(Sender: TObject; ACanvas: TCanvas;
          var Width, Height: Integer);
var
  ImageList: TCustomImageList;
begin
  with TMenuItem(Sender) do
  begin
    ImageList := GetImageList;
    ACanvas.Font := FFont; {указываем канве на наш фонт}
    if Assigned(ImageList) then
    begin
      if IsLine then
        if Max(FMinHeight, ImageList.Height) > 20 then {при большем 20 узкая полоска некрасива}
           Height := 11 else Height := 5
      else
        with ACanvas do
        begin
          Width := ImageList.Width;
          if Width < 8 then Width := 16 else Width := Width + 8;
          Width := Width + TextWidth(Caption + ShortCutToText(ShortCut)) + 15;
          Width := Max(Width, FMinWidth);

          Height := Max(ACanvas.TextHeight('W'), ImageList.Height);
          //if Height < 14 then Height := 18 else Height := Height + 4;
          Height := Max(Height + 4, FMinHeight);
        end
    end else
      with ACanvas do
      begin
        Height := Max(TextHeight('W'), FMinHeight);
        if IsLine then
          if Height > 20 then {при большем 20 узкая полоска некрасива}
             Height := 11 else Height := 5;
        Width := {Max(Height,} 20 + 15 +
          TextWidth(Caption + ShortCutToText(ShortCut));
        Width := Max(Width, FMinWidth);
      end
  end
end;

procedure TRyMenu.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TRyMenu.SetSelectedColor(const Value: TColor);
begin
  FSelectedColor := Value;
  FSelLightColor := GetLightColor(Value, 75);
end;

procedure InitBmp(Bmp: TBitmap; Radio: Boolean);
const
  pr : array[0..17] of array[0..1] of Byte = (
    (2, 6), (3, 7), (4, 8), (5, 9), (6, 8), (7, 7),
    (3, 6), (4, 7), (5, 8), (6, 7), (7, 6), (8, 5), (9, 4), (10, 3), (11, 2),
    (3, 5), (4, 6), (5, 7)
  );
  pc : array[0..23] of array[0..1] of Byte = (
    (3, 5), (3, 6), (4, 7), (5, 8), (6, 8), (7, 7), (8, 6), (8, 5),
    (7, 4), (6, 3), (5, 3), (4, 4), (4, 5), (4, 6), (5, 7), (6, 7),
    (7, 6), (7, 5), (6, 4), (5, 4), (5, 5), (5, 6), (6, 6), (6, 5)
  );
var
  I: Byte;
begin
  with Bmp, Canvas do  begin
    Width := 12;
    Height := 12;
    Monochrome := True;
    Transparent := True;
   //Pen.Color := clGreen;
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, Width, Height));
    if Radio then
      for I := Low(pc) to High(pc) do
        Pixels[pc[I, 0], pc[I, 1]] := clBlack
    else
      for I := Low(pr) to High(pr) do
        Pixels[pr[I, 0], pr[I, 1]] := clGreen;
  end;

end;

procedure TRyMenu.SetMinHeight(const Value: Integer);
begin
  FMinHeight := Max(18, Value);
end;

initialization
  BmpCheck[False]:= TBitmap.Create;
  BmpCheck[True]:= TBitmap.Create;
  InitBmp(BmpCheck[False], False);
  InitBmp(BmpCheck[True], True);
  {$IFNDEF RY}
  FMonoBitmap := TBitmap.Create;
  FMonoBitmap.Monochrome := True;
  {$ENDIF RY}
  RyMenu := TRyMenu.Create;

finalization
  {$IFNDEF RY}
  FMonoBitmap.Free;
  {$ENDIF RY}
  BmpCheck[False].Free;
  BmpCheck[True].Free;
  RyMenu.Free;

end.
