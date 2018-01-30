unit Func;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, math, fpexprpars;

type
  VectString = array of string;

type
  VectReal = array of real;

type
  TBox = class
    public
      x,y: integer;
      M: array of array of String;
      procedure Print;
      constructor Create(a: TList; size: integer);
      constructor Create(a,b: integer);
      destructor Destroy(); override;
  end;

type
  TMPoint = class
    public
      x,y: real;
      constructor Create(_x,_y: real);
      destructor Destroy(); override;
  end;

type
  TRD = record
    State: Boolean;
    Value: Real;
  end;

type
  TRS = record
    State: Boolean;
    Value: string;
  end;

type
  TRI = record
    State: Boolean;
    Value: integer;
  end;

type
  TRB = record
    MBox: TBox;
    Value: Real;
  end;

type
  TLP = record
    MList: TList;
    PList: TList;
  end;

type
  TSRA = record
    s1,s2: string;
    State: boolean;
  end;

var
  NULLF, ShiftArea: real;

function XIntervalo(MP: TList): TMPoint;
function StrToBase(base: string): TList;
function NChar(s,sb: string): integer;
function IdxStr(s,sb: string; idx: integer): integer;
function SubString(base: string; ini,fin: integer): string;
function StrToTMPoint(Tx: string): TMPoint;
function PListToStr(MS: TList): string;
function IsNumber(AValue: TExprFloat): Boolean;
function TBoxToTLP(a,b: integer; MB: TBox): TList;
function NCharToFind(s,sb,sf: string): integer;
function StrAssign(tx: string): VectString;
function FirstArg(tx,s: string): TRS;
function FSArg(tx: string): TSRA;

implementation

constructor TMPoint.Create(_x, _y: real);
begin
  Self.x:= _x;
  Self.y:= _y;
end;

destructor TMPoint.Destroy();
begin
end;

function XIntervalo(MP: TList): TMPoint;
var
  i: integer;
  xmin,xmax,xtmp: real;
begin
  xmin:= TMPoint(MP.Items[0]).x;
  xmax:= TMPoint(MP.Items[0]).x;
  for i:=1 to MP.Count-1 do begin
    xtmp:= TMPoint(MP.Items[i]).x;
    if(xtmp < xmin) then xmin:= xtmp;
    if(xtmp > xmax) then xmax:= xtmp;
  end;
  Result:= TMPoint.Create(xmin,xmax);
end;

constructor TBox.Create(a: TList; size: integer);
var
  r,i,j: integer;
begin
  r:= (a.Count div size);
  i:= 0;  j:=1;
  y:= size+1;
  x:= r+1;

  SetLength(M,x,y);
  if(size=2) then begin
    M[0,0]:= 'n'; M[0,1]:= 'xn'; M[0,2]:= 'e';
    while(i<a.Count) do begin
      M[j,0]:= IntToStr(j-1);
      M[j,1]:= FloatToStr(Real(a.Items[i]));
      M[j,2]:= FloatToStr(Real(a.Items[i+1]));
      i:= i+size;
      j:= j+1;
    end;
  end
  else if(size=4) then begin
    M[0,0]:= 'n'; M[0,1]:= 'a'; M[0,2]:= 'b'; M[0,3]:= 'xn'; M[0,4]:= 'e';
    while(i<a.Count) do begin
      M[j,0]:= IntToStr(j-1);
      M[j,1]:= FloatToStr(Real(a.Items[i]));
      M[j,2]:= FloatToStr(Real(a.Items[i+1]));
      M[j,3]:= FloatToStr(Real(a.Items[i+2]));
      M[j,4]:= FloatToStr(Real(a.Items[i+3]));

      i:= i+size;
      j:= j+1;
    end;
  end;
end;

constructor TBox.Create(a,b: integer);
begin
  x:= a;
  y:= b;
  SetLength(M,x,y);
end;

destructor TBox.Destroy();
begin
end;

procedure TBox.Print;
var
  i,j: integer;
begin
  for i:=0 to x-1 do begin
    for j:=0 to y-1 do
      Write(M[i,j]+' ');
    WriteLn()
  end;
end;

