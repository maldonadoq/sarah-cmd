unit FrameGraphic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, StdCtrls,
  ParseMath;

type
  TFrame1 = class(TFrame)
    Chart1: TChart;
    GraficaI: TLineSeries;
  public
    MParse: TParseMath;
    procedure Plotear(fn: string; xmin,xmax,h: real);
    procedure CreateParse;
    function Func(x: real; fn: string): real;
  private
end;

implementation

procedure TFrame1.CreateParse;
begin
  MParse:= TParseMath.Create;
  MParse.AddVariable('x',0);
end;

function TFrame1.Func(x: real; fn: string): real;
begin
  MParse.Expression:= fn;
  MParse.NewValue('x', x);
  Result:= MParse.Evaluate();
end;

procedure TFrame1.Plotear(fn: string; xmin,xmax,h: real);
var
  x: Real;
begin
  x:= xmin;
  CreateParse;
  GraficaI.Clear;
  with GraficaI do repeat
    AddXY(x,Func(x,fn));
    x:= x+h
  until(x>=xmax);
end;

{$R *.lfm}

end.

