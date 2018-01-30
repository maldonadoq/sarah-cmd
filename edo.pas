unit Edo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ParseMath, Func, Dialogs, Math;

type
  TEDO = class
    constructor Create();
    destructor Destroy(); override;

    private
      MParse: TParseMath;
      MR: TList;
      nv: integer;
    public
      procedure SizeH(xi,xf: real);
      function Func(x,y: real; fn: string): real;
      function Euler(xi,xf,xti,yti: real; fn,fs: string): TBox;
      function Heun(xi,xf,xti,yti: real; fn,fs: string): TBox;
      function RungeKutta4(xi,xf,xti,yti: real; fn,fs: string): TBox;
      function DormandPrince(xi,xf,xti,yti: real; fn,fs: string): TBox;
      function CreateTBox(n: integer): TBox;
  end;

implementation

constructor TEDO.Create();
begin
  MParse:= TParseMath.Create();
  MParse.AddVariable('x',0);
  MParse.AddVariable('y',0);
  MR:= TList.Create;
end;

destructor TEDO.Destroy();
begin
  MR.Destroy;
end;

procedure TEDO.SizeH(xi,xf: real);
begin
  nv:= Round((xf-xi)/0.01);
end;

function TEDO.Func(x,y: real; fn: string): real;
begin
  MParse.NewValue('x',x);
  MParse.NewValue('y',y);
  MParse.Expression:= fn;
  Result:= MParse.Evaluate();
end;

function TEDO.CreateTBox(n: integer): TBox;
var
  m,i,j,k: integer;
begin
  m:= (MR.Count div n);
  Result:= TBox.Create(m+1,n+1);
  Result.M[0,0]:= 'n';         Result.M[0,1]:= 'X';
  Result.M[0,2]:= 'Y [Método]'; Result.M[0,3]:= 'Solución Exacta';

  k:= 1; i:= 0;
  while(i<MR.Count-1) do begin
    Result.M[k,0]:= IntToStr(k-1);
    for j:=0 to 2 do
      Result.M[k,j+1]:= FloatToStr(Real(MR.Items[i+j]));
    i:= i+n;
    k:= k+1;
  end;
end;

function TEDO.Euler(xi,xf,xti,yti: real; fn,fs: string): TBox;
var
  h,myti: real;
  i: integer;
begin
  SizeH(xi,xf);
  h:= (xf-xi)/nv;
  if(xti = xi) then  h:= h
  else if(xti = xf) then  h:= 0-h
  else begin
    ShowMessage('Punto Inicial Mal');
    exit;
  end;

  MR.Clear;

  MR.Add(Pointer(xti));
  MR.Add(Pointer(yti));
  MR.Add(Pointer(yti));

  for i:=1 to nv do begin
    myti:= yti+(h*Func(xti,yti,fn));

    MR.Add(Pointer(xti+h));
    MR.Add(Pointer(myti));
    if(fs <> '') then
      MR.Add(Pointer(Func(xti+h,myti,fs)))
    else
      MR.Add(Pointer(0));
    xti:= xti+h;
    yti:= myti;
  end;
  Result:= CreateTBox(3);
end;

function TEDO.Heun(xi,xf,xti,yti: real; fn,fs: string): TBox;
var
  h,myti,myt,tmp: real;
  i: integer;
begin
  SizeH(xi,xf);
  h:= (xf-xi)/nv;
  if(xti = xi) then  h:= h
  else if(xti = xf) then  h:= 0-h
  else begin
    ShowMessage('Punto Inicial Mal');
    exit;
  end;

  MR.Clear;
  myt:= yti;

  MR.Add(Pointer(xti));
  MR.Add(Pointer(yti));
  MR.Add(Pointer(yti));

  for i:=1 to nv do begin
    tmp:= myt+(h*Func(xti,myt,fn));
    myti:= myt+(h*((Func(xti,myt,fn)+Func(xti+h,tmp,fn))/2));

    MR.Add(Pointer(xti+h));
    MR.Add(Pointer(myti));
    if(fs <> '') then
      MR.Add(Pointer(Func(xti+h,myti,fs)))
    else
      MR.Add(Pointer(0));
    xti:= xti+h;
    myt:= myti;
  end;
  Result:= CreateTBox(3);
