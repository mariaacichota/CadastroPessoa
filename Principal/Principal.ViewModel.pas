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
var
  HTTP : TNetHTTPClient;
  Response : string;
  Imovel : TImovel;
begin
  FImoveis.Clear;

  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get('https://developers.silbeck.com.br/mocks/apiteste/v2/aptos').ContentAsString;
    FImoveis := JSONParaImovel(Response);
    LimparDadosMemTable(fmtImovel);

    for Imovel in FImoveis do
    begin
      PopularMemTableImovel(fmtImovel,
              Imovel.Codigo, Imovel.Nome, Imovel.Preco, Imovel.Caracteristicas);
    end;
  finally
    HTTP.Free;
    Imovel.Free;
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaBanco(aExcluirId: Boolean);
var
  mQuery : TFDQuery;
  Pessoa : TPessoa;
begin
  LimparDadosMemTable(fmtPessoa);
  FMemTableAtual := fmtPessoa;

  mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Text   := 'SELECT Id, NOME, DATA_NASCIMENTO, SALDO_DEVEDOR FROM PESSOA';
    mQuery.Open;
    FPessoas.Clear;

    if mQuery.IsEmpty then
      ShowMessage('Não foram encontrados registros no banco de dados.')
    else
    begin
      while not mQuery.Eof do
      begin
        Pessoa := TPessoa.Create(mQuery.FieldByName('Id').AsInteger,
                                  mQuery.FieldByName('NOME').AsString,
                                  mQuery.FieldByName('DATA_NASCIMENTO').AsDateTime,
                                  mQuery.FieldByName('SALDO_DEVEDOR').AsCurrency);
        FPessoas.Add(Pessoa);
        PopularMemTablePessoa(fmtPessoa, mQuery.FieldByName('Id').AsInteger,
                                  mQuery.FieldByName('NOME').AsString,
                                  mQuery.FieldByName('DATA_NASCIMENTO').AsDateTime,
                                  mQuery.FieldByName('SALDO_DEVEDOR').AsCurrency);
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
var
  Pessoas : TObjectList<TPessoa>;
  Pessoa : TPessoa;
begin
  LimparDadosMemTable(fmtPessoaMemoria);

  MemTableAtual := fmtPessoaMemoria;

  Pessoas := ObterPessoas;
  for Pessoa in Pessoas do
  begin
    PopularMemTablePessoa(fmtPessoaMemoria, Pessoa.Id, Pessoa.Nome, Pessoa.DataNascimento, Pessoa.SaldoDevedor);
  end;
end;

procedure TPrincipalViewModel.ExcluirPessoaPorId(aIdSelecionado: Integer);
var
  mQuery : TFDQuery;
begin
  mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    fConn.StartTransaction;
    try
      mQuery.SQL.Text := 'DELETE FROM PESSOA WHERE Id = :id';
      mQuery.ParamByName('id').AsInteger := aIdSelecionado;
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
var
  mQuery : TFDQuery;
begin
  Result := 0;

  mQuery  := TFDQuery.Create(nil);
  try
    mQuery.Connection := fConn;
    mQuery.SQL.Text := 'SELECT ISNULL(MAX(Id), 0)+1 AS MAX_ID FROM PESSOA';
    mQuery.Open;

    if not mQuery.IsEmpty then
      Result := mQuery.FieldByName('MAX_ID').AsInteger;
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
var
  mQuery : TFDQuery;
  Pessoa : TPessoa;
begin
  mQuery := TFDQuery.Create(nil);
  try
    mQuery.Connection := FConn;
    FConn.StartTransaction;
    try
      for Pessoa in FPessoas do
      begin
        if ValidaPessoa(Pessoa.Nome, Pessoa.DataNascimento, Pessoa.SaldoDevedor) then
        begin
          mQuery.SQL.Text := 'INSERT INTO PESSOA (NOME, DATA_NASCIMENTO, SALDO_DEVEDOR) VALUES (:nome, :data_nascimento, :saldo_devedor)';
          mQuery.ParamByName('nome').AsString := Pessoa.Nome;
          mQuery.ParamByName('data_nascimento').AsDate := Pessoa.DataNascimento;
          mQuery.ParamByName('saldo_devedor').AsCurrency := Pessoa.SaldoDevedor;
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
var
  JSONArray : TJSONArray;
  JSONObject : TJSONObject;
  JSONValue : TJSONValue;
  Imovel : TImovel;
  Caracteristica : TCaracteristica;
  Avaliacao : TAvaliacao;
  AvaliacaoJSON : TJSONObject;
  CaracteristicasArray : TJSONArray;
  CaracteristicasList : TObjectList<TCaracteristica>;
  I : Integer;
begin
  Result := TObjectList<TImovel>.Create(True);

  JSONArray := TJSONObject.ParseJSONValue(aJSON) as TJSONArray;
  if not Assigned(JSONArray) then
    Exit;

  try
    for JSONValue in JSONArray do
    begin
      JSONObject           := JSONValue as TJSONObject;
      CaracteristicasList  := TObjectList<TCaracteristica>.Create(True);
      CaracteristicasArray := JSONObject.GetValue<TJSONArray>('caracteristicas');
      if Assigned(CaracteristicasArray) then
      begin
        for I := 0 to CaracteristicasArray.Count - 1 do
        begin
          Caracteristica := TCaracteristica.Create(
            CaracteristicasArray.Items[I].GetValue<Integer>('id'),
            CaracteristicasArray.Items[I].GetValue<string>('nome'),
            CaracteristicasArray.Items[I].GetValue<string>('icone')
          );
          CaracteristicasList.Add(Caracteristica);
        end;
      end;

      Avaliacao     := nil;
      AvaliacaoJSON := JSONObject.GetValue<TJSONObject>('avaliacao');
      if Assigned(AvaliacaoJSON) then
      begin
        Avaliacao := TAvaliacao.Create(
          AvaliacaoJSON.GetValue<Double>('nota', 0.0),
          AvaliacaoJSON.GetValue<Integer>('quantidade', 0)
        );
      end;

      Imovel := TImovel.Create(
        JSONObject.GetValue<Integer>('id', 0),
        JSONObject.GetValue<Integer>('hospedes', 0),
        JSONObject.GetValue<string>('url', ''),
        JSONObject.GetValue<string>('nome', ''),
        JSONObject.GetValue<string>('codigo', ''),
        JSONObject.GetValue<string>('img', ''),
        JSONObject.GetValue<string>('descricao', ''),
        JSONObject.GetValue<Double>('preco', 0.0),
        CaracteristicasList,
        Avaliacao
      );

      Result.Add(Imovel);
    end;
  finally
    JSONArray.Free;
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
var
  strCaracteristicas : String;
  Caracteristica : TCaracteristica;
begin
  strCaracteristicas := '';

  for Caracteristica in aCaracteristicas do
  begin
    if strCaracteristicas.IsEmpty then
      strCaracteristicas := Caracteristica.Nome
    else
      strCaracteristicas := strCaracteristicas + ', ' + Caracteristica.Nome;
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
var
  I : Integer;
begin
  Result := False;

  if Length(Trim(aNome)) < 3 then
  begin
    ShowMessage('O nome deve ter pelo menos 3 caracteres.');
    Exit(False);
  end;

  for I := 1 to Length(aNome) do
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
