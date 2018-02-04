unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, TAGraph, TATools, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, Grids, ComCtrls, ColorBox,
  FrameGraphic, CmdParse, FuncParse, FrameStrGrid, Func, OpeBin, TASeries,
  Evaluate, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    ChartPlot: TChart;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    CmdL: TCmdBox;
    BoxCmd: TGroupBox;
    LineColorBox: TColorBox;
    PanelFrame: TPanel;
    PanelVariable: TPanel;
    SgVariable: TStringGrid;
    CmdSplitter: TSplitter;
    Splitter1: TSplitter;

    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure CmdLInput(ACmdBox: TCmdBox; Input: string);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FuncSelected: boolean;
    idxcolor: integer;
    procedure StartCommand;
    procedure InstantFrame(FrameSelected: integer; state: boolean);
    procedure ExtraFrameT();
    procedure Visible;
    procedure Invisible;
    procedure PutVariable(vv: VectString);
    procedure ClearVariable;
    procedure ChartVisible(state: boolean);
    procedure MNewFunction(fn: string);
    procedure Plotear(fn: string; xmin,xmax: real);
    procedure ClearPlot();
    function Funct(fn: string): real;
    function FunctStr(fn: string): string;
    function VarOrFunct(fn,tv: string): TRS;
    function FindVariable(vr: string): TRI;
    function FindVariableI(vr: string): TSRA;
    function FSArguments(tx,tv: string): TRS;
  public
    MCmdParse: TCmdParse;
    MP: TEvaluate;
  end;

var
  Form1: TForm1;

implementation

procedure TForm1.FormCreate(Sender: TObject);
begin
  MFunct:= TStringList.Create;
  TLSFunct:= TList.Create;
  MP:= TEvaluate.Create();
  idxcolor:= 9;
  FuncSelected:= True;
  ShiftArea:= 0.2;
  XLim:= 10;
  NULLF:= 99999;
  TypeVarF:= 'function'; TypeVarM:= 'matrix';
  TypeVarR:= 'real';   TypeVarN:= 'null';
  TypeVarB:= 'base'; F1:='x'; F2:='-x';
  SgVariable.RowCount:= 10;
  SgVariable.Cells[0,0]:= 'name'; SgVariable.Cells[2,0]:= 'type';     SgVariable.Cells[1,0]:= 'value';
  SgVariable.Cells[0,1]:= 'f(x)'; SgVariable.Cells[2,1]:= 'function'; SgVariable.Cells[1,1]:= 'sin(x)';
  SgVariable.Cells[0,2]:= 'g(x)'; SgVariable.Cells[2,2]:= 'function'; SgVariable.Cells[1,2]:= 'cos(x)';
  SgVariable.Cells[0,3]:= 'h(x)'; SgVariable.Cells[2,3]:= 'function'; SgVariable.Cells[1,3]:= 'power(x,2)-2';
  SgVariable.Cells[0,4]:= 's(x)'; SgVariable.Cells[2,4]:= 'function'; SgVariable.Cells[1,4]:= 'sin(exp(x*y))/((2*y)-(x*cos(exp(x*y))))';
  SgVariable.Cells[0,5]:= 'M';    SgVariable.Cells[2,5]:= 'matrix';   SgVariable.Cells[1,5]:= '[1,2:2,3]';
  SgVariable.Cells[0,6]:= 'N';    SgVariable.Cells[2,6]:= 'matrix';   SgVariable.Cells[1,6]:= '[-6,2:4,3]';
  SgVariable.Cells[0,7]:= 'B';    SgVariable.Cells[2,7]:= 'base';     SgVariable.Cells[1,7]:= '[(1,5):(2,4):(3,2):(4,9)]';
  SgVariable.Cells[0,8]:= 'p';    SgVariable.Cells[2,8]:= 'real';     SgVariable.Cells[1,8]:= '10';
  SgVariable.Cells[0,9]:= 'q';    SgVariable.Cells[2,9]:= 'real';     SgVariable.Cells[1,9]:= '2';

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
    if SgVariable.Cells[0,i]=vr then begin
      Result.State:= True;
      Result.Value:= i;
      Exit;
    end;
