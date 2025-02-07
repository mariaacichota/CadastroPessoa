unit Pessoa.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Datasnap.DBClient,
  Vcl.ComCtrls, FireDAC.Comp.Client, Pessoa.ViewModel;

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
    Panel1: TPanel;
    btnMostrar: TButton;
    Panel2: TPanel;
    btnGravar: TButton;
    btnExcluir: TButton;
    btnCarregar: TButton;
    edtNome: TLabeledEdit;
    lblDataNascimento: TLabel;
    edtSaldoDevedor: TLabeledEdit;
    btnAdicionar: TButton;
    DateTimePicker1: TDateTimePicker;
  private
    FViewModel: TPessoaViewModel;
  public
    constructor Create(AOwner: TComponent; AConn: TFDConnection); reintroduce;
    destructor Destroy; override;
  end;

var
  frmPessoa: TfrmPessoa;

implementation

{$R *.dfm}

{ TfrmPessoa }

constructor TfrmPessoa.Create(AOwner: TComponent; AConn: TFDConnection);
begin

end;

destructor TfrmPessoa.Destroy;
begin

  inherited;
end;

end.
