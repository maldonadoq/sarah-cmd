unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Grids, FrameGraphic, CmdParse, Func;

type
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
    procedure Visible;
    procedure Invisible;
    procedure Funct(fn: string);
  public
    MCmdParse: TCmdParse;
  end;

var
  Form1: TForm1;

implementation

procedure TForm1.FormCreate(Sender: TObject);
begin
  SgVariable.Cells[0,0]:= 'n°';
  SgVariable.Cells[1,0]:= 'name';
  SgVariable.Cells[2,0]:= 'type';
  Invisible;
  MCmdParse:= TCmdParse.Create();

  CmdL.StartRead(clGreen, clBlack,'Sarah] ',clGreen, clBlack);
  StartCommand;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  MCmdParse.Destroy();
end;

procedure TForm1.Funct(fn: string);
begin
  MCmdParse.Expression:= fn;
  MCmdParse.Evaluate();
end;

procedure TForm1.CmdLInput(ACmdBox: TCmdBox; Input: string);
var
  FinalLine: string;
begin
  try
    Input:= Trim(Input);
    case input of
      'help': ShowMessage( 'help ');
      'exit': Application.Terminate;
      'clear': begin CmdL.Clear; StartCommand() end;
      'clearhistory': CmdL.ClearHistory;

      else begin
        FinalLine:= StringReplace(Input, ' ', '', [rfReplaceAll]);
        if Pos('=',FinalLine)>0 then begin
          InstantFrame(0,False);
        end
        else if pos('plot',FinalLine)>0 then begin
          InstantFrame(0,True);
          Funct(FinalLine);
        end;
      end;
  end;
  finally
     StartCommand()
  end;
end;

procedure TForm1.InstantFrame(FrameSelected: integer; state: boolean);
begin
  if state then begin
    Visible;
    if Assigned(ActualFrame) then
      ActualFrame.Free;

    case FrameSelected of
      0: ActualFrame:= TFrame1.Create(Form1);
      1: ActualFrame:= TFrame1.Create(Form1);
    end;

    ActualFrame.Parent:= Form1.PanelFrame;
    ActualFrame.Align:= alClient;
  end
  else Invisible;
end;

procedure TForm1.StartCommand;
begin
   CmdL.StartRead(clGreen, clBlack,'Sarah] ',clGreen, clBlack);
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

