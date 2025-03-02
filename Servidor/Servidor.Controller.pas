unit Servidor.Controller;

interface

uses
  Pessoa.Model, Imovel.Model, Caracteristica.Model, Avaliacao.Model,
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt,
  System.Net.HttpClientComponent, System.SysUtils, System.Generics.Collections,
  System.JSON, System.Net.HttpClient, FireDAC.Stan.Param;

type
  TServidorController = class

  private
    FPessoas: TObjectList<TPessoa>;
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure AdicionarPessoaMemoria(const Nome: string; DataNascimento: TDate; SaldoDevedor: Double);
    procedure AdicionarPessoaBanco(const Nome: string; DataNascimento: TDate; SaldoDevedor: Double);
    procedure AdicionarPessoaMemoriaBanco;
    procedure ExcluirPessoaPorId(IdSelecionado: Integer);
    function CarregarPessoaBanco: TFDQuery;
    function CarregarPessoaBancoPorId(IdSelecionado: Integer): TFDQuery;
    function ObterPessoas: TObjectList<TPessoa>;
    function GetMaxId: Integer;
  end;

implementation

{ TServidorController }

procedure TServidorController.AdicionarPessoaMemoria(const Nome: string;
  DataNascimento: TDate; SaldoDevedor: Double);
begin
  FPessoas.Add(TPessoa.Create(GetMaxId, Nome, DataNascimento, SaldoDevedor));
end;

procedure TServidorController.AdicionarPessoaBanco(const Nome: string;
  DataNascimento: TDate; SaldoDevedor: Double);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    FConn.StartTransaction;
    try
      Query.SQL.Text := 'INSERT INTO PESSOA (NOME, DATA_NASCIMENTO, SALDO_DEVEDOR) VALUES (:nome, :data_nascimento, :saldo_devedor)';
      Query.ParamByName('nome').AsString := Nome;
      Query.ParamByName('data_nascimento').AsDate := DataNascimento;
      Query.ParamByName('saldo_devedor').AsCurrency := SaldoDevedor;
      Query.ExecSQL;

      FConn.Commit;
    except
      on E: Exception do
      begin
        FConn.Rollback;
        raise Exception.Create('Erro ao gravar pessoa no banco: ' + E.Message);
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TServidorController.CarregarPessoaBanco: TFDQuery;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT Id, NOME, DATA_NASCIMENTO, SALDO_DEVEDOR FROM PESSOA';
    Query.Open;

    Result := Query;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao consultar pessoas: ' + E.Message);
      Result := nil;
    end;
  end;
end;

function TServidorController.CarregarPessoaBancoPorId(
  IdSelecionado: Integer): TFDQuery;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT Id, NOME, DATA_NASCIMENTO, SALDO_DEVEDOR FROM PESSOA WHERE Id = :id';
    Query.ParamByName('id').AsInteger := IdSelecionado;
    Query.Open;

    Result := Query;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao consultar pessoa por Id: ' + E.Message);
      Result := nil;
    end;
  end;
end;

function TServidorController.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := FPessoas;
end;

constructor TServidorController.Create(AConn: TFDConnection);
begin
  FPessoas := TObjectList<TPessoa>.Create(True);
  FConn := AConn;
end;

destructor TServidorController.Destroy;
begin
  FreeAndNil(FPessoas);
  FreeAndNil(FConn);
  inherited;
end;

procedure TServidorController.ExcluirPessoaPorId(IdSelecionado: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    FConn.StartTransaction;
    try
      Query.SQL.Text := 'DELETE FROM PESSOA WHERE Id = :id';
      Query.ParamByName('id').AsInteger := IdSelecionado;
      Query.ExecSQL;

      FConn.Commit;
    except
      on E: Exception do
      begin
        FConn.Rollback;
        raise Exception.Create('Erro ao excluir pessoa do banco: ' + E.Message);
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TServidorController.GetMaxId: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT ISNULL(MAX(Id), 0)+1 AS MAX_ID FROM PESSOA';
    Query.Open;

    if not Query.IsEmpty then
      Result := Query.FieldByName('MAX_ID').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TServidorController.AdicionarPessoaMemoriaBanco;
var
  Pessoa: TPessoa;
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    FConn.StartTransaction;
    try
      for Pessoa in FPessoas do
      begin
        Query.SQL.Text := 'INSERT INTO PESSOA (NOME, DATA_NASCIMENTO, SALDO_DEVEDOR) VALUES (:nome, :data_nascimento, :saldo_devedor)';
        Query.ParamByName('nome').AsString := Pessoa.Nome;
        Query.ParamByName('data_nascimento').AsDate := Pessoa.DataNascimento;
        Query.ParamByName('saldo_devedor').AsCurrency := Pessoa.SaldoDevedor;
        Query.ExecSQL;
      end;
      FConn.Commit;
    except
      on E: Exception do
      begin
        FConn.Rollback;
        raise Exception.Create('Erro ao gravar pessoa no banco: ' + E.Message);
      end;
    end;
  finally
    Query.Free;
  end;

  FPessoas.Clear;
end;

end.