function StrToTMPoint(Tx: string): TMPoint;
var
  PosCorcheteIni, PosCorcheteFin, PosSeparador: Integer;
  PosicionValidad: Boolean;
  i: Integer;
  xmin,xmax: string;
const
  CorcheteIni = '(';
  CorcheteFin = ')';
  Separador = ',';
begin

  PosCorcheteIni:= Pos(CorcheteIni, Tx);
  PosCorcheteFin:= pos(CorcheteFin, Tx);
  PosSeparador:= Pos(Separador, Tx);

  PosicionValidad:= (PosCorcheteIni > 0);
  PosicionValidad:= PosicionValidad and (PosSeparador > 2);
  PosicionValidad:= PosicionValidad and (PosCorcheteFin > 3);

  if not PosicionValidad then begin
    ShowMessage( 'Error en el Punto');
    exit;
  end;

  xmin:= Copy(Tx,PosCorcheteIni+1, PosSeparador-2);

  xmin:= Trim(xmin);
  xmax:= Copy(Tx, PosSeparador+1, Length(Tx)-PosSeparador-1);

  xmax:= Trim(xmax);
  Result:= TMPoint.Create(StrToFloat(xmin),StrToFloat(xmax));
end;

function PListToStr(MS: TList): string;
var
  i,dc: integer;
  TM: TMPoint;
begin
  dc:= 6;
  for i:=0 to MS.Count-1 do begin
    TM:= TMPoint(MS[i]);
    if(i=(MS.Count-1)) then
      Result:= Result+Format('   (%*.*f,%*.*f)', [0,dc,TM.x,0,dc,TM.y])
    else
      Result:= Result+Format('   (%*.*f,%*.*f)', [0,dc,TM.x,0,dc,TM.y])+#13#10;
  end;
end;

function NChar(s,sb: string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:=0 to Length(s)-1 do
    if(s[i]=sb) then
      Result:= Result+1;
end;

function NCharToFind(s,sb,sf: string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:=0 to Length(s)-1 do
    if(s[i]=sb) then Result:= Result+1
    else if(s[i]=sf) then Exit;
end;

function IdxStr(s,sb: string; idx: integer): integer;
begin
  for Result:=idx+1 to Length(s)-1 do
    if(s[Result]=sb) then
      Exit;
end;

function SubString(base: string; ini,fin: integer): string;
var
  i: integer;
begin
  Result:= '';
  for i:=ini to fin do
    Result:= Result+base[i];
end;

function StrToBase(base: string): TList;
var
  i,ns,idx, idxt: integer;
  sp: string;
begin
  idxt:= 0;
  ns:= NChar(base,':');
  Result:= TList.Create;
  for i:=0 to ns do begin
    idx:= idxt+2;
    idxt:= IdxStr(base,')',idx);
    sp:= SubString(base,idx,idxt);
    Result.Add(StrToTMPoint(sp));
  end;
end;

function IsNumber(AValue: TExprFloat): Boolean;
begin
  result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;

function TBoxToTLP(a,b: integer; MB: TBox): TList;
var
  i: integer;
begin
  Result:= TList.Create;
  for i:=1 to MB.x-1 do
    Result.Add(TMPoint.Create(StrToFloat(MB.M[i,a]),StrToFloat(MB.M[i,b])));
end;

function StrAssign(tx: string): VectString;
var
  idx: integer;
begin
  SetLength(Result,2);
  idx:= IdxStr(tx,'=',0);
  Result[0]:= SubString(tx,1,idx-1);
  Result[1]:= SubString(tx,idx+1,Length(tx));
end;

function FirstArg(tx,s: string): TRS;
var
  idx,idxt: integer;
begin
  idx:= IdxStr(tx,s,0)+1;
  idxt:= IdxStr(tx,';',idx)-1;
  Result.Value:= SubString(tx,idx,idxt);
  Result.State:= Pos(#39,Result.Value)>0;
end;

function FSArg(tx: string): TSRA;
var
  s1,s2: TRS;
begin
  Result.State:= True;
  Result.s1:= '';
  Result.s2:= '';

  s1:= FirstArg(tx,'(');
  s2:= FirstArg(tx,';');
  if not s1.State and not s2.State then begin
    Result.State:= False;
    Result.s1:= s1.Value;
    Result.s2:= s2.Value;
  end;
end;

end.

