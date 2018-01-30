unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Grids, FrameGraphic, CmdParse, FuncParse, FrameStrGrid,
  Func;

type

  { TForm1 }

  TForm1 = class(TForm)
    CmdL: TCmdBox;
    BoxCmd: TGroupBox;
    PanelFrame: TPanel;
    PanelVariable: TPanel;
    SgVariable: TStringGrid;
    PanelSplitter: TSplitter;

    procedure CmdLInput(ACmdBox: TCmdBox; Input: string);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure StartCommand;
    procedure InstantFrame(FrameSelected: integer; state: boolean);
    procedure ExtraFrameT();
    procedure Visible;
    procedure Invisible;
    procedure PutVariable(vv: VectString);
    procedure ClearVariable;
    function Funct(fn: string): real;
    function FunctStr(fn: string): string;
    function VarOrFunct(fn: string): TRS;
    function FindVariable(vr: string): TRI;
    function FSArguments(tx: string): TRS;
  public
    MCmdParse: TCmdParse;
  end;

var
  Form1: TForm1;

implementation

procedure TForm1.FormCreate(Sender: TObject);
begin
  ShiftArea:= 0.5;
  NULLF:= 99999;
  SgVariable.Cells[0,0]:= 'n°';
  SgVariable.Cells[1,0]:= 'name';
  SgVariable.Cells[2,0]:= 'value';
  Invisible;
  MCmdParse:= TCmdParse.Create();

  CmdL.StartRead(clLime, clBlack,'Sarah] ',clLime, clBlack);
  StartCommand;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  MCmdParse.Destroy();
end;

function TForm1.Funct(fn: string): real;
begin
  MCmdParse.Expression:= fn;
  Result:= MCmdParse.Evaluate();
end;

function TForm1.FunctStr(fn: string): string;
begin
  MCmdParse.Expression:= fn;
  Result:= MCmdParse.EvaluateFunc();
end;

function TForm1.FindVariable(vr: string): TRI;
var
  i: integer;
begin
  Result.State:= False;
  for i:=1 to SgVariable.RowCount-1 do
    if SgVariable.Cells[1,i]=vr then begin
      Result.State:= True;
      Result.Value:= i;
      Exit;
    end;
end;

function TForm1.FSArguments(tx: string): TRS;
var
  MTRSA: TSRA;
  MRI,MRII: TRI;
  s,st,fn: string;
begin
  MTRSA:= FSArg(tx);
  WriteLn(MTRSA.s1+' '+MTRSA.s2);
  s:= StringReplace(tx, ';', ',', [rfReplaceAll]);
  fn:= s;
  WriteLn(MTRSA.State);
  if not MTRSA.State then begin
    MRI:= FindVariable(MTRSA.s1);
    MRII:= FindVariable(MTRSA.s2);
    Write(MRI.State);
    Write(' ');
    WriteLn(MRII.State);

    if MRI.State and MRII.State then begin
      WriteLn(True);
      st:= StringReplace(fn, MTRSA.s1,SgVariable.Cells[2,MRI.Value],[rfReplaceAll]);
      s:= StringReplace(st, MTRSA.s2,SgVariable.Cells[2,MRII.Value],[rfReplaceAll]);
    end
    else begin
      WriteLn(False);
      Result.State:= False;
      Result.Value:= '';
      Exit;
    end;
  end;

  Result.State:= True;
  Result.Value:= s;
end;

function TForm1.VarOrFunct(fn: string): TRS;
var
  MRS: TRS;
  MRI: TRI;
  s: string;
begin
  MRS:= FirstArg(fn,'(');
  fn:= StringReplace(fn, ';', ',', [rfReplaceAll]);
  s:= fn;
  if not MRS.State then begin
    MRI:= FindVariable(MRS.Value);
    if MRI.State then
      s:= StringReplace(fn, MRS.Value, SGVariable.Cells[2,MRI.Value], [rfReplaceAll])
    else begin
      Result.State:= False;
      Result.Value:= '';
      Exit;
    end;
  end;
  Result.State:= True;
  Result.Value:= s;
end;

procedure TForm1.CmdLInput(ACmdBox: TCmdBox; Input: string);
var
  FinalLine, RTemp: string;
  RF: real;
  MRS: TRS;
  MVS: VectString;
