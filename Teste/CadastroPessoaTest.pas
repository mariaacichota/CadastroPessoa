unit CadastroPessoaTest;

interface
uses
  DUnitX.TestFramework, Principal.ViewModel, Pessoa.Model, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.MSSQL, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.DApt, FireDAC.Stan.Async;

type

  [TestFixture]
  TCadastroPessoaTest = class(TObject)
  private
    FConn: TFDConnection;
    FViewModel: TPrincipalViewModel;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    [TestOrder(1)]
    procedure TestCarregarPessoaMemoria;

    [Test]
    [TestOrder(2)]
    procedure TestAdicionarPessoa;

    [Test]
    [TestOrder(3)]
    procedure TestGravarPessoaBanco;

    [Test]
    [TestOrder(4)]
    procedure TestCarregarPessoaBanco;

    [Test]
    [TestOrder(5)]
    procedure TestExcluirPessoaPorId;

    [Test]
    [TestOrder(6)]
    procedure TestBuscarImoveisAPI;
  end;

implementation

uses
  System.SysUtils;

procedure TCadastroPessoaTest.Setup;
begin
  FConn := TFDConnection.Create(nil);
  FConn.DriverName := 'MSSQL';
  FConn.Params.Clear;
  FConn.Params.Add('Database=CadastroPessoa');
  FConn.Params.Add('OSAuthent=Yes');
  FConn.Params.Add('Server=DESKTOP-LQTA0BU\SQLEXPRESS');
  FConn.Params.Add('DriverID=MSSQL');
  FConn.Connected := True;

  FViewModel := TPrincipalViewModel.Create(FConn);
end;

procedure TCadastroPessoaTest.TearDown;
begin
  FViewModel.Free;
  FConn.Free;
end;

procedure TCadastroPessoaTest.TestAdicionarPessoa;
var
  Pessoa: TPessoa;
begin
  FViewModel.AdicionarPessoa('Jo�o', Now, 1000);
  Assert.AreEqual(1, FViewModel.ObterPessoas.Count);
end;

procedure TCadastroPessoaTest.TestBuscarImoveisAPI;
begin
  FViewModel.BuscarImoveisAPI;
  Assert.AreEqual(5, FViewModel.ObterImoveis.Count);
end;

procedure TCadastroPessoaTest.TestCarregarPessoaBanco;
begin
  FViewModel.CarregarPessoaBanco;
  Assert.AreEqual(1, FViewModel.ObterPessoas.Count);
end;

procedure TCadastroPessoaTest.TestCarregarPessoaMemoria;
begin
  FViewModel.AdicionarPessoa('Jo�o', Now, 1000);
  FViewModel.AdicionarPessoa('Maria', Now, 2000);
  FViewModel.CarregarPessoaMemoria;
  Assert.AreEqual(2, FViewModel.ObterPessoas.Count);
end;

procedure TCadastroPessoaTest.TestExcluirPessoaPorId;
var
  PessoaId: Integer;
begin
  FViewModel.ExcluirPessoaPorId(1);
  FViewModel.CarregarPessoaBanco;
  Assert.AreEqual(0, FViewModel.ObterPessoas.Count);
end;

procedure TCadastroPessoaTest.TestGravarPessoaBanco;
begin
  FViewModel.AdicionarPessoa('Maria', Now, 2000);
  FViewModel.GravarPessoaBanco;
  FViewModel.CarregarPessoaBanco;
  Assert.AreEqual(1, FViewModel.ObterPessoas.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TCadastroPessoaTest);
end.
