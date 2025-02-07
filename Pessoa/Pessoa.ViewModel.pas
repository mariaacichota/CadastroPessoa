unit Pessoa.ViewModel;

interface

uses
  Pessoa.Model, Imovel.Model, Caracteristica.Model, Avaliacao.Model,
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt,
  System.Net.HttpClientComponent, System.SysUtils, System.Generics.Collections,
  System.JSON, System.Net.HttpClient, FireDAC.Stan.Param;

type
  TPessoaViewModel = class

  private
    FPessoas: TObjectList<TPessoa>;
    FImoveis: TObjectList<TImovel>;
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    destructor Destroy; override;

    procedure AdicionarPessoa(const Nome: string; DataNascimento: TDate; SaldoDevedor: Double);
    procedure GravarPessoaBanco;
    procedure ExcluirPessoaPorId(Id: Integer);
    procedure CarregarPessoaMemoria;
    procedure BuscarImoveisAPI;

    function JSONParaImovel(JSON: string): TObjectList<TImovel>;
    function ObterImoveis: TObjectList<TImovel>;
    function ObterPessoas: TObjectList<TPessoa>;
  end;

implementation

constructor TPessoaViewModel.Create(AConn: TFDConnection);
begin
  FPessoas := TObjectList<TPessoa>.Create;
  FImoveis := TObjectList<TImovel>.Create;
  FConn := AConn;
end;

destructor TPessoaViewModel.Destroy;
begin
  FPessoas.Free;
  FImoveis.Free;
  inherited;
end;

procedure TPessoaViewModel.AdicionarPessoa(const Nome: string;
  DataNascimento: TDate; SaldoDevedor: Double);
begin
  FPessoas.Add(TPessoa.Create(Nome, DataNascimento, SaldoDevedor));
end;

procedure TPessoaViewModel.BuscarImoveisAPI;
var
  HTTP: TNetHTTPClient;
  Response: string;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get('https://developers.silbeck.com.br/mocks/apiteste/v2/aptos').ContentAsString;
    FImoveis := JSONParaImovel(Response);
  finally
    HTTP.Free;
  end;
end;

procedure TPessoaViewModel.CarregarPessoaMemoria;
var
  Query: TFDQuery;
  Pessoa: TPessoa;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT nome, data_nascimento, saldo_devedor FROM pessoas';
    Query.Open;
    FPessoas.Clear;
    while not Query.Eof do
    begin
      Pessoa := TPessoa.Create(Query.FieldByName('nome').AsString, Query.FieldByName('data_nascimento').AsDateTime, Query.FieldByName('saldo_devedor').AsCurrency);
      FPessoas.Add(Pessoa);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPessoaViewModel.ExcluirPessoaPorId(Id: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'DELETE FROM pessoas WHERE Id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TPessoaViewModel.GravarPessoaBanco;
var
  Pessoa: TPessoa;
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    for Pessoa in FPessoas do
    begin
      Query.SQL.Text := 'INSERT INTO pessoas (nome, data_nascimento, saldo_devedor) VALUES (:nome, :data_nascimento, :saldo_devedor)';
      Query.ParamByName('nome').AsString := Pessoa.Nome;
      Query.ParamByName('data_nascimento').AsDate := Pessoa.DataNascimento;
      Query.ParamByName('saldo_devedor').AsCurrency := Pessoa.SaldoDevedor;
      Query.ExecSQL;
    end;
  finally
    Query.Free;
  end;
end;

function TPessoaViewModel.JSONParaImovel(JSON: string): TObjectList<TImovel>;
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
  Result := TObjectList<TImovel>.Create;
  JSONArray := TJSONObject.ParseJSONValue(JSON) as TJSONArray;
  try
    for JSONValue in JSONArray do
    begin
      JSONObject := JSONValue as TJSONObject;

      CaracteristicasList := TObjectList<TCaracteristica>.Create;
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

      AvaliacaoJSON := JSONObject.GetValue<TJSONObject>('avaliacao');
      if Assigned(AvaliacaoJSON) then
      begin
        Avaliacao := TAvaliacao.Create(
          AvaliacaoJSON.GetValue<Double>('nota'),
          AvaliacaoJSON.GetValue<Integer>('quantidade')
        );
      end;

      Imovel := TImovel.Create(
        JSONObject.GetValue<Integer>('id'),
        JSONObject.GetValue<Integer>('hospedes'),
        JSONObject.GetValue<string>('url'),
        JSONObject.GetValue<string>('nome'),
        JSONObject.GetValue<string>('codigo'),
        JSONObject.GetValue<string>('img'),
        JSONObject.GetValue<string>('descricao'),
        JSONObject.GetValue<Double>('preco'),
        CaracteristicasList,
        Avaliacao
      );

      Result.Add(Imovel);
    end;
  finally
    JSONArray.Free;
  end;
end;

function TPessoaViewModel.ObterImoveis: TObjectList<TImovel>;
begin
  Result := FImoveis;
end;

function TPessoaViewModel.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := FPessoas;
end;

end.
