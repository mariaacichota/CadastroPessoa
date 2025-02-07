program CadastroPessoaProject;

uses
  Vcl.Forms,
  Avaliacao.Model      in 'Avalia��o\Avaliacao.Model.pas',
  Caracteristica.Model in 'Caracter�stica\Caracteristica.Model.pas',
  Imovel.Model         in 'Im�vel\Imovel.Model.pas',
  Pessoa.Model         in 'Pessoa\Pessoa.Model.pas',
  Pessoa.View          in 'Pessoa\Pessoa.View.pas' {frmPessoa},
  Pessoa.ViewModel     in 'Pessoa\Pessoa.ViewModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPessoa, frmPessoa);
  Application.Run;
end.
