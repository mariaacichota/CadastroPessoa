program CadastroPessoaProject;

{$R *.res}

uses
  FastMM4,
  Vcl.Forms,
  Horse,
  Avaliacao.Model in 'Avaliação\Avaliacao.Model.pas',
  Caracteristica.Model in 'Característica\Caracteristica.Model.pas',
  Imovel.Model in 'Imóvel\Imovel.Model.pas',
  Pessoa.Model in 'Pessoa\Pessoa.Model.pas',
  Principal.Auxiliar.View in 'Principal\Principal.Auxiliar.View.pas' {frmAuxiliarPrincipal},
  Principal.View in 'Principal\Principal.View.pas' {frmPrincipal},
  Principal.ViewModel in 'Principal\Principal.ViewModel.pas',
  ServerHorse in 'Servidor\ServerHorse.pas',
  Conexao.Model in 'Conexão\Conexao.Model.pas',
  Servidor.Controller in 'Servidor\Servidor.Controller.pas';

begin
  ReportMemoryLeaksOnShutdown := True;

  RegistrarEndpoints;
  THorse.Listen(9000);  

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
