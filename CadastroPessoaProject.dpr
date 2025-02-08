program CadastroPessoaProject;

uses
  Vcl.Forms,
  Avaliacao.Model in 'Avaliação\Avaliacao.Model.pas',
  Caracteristica.Model in 'Característica\Caracteristica.Model.pas',
  Imovel.Model in 'Imóvel\Imovel.Model.pas',
  Pessoa.Model in 'Pessoa\Pessoa.Model.pas',
  Principal.Auxiliar.View in 'Principal\Principal.Auxiliar.View.pas' {frmAuxiliarPrincipal},
  Principal.View in 'Principal\Principal.View.pas' {frmPrincipal},
  Principal.ViewModel in 'Principal\Principal.ViewModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
