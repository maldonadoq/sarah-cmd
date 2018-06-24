unit Derivate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Evaluate;

type
  TDerivate = class
    constructor Create(th: real);
    destructor Destroy(); override;

    private
      h: real;
      MP: TEvaluate;
    public
      function FFD(x: real; fn: string): real;
  end;

implementation

constructor TDerivate.Create(th: real);
begin
  h:= th;
  MP:= TEvaluate.Create();
end;

destructor TDerivate.Destroy();
begin
end;

function TDerivate.FFD(x: real; fn: string): real;
begin
  Result:= (MP.Func(x+h,fn)-MP.Func(x-h,fn))/(2*h)
end;

end.

