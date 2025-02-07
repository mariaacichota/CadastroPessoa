program CadastroPessoaProject;

uses
  Vcl.Forms,
  Avaliacao.Model      in 'Avaliação\Avaliacao.Model.pas',
  Caracteristica.Model in 'Característica\Caracteristica.Model.pas',
  Imovel.Model         in 'Imóvel\Imovel.Model.pas',
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
