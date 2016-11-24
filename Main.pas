// 2016 Peter. S.
//
// License:
//
// The MIT License (MIT)
// Copyright © 2016 by Peter S. (http://anotheritstudent.blogspot.com/)
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the УSoftwareФ), to deal in the Software without restriction, 
// including without limitation the rights to use, copy, modify, merge, publish, distribute, 
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or 
// substantial portions of the Software.
// THE SOFTWARE IS PROVIDED УAS ISФ, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// ѕрограмма-пример построени€ 4-х графиков функций.
// — помощью мыши можно исследовать функции.  

unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.EditBox, FMX.NumberBox;

type
  TMainForm = class(TForm)
    Disp: TPaintBox;
    Panel1: TPanel;
    nbMinX: TNumberBox;
    Label1: TLabel;
    Label2: TLabel;
    nbMinY: TNumberBox;
    Label3: TLabel;
    nbMaxX: TNumberBox;
    Label4: TLabel;
    nbMaxY: TNumberBox;
    Label5: TLabel;
    nbDotX: TNumberBox;
    Label6: TLabel;
    nbDotY: TNumberBox;
    procedure DispPaint(Sender: TObject; Canvas: TCanvas);
    procedure ParamsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DispMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DispMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure DispMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    MinX, MaxX, DotX: Single;
    MinY, MaxY, DotY: Single;
    SX, SY: Single;
    IsMove: Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.Math;

type
  TFunction = reference to function (X: Single; var Y: Single): Boolean;

procedure TMainForm.DispMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  SX := X;
  SY := Y;
  IsMove := True;
end;

procedure TMainForm.DispMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  procedure UpdateNb;
  begin
    nbMinX.Value := MinX;
    nbMinY.Value := MinY;
    nbMaxX.Value := MaxX;
    nbMaxY.Value := MaxY;
  end;

var
  DX, DY: Single;
begin
  if IsMove then
  begin
    DX := (X - SX) * ((MaxX - MinX)/ Disp.Width);
    DY := (Y - SY) * ((MaxY - MinY)/ Disp.Height);
    MinX := MinX - DX;
    MinY := MinY + DY;
    MaxX := MaxX - DX;
    MaxY := MaxY + DY;
    SX := X;
    SY := Y;
    UpdateNb;
    Disp.Repaint;
  end;
end;

procedure TMainForm.DispMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  IsMove := False;
end;

procedure TMainForm.DispPaint(Sender: TObject; Canvas: TCanvas);
var
  W, H, CX: Single;

  function ToDispX(X: Single): Single;
  begin
    Result := (X - MinX) * (W / (MaxX - MinX));
  end;

  function ToDispY(Y: Single): Single;
  begin
    Result := (MaxY - Y) * (H / (MaxY - MinY));
  end;

  function ToGraphX(X: Single): Single;
  begin
    Result := (X - CX) * ((MaxX - MinX) / W);
  end;

  procedure DrawFunction(Canvas: TCanvas; Color: TAlphaColor; F: TFunction);
  var
    I: Integer;
    Y, OldY: Single;
    Twice: Boolean;
  begin
    Canvas.Stroke.Color := Color;
    Twice := False;
    for I := 0 to Trunc(W) do
    begin
      OldY := Y;
      if F(ToGraphX(I), Y) then
        if Twice then
          Canvas.DrawLine(PointF(I - 1, ToDispY(OldY)), PointF(I, ToDispY(Y)), 1)
        else
          Twice := True
      else
        Twice := False;
    end;
  end;

  procedure DrawText(Canvas: TCanvas; X, Y: Single; Text: string);
  begin
    Canvas.FillText(RectF(X, Y, X + Canvas.TextWidth(Text), Y + Canvas.TextHeight(Text)), Text,
      False, 1, [], TTextAlign.Leading);
  end;

var
  t: Single;
