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
    fPessoas: TObjectList<TPessoa>;
    fConn: TFDConnection;
  public
    constructor Create(mConn: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure AdicionarPessoaMemoria(const mNome: string; mDataNascimento: TDate; mSaldoDevedor: Double);
    procedure AdicionarPessoaBanco(const mNome: string; mDataNascimento: TDate; mSaldoDevedor: Double);
    procedure AdicionarPessoaMemoriaBanco;
    procedure ExcluirPessoaPorId(mIdSelecionado: Integer);
    function CarregarPessoaBanco: TFDQuery;
    function CarregarPessoaBancoPorId(mIdSelecionado: Integer): TFDQuery;
    function ObterPessoas: TObjectList<TPessoa>;
    function GetMaxId: Integer;
  end;

implementation

{ TServidorController }

procedure TServidorController.AdicionarPessoaMemoria(const mNome: string; mDataNascimento: TDate; mSaldoDevedor: Double);
begin
  fPessoas.Add(TPessoa.Create(GetMaxId, mNome, mDataNascimento, mSaldoDevedor));
end;

procedure TServidorController.AdicionarPessoaBanco(const mNome: string; mDataNascimento: TDate; mSaldoDevedor: Double);
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      mQuery.SQL.Add('INSERT INTO pessoa ');
      mQuery.SQL.Add('(nome, data_nascimento, saldo_devedor) ');
      mQuery.SQL.Add('VALUES ');
      mQuery.SQL.Add(':mNome, :mDataNascimento, :mSaldoDevedor)');
      mQuery.ParamByName('mNome').AsString := mNome;
      mQuery.ParamByName('mDataNascimento').AsDate := mDataNascimento;
      mQuery.ParamByName('mSaldoDevedor').AsCurrency := mSaldoDevedor;
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
    FreeAndNil(mQuery);
  end;
end;

function TServidorController.CarregarPessoaBanco: TFDQuery;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    try
      mQuery.Connection := fConn;
      mQuery.SQL.Add('SELECT id, nome, data_nascimento, saldo_devedor ');
      mQuery.SQL.Add('FROM pessoa');
      mQuery.Open;

      Result := mQuery;
    except
      on E: Exception do
        begin
          raise Exception.Create('Erro ao consultar pessoas: ' + E.Message);
          Result := nil;
        end;
    end;
  finally
    FreeAndNil(mQuery);
  end;
end;

function TServidorController.CarregarPessoaBancoPorId(mIdSelecionado: Integer): TFDQuery;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    try
      mQuery.Connection := fConn;
      mQuery.SQL.Add('SELECT id, nome, data_nascimento, saldo_devedor ');
      mQuery.SQL.Add('FROM pessoa ');
      mQuery.SQL.Add('WHERE ');
      mQuery.SQL.Add('(id = :mId)');
      mQuery.ParamByName('mId').AsInteger := mIdSelecionado;
      mQuery.Open;

      Result := mQuery;
    except
      on E: Exception do
        begin
          raise Exception.Create('Erro ao consultar pessoa por Id: ' + E.Message);
          Result := nil;
        end;
    end;
  finally
    FreeAndNil(mQuery);
  end;
end;

function TServidorController.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := fPessoas;
end;

constructor TServidorController.Create(mConn: TFDConnection);
begin
  fPessoas := TObjectList<TPessoa>.Create(True);
  fConn := mConn;
end;

destructor TServidorController.Destroy;
begin
  FreeAndNil(fPessoas);
  FreeAndNil(fConn);

  inherited;
end;

procedure TServidorController.ExcluirPessoaPorId(mIdSelecionado: Integer);
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      mQuery.SQL.Add('DELETE FROM pessoa ');
      mQuery.SQL.Add('WHERE ');
      mQuery.SQL.Add('(id = :mId)');
      mQuery.ParamByName('mId').AsInteger := mIdSelecionado;
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
    FreeAndNil(mQuery);
  end;
end;

function TServidorController.GetMaxId: Integer;
begin
  Result := 0;
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Add('SELECT ISNULL(MAX(id), 0)+1 AS max_id ');
    mQuery.SQL.Add('FROM pessoa');
    mQuery.Open;

    if (not mQuery.IsEmpty) then
      Result := mQuery.FieldByName('max_id').AsInteger;
  finally
    FreeAndNil(mQuery);
  end;
end;

procedure TServidorController.AdicionarPessoaMemoriaBanco;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      for var mPessoa in fPessoas do
        begin
          mQuery.SQL.Add('INSERT INTO pessoa ');
          mQuery.SQL.Add('(nome, data_nascimento, saldo_devedor) ');
          mQuery.SQL.Add('VALUES ');
          mQuery.SQL.Add('(:mNome, :mData, :mSaldo)');
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
    FreeAndNil(mQuery);
  end;

  fPessoas.Clear;
end;

end.
