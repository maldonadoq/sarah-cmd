unit FuncParse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpexprpars, Forms, FrameGraphic, Integral, Intersection,
  FrameStrGrid, Dialogs, Interpolacion, Func, Edo, Matrices, Extrapolacion;

var
  ActualFrame, ExtraFrame: TFrame;

procedure ExprPlot(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprIntegrate(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprInterMeth(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprIntersection(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprInterpolation(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprEdo(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprMatrix(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
procedure ExprMethExtra(var Result: TFPExpressionResult; Const Args: TExprParameterArray);

implementation

function ReadDataExtra(data: string): TList;
var
  n,i: integer;
begin
  Result:= TList.Create;
  TFrame2(ExtraFrame).DataSG.LoadFromCSVFile(data);
  n:= TFrame2(ExtraFrame).DataSG.RowCount;
  for i:=0 to n-1 do
    Result.Add(TMPoint.Create(StrToFloat(TFrame2(ExtraFrame).DataSG.Cells[0,i]),StrToFloat(TFrame2(ExtraFrame).DataSG.Cells[1,i])))
end;

procedure ExprPlot(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
begin
  Result.resFloat:= 0;
  TFrame1(ActualFrame).Plotear(Args[0].ResString,ArgToFloat(Args[1]),ArgToFloat(Args[2]),ArgToFloat(Args[3]),False);
end;

procedure ExprIntegrate(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  MIn: TIntegral;
  a,b: real;
  n: integer;
begin
  a:= ArgToFloat(Args[1]);
  b:= ArgToFloat(Args[2]);
  n:= Round(ArgToFloat(Args[3]));
  MIn:= TIntegral.Create();
  case Args[4].ResString of
    'Trapecio': Result.resFloat:= MIn.Trapecio(a,b,Args[0].ResString,n);
    'Simpson1/3': Result.resFloat:= MIn.SimpsonI(a,b,Args[0].ResString,n);
    'Simpson3/8': Result.resFloat:= MIn.SimpsonII(a,b,Args[0].ResString,n);
    'Cuadratura': Result.resFloat:= MIn.CuadraturaGauss(a,b,Args[0].ResString,n);
    else Result.resFloat:= NULLF;
  end;
  TFrame1(ActualFrame).Plotear(Args[0].ResString,a-ShiftArea,b+ShiftArea,0.001,True);
end;

procedure ExprInterMeth(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  a,b,e: real;
  MInters: TMethIntersection;
  MTRB: TRB;
begin
  a:= ArgToFloat(Args[1]);
  b:= ArgToFloat(Args[2]);
  e:= ArgToFloat(Args[3]);
  MInters:= TMethIntersection.Create();
  case Args[4].ResString of
    'Bisect': MTRB:= MInters.MBisect(a,b,e,Args[0].ResString);
    'FalPos': MTRB:= MInters.MFalPos(a,b,e,Args[0].ResString);
    'Secant': MTRB:= MInters.MSecant(a,e,Args[0].ResString);
    'Newton': MTRB:= MInters.MNewton(a,e,Args[0].ResString,Args[5].ResString);
  end;
  Result.resFloat:= MTRB.Value;
  TFrame2(ActualFrame).PutSG(MTRB.MBox);
  MInters.Destroy();
end;

procedure ExprIntersection(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  a,b,e: real;
  MInters: TMethIntersection;
  fn,fx,gx: string;
  MS: TList;
begin

  fx:= Args[0].ResString;
  gx:= Args[1].ResString;
  a:= ArgToFloat(Args[2]);
  b:= ArgToFloat(Args[3]);
  e:= ArgToFloat(Args[4]);
  fn:= '('+fx+')-('+gx+')';

  MS:= TList.Create;
  MInters:= TMethIntersection.Create();
  TFrame1(ActualFrame).PlotearIntersection(fx,gx,a,b,0.01);

  MS:= MInters.MBoth(a,b,e,fn,fx);
  if(MS.Count=0) then Result.resString:= '  No Existe Intersection!!'
  else begin
    TFrame1(ActualFrame).PlotearPoints(MS,True);
    Result.resString:= PListToStr(MS);
  end;

  MInters.Destroy();
  MS.Destroy;
end;

procedure ExprInterpolation(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  base: string;
  MInterp: TInterpolacion;
  MList: TList;
  TM: TMPoint;
begin
  MList:= TList.Create;
  MInterp:= TInterpolacion.Create();
  base:= Args[0].ResString;
  MList:= StrToBase(base);
  TM:= XIntervalo(MList);
  case Args[1].ResString of
    'Lagrange': Result.resString:= MInterp.Lagrange(MList);
  end;

  if(MList.Count<>0) then begin
    TFrame1(ActualFrame).Plotear(Result.resString,TM.x-ShiftArea,TM.y+ShiftArea,0.001,False);
    TFrame1(ActualFrame).PlotearPoints(MList,True);
  end;
end;

procedure ExprEdo(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  MEDO: TEDO;
  MB: TBox;
  xi,xf,xin,yin: real;
begin
  Result.resString:= '  No Existe Este Metodo';
  xi:=  ArgToFloat(Args[1]);
  xf:=  ArgToFloat(Args[2]);
  xin:= ArgToFloat(Args[3]);
  yin:= ArgToFloat(Args[4]);

  MEDO:= TEDO.Create();
  case Args[5].ResString of
    'Euler':      MB:= MEDO.Euler(xi,xf,xin,yin,Args[0].ResString,'');
    'Heun':       MB:= MEDO.Heun(xi,xf,xin,yin,Args[0].ResString,'');
    'RungeKutta': MB:= MEDO.RungeKutta4(xi,xf,xin,yin,Args[0].ResString,'');
    'Dormand':    MB:= MEDO.DormandPrince(xi,xf,xin,yin,Args[0].ResString,'');
    else Exit;
  end;

  case Args[6].ResString of
    'Table': TFrame2(ActualFrame).PutSG(MB);
    'Graphic': TFrame1(ActualFrame).PlotearPointFunct(TBoxToTLP(1,2,MB));
  end;
  Result.resString:= '';
  MEDO.Destroy();
  MB.Destroy();
end;

procedure ExprMatrix(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  ma,mb,cs: string;
  det: TRD;
  TMA,TMB,TMR: TMatriz;
begin
  ma:= Args[0].ResString;
  mb:= Args[1].ResString;
  cs:= Args[3].ResString;
  TMR:= TMatriz.Create(0,0);

  TMA:= StrToMatriz(ma);
  TMB:= StrToMatriz(mb);
  if ((TMA.x=0) or (TMA.y=0)) and ((TMB.x=0) or (TMB.y=0)) then begin
    Result.resString:= '  Wrong!! Matriz Example '+#39+'[a00,a01:a10,a11]'+#39;
    Exit;
  end;

  Result.resString:= '  No Exite Esta Operación';
  case cs of
    '+': TMR:= TMA+TMB;
    '-': TMR:= TMA-TMB;
    '*': TMR:= TMA*TMB;
    'esc': TMR:= TMA.Escalar(ArgToFloat(Args[2]));
    'pow': TMR:= TMA.MPower(Round(ArgToFloat(Args[2])));
    'tra': TMR:= TMA.Transpuesta();
    'inv': begin
      det:=TMA.Determinante();
      if(det.State and (det.Value<>0)) then begin
        TMR:= TMA.Inversa(det.Value);
        Result.resString:= TMR.ToStr;
      end
      else
        Result.resString:= '  No Tiene Inversa';
    end;
    'det': begin
      det:= TMA.Determinante();
      if det.State then Result.resString:= FloatToStr(det.Value)
      else Result.resString:= '  No Tiene Determinante';
    end;
    else Exit;
  end;

  if (cs<>'inv') and (cs<>'det') then begin
    if (TMR.x=0) and (TMR.y=0) then Result.resString:= '  Imposible Realizar Esta Operación Matricial!!'
    else Result.resString:= TMR.ToStr;
  end;
  TMA.Destroy(); TMB.Destroy(); TMR.Destroy();
end;

procedure ExprMethExtra(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  MEX: TExtrapolation;
  data: string;
  MPD: TList;
  TM: TMPoint;
  MTRS: TSRA;
begin
  data:= Args[0].ResString;
  MPD := ReadDataExtra(data);
  if MPD.Count<>0 then begin
    TM:= XIntervalo(MPD);
    MEX:= TExtrapolation.Create(MPD,4);

    case Args[1].ResString of
      'Lineal':      MTRS:= MEX.MLineal();
      'Exponencial': MTRS:= MEX.MExponencial();
      'Logaritmo': MTRS:= MEX.MLogaritmo();
    end;

    if MTRS.State then begin
      Result.ResString:= 'f(x)= '+MTRS.s1+#13#10+'  R= '+MTRS.s2;
      TFrame1(ActualFrame).Plotear(MTRS.s1,TM.x,TM.y,0.001,False);
      TFrame1(ActualFrame).PlotearPoints(MPD,False);
    end
    else
      Result.ResString:= MTRS.s1;
    MEX.Destroy();
  end
  else
    Result.ResString:= 'Data Empty!!';

  MPD.Destroy;
end;

end.

