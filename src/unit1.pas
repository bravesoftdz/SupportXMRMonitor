unit Unit1;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, fphttpclient, fpjson, jsonparser, IniFiles, lclintf;

type

  { TXmrInfoForm }

  TXmrInfoForm = class(TForm)
    MenuItem1, MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PopMenu: TPopupMenu;
    XmrLabel: TLabel;
    UpdateTimer: TTimer;
    VersionLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure UpdateGui(Sender: TObject);
    procedure SetMinerGroup(Sender: TObject);
  end;

var
  XmrInfoForm: TXmrInfoForm;
  MinerGroup, BinaryFolder: String;
  UpdateInterval: Integer;
  INI: TINIFile;
  INI_GROUP: String = 'SUPPORT-XMR-MONITOR';
  VERSION_INFO: String = '0.1.1';

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
  end
  else
    getMyXMR := 0;
end;

procedure TXmrInfoForm.FormCreate(Sender: TObject);
begin
  XmrInfoForm.Top := 25;
  XmrInfoForm.Height := 32;
  XmrInfoForm.Width := 125;
  XmrInfoForm.Left := Screen.width - (XmrInfoForm.Width + 5);
  XmrLabel.Width := 115;
  BinaryFolder := ExtractFileDir(ParamStr(0)) + PathDelim;

  INI := TINIFile.Create(BinaryFolder + 'supportxmrsettings.ini');
  MinerGroup := INI.ReadString(INI_GROUP,'MinerGroup','');
  UpdateInterval := INI.ReadInteger(INI_GROUP, 'UpdateInterval', 60000);

  If MinerGroup.Length = 0 Then
    SetMinerGroup(Sender);

  UpdateTimer.Interval := UpdateInterval;
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

procedure TXmrInfoForm.MenuItem3Click(Sender: TObject);
var
  TempInterval: String;
begin
  TempInterval := UpdateInterval.ToString;
  InputQuery('', 'Update interval in milliseconds (60000 = 1 minute)', TempInterval);
  If TempInterval.Length > 0 Then
  begin
    INI.WriteInteger('SUPPORT-XMR-MONITOR','UpdateInterval', TempInterval.ToInteger());
    UpdateInterval := TempInterval.ToInteger();
    UpdateTimer.Interval := UpdateInterval;
  end;
end;

procedure TXmrInfoForm.MenuItem4Click(Sender: TObject);
begin
  OpenURL('https://github.com/MFernstrom/SupportXMRMonitor');
end;

procedure TXmrInfoForm.SetMinerGroup(Sender: TObject);
begin
  InputQuery('', 'Miner group to monitor', MinerGroup);
  INI.WriteString('SUPPORT-XMR-MONITOR','MinerGroup', MinerGroup);
  UpdateGui(Sender);
end;
end.
