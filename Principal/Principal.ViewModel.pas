﻿unit Principal.ViewModel;

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
    FmtPessoa: TFDMemTable;
    FmtPessoaMemoria: TFDMemTable;
    FmtImovel: TFDMemTable;
    FConn: TFDConnection;
    FMemTableAtual: TFDMemTable;
  public
    constructor Create(AConn: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure AdicionarPessoa(const Nome: string; DataNascimento: TDate; SaldoDevedor: Double);
    procedure GravarPessoaBanco;
    procedure ExcluirPessoaPorId(IdSelecionado: Integer);
    procedure CarregarPessoaBanco(ExcluirId: Boolean);
    procedure CarregarPessoaMemoria;
    procedure BuscarImoveisAPI;
    procedure CriarMemTablePessoa;
    procedure CriarMemTableImovel;
    procedure PopularMemTablePessoa(MemTable: TFDMemTable; Id: Integer; Nome: String; DataNascimento: TDate; SaldoDevedor: Double);
    procedure PopularMemTableImovel(MemTable: TFDMemTable; Codigo, Nome: String; Preco: Double; Caracteristicas: TObjectList<TCaracteristica>);
    procedure LimparDadosMemTable(MemTable: TFDMemTable);

    function JSONParaImovel(JSON: string): TObjectList<TImovel>;
    function ObterImoveis: TObjectList<TImovel>;
    function ObterPessoas: TObjectList<TPessoa>;
    function GetMemTable: TFDMemTable;
    function GetMemTableImovel: TFDMemTable;
    function GetMaxId: Integer;
    function ValidaPessoa(Nome: String; DataNascimento: TDate; SaldoDevedor: Double): Boolean;

    property MemTableAtual: TFDMemTable read FMemTableAtual write FMemTableAtual;
  end;

implementation

uses
  Data.DB, Vcl.Dialogs;

constructor TPrincipalViewModel.Create(AConn: TFDConnection);
begin
  FPessoas := TObjectList<TPessoa>.Create(True);
  FImoveis := TObjectList<TImovel>.Create(True);
  FConn := AConn;
  CriarMemTablePessoa;
  CriarMemTableImovel;
end;

procedure TPrincipalViewModel.CriarMemTableImovel;
begin
  FmtImovel := TFDMemTable.Create(nil);
  with FmtImovel.FieldDefs do
  begin
    Add('Código', ftString, 50);
    Add('Nome', ftString, 100);
    Add('Preço', ftCurrency);
    Add('Características', ftString, 250);
  end;
  FmtImovel.CreateDataSet;
end;

procedure TPrincipalViewModel.CriarMemTablePessoa;
begin
  FmtPessoa := TFDMemTable.Create(nil);
  with FmtPessoa.FieldDefs do
  begin
    Add('Id', ftInteger);
    Add('Nome', ftString, 100);
    Add('Data de Nascimento', ftDate);
    Add('Saldo Devedor', ftCurrency);
  end;
  FmtPessoa.CreateDataSet;


  FmtPessoaMemoria := TFDMemTable.Create(nil);
  with FmtPessoaMemoria.FieldDefs do
  begin
    Add('Id', ftInteger);
    Add('Nome', ftString, 100);
    Add('Data de Nascimento', ftDate);
    Add('Saldo Devedor', ftCurrency);
  end;
  FmtPessoaMemoria.CreateDataSet;
end;

destructor TPrincipalViewModel.Destroy;
begin
  FreeAndNil(FPessoas);
  FreeAndNil(FConn);
  FreeAndNil(FmtImovel);
  FreeAndNil(FmtPessoa);
  FreeAndNil(FmtPessoaMemoria);

  inherited;
end;

procedure TPrincipalViewModel.AdicionarPessoa(const Nome: string;
  DataNascimento: TDate; SaldoDevedor: Double);
begin
  if not ValidaPessoa(Nome, DataNascimento, SaldoDevedor) then
    exit;

  FPessoas.Add(TPessoa.Create(GetMaxId, Nome, DataNascimento, SaldoDevedor));
  ShowMessage('Os dados de '+ Nome +' foram adicionados a memória com sucesso!');
end;

procedure TPrincipalViewModel.BuscarImoveisAPI;
var
  HTTP: TNetHTTPClient;
  Response: string;
  Imovel: TImovel;
begin
  FImoveis.Clear;
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get('https://developers.silbeck.com.br/mocks/apiteste/v2/aptos').ContentAsString;
    FImoveis := JSONParaImovel(Response);
    LimparDadosMemTable(FmtImovel);

    for Imovel in FImoveis do
    begin
      PopularMemTableImovel(FmtImovel,
              Imovel.Codigo, Imovel.Nome, Imovel.Preco, Imovel.Caracteristicas);
    end;

  finally
    HTTP.Free;
    Imovel.Free;
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaBanco(ExcluirId: Boolean);
var
  Query: TFDQuery;
  Pessoa: TPessoa;
begin
  LimparDadosMemTable(FmtPessoa);
  FMemTableAtual := FmtPessoa;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT Id, NOME, DATA_NASCIMENTO, SALDO_DEVEDOR FROM PESSOA';
    Query.Open;
    FPessoas.Clear;

    if Query.IsEmpty then
      ShowMessage('Não foram encontrados registros no banco de dados.')
    else
    begin
      while not Query.Eof do
      begin
        Pessoa := TPessoa.Create(Query.FieldByName('Id').AsInteger,
                                  Query.FieldByName('NOME').AsString,
                                  Query.FieldByName('DATA_NASCIMENTO').AsDateTime,
                                  Query.FieldByName('SALDO_DEVEDOR').AsCurrency);
        FPessoas.Add(Pessoa);
        PopularMemTablePessoa(FmtPessoa, Query.FieldByName('Id').AsInteger,
                                  Query.FieldByName('NOME').AsString,
                                  Query.FieldByName('DATA_NASCIMENTO').AsDateTime,
                                  Query.FieldByName('SALDO_DEVEDOR').AsCurrency);
        Query.Next;
      end;

      if not ExcluirId then
        ShowMessage('Os dados adicionados no banco foram carregados na memória com sucesso!');
    end;
  finally
    Query.Free;
  end;
end;

procedure TPrincipalViewModel.CarregarPessoaMemoria;
var
  Pessoas: TObjectList<TPessoa>;
  Pessoa: TPessoa;
begin
  LimparDadosMemTable(FmtPessoaMemoria);
  Pessoas := ObterPessoas;
  MemTableAtual := FmtPessoaMemoria;
  for Pessoa in Pessoas do
  begin
    PopularMemTablePessoa(FmtPessoaMemoria, Pessoa.Id, Pessoa.Nome, Pessoa.DataNascimento, Pessoa.SaldoDevedor);
  end;
end;

procedure TPrincipalViewModel.ExcluirPessoaPorId(IdSelecionado: Integer);
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
      ShowMessage('Pessoa com ID ' + IntToStr(IdSelecionado) + ' foi excluída.');
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

function TPrincipalViewModel.GetMaxId: Integer;
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

function TPrincipalViewModel.GetMemTable: TFDMemTable;
begin
  Result := FMemTableAtual;
end;

function TPrincipalViewModel.GetMemTableImovel: TFDMemTable;
begin
  Result := FmtImovel;
end;

procedure TPrincipalViewModel.GravarPessoaBanco;
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
        if ValidaPessoa(Pessoa.Nome, Pessoa.DataNascimento, Pessoa.SaldoDevedor) then
        begin
          Query.SQL.Text := 'INSERT INTO PESSOA (NOME, DATA_NASCIMENTO, SALDO_DEVEDOR) VALUES (:nome, :data_nascimento, :saldo_devedor)';
          Query.ParamByName('nome').AsString := Pessoa.Nome;
          Query.ParamByName('data_nascimento').AsDate := Pessoa.DataNascimento;
          Query.ParamByName('saldo_devedor').AsCurrency := Pessoa.SaldoDevedor;
          Query.ExecSQL;
        end;
      end;
      FConn.Commit;
      ShowMessage('Os dados da memória foram salvos no banco de dados com sucesso!');
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

function TPrincipalViewModel.JSONParaImovel(JSON: string): TObjectList<TImovel>;
var
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
  Imovel: TImovel;
  Caracteristica: TCaracteristica;
  Avaliacao: TAvaliacao;
  AvaliacaoJSON: TJSONObject;
  CaracteristicasArray: TJSONArray;
  CaracteristicasList: TObjectList<TCaracteristica>;
  I: Integer;
begin
  Result := TObjectList<TImovel>.Create(True);

  JSONArray := TJSONObject.ParseJSONValue(JSON) as TJSONArray;
  if not Assigned(JSONArray) then
    Exit;

  try
    for JSONValue in JSONArray do
    begin
      JSONObject := JSONValue as TJSONObject;

      CaracteristicasList := TObjectList<TCaracteristica>.Create(True);
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

      Avaliacao := nil;
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

procedure TPrincipalViewModel.LimparDadosMemTable(MemTable: TFDMemTable);
begin
  MemTable.EmptyDataSet;
end;

function TPrincipalViewModel.ObterImoveis: TObjectList<TImovel>;
begin
  Result := FImoveis;
end;

function TPrincipalViewModel.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := FPessoas;
end;

procedure TPrincipalViewModel.PopularMemTableImovel(MemTable: TFDMemTable;
  Codigo, Nome: String; Preco: Double; Caracteristicas: TObjectList<TCaracteristica>);
var
  strCaracteristicas: String;
  Caracteristica: TCaracteristica;
begin
  strCaracteristicas := '';

  for Caracteristica in Caracteristicas do
  begin
    if strCaracteristicas.IsEmpty then
      strCaracteristicas := Caracteristica.Nome
    else
      strCaracteristicas := strCaracteristicas + ', ' + Caracteristica.Nome;
  end;

  MemTable.Append;
  MemTable.FieldByName('Código').AsString := Codigo;
  MemTable.FieldByName('Nome').AsString := Nome;
  MemTable.FieldByName('Preço').AsCurrency := Preco;
  MemTable.FieldByName('Características').AsString := strCaracteristicas;
  MemTable.Post;
end;

procedure TPrincipalViewModel.PopularMemTablePessoa(MemTable: TFDMemTable; Id: Integer;
    Nome: String; DataNascimento: TDate; SaldoDevedor: Double);
begin
  MemTable.Append;
  MemTable.FieldByName('Id').AsInteger := Id;
  MemTable.FieldByName('Nome').AsString := Nome;
  MemTable.FieldByName('Data de Nascimento').AsDateTime := DataNascimento;
  MemTable.FieldByName('Saldo Devedor').AsCurrency := SaldoDevedor;
  MemTable.Post;
end;

function TPrincipalViewModel.ValidaPessoa(Nome: String;
  DataNascimento: TDate; SaldoDevedor: Double): Boolean;
var
  I: Integer;
begin
  Result := False;

  if Length(Trim(Nome)) < 3 then
  begin
    ShowMessage('O nome deve ter pelo menos 3 caracteres.');
    Exit(False);
  end;

  for I := 1 to Length(Nome) do
    if CharInSet(Nome[I], ['0'..'9']) then
    begin
      ShowMessage('O nome não pode conter números.');
      Exit(False);
    end;

  if DataNascimento >= Date then
  begin
    ShowMessage('A data de nascimento deve ser anterior à data atual.');
    Exit(False);
  end;

  if SaldoDevedor < 0 then
  begin
    ShowMessage('O saldo devedor não pode ser negativo.');
    Exit(False);
  end;

  Result := True;
end;

end.
