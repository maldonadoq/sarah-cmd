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
      function MLineal(): TSE;
      function MExponencial(): TSE;
      function MLogaritmo(): TSE;
      function MSenoidal(): TSE;
      function MBest(): TSRA;
      function Choose(op: string): TSRA;
      function ToStr(TM: TSE): TSRA;
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
  Ymt,fs, ss: real;
  TM: TMPoint;
begin
  fs := 0; ss := 0; Ymt:=0;
  for i:=0 to MP.Count-1 do
    Ymt:= Ymt+TMPoint(MP.Items[i]).y;

  Ymt:= Ymt/MP.Count;
  for i:=0 to MP.Count-1 do begin
    TM:= TMPoint(MP.Items[i]);
    fs:= fs+Power(Func(TM.x,fn)-Ymt,2);
    ss:= ss+Power(TM.y-Ymt,2);
  end;
  Result := sqrt(fs/ss);
end;

function TExtrapolation.Func(x: real; fn: string): real;
begin
  MParse.NewValue('x',x);
  MParse.Expression:= fn;
  Result:= MParse.Evaluate();
end;

function TExtrapolation.MLineal(): TSE;
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

  Result:= TSE.Create(True,Sol,MR(Sol,MDP));
end;

function TExtrapolation.MExponencial(): TSE;
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
      Result:= TSE.Create(False,'Variable y!<=0',0);
      Exit;
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

  Result:= TSE.Create(True,Sol,MR(Solt,ML));
end;

function TExtrapolation.MLogaritmo(): TSE;
var
  i: integer;
  slny,sln,slnp,m,b: real;
  Sol: string;
  TM: TMPoint;
begin
  slny:=0; sln:=0; slnp:=0;
  for i:=0 to MDP.Count-1 do begin
    TM:= TMPoint(MDP.Items[i]);
    if(TM.x<=0) then begin
      Result:= TSE.Create(False,'Variable x!<=0',0);
      Exit;
    end;
    slny:= slny+(Ln(TM.x)*TM.y);
    sln:= sln+Ln(TM.x);
    slnp:= slnp+Power(Ln(TM.x),2);
  end;

  m:= (slny-(Ym*sln))/(slnp-((sln/MDP.Count)*sln));
  b:= Ym-(m*(sln/MDP.Count));

  if(b<0) then
    Sol:= Format('(%*.*f*ln(x))-%*.*f',[0,Ndc,m,0,Ndc,Abs(b)])
  else
    Sol:= Format('(%*.*f*ln(x))+%*.*f',[0,Ndc,m,0,Ndc,b]);

  Result:= TSE.Create(True,Sol,MR(Sol,MDP));
end;

function TExtrapolation.MSenoidal(): TSE;
begin
  Result:= TSE.Create(True,'sin(x)',0);
end;

function TExtrapolation.ToStr(TM: TSE): TSRA;
begin
  Result.State:= TM.State;
  Result.s1:= TM.Value;
  Result.s2:= Format('%*.*f',[0,Ndc,TM.R]);
end;

function TExtrapolation.Choose(op: string): TSRA;
var
  TM: TSE;
begin
  case op of
    'Lineal': TM:= MLineal();
    'Exponencial': TM:= MExponencial();
    'Logaritmo': TM:= MLogaritmo();
    'Senoidal': TM:= MSenoidal();
  end;
  Result:= ToStr(TM);
end;

function TExtrapolation.MBest(): TSRA;
var
  A: TSE;
  MRT: TList;
  i: integer;
begin
  MRT:= TList.Create;
  MRT.Add(MLineal); MRT.Add(MExponencial); MRT.Add(MLogaritmo); MRT.Add(MSenoidal);
  A:= TSE(MRT.Items[0]);
  for i:=1 to MRT.Count-1 do begin
    if  (1-TSE(MRT.Items[i]).R)<(1-A.R) then
      A:= TSE(MRT.Items[i]);
  end;
  Result:= ToStr(A);
end;

end.

