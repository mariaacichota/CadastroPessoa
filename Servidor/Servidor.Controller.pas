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
    fConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure AdicionarPessoaMemoria(const aNome: string; aDataNascimento: TDate; aSaldoDevedor: Double);
    procedure AdicionarPessoaBanco(const aNome: string; aDataNascimento: TDate; aSaldoDevedor: Double);
    procedure AdicionarPessoaMemoriaBanco;
    procedure ExcluirPessoaPorId(aIdSelecionado: Integer);
    function CarregarPessoaBanco: TFDQuery;
    function CarregarPessoaBancoPorId(aIdSelecionado: Integer): TFDQuery;
    function ObterPessoas: TObjectList<TPessoa>;
    function GetMaxId: Integer;
  end;

implementation

{ TServidorController }

procedure TServidorController.AdicionarPessoaMemoria(const aNome: string;
  aDataNascimento: TDate; aSaldoDevedor: Double);
begin
  FPessoas.Add(TPessoa.Create(GetMaxId, aNome, aDataNascimento, aSaldoDevedor));
end;

procedure TServidorController.AdicionarPessoaBanco(const aNome: string;
  aDataNascimento: TDate; aSaldoDevedor: Double);
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      mQuery.SQL.Text := 'INSERT INTO pessoa (nome, data_nascimento, saldo_devedor) VALUES (:mNome, :mDataNascimento, :mSaldoDevedor)';
      mQuery.ParamByName('mNome').AsString := aNome;
      mQuery.ParamByName('mDataNascimento').AsDate := aDataNascimento;
      mQuery.ParamByName('mSaldoDevedor').AsCurrency := aSaldoDevedor;
      mQuery.ExecSQL;

      fConn.Commit;
    except
      on E: Exception do
        begin
          fConn.Rollback;
          raise Exception.Create('Erro ao gravar pessoa no banco: ' + E.Message);
        end;
    end;
  finally
    mQuery.Free;
  end;
end;

function TServidorController.CarregarPessoaBanco: TFDQuery;
var
  mQuery: TFDQuery;
begin
  mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Text := 'SELECT id, nome, data_nascimento, saldo_devedor FROM pessoa';
    mQuery.Open;

    Result := mQuery;
  except
    on E: Exception do
      begin
        raise Exception.Create('Erro ao consultar pessoas: ' + E.Message);
        Result := nil;
      end;
  end;
end;

function TServidorController.CarregarPessoaBancoPorId(
  aIdSelecionado: Integer): TFDQuery;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Text := 'SELECT id, nome, data_nascimento, saldo_devedor FROM pessoa WHERE id = :mId';
    mQuery.ParamByName('mId').AsInteger := aIdSelecionado;
    mQuery.Open;

    Result := mQuery;
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
  fConn := AConn;
end;

destructor TServidorController.Destroy;
begin
  FreeAndNil(FPessoas);
  FreeAndNil(fConn);
  inherited;
end;

procedure TServidorController.ExcluirPessoaPorId(aIdSelecionado: Integer);
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      mQuery.SQL.Text := 'DELETE FROM pessoa WHERE id = :mId';
      mQuery.ParamByName('mId').AsInteger := aIdSelecionado;
      mQuery.ExecSQL;

      fConn.Commit;
    except
      on E: Exception do
        begin
          fConn.Rollback;
          raise Exception.Create('Erro ao excluir pessoa do banco: ' + E.Message);
        end;
    end;
  finally
    mQuery.Free;
  end;
end;

function TServidorController.GetMaxId: Integer;
begin
  Result := 0;
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Text := 'SELECT ISNULL(MAX(id), 0)+1 AS max_id FROM pessoa';
    mQuery.Open;

    if not mQuery.IsEmpty then
      Result := mQuery.FieldByName('max_id').AsInteger;
  finally
    mQuery.Free;
  end;
end;

procedure TServidorController.AdicionarPessoaMemoriaBanco;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;

    try
      for var mPessoa in FPessoas do
        begin
          mQuery.SQL.Text := 'INSERT INTO pessoa (nome, data_nascimento, saldo_devedor) VALUES (:mNome, :mData, :mSaldo)';
          mQuery.ParamByName('mNome').AsString := mPessoa.Nome;
          mQuery.ParamByName('mData').AsDate := mPessoa.DataNascimento;
          mQuery.ParamByName('mSaldo').AsCurrency := mPessoa.SaldoDevedor;
          mQuery.ExecSQL;
        end;

      fConn.Commit;
    except
      on E: Exception do
        begin
          fConn.Rollback;
          raise Exception.Create('Erro ao gravar pessoa no banco: ' + E.Message);
        end;
    end;
  finally
    mQuery.Free;
  end;

  FPessoas.Clear;
end;

end.
