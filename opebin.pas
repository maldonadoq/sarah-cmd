unit OpeBin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Func, Matrices;

function OpeTwo(V1,V2: TSRA; op: string): string;

implementation

function OpeTwo(V1,V2: TSRA; op: string): string;
var
  MA,MB: TMatriz;
begin
  case op of
    '+': begin
      case V1.s2 of
        'real': begin
          case V2.s2 of
            'real':     Result:= '  '+FloatToStr(StrToFloat(V1.s1)+StrToFloat(V2.s1));
            'matrix':   Result:= 'Imposible!! Real+Matrix';
            'function': Result:= 'Imposible!! Real+Function';
            'base':     Result:= 'Imposible!! Real+Base';
          end;
        end;
        'matrix': begin
          case V2.s2 of
            'real':     Result:= 'Imposible!! Matrix+Real';
            'matrix':begin
              MA:= StrToMatriz(V1.s1);
              MB:= StrToMatriz(V2.s1);
              Result:= (MA+MB).ToStr();
              MA.Destroy(); MB.Destroy();
            end;
            'function': Result:= 'Imposible!! Matrix+Function';
            'base':     Result:= 'Imposible!! Matrix+Base';
          end;
        end;
        'function': Result:= 'Invalid Operation!!';
        'base':     Result:= 'Invalid Operation!!';
      end;
    end;
    '-': begin
      case V1.s2 of
        'real': begin
          case V2.s2 of
            'real':     Result:= '  '+FloatToStr(StrToFloat(V1.s1)-StrToFloat(V2.s1));
            'matrix':   Result:= 'Imposible!! Real-Matrix';
            'function': Result:= 'Imposible!! Real-Function';
            'base':     Result:= 'Imposible!! Real-Base';
          end;
        end;
        'matrix': begin
          case V2.s2 of
            'real':     Result:= 'Imposible!! Matrix-Real';
            'matrix':begin
              MA:= StrToMatriz(V1.s1);
              MB:= StrToMatriz(V2.s1);
              Result:= (MA-MB).ToStr();
              MA.Destroy(); MB.Destroy();
            end;
            'function': Result:= 'Imposible!! Matrix-Function';
            'base':     Result:= 'Imposible!! Matrix-Base';
          end;
        end;
        'function': Result:= 'Invalid Operation Function!!';
        'base':     Result:= 'Invalid Operation Base!!';
      end;
    end;
    '*': begin
      case V1.s2 of
        'real': begin
          case V2.s2 of
            'real':     Result:= '  '+FloatToStr(StrToFloat(V1.s1)*StrToFloat(V2.s1));
            'matrix':begin
              MA:= StrToMatriz(V2.s1);
              Result:= (MA.Escalar(StrToFloat(V1.s1))).ToStr();
              MA.Destroy();
            end;
            'function': Result:= 'Imposible!! Real+Function';
            'base':     Result:= 'Imposible!! Real+Base';
          end;
        end;
        'matrix': begin
          case V2.s2 of
            'real':begin
              MA:= StrToMatriz(V1.s1);
              Result:= (MA.Escalar(StrToFloat(V2.s1))).ToStr();
              MA.Destroy();
            end;
            'matrix':begin
              MA:= StrToMatriz(V1.s1);
              MB:= StrToMatriz(V2.s1);
              Result:= (MA*MB).ToStr();
              MA.Destroy(); MB.Destroy();
            end;
            'function': Result:= 'Imposible!! Matrix+Function';
            'base':     Result:= 'Imposible!! Matrix+Base';
          end;
        end;
        'function': Result:= 'Invalid Operation Function!!';
        'base':     Result:= 'Invalid Operation Base!!';
      end;
    end;
    '/': begin
      case V1.s2 of
        'real': begin
          case V2.s2 of
            'real':     Result:= '  '+FloatToStr(StrToFloat(V1.s1)/StrToFloat(V2.s1));
            'matrix':   Result:= 'Imposible!! Real/Matrix';
            'function': Result:= 'Imposible!! Real/Function';
            'base':     Result:= 'Imposible!! Real/Base';
          end;
        end;
        'matrix': begin
          case V2.s2 of
            'real':begin
              MA:= StrToMatriz(V1.s1);
              Result:= (MA.Escalar(1/StrToFloat(V2.s1))).ToStr();
              MA.Destroy();
            end;
            'matrix':begin
              MA:= StrToMatriz(V1.s1);
              MB:= StrToMatriz(V2.s1);
              Result:= (MA/MB).ToStr();
              MA.Destroy(); MB.Destroy();
            end;
            'function': Result:= 'Imposible!! Matrix/Function';
            'base':     Result:= 'Imposible!! Matrix/Base';
          end;
        end;
        'function': Result:= 'Invalid Operation Function!!';
        'base':     Result:= 'Invalid Operation Base!!';
      end;
    end;
  end;
end;

end.

