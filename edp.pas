unit Edp;

interface

uses
  Classes, SysUtils, ParseMath, Func, Dialogs;

type
  TEDP = class
    private
      nv: integer;
      MP: TParseMath;
      MR: TList;
    public
      constructor Create();
      destructor Destroy(); override;

      procedure SizeH(xi,xf: real);
      function Func(x,y,z: real; fn: string): real;
      function CreateTBox(n: integer): TBox;
      function Euler(xi,xf,xti,yti,xpti,ypti: real; fn,fs: string): TBox;
      function RungeKutta4(xi,xf,xti,yti,xpti,ypti: real; fn,fs: string): TBox;
  end;

implementation

constructor TEDP.Create();
begin
  MR:= TList.Create;
  MP:= TParseMath.Create();
  MP.AddVariable('x',0);
  MP.AddVariable('y',0);
  MP.AddVariable('z',0);
end;

destructor TEDP.Destroy();
begin
  MP.Destroy();
end;

function TEDP.Func(x,y,z: real; fn: string): real;
begin
  MP.NewValue('x',x);
  MP.NewValue('y',y);
  MP.NewValue('z',z);
  MP.Expression:= fn;
  Result:= MP.Evaluate();
end;

function TEDP.CreateTBox(n: integer): TBox;
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

procedure TEDP.SizeH(xi,xf: real);
begin
  nv:= Round((xf-xi)/0.01);
end;

{function TEDP.Validate(xi,xf,xti,yti,xpti,ypti: real): real;
begin
end;}

function TEDP.Euler(xi,xf,xti,yti,xpti,ypti: real; fn,fs: string): TBox;
var
  h,x,y,z,myt,mzt: real;
  i: integer;
  fp: string;
begin
  SizeH(xi,xf);
  h:= (xf-xi)/nv;
  if xti=xpti then begin
    if(xti = xi) then  h:= h
    else if(xti = xf) then  h:= 0-h
    else begin
      ShowMessage('Punto Inicial Mal');
      Exit;
    end;
  end
  else begin
    ShowMessage('Punto Inicial Diferentes');
    Exit;
  end;


  MR.Clear;

  MR.Add(Pointer(xti));
  MR.Add(Pointer(yti));
  MR.Add(Pointer(yti));

  fp:= 'z'; x:= xti; y:= yti; z:= ypti;
  for i:=1 to nv do begin
    myt:= y+(h*Func(x,y,z,fp));
    mzt:= z+(h*Func(x,y,z,fn));

    MR.Add(Pointer(x+h));
    MR.Add(Pointer(myt));
    if(fs <> '') then
      MR.Add(Pointer(Func(x+h,0,z,fs)))
    else
      MR.Add(Pointer(0));
    x:= x+h;
    y:= myt;
    z:= mzt;
  end;
  Result:= CreateTBox(3);
end;

function TEDP.RungeKutta4(xi,xf,xti,yti,xpti,ypti: real; fn,fs: string): TBox;
var
  h,x,y,z,myt,mzt,ky1,ky2,ky3,ky4,kz1,kz2,kz3,kz4: real;
  i: integer;
  fp: string;
begin
  SizeH(xi,xf);
  h:= (xf-xi)/nv;
  if xti=xpti then begin
    if(xti = xi) then  h:= h
    else if(xti = xf) then  h:= 0-h
    else begin
      ShowMessage('Punto Inicial Mal');
      Exit;
    end;
  end
  else begin
    ShowMessage('Punto Inicial Diferentes');
    Exit;
  end;


  MR.Clear;

  MR.Add(Pointer(xti));
  MR.Add(Pointer(yti));
  MR.Add(Pointer(yti));

  fp:= 'z'; x:= xti; y:= yti; z:= ypti;
  for i:=1 to nv do begin
    myt:= y+(h*Func(x,y,z,fp));
    mzt:= z+(h*Func(x,y,z,fn));

    ky1:= Func(x,y,z,'z');
    ky2:= Func(x+(h/2),y+(ky1*h/2),z,'z');
    ky3:= Func(x+(h/2),y+(ky2*h/2),z,'z');
    ky4:= Func(x+h,y+(ky3*h),z,'z');

    kz1:= Func(x,y,z,fn);
    kz2:= Func(x+(h/2),y+(ky1*h/2),z+(kz1*h/2),fn);
    kz3:= Func(x+(h/2),y+(ky2*h/2),z+(kz2*h/2),fn);
    kz4:= Func(x+h,y+(ky3*h),z+(kz3*h),fn);

    myt:= y+(h*(ky1 + (2*ky2) + (2*ky3) +ky4)/6);
    mzt:= z+(h*(kz1 + (2*kz2) + (2*kz3) +kz4)/6);

    MR.Add(Pointer(x+h));
    MR.Add(Pointer(myt));
    if(fs <> '') then
      MR.Add(Pointer(Func(x+h,0,0,fs)))
    else
      MR.Add(Pointer(0));
    x:= x+h;
    y:= myt;
    z:= mzt;
  end;
  Result:= CreateTBox(3);
end;

end.

