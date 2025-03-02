unit Conexao.Model;

interface

uses
  FireDAC.DApt, FireDAC.Stan.Option, FireDAC.Stan.Intf, FireDAC.UI.Intf,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, System.Classes,
  System.IniFiles, System.SysUtils;

var
  FConnection : TFDConnection;

function SetupConnection(FConn: TFDConnection): String;
function Connect : TFDConnection;
procedure Disconect;

implementation

function SetupConnection(FConn: TFDConnection): string;
var
  arq_ini : string;
  ini : TIniFile;
begin
  try
    FConn.Params.Values['DriverID'] := 'MSSQL';
    FConn.Params.Values['Database'] := 'CadastroPessoa';
    FConn.Params.Add('OSAuthent=Yes');
    FConn.Params.Add('Server=DESKTOP-LQTA0BU\SQLEXPRESS');

    Result := 'OK';
  except
    on ex:exception do
    Result := 'Erro ao configurar banco: ' + ex.Message;
  end;
end;

function Connect: TFDConnection;
begin
  FConnection := TFDConnection.Create(nil);
  SetupConnection(FConnection);
  FConnection.Connected := True;
  Result := FConnection;
end;

procedure Disconect;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;

    FConnection.Free;
  end;
end;

end.