begin
  W := Disp.Width;
  H := Disp.Height;
  CX := ToDispX(0);

  // очищаем экран
  Canvas.Fill.Color := TAlphaColorRec.White;
  Canvas.FillRect(RectF(0, 0, W, H), 0, 0, AllCorners, 1);

  // –исуем оси
  Canvas.Stroke.Color := TAlphaColorRec.Black;
  // CX
  Canvas.DrawLine(
    PointF(0, ToDispY(0)),
    PointF(W, ToDispY(0)), 0.8);
  // CY
  Canvas.DrawLine(
    PointF(ToDispX(0), 0),
    PointF(ToDispX(0), H), 0.8);

  // –исуем метки
  Canvas.Fill.Color := TAlphaColorRec.Mediumblue;
  DrawText(Canvas, W - 10, ToDispY(0) - 20, 'X');// CX
  DrawText(Canvas, ToDispX(0) + 10, 0, 'Y');// CY

  // –исуем метки масштаба
  Canvas.Fill.Color := TAlphaColorRec.Fuchsia;
  DrawText(Canvas, ToDispX(DotX), ToDispY(0), FloatToStrF(DotX, TFloatFormat.ffGeneral, 0, 2));// CX
  DrawText(Canvas, ToDispX(0) + 3, ToDispY(-DotY), FloatToStrF(DotY, TFloatFormat.ffGeneral, 0, 2));// CY

  // Ќаносим "риски"
  // 0..MaxX
  t := DotX;
  while t <= MaxX do
  begin
    Canvas.DrawLine(PointF(ToDispX(t), ToDispY(0) - 2), PointF(ToDispX(t), ToDispY(0) + 2), 0.5);
    Canvas.DrawLine(PointF(ToDispX(t), 0), PointF(ToDispX(t), H), 0.1);
    t := t + DotX;
  end;
  // MixX..0
  t := -DotX;
  while t >= MinX do
  begin
    Canvas.DrawLine(PointF(ToDispX(t), ToDispY(0) - 2), PointF(ToDispX(t), ToDispY(0) + 2), 0.5);
    Canvas.DrawLine(PointF(ToDispX(t), 0), PointF(ToDispX(t), H), 0.1);
    t := t - DotX;
  end;
  // 0..MaxY
  t := DotY;
  while t <= MaxY do
  begin
    Canvas.DrawLine(PointF(ToDispX(0) - 2, ToDispY(t)), PointF(ToDispX(0) + 2, ToDispY(t)), 0.5);
    Canvas.DrawLine(PointF(0, ToDispY(t)), PointF(W, ToDispY(t)), 0.1);
    t := t + DotY;
  end;
  // MixY..0
  t := -DotY;
  while t >= MinY do
  begin
    Canvas.DrawLine(PointF(ToDispX(0) - 2, ToDispY(t)), PointF(ToDispX(0) + 2, ToDispY(t)), 0.5);
    Canvas.DrawLine(PointF(0, ToDispY(t)), PointF(W, ToDispY(t)), 0.1);
    t := t - DotY;
  end;

  // –исуем графики
  DrawFunction(Canvas, TAlphaColorRec.Blue,
    function(X: Single; var Y: Single): Boolean
    begin
      Result := True;
      Y := Sin(X);
    end);

  DrawFunction(Canvas, TAlphaColorRec.Red,
    function(X: Single; var Y: Single): Boolean
    begin
      Result := X * X <= 30;
      if Result then
        Y := Sqrt(30 - X*X);
    end);

  DrawFunction(Canvas, TAlphaColorRec.Green,
    function(X: Single; var Y: Single): Boolean
    begin
      Result := X <> 0;
      if Result then
        Y := Sin(X) / Cos(X);
    end);

  DrawFunction(Canvas, TAlphaColorRec.Orange,
    function(X: Single; var Y: Single): Boolean
    begin
      Result := X >= 0;
      if Result then
        Y := Sqrt(X) * 2;
    end);

  // –исуем описание
  Canvas.Fill.Color := TAlphaColorRec.Blue;
  DrawText(Canvas, 2, 0, 'Y = Sin(X)');
  Canvas.Fill.Color := TAlphaColorRec.Red;
  DrawText(Canvas, 2, 16, 'Y = Sqrt(30 - X*X)');
  Canvas.Fill.Color := TAlphaColorRec.Green;
  DrawText(Canvas, 2, 32, 'Y = Sin(X) / Cos(X)');
  Canvas.Fill.Color := TAlphaColorRec.Orange;
  DrawText(Canvas, 2, 48, 'Y = Sqrt(X) * 2');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Disp.AutoCapture := True;
  ParamsChange(nil);
end;

procedure TMainForm.ParamsChange(Sender: TObject);
begin
  if IsMove then
    Exit;
    
  MinX := nbMinX.Value;
  MinY := nbMinY.Value;
  MaxX := Max(nbMaxX.Value, MinX);
  MaxY := Max(nbMaxY.Value, MinY);
  DotX := nbDotX.Value;
  DotY := nbDotY.Value;
  Disp.Repaint;// перерисовка графика при изменении параметров

  nbMaxX.Value := MaxX;
  nbMaxY.Value := MaxY;
end;

end.
