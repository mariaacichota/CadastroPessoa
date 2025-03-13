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
    FMemTableAtual: TFDMemTable;
    fPessoas: TObjectList<TPessoa>;
    fImoveis: TObjectList<TImovel>;
    fMtPessoa: TFDMemTable;
    fMtPessoaMemoria: TFDMemTable;
    fMtImovel: TFDMemTable;
    fConn: TFDConnection;
  public
    constructor Create(mConn: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure AdicionarPessoa(const mNome: string; mDataNascimento: TDate; mSaldoDevedor: Double);
    procedure GravarPessoaBanco;
    procedure ExcluirPessoaPorId(mIdSelecionado: Integer);
    procedure CarregarPessoaBanco(mExcluirId: Boolean);
    procedure CarregarPessoaMemoria;
    procedure BuscarImoveisAPI;
    procedure CriarMemTablePessoa;
    procedure CriarMemTableImovel;
    procedure PopularMemTablePessoa(mMemTable: TFDMemTable; mId: Integer; mNome: String; mDataNascimento: TDate; mSaldoDevedor: Double);
    procedure PopularMemTableImovel(mMemTable: TFDMemTable; mCodigo, mNome: String; mPreco: Double; mCaracteristicas: TObjectList<TCaracteristica>);
    procedure LimparDadosMemTable(mMemTable: TFDMemTable);
    function JSONParaImovel(aJSON: string): TObjectList<TImovel>;
    function ObterImoveis: TObjectList<TImovel>;
    function ObterPessoas: TObjectList<TPessoa>;
    function GetMemTable: TFDMemTable;
    function GetMemTableImovel: TFDMemTable;
    function GetMaxId: Integer;
    function ValidaPessoa(mNome: String; mDataNascimento: TDate; mSaldoDevedor: Double): Boolean;

    property MemTableAtual: TFDMemTable read FMemTableAtual write FMemTableAtual;
  end;

implementation

uses
  Data.DB, Vcl.Dialogs;

constructor TPrincipalViewModel.Create(mConn: TFDConnection);
begin
  fPessoas := TObjectList<TPessoa>.Create(True);
  fImoveis := TObjectList<TImovel>.Create(True);
  fConn    := mConn;
  CriarMemTablePessoa;
  CriarMemTableImovel;
end;
procedure TPrincipalViewModel.CriarMemTableImovel;
begin
  fMtImovel := TFDMemTable.Create(nil);
  fMtImovel.FieldDefs.Add('Codigo', ftString, 50);
  fMtImovel.FieldDefs.Add('Nome', ftString, 100);
  fMtImovel.FieldDefs.Add('Preco', ftCurrency);
  fMtImovel.FieldDefs.Add('Caracteristicas', ftString, 250);
  fMtImovel.CreateDataSet;
end;

procedure TPrincipalViewModel.CriarMemTablePessoa;
begin
  fMtPessoa := TFDMemTable.Create(nil);
  fMtPessoa.FieldDefs.Add('Id', ftInteger);
  fMtPessoa.FieldDefs.Add('Nome', ftString, 100);
  fMtPessoa.FieldDefs.Add('Data de Nascimento', ftDate);
  fMtPessoa.FieldDefs.Add('Saldo Devedor', ftCurrency);
  fMtPessoa.CreateDataSet;

  fMtPessoaMemoria := TFDMemTable.Create(nil);
  fMtPessoaMemoria.FieldDefs.Add('Id', ftInteger);
  fMtPessoaMemoria.FieldDefs.Add('Nome', ftString, 100);
  fMtPessoaMemoria.FieldDefs.Add('Data de Nascimento', ftDate);
  fMtPessoaMemoria.FieldDefs.Add('Saldo Devedor', ftCurrency);
  fMtPessoaMemoria.CreateDataSet;
end;

destructor TPrincipalViewModel.Destroy;
begin
  FreeAndNil(fPessoas);
  FreeAndNil(fConn);
  FreeAndNil(fMtImovel);
  FreeAndNil(fMtPessoa);
  FreeAndNil(fMtPessoaMemoria);
  inherited;
end;
procedure TPrincipalViewModel.AdicionarPessoa(const mNome: string; mDataNascimento: TDate; mSaldoDevedor: Double);
begin
  if (not ValidaPessoa(mNome, mDataNascimento, mSaldoDevedor)) then
    Exit;

  fPessoas.Add(TPessoa.Create(GetMaxId, mNome, mDataNascimento, mSaldoDevedor));

  ShowMessage('Os dados de '+ mNome +' foram adicionados a memória com sucesso!');
end;

procedure TPrincipalViewModel.BuscarImoveisAPI;
begin
  fImoveis.Clear;

  var mHTTP := TNetHTTPClient.Create(nil);
  try
    var mResponse := mHTTP.Get('https://developers.silbeck.com.br/mocks/apiteste/v2/aptos').ContentAsString;
    fImoveis := JSONParaImovel(mResponse);

    LimparDadosMemTable(fMtImovel);

    for var mImovel in fImoveis do
      PopularMemTableImovel(fMtImovel,mImovel.Codigo, mImovel.Nome, mImovel.Preco, mImovel.Caracteristicas);
  finally
    FreeAndNil(mHTTP);
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaBanco(mExcluirId: Boolean);
begin
  LimparDadosMemTable(fMtPessoa);
  FMemTableAtual := fMtPessoa;

  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Add('SELECT id, nome, data_nascimento, saldo_devedor ');
    mQuery.SQL.Add('FROM pessoa');
    mQuery.Open;

    fPessoas.Clear;

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
            fPessoas.Add(mPessoa);
            PopularMemTablePessoa(fMtPessoa,
                                  mQuery.FieldByName('id').AsInteger,
                                  mQuery.FieldByName('nome').AsString,
                                  mQuery.FieldByName('data_nascimento').AsDateTime,
                                  mQuery.FieldByName('saldo_devedor').AsCurrency);

            mQuery.Next;
          end;

        if (not mExcluirId) then
          ShowMessage('Os dados adicionados no banco foram carregados na memória com sucesso!');
      end;
  finally
    FreeAndNil(mQuery);
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaMemoria;
begin
  LimparDadosMemTable(fMtPessoaMemoria);

  MemTableAtual := fMtPessoaMemoria;

  var mPessoas := ObterPessoas;
  for var mPessoa in mPessoas do
    begin
      PopularMemTablePessoa(fMtPessoaMemoria, mPessoa.Id, mPessoa.Nome, mPessoa.DataNascimento, mPessoa.SaldoDevedor);
    end;
end;

procedure TPrincipalViewModel.ExcluirPessoaPorId(mIdSelecionado: Integer);
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      mQuery.SQL.Add('DELETE FROM pessoa ');
      mQuery.SQL.Add('WHERE (id = :mId)');
      mQuery.ParamByName('mId').AsInteger := mIdSelecionado;

      mQuery.ExecSQL;

      fConn.Commit;

      ShowMessage('Pessoa com ID ' + IntToStr(mIdSelecionado) + ' foi excluída.');
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

function TPrincipalViewModel.GetMaxId: Integer;
begin
  Result := 0;

  var mQuery  := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Add('SELECT ISNULL(MAX(id), 0)+1 AS max_id ');
    mQuery.SQL.Add('FROM pessoa');
    mQuery.Open;

    if (not mQuery.IsEmpty) then
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
  Result := fMtImovel;
end;

procedure TPrincipalViewModel.GravarPessoaBanco;
begin
  var mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := FConn;
    fConn.StartTransaction;
    try
      for var mPessoa in fPessoas do
        begin
          if ValidaPessoa(mPessoa.Nome, mPessoa.DataNascimento, mPessoa.SaldoDevedor) then
            begin
              mQuery.SQL.Add('INSERT INTO pessoa ');
              mQuery.SQL.Add('(nome, data_nascimento, saldo_devedor) ');
              mQuery.SQL.Add('VALUES ');
              mQuery.SQL.Add('(:mNome, :mDataNascimento, :mSaldoDevedor)');
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
    FreeAndNil(mQuery);
  end;

  fPessoas.Clear;
end;

function TPrincipalViewModel.JSONParaImovel(aJSON: string): TObjectList<TImovel>;
begin
  Result := TObjectList<TImovel>.Create(True);

  var mJSONArray := TJSONObject.ParseJSONValue(aJSON) as TJSONArray;
  if (not Assigned(mJSONArray)) then
    Exit;

  try
    for var mJSONValue in mJSONArray do
      begin
        var mJSONObject           := mJSONValue as TJSONObject;
        var mCaracteristicasList  := TObjectList<TCaracteristica>.Create(True);
        var mCaracteristicasArray := mJSONValue.GetValue<TJSONArray>('caracteristicas');
        if Assigned(mCaracteristicasArray) then
          begin
            for var I := 0 to mCaracteristicasArray.Count - 1 do
              begin
                var mCaracteristica := TCaracteristica.Create(mCaracteristicasArray.Items[I].GetValue<Integer>('id'),
                                                              mCaracteristicasArray.Items[I].GetValue<string>('nome'),
                                                              mCaracteristicasArray.Items[I].GetValue<string>('icone'));

                mCaracteristicasList.Add(mCaracteristica);
              end;
          end;

        var mAvaliacaoJSON := mJSONObject.GetValue<TJSONObject>('avaliacao');
        var mAvaliacao := nil;

        if Assigned(mAvaliacaoJSON) then
          begin
            mAvaliacao := TAvaliacao.Create(mAvaliacaoJSON.GetValue<Double>('nota', 0.0),
                                            mAvaliacaoJSON.GetValue<Integer>('quantidade', 0));
          end;

        var mImovel := TImovel.Create(mJSONObject.GetValue<Integer>('id', 0),
                                      mJSONObject.GetValue<Integer>('hospedes', 0),
                                      mJSONObject.GetValue<string>('url', ''),
                                      mJSONObject.GetValue<string>('nome', ''),
                                      mJSONObject.GetValue<string>('codigo', ''),
                                      mJSONObject.GetValue<string>('img', ''),
                                      mJSONObject.GetValue<string>('descricao', ''),
                                      mJSONObject.GetValue<Double>('preco', 0.0),
                                      mCaracteristicasList,
                                      mAvaliacao);

        Result.Add(mImovel);
      end;
  finally
    FreeAndNil(mJSONArray);
  end;
end;

procedure TPrincipalViewModel.LimparDadosMemTable(mMemTable: TFDMemTable);
begin
  mMemTable.EmptyDataSet;
end;

function TPrincipalViewModel.ObterImoveis: TObjectList<TImovel>;
begin
  Result := fImoveis;
end;

function TPrincipalViewModel.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := fPessoas;
end;

procedure TPrincipalViewModel.PopularMemTableImovel(mMemTable: TFDMemTable; mCodigo, mNome: String; mPreco: Double; mCaracteristicas: TObjectList<TCaracteristica>);
begin
  var mStrCaracteristicas := '';

  for var mCaracteristica in mCaracteristicas do
    begin
      if mStrCaracteristicas.IsEmpty then
        mStrCaracteristicas := mCaracteristica.Nome
      else
        mStrCaracteristicas := mStrCaracteristicas + ', ' + mCaracteristica.Nome;
    end;

  mMemTable.Append;
  mMemTable.FieldByName('Código').AsString  := mCodigo;
  mMemTable.FieldByName('Nome').AsString    := mNome;
  mMemTable.FieldByName('Preço').AsCurrency := mPreco;
  mMemTable.FieldByName('Características').AsString := mStrCaracteristicas;
  mMemTable.Post;
end;

procedure TPrincipalViewModel.PopularMemTablePessoa(mMemTable: TFDMemTable; mId: Integer; mNome: String; mDataNascimento: TDate; mSaldoDevedor: Double);
begin
  mMemTable.Append;
  mMemTable.FieldByName('Id').AsInteger  := mId;
  mMemTable.FieldByName('Nome').AsString := mNome;
  mMemTable.FieldByName('Data de Nascimento').AsDateTime := mDataNascimento;
  mMemTable.FieldByName('Saldo Devedor').AsCurrency      := mSaldoDevedor;
  mMemTable.Post;
end;

function TPrincipalViewModel.ValidaPessoa(mNome: String; mDataNascimento: TDate; mSaldoDevedor: Double): Boolean;
begin
  Result := False;
  if (Length(Trim(mNome)) < 3) then
    begin
      ShowMessage('O nome deve ter pelo menos 3 caracteres.');
      Exit(False);
    end;

  for var I := 1 to Length(mNome) do
    begin
      if (CharInSet(mNome[I], ['0'..'9'])) then
        begin
          ShowMessage('O nome não pode conter números.');
          Exit(False);
        end;
    end;

  if (mDataNascimento >= Date) then
    begin
      ShowMessage('A data de nascimento deve ser anterior à data atual.');
      Exit(False);
    end;

  if (mSaldoDevedor < 0) then
    begin
      ShowMessage('O saldo devedor não pode ser negativo.');
      Exit(False);
    end;

  Result := True;
end;

end.
