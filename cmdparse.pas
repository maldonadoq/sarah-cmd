unit CmdParse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpexprpars, Dialogs, Forms, FuncParse;

type
  TCmdParse = Class
  public
    Expression: string;
    procedure NewValue(Variable:string; Value: Double);
    procedure AddVariable(Variable: string; Value: Double);
    procedure AddString( Variable: string; Value: string );
    function Evaluate(): Double;
    function EvaluateFunc(): String;
    constructor Create();
    destructor Destroy(); override;
  private
    FParser: TFPExpressionParser;
    identifier: array of TFPExprIdentifierDef;
    procedure AddFunctions();
  end;

implementation

constructor TCmdParse.Create;
begin
   FParser:= TFPExpressionParser.Create( nil );
   FParser.Builtins := [ bcMath ];
   AddFunctions();
end;

destructor TCmdParse.Destroy;
begin
  FParser.Destroy;
end;

procedure TCmdParse.NewValue( Variable: string; Value: Double );
begin
  FParser.IdentifierByName(Variable).AsFloat:= Value;
end;

function TCmdParse.Evaluate(): Double;
begin
  FParser.Expression:= Expression;
  Result:= ArgToFloat(FParser.Evaluate);
end;

function TCmdParse.EvaluateFunc(): String;
begin
  FParser.Expression:= Expression;
  Result:= (FParser.Evaluate).ResString;
end;

procedure TCmdParse.AddFunctions();
begin
  with FParser.Identifiers do begin
     AddFunction('plot', 'F', 'SFF', @ExprPlot);
     AddFunction('integrate', 'F', 'SFFFS', @ExprIntegrate);
     AddFunction('raiz', 'F', 'SFFFSS', @ExprInterMeth);
     AddFunction('intersection', 'S', 'SSFFF', @ExprIntersection);
     AddFunction('matrix', 'S', 'SSFS', @ExprMatrix);
     AddFunction('interpolation', 'S', 'SS', @ExprInterpolation);
     AddFunction('edo', 'S', 'SFFFFSS', @ExprEdo);
     AddFunction('extrapolation', 'S', 'SS', @ExprMethExtra);
     AddFunction('areaI', 'F', 'SFFF', @ExprAreaI);
     AddFunction('areaII', 'F', 'SS', @ExprAreaII);
  end
end;

procedure TCmdParse.AddVariable(Variable: string; Value: Double);
var Len: Integer;
begin
  Len:= Length(identifier)+1;
  SetLength(identifier,Len);
  identifier[Len-1]:= FParser.Identifiers.AddFloatVariable(Variable, Value);
end;

procedure TCmdParse.AddString( Variable: string; Value: string );
var Len: Integer;
begin
  Len:= length(identifier)+1;
  SetLength(identifier,Len);

  identifier[Len-1]:= FParser.Identifiers.AddStringVariable(Variable, Value);
end;

end.


