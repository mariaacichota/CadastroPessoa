program CadastroPessoaProject;

uses
  Vcl.Forms,
  Pessoa.View in 'Pessoa.View.pas' {frmPessoa},
  Pessoa.ViewModel in 'Pessoa.ViewModel.pas',
  Imovel.Model in 'Imovel.Model.pas',
  Pessoa.Model in 'Pessoa.Model.pas',
  Caracteristica.Model in 'Caracteristica.Model.pas',
  Avaliacao.Model in 'Avaliacao.Model.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPessoa, frmPessoa);
  Application.Run;
end.
