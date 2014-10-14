{Animated Ellipse Style
by Fred van Stappen
fiens@hotmail.com
}

unit fpg_style_anim_ellipse_silver_horz;

{$mode objfpc}{$H+}

interface

uses
  Classes, fpg_main, fpg_base;

type

  TExtStyle = class(TfpgStyle)
  private
    fadein: boolean;
    FTimer, FPressTimer: TfpgTimer;
    i: integer;
    fbutton: TfpgWindowBase;
    procedure TimerFired(Sender: TObject);
    procedure TimerPressed(Sender: TObject);

  public
    constructor Create; override;
    { General }
    procedure DrawControlFrame(ACanvas: TfpgCanvas; x, y, w, h: TfpgCoord); override;
    { Buttons }
    procedure DrawButtonFace(ACanvas: TfpgCanvas; x, y, w, h: TfpgCoord;
      AFlags: TfpgButtonFlags); override;
    { Menus }
    procedure DrawMenuRow(ACanvas: TfpgCanvas; r: TfpgRect;
      AFlags: TfpgMenuItemFlags); override;
    procedure DrawMenuBar(ACanvas: TfpgCanvas; r: TfpgRect;
      ABackgroundColor: TfpgColor); override;
    function HasButtonHoverEffect: boolean; override;
  end;


implementation

uses
  fpg_stylemanager,
  fpg_widget;

{ TExtStyle }

var
  waspressed: boolean;

constructor TExtStyle.Create;
begin
  inherited Create;
  fpgSetNamedColor(clWindowBackground, TfpgColor($eeeeec));
  FTimer := TfpgTimer.Create(200);
  FTimer.OnTimer := @TimerFired;

  FPressTimer := TfpgTimer.Create(1500);
  FPressTimer.OnTimer := @TimerPressed;
  FPressTimer.Enabled := False;
  i := 2;
  waspressed := False;
end;

procedure TExtStyle.TimerPressed(Sender: TObject);
begin
  FPressTimer.Enabled := False;
  waspressed := False;
end;

procedure TExtStyle.TimerFired(Sender: TObject);
begin
  FTimer.Enabled := False;
  if fadein = True then
  begin
    Inc(i);
    if i > 4 then
    begin
      fadein := False;
    end;
  end
  else
  begin
    Dec(i);
    if i < 1 then
    begin
      fadein := True;
    end;
  end;

  if Assigned(fbutton) then
    TfpgWidget(fbutton).Invalidate;
end;

function TExtStyle.HasButtonHoverEffect: boolean;
begin
  Result := True;
end;

procedure TExtStyle.DrawControlFrame(ACanvas: TfpgCanvas; x, y, w, h: TfpgCoord);
var
  r: TfpgRect;
begin
  r.SetRect(x, y, w, h);
  ACanvas.SetColor(clShadow1);
  ACanvas.Clear(clWindowBackground);
  ACanvas.DrawRectangle(r);
end;

procedure TExtStyle.DrawButtonFace(ACanvas: TfpgCanvas; x, y, w, h: TfpgCoord;
  AFlags: TfpgButtonFlags);
var
  r, r21, r22: TfpgRect;
