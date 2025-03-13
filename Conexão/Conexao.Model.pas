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
  gConnection : TFDConnection;

function SetupConnection(mConn: TFDConnection): String;
function Connect : TFDConnection;
procedure Disconect;

implementation

function SetupConnection(mConn: TFDConnection): string;
begin
  try
    mConn.Params.Values['DriverID'] := 'MSSQL';
    mConn.Params.Values['Database'] := 'CadastroPessoa';
    mConn.Params.Add('OSAuthent=Yes');
    mConn.Params.Add('Server=DESKTOP-LQTA0BU\SQLEXPRESS');

    Result := 'OK';
  except
    on E: Exception do
      Result := 'Erro ao configurar banco: ' + E.Message;
  end;
end;

function Connect: TFDConnection;
begin
  gConnection := TFDConnection.Create(nil);
  SetupConnection(gConnection);
  gConnection.Connected := True;

  Result := gConnection;
end;

procedure Disconect;
begin
  if Assigned(gConnection) then
    begin
      if gConnection.Connected then
        gConnection.Connected := False;

      FreeAndNil(gConnection);
    end;
end;

end.
