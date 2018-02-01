unit FrameGraphic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, StdCtrls,
  ParseMath, Func, Math, TAChartUtils;

type

  { TFrame1 }

  TFrame1 = class(TFrame)
    Chart1: TChart;
    AreaDraw: TAreaSeries;
    GraficaIII: TLineSeries;
    GraficaII: TLineSeries;
    GraficaI: TLineSeries;
  public
    h: real;
    MParse: TParseMath;
    procedure Plotear(fn: string; xmin,xmax: real; state: boolean);
    procedure PlotearIntersection(f1,f2: string; xmin,xmax: real);
    procedure CreateParse;
    procedure PlotearPoints(MS: TList; Stick: boolean);
    procedure PlotearPointFunct(MS: TList);
    function Func(x: real; fn: string): real;
  private
end;

implementation

procedure TFrame1.CreateParse;
begin
  MParse:= TParseMath.Create;
  MParse.AddVariable('x',0);
  h:= 0.001;
end;

function TFrame1.Func(x: real; fn: string): real;
begin
  MParse.Expression:= fn;
  MParse.NewValue('x', x);
  Result:= MParse.Evaluate();
end;

procedure TFrame1.Plotear(fn: string; xmin,xmax: real; state: boolean);
var
  x,y,xmna,xmxa: Real;
begin
  x:= xmin;
  xmna:= xmin+ShiftArea;
  xmxa:= xmax-ShiftArea;
  CreateParse;
  GraficaI.Clear;
  AreaDraw.clear;
  if not state then begin
    with GraficaI do repeat
      AddXY(x,Func(x,fn));
      x:= x+h
    until(x>=xmax);
  end
  else begin
    with GraficaI do repeat
      y:= Func(x,fn);
      AddXY(x,y);
      if(x>=xmna) and (x<=xmxa) then
        AreaDraw.AddXY(x,y);
      x:= x+h
    until(x>=xmax);
  end;
end;

procedure TFrame1.PlotearIntersection(f1,f2: string; xmin,xmax: real);
var
  x: Real;
begin
  x:= xmin;
  CreateParse;
  GraficaI.Clear;
  GraficaII.Clear;
  with GraficaI do repeat
    AddXY(x,Func(x,f1));
    GraficaII.AddXY(x,Func(x,f2));
    x:= x+h
  until(x>=xmax);
end;

procedure TFrame1.PlotearPoints(MS: TList; Stick: boolean);
var
  i: integer;
  TM: TMPoint;
begin
  GraficaIII.ShowPoints:= True;
  if Stick then
    GraficaIII.Marks.Style:= smsValue;
  for i:=0 to MS.Count-1 do begin
    TM:= TMPoint(MS[i]);
    GraficaIII.AddXY(TM.x,TM.y);
    GraficaIII.AddXY(NaN,NaN);
  end;
end;

procedure TFrame1.PlotearPointFunct(MS: TList);
var
  i: integer;
  TM: TMPoint;
begin
  for i:=0 to MS.Count-1 do begin
    TM:= TMPoint(MS[i]);
    GraficaII.AddXY(TM.x,TM.y);
  end;
end;

{$R *.lfm}

end.
