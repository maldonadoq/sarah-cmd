unit Extrapolacion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Func, Math, ParseMath;

type
  TExtrapolation = class
    constructor Create(M: TList; dc: integer);
    destructor Destroy(); override;
    public
      MDP: TList;
      Xm, Ym: real;
      Ndc: integer;
      MParse: TParseMath;
      function MLineal(): TSRA;
      function MExponencial(): TSRA;
      function Func(x: real; fn: string): real;
      function MR(fn: string; MP: TList): real;
  end;

implementation

constructor TExtrapolation.Create(M: TList; dc: integer);
var
  i: integer;
  TM: TMPoint;
begin
  MDP:= M; Xm:= 0; Ym:= 0;
  for i:=0 to MDP.Count-1 do begin
    TM:= TMPoint(MDP.Items[i]);
    Xm := Xm + TM.x;
    Ym := Ym + TM.y;
  end;

  Xm:= Xm/MDP.Count; Ym:= Ym/MDP.Count;
  Ndc:= dc;
  MParse:= TParseMath.Create();
  MParse.AddVariable('x',0);
end;

destructor TExtrapolation.Destroy();
begin
end;

function TExtrapolation.MR(fn: string; MP: TList): real;
var
  i: integer;
  fs, ss: real;
  TM: TMPoint;
begin
  fs := 0; ss := 0;
  for i:=0 to MP.Count-1 do begin
    TM:= TMPoint(MP.Items[i]);
    fs:= fs+Power(Func(TM.x,fn)-Ym,2);
    ss:= ss+Power(TM.y-Ym,2);
  end;
  Result := sqrt(fs/ss);
end;

function TExtrapolation.Func(x: real; fn: string): real;
begin
  MParse.NewValue('x',x);
  MParse.Expression:= fn;
  Result:= MParse.Evaluate();
end;

function TExtrapolation.MLineal(): TSRA;
var
  i: integer;
  fs, ss, bt: real;
  MP: TMPoint;
  Sol: string;
begin
  fs := 0; ss := 0;
  for i := 0 to MDP.Count-1 do begin
    MP:= TMPoint(MDP.Items[i]);
    fs := fs + ((MP.y-Ym)*(MP.x-Xm));
    ss := ss + Power(Xm-MP.x, 2);
  end;
  bt:= Ym-((fs/ss)*Xm);
  if bt<0 then
    Sol:= Format('(%*.*f*x)-%*.*f',[0,Ndc,fs/ss,0,Ndc,Abs(bt)])
  else
    Sol:= Format('(%*.*f*x)+%*.*f',[0,Ndc,fs/ss,0,Ndc,bt]);

  Result.State:= True;
  Result.s1 := Sol;
  Result.s2:= Format('%*.*f',[0,Ndc,MR(Sol,MDP)]);
end;

function TExtrapolation.MExponencial(): TSRA;
var
  i: integer;
  Ymt, c, A, fs, ss: real;
  Sol,Solt: string;
  TP: TMPoint;
  ML: TList;
begin
  ML:= TList.Create;
  Ymt := 0;
  for i:=0 to MDP.Count-1 do begin
    TP:= TMPoint(MDP.Items[i]);
    if(TP.y<=0) then begin
      Result.State:= False;
      exit;
    end;
    Ymt := Ymt + Ln(TP.y);
    ML.Add(TMPoint.Create(TP.x,Ln(TP.y)));
  end;

  Ymt := Ymt/MDP.Count;
  fs := 0; ss := 0;
  for i:=0 to ML.Count-1 do begin
    TP:= TMPoint(ML.Items[i]);
    fs := fs + ((TP.y-Ymt)*(TP.x-Xm));
    ss := ss + Power(Xm-TP.x,2);
  end;

  c := fs/ss;
  A := exp(Ymt-(c*Xm));

  if c<0 then begin
    Sol:= Format('%*.*f*exp(-x*%*.*f)',[0,Ndc,A,0,Ndc,Abs(c)]);
    Solt:= FloatToStr((Ymt-(c*Xm)))+'-(x*'+FloatToStr(Abs(c))+')';
  end
  else begin
    Sol:= Format('%*.*f*exp(x*%*.*f)',[0,Ndc,A,0,Ndc,c]);
    Solt:= FloatToStr((Ymt-(c*Xm)))+'+(x*'+FloatToStr(c)+')';
  end;

  WriteLn(Solt);
  Result.State:= True;
  Result.s1:= Sol;
  Result.s2:= Format('%*.*f',[0,Ndc,MR(Solt,ML)]);
end;

end.

