unit FuncParse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, fpexprpars, Forms, FrameGraphic;

var
  ActualFrame: TFrame;

function IsNumber(AValue: TExprFloat): Boolean;
procedure ExprPlot( var Result: TFPExpressionResult; Const Args: TExprParameterArray);

implementation

function IsNumber(AValue: TExprFloat): Boolean;
begin
  result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;

procedure ExprPlot( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: real;
begin
  WriteLn(Args[0].ResString);
  Result.resFloat:= 0.01;
  TFrame1(ActualFrame).Plotear(Args[0].ResString,ArgToFloat(Args[1]),ArgToFloat(Args[2]),ArgToFloat(Args[3]));
end;

end.

