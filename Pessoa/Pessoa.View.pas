unit Pessoa.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Datasnap.DBClient,
  Vcl.ComCtrls, FireDAC.Comp.Client, Pessoa.ViewModel, Pessoa.Auxiliar.View,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait;

type
  TfrmPessoa = class(TForm)
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
  private
    FViewModel: TPessoaViewModel;
    FConn     : TFDConnection;
  public
    destructor Destroy; override;
  end;

var
  frmPessoa: TfrmPessoa;

implementation

{$R *.dfm}

{ TfrmPessoa }

procedure TfrmPessoa.FormCreate(Sender: TObject);
begin
  FConn := Conexao;
  FViewModel := TPessoaViewModel.Create(FConn);
end;

destructor TfrmPessoa.Destroy;
begin
  FViewModel.Free;
  FConn.Free;
  inherited;
end;

procedure TfrmPessoa.btnAdicionarClick(Sender: TObject);
begin
  FViewModel.AdicionarPessoa(EdtNome.Text, EdtDataNascimento.Date, StrToFloat(EdtSaldoDevedor.Text));
end;

procedure TfrmPessoa.btnBuscarImoveisClick(Sender: TObject);
begin
  FViewModel.BuscarImoveisAPI;
  dsImovel.DataSet := FViewModel.GetMemTableImovel;
end;

procedure TfrmPessoa.btnCarregarClick(Sender: TObject);
begin
  FViewModel.CarregarPessoaBanco;
end;

procedure TfrmPessoa.btnExcluirClick(Sender: TObject);
var
  frmAuxiliarPessoa: TfrmAuxiliarPessoa;
  IdSelecionado: Integer;
begin
  if FViewModel.GetMemTable.IsEmpty then
  begin
     ShowMessage('Nenhum cadastro foi encontrado. Verifique se est�o em mem�ria!');
     exit;
  end;

  FViewModel.CarregarPessoaBanco;

  frmAuxiliarPessoa := TfrmAuxiliarPessoa.Create(nil, FViewModel);
  try
    IdSelecionado := frmAuxiliarPessoa.SelecionarPessoa;
    if IdSelecionado > 0 then
    begin
      if MessageDlg('Voc� confirma a exclus�o da Pessoa com o Id: ' + IntToStr(IdSelecionado) + '?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        FViewModel.ExcluirPessoaPorId(IdSelecionado);
        ShowMessage('Pessoa com ID ' + IntToStr(IdSelecionado) + ' foi exclu�da.');
      end
      else
        ShowMessage('A exclus�o foi cancelada.');
    end
    else
      ShowMessage('Nenhum Id foi selecionado, a exclus�o foi cancelada.');
  finally
    frmAuxiliarPessoa.Free;
  end;
end;

procedure TfrmPessoa.btnGravarClick(Sender: TObject);
begin
  FViewModel.GravarPessoaBanco;
end;

procedure TfrmPessoa.btnMostrarClick(Sender: TObject);
begin
  FViewModel.CarregarPessoaMemoria;
  frmAuxiliarPessoa := TfrmAuxiliarPessoa.Create(nil, FViewModel);
  frmAuxiliarPessoa.ShowModalAuxiliar;
end;

end.
