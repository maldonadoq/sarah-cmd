unit FrameStrGrid;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Grids, Func;

type
  TFrame2 = class(TFrame)
    DataSG: TStringGrid;
  private
  public
    procedure PutSG(TB: TBox);
  end;

implementation

procedure TFrame2.PutSG(TB: TBox);
var
  i,j: integer;
begin
  DataSG.Clear();
  DataSG.RowCount:= TB.x;
  DataSG.ColCount:= TB.y;
  for i:=0 to TB.x-1 do
    for j:=0 to TB.y-1 do
      DataSG.Cells[j,i]:= TB.M[i,j];
end;

{$R *.lfm}

end.