end;

function TEDO.RungeKutta4(xi,xf,xti,yti: real; fn,fs: string): TBox;
var
  h,myti,k1,k2,k3,k4: real;
  i: integer;
begin
  SizeH(xi,xf);
  h:= (xf-xi)/nv;
  if(xti = xi) then  h:= h
  else if(xti = xf) then  h:= 0-h
  else begin
    ShowMessage('Punto Inicial Mal');
    exit;
  end;

  MR.Clear;
  MR.Add(Pointer(xti));
  MR.Add(Pointer(yti));
  MR.Add(Pointer(yti));
  for i:=1 to nv do begin

    k1:= Func(xti,yti,fn);
    k2:= Func(xti+(h/2),yti+(k1*h/2),fn);
    k3:= func(xti+(h/2),yti+(k2*h/2),fn);
    k4:= func(xti+h,yti+(k3*h),fn);

    myti:= yti+(h*(k1 + (2*k2) + (2*k3) + k4)/6);

    MR.Add(Pointer(xti+h));
    MR.Add(Pointer(myti));
    if(fs <> '') then
      MR.Add(Pointer(Func(xti+h,myti,fs)))
    else
      MR.Add(Pointer(0));

    xti:= xti+h;
    yti:= myti;
  end;
  Result:= CreateTBox(3);
end;

function TEDO.DormandPrince(xi,xf,xti,yti: real; fn,fs: string): TBox;
var
  h,eps,k1,k2,k3,k4,k5,k6,k7,er,z1,y1,s,h1,hmin,hmax: real;
begin
  eps:= 0.001;
  SizeH(xi,xf);
  h:= (xf-xi)/nv;
  if(xti = xi) then  h:= h
  else if(xti = xf) then  h:= 0-h
  else begin
    ShowMessage('Punto Inicial Mal');
    exit;
  end;

  MR.Clear;
  MR.Add(Pointer(xti));
  MR.Add(Pointer(yti));
  MR.Add(Pointer(yti));

  hmin:= 0.001;
  hmax:= 0.1;
  while(xti<xf) do begin
    k1:= h*Self.Func(xti,yti,fn);
    k2:= h*Self.Func(xti+(h*0.2),yti+(k1*0.2),fn);
    k3:= h*Self.Func(xti+(h*0.3),yti+(k1*0.075)+(k2*0.225),fn);
    k4:= h*Self.Func(xti+(h*0.8),yti+(k1*0.977777778)-(k2*3.733333333)+(k3*3.555555556),fn);
    k5:= h*Self.Func(xti+(h*0.888888889),yti+(k1*2.952598689)-(k2*11.595793324)+(k3*9.822892852)-(k4*0.290809328),fn);
    k6:= h*Self.Func(xti+h,yti+(k1*2.846275253)-(k2*10.757575758)-(k3*8.906422718)+(k4*0.278409091)-(k5*0.273531304),fn);
    k7:= h*Self.Func(xti+h,yti+(k1*0.091145833)+(k3*0.449236298)+(k4*0.651041667)-(k5*0.322376179)+(k6*0.130952381),fn);

    y1:= yti+(k1*0.091145833)+(k3*0.449236298)+(k4*0.651041667)-(k5*0.322376179)+(k6*0.130952381);
    z1:= yti+(k1*0.089913194)+(k3*0.453489069)+(k4*0.614062500)-(k5*0.271512382)+(k6*0.089047619)+(k7*0.025);

    er:= abs(z1-y1);
    s:= Power(eps*h/(2*er),0.2);
    h1:= s*h;
    yti:= y1;
    MR.Add(Pointer(xti+h));
    MR.Add(Pointer(yti));

    if(h1<hmin) then h1:= hmin
    else if(h1>hmax) then h1:= hmax;

    if(fs <> '') then
      MR.Add(Pointer(Func(xti+h,yti,fs)))
    else
      MR.Add(Pointer(0));
    xti:= xti+h;
    h:= h1;
  end;
  Result:= CreateTBox(3);
end;

end.