begin
  FTimer.Enabled := False;
  r.SetRect(x, y, w, h);

  r21.SetRect(x, y, w div 2, h);

  r22.SetRect(x + (w div 2), y, w div 2, h);

  if btfIsDefault in AFlags then
  begin
    ACanvas.SetColor(TfpgColor($7b7b7b));
    ACanvas.SetLineStyle(1, lsSolid);
    ACanvas.DrawRectangle(r);
    InflateRect(r, -1, -1);
    Exclude(AFlags, btfIsDefault);
    fpgStyle.DrawButtonFace(ACanvas, r.Left, r.Top, r.Width, r.Height, AFlags);
    Exit; //==>
  end;

  // Clear the canvas
  ACanvas.SetColor(clWindowBackground);
  ACanvas.FillRectangle(r);

  if (btfFlat in AFlags) and not (btfIsPressed in AFlags) then
    Exit; // no need to go further

  // outer rectangle
  ACanvas.SetLineStyle(1, lsSolid);
  ACanvas.SetColor(clblack);
  ACanvas.DrawRectangle(r);

  // so we don't paint over the border
  InflateRect(r, -1, -1);
  // now paint the face of the button
  if (btfIsPressed in AFlags) or (btfHover in AFlags) then
  begin
    FTimer.Enabled := False;
    if ACanvas.Window.ClassName = 'TfpgButton' then
      if waspressed = False then
        fbutton := ACanvas.Window;

    if i = 0 then
      r21.SetRect(x, y, 1, h)
    else
      r21.SetRect(x, y, round(w * ((i) / 5)), h);

    if i = 5 then
      r22.SetRect(x + w, y, 1, h)
    else

      r22.SetRect(x + (i * (w div 5)), y, w - (i * (w div 5)), h);

    if (btfIsPressed in AFlags) then
    begin
      waspressed := True;
      FTimer.Enabled := False;
      FPressTimer.Enabled := False;
      ACanvas.GradientFill(r21, clWindowBackground, clLightgreen, gdHorizontal);
      ACanvas.GradientFill(r22, clLightgreen, clWindowBackground, gdHorizontal);
      fbutton := nil;
      FPressTimer.Enabled := True;
    end
    else
    begin
      ACanvas.GradientFill(r21, clWindowBackground, clLightYellow, gdHorizontal);
      ACanvas.GradientFill(r22, clLightYellow, clWindowBackground, gdHorizontal);
    end;

    ACanvas.SetColor(cldarkgray);
    ACanvas.DrawRectangle(r);
    InflateRect(r, -1, -1);
    if (btfHover in AFlags) then
      ACanvas.SetColor(clyellow)
    else
      ACanvas.SetColor(cllime);
    ACanvas.DrawRectangle(r);

  end
  else
  begin
    FTimer.Enabled := False;
    i := 2;
    fadein := True;
    ACanvas.GradientFill(r21, clsilver, clwhite, gdHorizontal);
    ACanvas.GradientFill(r22, clwhite, clsilver, gdHorizontal);

    ACanvas.SetColor(cldarkgray);
    ACanvas.DrawRectangle(r);

  end;
  ACanvas.SetColor(clWindowBackground);
  //  ACanvas.SetColor(cldarkgray);
  acanvas.DrawLine(0, 1, 1, 0);
  acanvas.DrawLine(0, 2, 2, 0);
  // ACanvas.SetColor(clgray);
  acanvas.DrawLine(0, 3, 3, 0);
  acanvas.DrawLine(0, 4, 4, 0);
  //  ACanvas.SetColor(clgray);
  acanvas.DrawLine(0, 5, 5, 0);
  ACanvas.SetColor(cldarkgray);
  acanvas.DrawLine(0, 6, 6, 0);

  ACanvas.SetColor(clWindowBackground);
  //  ACanvas.SetColor(cldarkgray);
  acanvas.DrawLine(w, 1, w - 1, 0);
  acanvas.DrawLine(w, 2, w - 2, 0);
  // ACanvas.SetColor(clgray);
  acanvas.DrawLine(w, 3, w - 3, 0);
  acanvas.DrawLine(w, 4, w - 4, 0);
  // ACanvas.SetColor(clgray);
  acanvas.DrawLine(w, 5, w - 5, 0);
  ACanvas.SetColor(cldarkgray);
  acanvas.DrawLine(w, 6, w - 6, 0);

  ACanvas.SetColor(clWindowBackground);
  acanvas.DrawLine(0, h - 1, 1, h);
  acanvas.DrawLine(0, h - 2, 2, h);
  // ACanvas.SetColor(clgray);
  acanvas.DrawLine(0, h - 3, 3, h);
  acanvas.DrawLine(0, h - 4, 4, h);
  //ACanvas.SetColor(clgray);
  acanvas.DrawLine(0, h - 5, 5, h);
  ACanvas.SetColor(cldarkgray);
  acanvas.DrawLine(0, h - 6, 6, h);

  ACanvas.SetColor(clgray);
  acanvas.DrawLine(w, h - 6, w - 6, h);
  ACanvas.SetColor(clWindowBackground);
  acanvas.DrawLine(w, h - 5, w - 5, h);
  acanvas.DrawLine(w - 4, h, w, h - 4);
  acanvas.DrawLine(w - 3, h, w, h - 3);
  ACanvas.SetColor(clgray);
  acanvas.DrawLine(w - 2, h, w, h - 2);
  acanvas.DrawLine(w - 1, h, w, h - 1);

  InflateRect(r, 1, 1);
  ACanvas.SetColor(clWindowBackground);
  ACanvas.DrawRectangle(r);

  if (waspressed = False) and (btfHover in AFlags) then
    FTimer.Enabled := True;

end;

procedure TExtStyle.DrawMenuRow(ACanvas: TfpgCanvas; r: TfpgRect;
  AFlags: TfpgMenuItemFlags);
var
  r21, r22: TfpgRect;
begin
  r21.Height := r.Height div 2;
  r21.Width := r.Width;
  r21.Top := r.top;
  r21.Left := r.Left;

  r22.Height := r.Height div 2;
  r22.Width := r.Width;
  r22.Top := r.top + r22.Height;
  r22.Left := r.Left;
  ACanvas.SetColor(clwhite);
  ACanvas.FillRectangle(r);
  inherited DrawMenuRow(ACanvas, r, AFlags);
  if (mifSelected in AFlags) and not (mifSeparator in AFlags) then
  begin
    ACanvas.GradientFill(r21, clsilver, clwhite, gdVertical);
    ACanvas.GradientFill(r22, clwhite, clsilver, gdVertical);
    ACanvas.SetColor(cldarkgray);
    ACanvas.SetTextColor(clblack);
    ACanvas.DrawRectangle(r);
    InflateRect(r, -1, -1);
    ACanvas.SetColor(cllime);
    ACanvas.DrawRectangle(r);
  end;
end;

procedure TExtStyle.DrawMenuBar(ACanvas: TfpgCanvas; r: TfpgRect;
  ABackgroundColor: TfpgColor);
var
  FLightColor: TfpgColor;
  FDarkColor: TfpgColor;
begin

  FLightColor := TfpgColor($f0ece3);  // color at top of menu bar
  FDarkColor := TfpgColor($beb8a4);  // color at bottom of menu bar
  ACanvas.GradientFill(r, FLightColor, FDarkColor, gdVertical);

  // inner bottom line
  ACanvas.SetColor(clShadow1);
  ACanvas.DrawLine(r.Left, r.Bottom - 1, r.Right + 1, r.Bottom - 1);   // bottom
  // outer bottom line
  ACanvas.SetColor(clWhite);
  ACanvas.DrawLine(r.Left, r.Bottom, r.Right + 1, r.Bottom);   // bottom
end;


initialization
  fpgStyleManager.RegisterClass('Anim Ellipse Silver horz', TExtStyle);

end.
