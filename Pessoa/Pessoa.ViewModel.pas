interface

uses
  System.Generics.Collections, Pessoa.Model, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt;

type
  TPessoaViewModel = class
uses
  FireDAC.Comp.Client;PssoaViewModel = class
  private
    FPessoas: TObjectList<TPessoa>;
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    destructor Destroy; override;
    procedure AdicionarPessoa(const Nome: string; DataNascimento: TDate; SaldoDevedor: Currency);
    procedure SalvarNoBanco;
    procedure CarregarDoBanco;
    function ObterPessoas: TObjectList<TPessoa>;
  end;

implementation

constructor TPessoaViewModel.Create(AConn: TFDConnection);
begin
  FPessoas := TObjectList<TPessoa>.Create;
  FConn := AConn;
end;

destructor TPessoaViewModel.Destroy;
begin
  FPessoas.Free;
  inherited;
end;

procedure TPessoaViewModel.AdicionarPessoa(const Nome: string; DataNascimento: TDate; SaldoDevedor: Currency);
begin
  FPessoas.Add(TPessoa.Create(Nome, DataNascimento, SaldoDevedor));
end;

procedure TPessoaViewModel.SalvarNoBanco;
var
  Query: TFDQuery;
  Pessoa: TPessoa;
begin
  for Pessoa in FPessoas do
  begin
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConn;
      Query.SQL.Text := 'INSERT INTO Pessoas (Nome, DataNascimento, SaldoDevedor) VALUES (:Nome, :DataNascimento, :SaldoDevedor)';
      Query.ParamByName('Nome').AsString := Pessoa.Nome;
      Query.ParamByName('DataNascimento').AsDate := Pessoa.DataNascimento;
      Query.ParamByName('SaldoDevedor').AsCurrency := Pessoa.SaldoDevedor;
      Query.ExecSQL;
    finally
      Query.Free;
    end;
  end;
end;

procedure TPessoaViewModel.CarregarDoBanco;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT Nome, DataNascimento, SaldoDevedor FROM Pessoas';
    Query.Open;
    FPessoas.Clear;
    while not Query.Eof do
    begin
      FPessoas.Add(TPessoa.Create(Query.FieldByName('Nome').AsString, Query.FieldByName('DataNascimento').AsDateTime, Query.FieldByName('SaldoDevedor').AsCurrency));
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TPessoaViewModel.ObterPessoas: TObjectList<TPessoa>;
begin
  Result := FPessoas;
end;

end.
