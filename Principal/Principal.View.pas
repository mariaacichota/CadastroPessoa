unit Principal.View;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Datasnap.DBClient,
  Vcl.ComCtrls, FireDAC.Comp.Client, Principal.ViewModel, Principal.Auxiliar.View,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait,
  Vcl.Mask, Conexao.Model;
type
  TfrmPrincipal = class(TForm)
    pgcGeral: TPageControl;
    tabBuscaImovel: TTabSheet;
    pnlTopImoveis: TPanel;
    btnBuscarImoveis: TButton;
    pnlGridImoveis: TPanel;
    gridImoveis: TDBGrid;
    tabCadastroPessoa: TTabSheet;
    gbCadastro: TGroupBox;
    gbBancoDeDados: TGroupBox;
    pnlFooterPessoa: TPanel;
    btnMostrar: TButton;
    btnGravar: TButton;
    btnExcluir: TButton;
    btnCarregar: TButton;
    edtNome: TLabeledEdit;
    lblDataNascimento: TLabel;
    edtSaldoDevedor: TLabeledEdit;
    btnAdicionar: TButton;
    edtDataNascimento: TDateTimePicker;
    dsImovel: TDataSource;
    lblStatus: TLabel;
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure btnMostrarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnBuscarImoveisClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fViewModel: TPrincipalViewModel;
    fSaldoDevedor: Double;
    procedure LimparCampos;
    property SaldoDevedor: Double read FSaldoDevedor write FSaldoDevedor;
  public
    destructor Destroy; override;
  end;
implementation
{$R *.dfm}
{ TfrmPessoa }


procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  fViewModel        := TPrincipalViewModel.Create(Conexao.Model.Connect);
  PgcGeral.TabIndex := 0;
  LimparCampos;
end;


procedure TfrmPrincipal.LimparCampos;
begin
  edtNome.Text           := EmptyStr;
  edtSaldoDevedor.Text   := EmptyStr;
  edtDataNascimento.Date := Now;
end;

destructor TfrmPrincipal.Destroy;
begin
  fViewModel.Free;
  inherited;
end;


procedure TfrmPrincipal.btnAdicionarClick(Sender: TObject);
begin
  fViewModel.AdicionarPessoa(edtNome.Text, edtDataNascimento.Date, fSaldoDevedor);
  LimparCampos;
end;

procedure TfrmPrincipal.btnBuscarImoveisClick(Sender: TObject);
begin
  fViewModel.BuscarImoveisAPI;
  dsImovel.DataSet := fViewModel.GetMemTableImovel;
end;

procedure TfrmPrincipal.btnCarregarClick(Sender: TObject);
begin
  lblStatus.Left    := 401;
  lblStatus.Visible := True;
  lblStatus.Caption := 'Salvando os dados na memória...';

  fViewModel.CarregarPessoaBanco(False);

  lblStatus.Visible := False;
end;

procedure TfrmPrincipal.btnExcluirClick(Sender: TObject);
begin
  if fViewModel.GetMemTable.IsEmpty then
  begin
     ShowMessage('Nenhum cadastro foi encontrado. Verifique se estão em memória!');
     exit;
  end;

  fViewModel.CarregarPessoaBanco(True);

  var mFrmAuxiliarPrincipal := TfrmAuxiliarPrincipal.Create(nil, fViewModel);
  mFrmAuxiliarPrincipal.pnlTipExcluir.Visible := True;
  mFrmAuxiliarPrincipal.lblTipExcluir.Visible := True;
  try
    var mIdSelecionado := mFrmAuxiliarPrincipal.SelecionarPessoa;
    if mIdSelecionado > 0 then
      begin
        if MessageDlg('Você confirma a exclusão da Pessoa com o Id: ' + IntToStr(mIdSelecionado) + '?',
                      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            FViewModel.ExcluirPessoaPorId(mIdSelecionado);
          end
        else
          ShowMessage('A exclusão foi cancelada.');
      end
    else
      ShowMessage('Nenhum Id foi selecionado, a exclusão foi cancelada.');
  finally
    mFrmAuxiliarPrincipal.Free;
  end;

  LimparCampos;
end;

procedure TfrmPrincipal.btnGravarClick(Sender: TObject);
begin
  lblStatus.Left    := 8;
  lblStatus.Visible := True;
  lblStatus.Caption := 'Salvando os dados da memória no banco de dados...';
  fViewModel.GravarPessoaBanco;
  lblStatus.Visible := False;
end;

procedure TfrmPrincipal.btnMostrarClick(Sender: TObject);
begin
  fViewModel.CarregarPessoaMemoria;

  var mFrmAuxiliarPrincipal := TfrmAuxiliarPrincipal.Create(nil, fViewModel);
  mFrmAuxiliarPrincipal.ShowModalAuxiliar;
end;

end.