begin
  try
    Input:= Trim(Input);
    FinalLine:= StringReplace(Input, ' ', '', [rfReplaceAll]);
    case input of
      'help': ShowMessage( 'help ');
      'exit': Application.Terminate;
      'clear': begin CmdL.Clear; StartCommand(); end;
      'clrhis': CmdL.ClearHistory;
      'clrvar': ClearVariable;
      'clrall': begin CmdL.Clear; StartCommand(); CmdL.ClearHistory; ClearVariable; end;

      else begin
        if Pos('=',FinalLine)>0 then begin
          MVS:= StrAssign(FinalLine);
          PutVariable(MVS);
          InstantFrame(0,False);
        end
        else if pos('plot',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine);
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(0,True);
          Funct(FinalLine);
        end
        else if pos('integrate',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine);
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(0,True);
          RF:= Funct(FinalLine);
          if(RF<>NULLF) then
            CmdL.WriteLn('  '+FloatToStr(RF))
          else
            CmdL.WriteLn('  No Existe Este Metodo');
        end
        else if pos('raiz',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine);
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(1,True);
          CmdL.WriteLn('  '+FloatToStr(Funct(FinalLine)));
        end
        else if pos('interpolation',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine);
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(0,True);
          CmdL.WriteLn(FunctStr(FinalLine));
        end
        else if pos('edo',FinalLine)>0 then begin
          if pos('Table',FinalLine)>0 then InstantFrame(1,true)
          else if pos('Graphic',FinalLine)>0 then InstantFrame(0,true)
          else begin
            InstantFrame(0,false);
            CmdL.WriteLn('  No Existe Esta Propiedad');
            Exit;
          end;

          MRS:= VarOrFunct(FinalLine);
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          RTemp:= FunctStr(FinalLine);
          if Rtemp<>'' then begin
            InstantFrame(0,false);
            CmdL.WriteLn(Rtemp);
          end;
        end
        else if pos('matrix',FinalLine)>0 then begin
          InstantFrame(0,false);
          CmdL.WriteLn(FunctStr(FinalLine));
        end
        else if pos('extrapolation',FinalLine)>0 then begin
          ExtraFrameT();
          InstantFrame(0,true);
          CmdL.WriteLn('  '+FunctStr(FinalLine));
        end
        else if pos('intersection',FinalLine)>0 then begin
          MRS:= FSArguments(FinalLine);
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Alguna Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;
          InstantFrame(0,True);
          CmdL.WriteLn(FunctStr(FinalLine));
        end;
      end;
  end;
  finally
     StartCommand()
  end;
end;

procedure TForm1.ExtraFrameT();
begin
  if Assigned(ExtraFrame) then
    ExtraFrame.Free;
  ExtraFrame:= TFrame2.Create(Form1);
end;

procedure TForm1.InstantFrame(FrameSelected: integer; state: boolean);
begin
  if state then begin
    Visible;
    if Assigned(ActualFrame) then
      ActualFrame.Free;

    case FrameSelected of
      0: ActualFrame:= TFrame1.Create(Form1);
      1: ActualFrame:= TFrame2.Create(Form1);
    end;

    ActualFrame.Parent:= Form1.PanelFrame;
    ActualFrame.Align:= alClient;
  end
  else Invisible;
end;

procedure TForm1.ClearVariable;
begin
  SgVariable.Clear;
  SgVariable.RowCount:= 1; SgVariable.ColCount:= 3;
  SgVariable.Cells[0,0]:= 'n°';
  SgVariable.Cells[1,0]:= 'name';
  SgVariable.Cells[2,0]:= 'value';
end;

procedure TForm1.PutVariable(vv: VectString);
var
  i: integer;
begin
  i:= SgVariable.RowCount;
  SgVariable.RowCount:= i+1;
  SgVariable.Cells[0,i]:= IntToStr(i);
  SgVariable.Cells[1,i]:= vv[0];
  SgVariable.Cells[2,i]:= vv[1];
end;

procedure TForm1.StartCommand;
begin
   CmdL.StartRead(clLime, clBlack,'Sarah] ',clLime, clBlack);
end;

procedure TForm1.Invisible;
begin
  CmdL.Align:= alClient;
  PanelFrame.Visible:= False;
end;

procedure TForm1.Visible;
begin
  CmdL.Align:= alBottom;
  PanelFrame.Visible:= True;
end;

{$R *.lfm}

end.

