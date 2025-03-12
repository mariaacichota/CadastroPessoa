unit Principal.ViewModel;

interface

uses
  Pessoa.Model, Imovel.Model, Caracteristica.Model, Avaliacao.Model,
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt,
  System.Net.HttpClientComponent, System.SysUtils, System.Generics.Collections,
  System.JSON, System.Net.HttpClient, FireDAC.Stan.Param;

type
  TPrincipalViewModel = class

  private
    FPessoas: TObjectList<TPessoa>;
    FImoveis: TObjectList<TImovel>;
    FMemTableAtual: TFDMemTable;
    fmtPessoa: TFDMemTable;
    fmtPessoaMemoria: TFDMemTable;
    fmtImovel: TFDMemTable;
    fConn: TFDConnection;
  public
    constructor Create(aConn: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure AdicionarPessoa(const aNome: string; aDataNascimento: TDate; aSaldoDevedor: Double);
    procedure GravarPessoaBanco;
    procedure ExcluirPessoaPorId(aIdSelecionado: Integer);
    procedure CarregarPessoaBanco(aExcluirId: Boolean);
    procedure CarregarPessoaMemoria;
    procedure BuscarImoveisAPI;
    procedure CriarMemTablePessoa;
    procedure CriarMemTableImovel;
    procedure PopularMemTablePessoa(aMemTable: TFDMemTable; aId: Integer; aNome: String; aDataNascimento: TDate; aSaldoDevedor: Double);
    procedure PopularMemTableImovel(aMemTable: TFDMemTable; aCodigo, aNome: String; aPreco: Double; aCaracteristicas: TObjectList<TCaracteristica>);
    procedure LimparDadosMemTable(aMemTable: TFDMemTable);

    function JSONParaImovel(aJSON: string): TObjectList<TImovel>;
    function ObterImoveis: TObjectList<TImovel>;
    function ObterPessoas: TObjectList<TPessoa>;
    function GetMemTable: TFDMemTable;
    function GetMemTableImovel: TFDMemTable;
    function GetMaxId: Integer;
    function ValidaPessoa(aNome: String; aDataNascimento: TDate; aSaldoDevedor: Double): Boolean;

    property MemTableAtual: TFDMemTable read FMemTableAtual write FMemTableAtual;
  end;

implementation

uses
  Data.DB, Vcl.Dialogs;

constructor TPrincipalViewModel.Create(aConn: TFDConnection);
begin
  FPessoas := TObjectList<TPessoa>.Create(True);
  FImoveis := TObjectList<TImovel>.Create(True);
  fConn    := aConn;
  CriarMemTablePessoa;
  CriarMemTableImovel;
end;

procedure TPrincipalViewModel.CriarMemTableImovel;
begin
  fmtImovel := TFDMemTable.Create(nil);
  fmtImovel.FieldDefs.Add('Codigo', ftString, 50);
  fmtImovel.FieldDefs.Add('Nome', ftString, 100);
  fmtImovel.FieldDefs.Add('Preco', ftCurrency);
  fmtImovel.FieldDefs.Add('Caracteristicas', ftString, 250);
  fmtImovel.CreateDataSet;
end;

procedure TPrincipalViewModel.CriarMemTablePessoa;
begin
  fmtPessoa := TFDMemTable.Create(nil);
  fmtPessoa.FieldDefs.Add('Id', ftInteger);
  fmtPessoa.FieldDefs.Add('Nome', ftString, 100);
  fmtPessoa.FieldDefs.Add('Data de Nascimento', ftDate);
  fmtPessoa.FieldDefs.Add('Saldo Devedor', ftCurrency);
  fmtPessoa.CreateDataSet;

  fmtPessoaMemoria := TFDMemTable.Create(nil);
  fmtPessoaMemoria.FieldDefs.Add('Id', ftInteger);
  fmtPessoaMemoria.FieldDefs.Add('Nome', ftString, 100);
  fmtPessoaMemoria.FieldDefs.Add('Data de Nascimento', ftDate);
  fmtPessoaMemoria.FieldDefs.Add('Saldo Devedor', ftCurrency);
  fmtPessoaMemoria.CreateDataSet;
end;

destructor TPrincipalViewModel.Destroy;
begin
  FreeAndNil(FPessoas);
  FreeAndNil(fConn);
  FreeAndNil(fmtImovel);
  FreeAndNil(fmtPessoa);
  FreeAndNil(fmtPessoaMemoria);

  inherited;
end;

procedure TPrincipalViewModel.AdicionarPessoa(const aNome: string;
  aDataNascimento: TDate; aSaldoDevedor: Double);
begin
  if not ValidaPessoa(aNome, aDataNascimento, aSaldoDevedor) then
    exit;

  FPessoas.Add(TPessoa.Create(GetMaxId, aNome, aDataNascimento, aSaldoDevedor));

  ShowMessage('Os dados de '+ aNome +' foram adicionados a memória com sucesso!');
end;

procedure TPrincipalViewModel.BuscarImoveisAPI;
begin
  FImoveis.Clear;

  var mHTTP := TNetHTTPClient.Create(nil);
  try
    var mResponse := HTTP.Get('https://developers.silbeck.com.br/mocks/apiteste/v2/aptos').ContentAsString;
    FImoveis := JSONParaImovel(mResponse);
    LimparDadosMemTable(fmtImovel);

    for var mImovel in FImoveis do
      begin
        PopularMemTableImovel(fmtImovel,
                mImovel.Codigo, mImovel.Nome, mImovel.Preco, mImovel.Caracteristicas);
      end;
  finally
    mHTTP.Free;
    mImovel.Free;
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaBanco(aExcluirId: Boolean);
begin
  LimparDadosMemTable(fmtPessoa);
  FMemTableAtual := fmtPessoa;

  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Text   := 'SELECT id, nome, data_nascimento, saldo_devedor FROM pessoa';
    mQuery.Open;
    FPessoas.Clear;

    if mQuery.IsEmpty then
      ShowMessage('Não foram encontrados registros no banco de dados.')
    else
      begin
        while not mQuery.Eof do
          begin
            var mPessoa := TPessoa.Create(mQuery.FieldByName('id').AsInteger,
                                      mQuery.FieldByName('nome').AsString,
                                      mQuery.FieldByName('data_nascimento').AsDateTime,
                                      mQuery.FieldByName('saldo_devedor').AsCurrency);
            FPessoas.Add(Pessoa);
            PopularMemTablePessoa(fmtPessoa, mQuery.FieldByName('id').AsInteger,
                                      mQuery.FieldByName('nome').AsString,
                                      mQuery.FieldByName('data_nascimento').AsDateTime,
                                      mQuery.FieldByName('saldo_devedor').AsCurrency);
            mQuery.Next;
          end;

        if not aExcluirId then
          ShowMessage('Os dados adicionados no banco foram carregados na memória com sucesso!');
      end;
  finally
    mQuery.Free;
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaMemoria;
begin
  LimparDadosMemTable(fmtPessoaMemoria);

  MemTableAtual := fmtPessoaMemoria;

  var mPessoas := ObterPessoas;
  for mPessoa in mPessoas do
    begin
      PopularMemTablePessoa(fmtPessoaMemoria, mPessoa.Id, mPessoa.Nome, mPessoa.DataNascimento, mPessoa.SaldoDevedor);
    end;
end;

procedure TPrincipalViewModel.ExcluirPessoaPorId(aIdSelecionado: Integer);
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

      ShowMessage('Pessoa com ID ' + IntToStr(aIdSelecionado) + ' foi excluída.');
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

function TPrincipalViewModel.GetMaxId: Integer;
begin
  Result := 0;

  var mQuery  := TFDQuery.Create(nil);
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

function TPrincipalViewModel.GetMemTable: TFDMemTable;
begin
  Result := FMemTableAtual;
end;

function TPrincipalViewModel.GetMemTableImovel: TFDMemTable;
begin
  Result := fmtImovel;
end;

procedure TPrincipalViewModel.GravarPessoaBanco;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := FConn;
    fConn.StartTransaction;
    try
      for var mPessoa in FPessoas do
        begin
          if ValidaPessoa(mPessoa.Nome, mPessoa.DataNascimento, mPessoa.SaldoDevedor) then
            begin
              mQuery.SQL.Text := 'INSERT INTO pessoa (nome, data_nascimento, saldo_devedor) VALUES (:mNome, :mDataNascimento, :mSaldoDevedor)';
              mQuery.ParamByName('mNome').AsString           := mPessoa.Nome;
              mQuery.ParamByName('mDataNascimento').AsDate   := mPessoa.DataNascimento;
              mQuery.ParamByName('mSaldoDevedor').AsCurrency := mPessoa.SaldoDevedor;
              mQuery.ExecSQL;
            end;
        end;

      fConn.Commit;

      ShowMessage('Os dados da memória foram salvos no banco de dados com sucesso!');
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

function TPrincipalViewModel.JSONParaImovel(aJSON: string): TObjectList<TImovel>;
begin
  Result := TObjectList<TImovel>.Create(True);

  var mJSONArray := TJSONObject.ParseJSONValue(aJSON) as TJSONArray;

  if not Assigned(mJSONArray) then
    Exit;

  try
    for var mJSONValue in mJSONArray do
    begin
      var mJSONObject           := JSONValue as TJSONObject;
      var mCaracteristicasList  := TObjectList<TCaracteristica>.Create(True);
      var mCaracteristicasArray := JSONObject.GetValue<TJSONArray>('caracteristicas');

      if Assigned(mCaracteristicasArray) then
        begin
          for var I := 0 to mCaracteristicasArray.Count - 1 do
            begin
              var mCaracteristica := TCaracteristica.Create(
                mCaracteristicasArray.Items[I].GetValue<Integer>('id'),
                mCaracteristicasArray.Items[I].GetValue<string>('nome'),
                mCaracteristicasArray.Items[I].GetValue<string>('icone')
              );
              mCaracteristicasList.Add(mCaracteristica);
            end;
        end;

      var mAvaliacaoJSON := JSONObject.GetValue<TJSONObject>('avaliacao');
      if Assigned(mAvaliacaoJSON) then
        begin
          var mAvaliacao := TAvaliacao.Create(
            mAvaliacaoJSON.GetValue<Double>('nota', 0.0),
            mAvaliacaoJSON.GetValue<Integer>('quantidade', 0)
          );
        end;

      var mImovel := TImovel.Create(
        mJSONObject.GetValue<Integer>('id', 0),
        mJSONObject.GetValue<Integer>('hospedes', 0),
        mJSONObject.GetValue<string>('url', ''),
        mJSONObject.GetValue<string>('nome', ''),
        mJSONObject.GetValue<string>('codigo', ''),
        mJSONObject.GetValue<string>('img', ''),
        mJSONObject.GetValue<string>('descricao', ''),
        mJSONObject.GetValue<Double>('preco', 0.0),
        mCaracteristicasList,
        mAvaliacao
      );

      Result.Add(mImovel);
    end;
  finally
    mJSONArray.Free;
  end;
end;

procedure TPrincipalViewModel.LimparDadosMemTable(aMemTable: TFDMemTable);
begin
  aMemTable.EmptyDataSet;
end;

function TPrincipalViewModel.ObterImoveis: TObjectList<TImovel>;
begin
  Result := FImoveis;
end;

function TPrincipalViewModel.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := FPessoas;
end;

procedure TPrincipalViewModel.PopularMemTableImovel(aMemTable: TFDMemTable;
  aCodigo, aNome: String; aPreco: Double; aCaracteristicas: TObjectList<TCaracteristica>);
begin
  var mStrCaracteristicas := '';

  for var mCaracteristica in aCaracteristicas do
    begin
      if mStrCaracteristicas.IsEmpty then
        mStrCaracteristicas := mCaracteristica.Nome
      else
        mStrCaracteristicas := mStrCaracteristicas + ', ' + mCaracteristica.Nome;
    end;

  aMemTable.Append;
  aMemTable.FieldByName('Código').AsString := aCodigo;
  aMemTable.FieldByName('Nome').AsString := aNome;
  aMemTable.FieldByName('Preço').AsCurrency := aPreco;
  aMemTable.FieldByName('Características').AsString := strCaracteristicas;
  aMemTable.Post;
end;

procedure TPrincipalViewModel.PopularMemTablePessoa(aMemTable: TFDMemTable; aId: Integer;
    aNome: String; aDataNascimento: TDate; aSaldoDevedor: Double);
begin
  aMemTable.Append;
  aMemTable.FieldByName('Id').AsInteger := aId;
  aMemTable.FieldByName('Nome').AsString := aNome;
  aMemTable.FieldByName('Data de Nascimento').AsDateTime := aDataNascimento;
  aMemTable.FieldByName('Saldo Devedor').AsCurrency := aSaldoDevedor;
  aMemTable.Post;
end;

function TPrincipalViewModel.ValidaPessoa(aNome: String;
  aDataNascimento: TDate; aSaldoDevedor: Double): Boolean;
begin
  Result := False;

  if Length(Trim(aNome)) < 3 then
    begin
      ShowMessage('O nome deve ter pelo menos 3 caracteres.');
      Exit(False);
    end;

  for var I := 1 to Length(aNome) do
    begin
      if CharInSet(aNome[I], ['0'..'9']) then
        begin
          ShowMessage('O nome não pode conter números.');
          Exit(False);
        end;
    end;

  if aDataNascimento >= Date then
    begin
      ShowMessage('A data de nascimento deve ser anterior à data atual.');
      Exit(False);
    end;

  if aSaldoDevedor < 0 then
    begin
      ShowMessage('O saldo devedor não pode ser negativo.');
      Exit(False);
    end;

  Result := True;
end;

end.
