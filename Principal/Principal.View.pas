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
  Vcl.Mask;

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
    Conexao: TFDConnection;
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure btnMostrarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnBuscarImoveisClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtSaldoDevedorExit(Sender: TObject);
  private
    FViewModel: TPrincipalViewModel;
    FConn     : TFDConnection;
    FSaldoDevedor: Double;
    property SaldoDevedor: Double read FSaldoDevedor write FSaldoDevedor;
  public
    destructor Destroy; override;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

{ TfrmPessoa }

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FConn := Conexao;
  FViewModel := TPrincipalViewModel.Create(FConn);
end;

destructor TfrmPrincipal.Destroy;
begin
  FViewModel.Free;
  FConn.Free;
  inherited;
end;

procedure TfrmPrincipal.edtSaldoDevedorExit(Sender: TObject);
var
  TextOnEdit: UnicodeString;
  Value: Currency;
begin
  TextOnEdit := EdtSaldoDevedor.Text;

  if EdtSaldoDevedor.Text = EmptyStr then
    TextOnEdit := '0';

  if TryStrToCurr(TextOnEdit, Value) then
  begin
    if  StrToFloat(EdtSaldoDevedor.Text) < 0 then
      ShowMessage('Informe um valor válido no campo de Saldo Devedor.')
    else
      FSaldoDevedor := StrToFloat(TextOnEdit);
  end
  else
    ShowMessage('Informe um valor válido no campo de Saldo Devedor.');
end;

procedure TfrmPrincipal.btnAdicionarClick(Sender: TObject);
begin
  FViewModel.AdicionarPessoa(EdtNome.Text, EdtDataNascimento.Date, FSaldoDevedor);
end;

procedure TfrmPrincipal.btnBuscarImoveisClick(Sender: TObject);
begin
  FViewModel.BuscarImoveisAPI;
  dsImovel.DataSet := FViewModel.GetMemTableImovel;
end;

procedure TfrmPrincipal.btnCarregarClick(Sender: TObject);
begin
  FViewModel.CarregarPessoaBanco;
end;

procedure TfrmPrincipal.btnExcluirClick(Sender: TObject);
var
  frmAuxiliarPrincipal: TfrmAuxiliarPrincipal;
  IdSelecionado: Integer;
begin
  if FViewModel.GetMemTable.IsEmpty then
  begin
     ShowMessage('Nenhum cadastro foi encontrado. Verifique se estão em memória!');
     exit;
  end;

  FViewModel.CarregarPessoaBanco;

  frmAuxiliarPrincipal := TfrmAuxiliarPrincipal.Create(nil, FViewModel);
  frmAuxiliarPrincipal.pnlTipExcluir.Visible := True;
  frmAuxiliarPrincipal.lblTipExcluir.Visible := True;
  try
    IdSelecionado := frmAuxiliarPrincipal.SelecionarPessoa;
    if IdSelecionado > 0 then
    begin
      if MessageDlg('Você confirma a exclusão da Pessoa com o Id: ' + IntToStr(IdSelecionado) + '?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        FViewModel.ExcluirPessoaPorId(IdSelecionado);
        ShowMessage('Pessoa com ID ' + IntToStr(IdSelecionado) + ' foi excluída.');
      end
      else
        ShowMessage('A exclusão foi cancelada.');
    end
    else
      ShowMessage('Nenhum Id foi selecionado, a exclusão foi cancelada.');
  finally
    frmAuxiliarPrincipal.Free;
  end;
end;

procedure TfrmPrincipal.btnGravarClick(Sender: TObject);
begin
  FViewModel.GravarPessoaBanco;
end;

procedure TfrmPrincipal.btnMostrarClick(Sender: TObject);
begin
  FViewModel.CarregarPessoaMemoria;
  frmAuxiliarPrincipal := TfrmAuxiliarPrincipal.Create(nil, FViewModel);
  frmAuxiliarPrincipal.ShowModalAuxiliar;
end;

end.
