unit FuncParse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, fpexprpars, Forms, FrameGraphic, Integral;

var
  ActualFrame: TFrame;

function IsNumber(AValue: TExprFloat): Boolean;
procedure ExprPlot( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprIntegrate( var Result: TFPExpressionResult; Const Args: TExprParameterArray);

implementation

function IsNumber(AValue: TExprFloat): Boolean;
begin
  result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;

procedure ExprPlot( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
begin
  Result.resFloat:= 0.01;
  TFrame1(ActualFrame).Plotear(Args[0].ResString,ArgToFloat(Args[1]),ArgToFloat(Args[2]),ArgToFloat(Args[3]));
end;

procedure ExprIntegrate( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  MIn: TIntegral;
begin
  MIn:= TIntegral.Create();
  case Args[4].ResString of
    'Trapecio': Result.resFloat:= MIn.Trapecio(ArgToFloat(Args[1]),ArgToFloat(Args[2]),Args[0].ResString,Round(ArgToFloat(Args[3])));
    'Simpson1/3': Result.resFloat:= MIn.SimpsonI(ArgToFloat(Args[1]),ArgToFloat(Args[2]),Args[0].ResString,Round(ArgToFloat(Args[3])));
    'Simpson3/8': Result.resFloat:= MIn.SimpsonII(ArgToFloat(Args[1]),ArgToFloat(Args[2]),Args[0].ResString,Round(ArgToFloat(Args[3])));
    'Cuadratura': Result.resFloat:= MIn.CuadraturaGauss(ArgToFloat(Args[1]),ArgToFloat(Args[2]),Args[0].ResString,Round(ArgToFloat(Args[3])));
  end;
  TFrame1(ActualFrame).Plotear(Args[0].ResString,ArgToFloat(Args[1])-2,ArgToFloat(Args[2])+2,0.001);
end;

end.