end;

function TForm1.FindVariableI(vr: string): TSRA;
var
  i: integer;
begin
  Result.State:= False;
  for i:=1 to SgVariable.RowCount-1 do
    if SgVariable.Cells[0,i]=vr then begin
      Result.State:= True;
      Result.s1:= SgVariable.Cells[1,i];
      Result.s2:= SgVariable.Cells[2,i];
      Exit;
    end;
end;

function TForm1.FSArguments(tx,tv: string): TRS;
var
  MTRSA: TSRA;
  MRI,MRII: TRI;
  s,st,fn: string;
begin
  MTRSA:= FSArg(tx);
  s:= StringReplace(tx, ';', ',', [rfReplaceAll]);
  fn:= s;
  if not MTRSA.State then begin
    MRI:= FindVariable(MTRSA.s1);
    MRII:= FindVariable(MTRSA.s2);

    if MRI.State and MRII.State then begin
      if (SgVariable.Cells[2,MRI.Value]=tv) and (SgVariable.Cells[2,MRII.Value]=tv) then begin
        st:= StringReplace(fn, MTRSA.s1,#39+SgVariable.Cells[1,MRI.Value]+#39,[rfReplaceAll]);
        s := StringReplace(st, MTRSA.s2,#39+SgVariable.Cells[1,MRII.Value]+#39,[rfReplaceAll]);
      end
      else begin
        Result.State:= False;
        Result.Value:= '  Wrong Data Type';
        Exit;
      end;
    end
    else begin
      Result.State:= False;
      Result.Value:= '';
      Exit;
    end;
  end;

  Result.State:= True;
  Result.Value:= s;
end;

procedure TForm1.MNewFunction(fn: string);
begin
  MFunct.Add(fn);
  TLSFunct.Add(TLineSeries.Create(ChartPlot));
  with TLineSeries(TLSFunct[TLSFunct.Count-1]) do begin
    Name:= 'FunctionName'+IntToStr(TLSFunct.Count);
    Tag:= MFunct.Count-1;
    LinePen.Color:= LineColorBox.Colors[idxcolor];  ;
  end;
  idxcolor:= idxcolor+1;
  ChartPlot.AddSeries(TLineSeries(TLSFunct[TLSFunct.Count-1]));
end;

procedure TForm1.Plotear(fn: string; xmin,xmax: real);
var
  x,h: Real;
begin
  x:= xmin;
  h:= 0.01;

  MNewFunction(fn);
  with TLineSeries(TLSFunct[TLSFunct.Count-1]) do repeat
    AddXY(x,MP.Func(x,fn));
    x:= x+h
  until(x>=xmax);
end;

procedure TForm1.ClearPlot();
var
  i: integer;
begin
  for i:=0 to TLSFunct.Count-1 do
    TLineSeries(TLSFunct.Items[i]).Destroy;

  MFunct.Clear;
  TLSFunct.Clear;
  ChartPlot.ClearSeries;
  idxcolor:= 9;
end;

function TForm1.VarOrFunct(fn,tv: string): TRS;
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
    if MRI.State then begin
      if SGVariable.Cells[2,MRI.Value]=tv then
        s:= StringReplace(fn, MRS.Value, #39+SGVariable.Cells[1,MRI.Value]+#39, [rfReplaceAll])
      else begin
        Result.State:= False;
        Result.Value:= '  Wrong Data Type';
        Exit;
      end;
    end
    else begin
      Result.State:= False;
      Result.Value:= '  Does Not Exist This Variable!';
      Exit;
    end;
  end;
  Result.State:= True;
  Result.Value:= s;
end;

procedure TForm1.CmdLInput(ACmdBox: TCmdBox; Input: string);
var
  Final,FinalLine, RTemp: string;
  RF: real;
  MRS: TRS;
  MRI: TRI;
  MVS: VectString;
  MV,MVA,MVB: TSRA;
begin
  try
    Input:= Trim(Input);
    FinalLine:= StringReplace(Input, ' ', '', [rfReplaceAll]);
    ChartVisible(False);
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
          MRI:= FindVariable(MVS[0]);
          if MRI.State then begin
            if MVS[2]=TypeVarN then
              CmdL.WriteLn('  Wrong Data Type!!')
            else begin
              SgVariable.Cells[1,MRI.Value]:= MVS[1];
              SgVariable.Cells[2,MRI.Value]:= MVS[2];
            end;
          end
          else
            PutVariable(MVS);

          InstantFrame(0,False);
        end
        else if pos('plotear',FinalLine)>0 then begin
          Final:= SubString(FinalLine,Pos('(',FinalLine)+1, Length(FinalLine)-1);
          if Final='clear' then begin
            ClearPlot();
            Exit;
          end
          else if Final='view' then begin
            ChartVisible(true);
            Exit;
          end;
          MV:= FindVariableI(Final);
          if MV.State then begin
            if(MV.s2<>'function') then begin
              CmdL.WriteLn('  Wrong Data Type');
              Exit;
            end
            else
              Final:= MV.s1;
          end;
          ChartVisible(true);
          Plotear(Final,-XLim,XLim);
        end
        else if pos('plot',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine,'function');
          if not MRS.State then begin
            CmdL.WriteLn(MRS.Value);
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(0,True);
          Funct(FinalLine);
        end
        else if pos('select',FinalLine)>0 then begin
          if pos('intersection',FinalLine)>0 then begin
            Final:= 'intersection('+#39+F1+#39+','+#39+F2+#39+',-'+FloatToStr(XLim)+','+FloatToStr(XLim)+',0.001)';
            InstantFrame(0,True);
            CmdL.WriteLn(FunctStr(Final));
          end
          else if pos('area',FinalLine)>0 then begin
            Final:= 'areaII('+#39+F1+#39+','+#39+F2+#39+')';
            InstantFrame(0,True);
            RF:= Funct(Final);
            if(RF<>NULLF) then
              CmdL.WriteLn('  '+FloatToStr(RF))
            else
              CmdL.WriteLn('  Does not Exist Area!!');
          end;
        end
        else if pos('areaII',FinalLine)>0 then begin
          MRS:= FSArguments(FinalLine,'function');
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Alguna Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;
          InstantFrame(0,True);
          RF:= Funct(FinalLine);
          if(RF<>NULLF) then
            CmdL.WriteLn('  '+FloatToStr(RF))
          else
            CmdL.WriteLn('  Does not Exist Area!!');
        end
        else if pos('areaI',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine,'function');
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(0,True);
          CmdL.WriteLn('  '+FloatToStr(Funct(FinalLine)))
        end
        else if pos('integrate',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine,'function');
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
          MRS:= VarOrFunct(FinalLine,'function');
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Esta Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;

          InstantFrame(1,True);
          CmdL.WriteLn('  '+FloatToStr(Funct(FinalLine)));
        end
        else if pos('interpolation',FinalLine)>0 then begin
          MRS:= VarOrFunct(FinalLine,'base');
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

          MRS:= VarOrFunct(FinalLine,'function');
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
        else if pos('extrapolation',FinalLine)>0 then begin
          ExtraFrameT();
          InstantFrame(0,true);
          CmdL.WriteLn('  '+FunctStr(FinalLine));
        end
        else if pos('matrix',FinalLine)>0 then begin
          MRS:= FSArguments(FinalLine,'matrix');
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Alguna Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;
          InstantFrame(0,false);
          CmdL.WriteLn(FunctStr(FinalLine));
        end
        else if pos('intersection',FinalLine)>0 then begin
          MRS:= FSArguments(FinalLine,'function');
          if not MRS.State then begin
            CmdL.WriteLn('  No Existe Alguna Variable');
            Exit;
          end;
          FinalLine:= MRS.Value;
          InstantFrame(0,True);
          CmdL.WriteLn(FunctStr(FinalLine));
        end
        else begin
          if pos('+',FinalLine)>0 then begin
            MV:= VarBin(FinalLine,IdxStrT(FinalLine,'+')-1);
            MVA:= FindVariableI(MV.s1);
            MVB:= FindVariableI(MV.s2);
            if MVA.State and MVB.State then CmdL.WriteLn(OpeTwo(MVA,MVB,'+'))
            else CmdL.WriteLn('  Does Not Exist Someone Variable');
          end
          else if pos('-',FinalLine)>0 then begin
            MV:= VarBin(FinalLine,IdxStrT(FinalLine,'-')-1);
            MVA:= FindVariableI(MV.s1);
            MVB:= FindVariableI(MV.s2);
            if MVA.State and MVB.State then CmdL.WriteLn(OpeTwo(MVA,MVB,'-'))
            else CmdL.WriteLn('  Does Not Exist Someone Variable');
          end
          else if pos('*',FinalLine)>0 then begin
            MV:= VarBin(FinalLine,IdxStrT(FinalLine,'*')-1);
            MVA:= FindVariableI(MV.s1);
            MVB:= FindVariableI(MV.s2);
            if MVA.State and MVB.State then CmdL.WriteLn(OpeTwo(MVA,MVB,'*'))
            else CmdL.WriteLn('  Does Not Exist Someone Variable');
          end
          else if pos('/',FinalLine)>0 then begin
            MV:= VarBin(FinalLine,IdxStrT(FinalLine,'/')-1);
            MVA:= FindVariableI(MV.s1);
            MVB:= FindVariableI(MV.s2);
            if MVA.State and MVB.State then CmdL.WriteLn(OpeTwo(MVA,MVB,'/'))
            else CmdL.WriteLn('  Does Not Exist Someone Variable');
          end
          else
            WriteLn('Exit');
        end;
      end;
  end;
  finally
     StartCommand()
  end;
end;

procedure TForm1.ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
  APoint: TPoint);
begin
  with ATool as TDatapointClickTool do begin
    if (Series is TLineSeries) then begin
      with TLineSeries(Series) do begin
        if(FuncSelected) then begin
          F1:= MFunct[Tag];
          ShowMessage('f(x): '+F1);
          FuncSelected:= False;
        end
        else begin
          if(F1 <> MFunct[Tag]) then begin
            F2:= MFunct[Tag];
            ShowMessage('g(x): '+F2);
            FuncSelected:= True;
          end
          else
            ShowMessage('Seleccione otra función, no la misma!!');
        end;
      end;
    end;
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
  SgVariable.Cells[0,0]:= 'name';
  SgVariable.Cells[1,0]:= 'value';
  SgVariable.Cells[2,0]:= 'type';
end;

procedure TForm1.PutVariable(vv: VectString);
var
  i: integer;
begin
  i:= SgVariable.RowCount;
  SgVariable.RowCount:= i+1;
  SgVariable.Cells[0,i]:= vv[0];
  SgVariable.Cells[1,i]:= vv[1];
  SgVariable.Cells[2,i]:= vv[2];
end;

procedure TForm1.StartCommand;
begin
   CmdL.StartRead(clLime, clBlack,'Sarah] ',clLime, clBlack);
end;

procedure TForm1.ChartVisible(state: boolean);
begin
  if state then begin
    Visible();
    ChartPlot.Visible:= True;
    ChartPlot.Align:= alClient;
  end
  else begin
    Invisible();
    ChartPlot.Align:= alNone;
    ChartPlot.Visible:= False;
  end;
end;

procedure TForm1.Invisible;
begin
  CmdL.Align:= alClient;
  PanelFrame.Visible:= False;
end;

procedure TForm1.Visible;
begin
  CmdSplitter.Align:= alNone;
  CmdL.Align:= alBottom;
  PanelFrame.Visible:= True;
  CmdSplitter.Align:= alBottom;
end;

{$R *.lfm}

end.
