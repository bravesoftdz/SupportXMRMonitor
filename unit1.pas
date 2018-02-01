unit Unit1;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, fphttpclient, fpjson, jsonparser, IniFiles;

type

  { TXmrInfoForm }

  TXmrInfoForm = class(TForm)
    MenuItem1, MenuItem2: TMenuItem;
    PopMenu: TPopupMenu;
    XmrLabel: TLabel;
    UpdateTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure UpdateGui(Sender: TObject);
    procedure SetMinerGroup(Sender: TObject);
  end;

var
  XmrInfoForm: TXmrInfoForm;
  MinerGroup, BinaryFolder: String;
  INI: TINIFile;

implementation

{$R *.lfm}

function getMyXMR():Real;
var
  jData : TJSONData;
  due, paid : Int64;
begin
  If MinerGroup.Length > 0 Then
  begin
    jData := GetJSON(TFPCustomHTTPClient.SimpleGet('https://supportxmr.com/api/miner/' + MinerGroup + '/stats'));
    due := jData.GetPath('amtDue').AsInt64;
    paid := jData.GetPath('amtPaid').AsInt64;
    getMyXMR := (due + paid) / 1000000000000;
  end;
end;

procedure TXmrInfoForm.UpdateTimerTimer(Sender: TObject);
begin
  UpdateGui(Sender);
end;

procedure TXmrInfoForm.FormCreate(Sender: TObject);
begin
  XmrInfoForm.Top := 25;
  XmrInfoForm.Height := 16;
  XmrInfoForm.Width := 125;
  XmrInfoForm.Left := Screen.width - (XmrInfoForm.Width + 5);
  XmrLabel.Width := 115;
  BinaryFolder := ExtractFileDir(ParamStr(0)) + PathDelim;

  INI := TINIFile.Create(BinaryFolder + 'supportxmrsettings.ini');
  MinerGroup := INI.ReadString('SUPPORT-XMR-MONITOR','MinerGroup','');

  If MinerGroup.Length = 0 Then
    SetMinerGroup(Sender);

  UpdateTimer.Enabled := true;
end;

procedure TXmrInfoForm.FormDestroy(Sender: TObject);
begin
  INI.Free;
end;

procedure TXmrInfoForm.MenuItem1Click(Sender: TObject);
begin
  SetMinerGroup(Sender);
end;

procedure TXmrInfoForm.MenuItem2Click(Sender: TObject);
begin
  Halt;
end;

procedure TXmrInfoForm.UpdateGui(Sender: TObject);
begin
  XmrLabel.Caption := FloatToStr(getMyXmr());
  XmrInfoForm.Width := XmrLabel.Width + (XmrLabel.Left * 2);
  XmrInfoForm.Left := Screen.Width - (XmrInfoForm.Width + 5);
end;

procedure TXmrInfoForm.SetMinerGroup(Sender: TObject);
begin
  InputQuery('', 'Miner group to monitor', MinerGroup);
  INI.WriteString('SUPPORT-XMR-MONITOR','MinerGroup',MinerGroup);
end;
end.
