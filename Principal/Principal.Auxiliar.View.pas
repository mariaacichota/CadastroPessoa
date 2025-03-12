unit Principal.Auxiliar.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, Principal.ViewModel,
  Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmAuxiliarPrincipal = class(TForm)
    gridAuxiliarPessoa: TDBGrid;
    dsPessoa: TDataSource;
    pnlTipExcluir: TPanel;
    lblTipExcluir: TLabel;
    procedure gridAuxiliarPessoaDblClick(Sender: TObject);
  private
    fPessoaViewModel: TPrincipalViewModel;
    fSelecionado: Integer;
  public
    constructor Create(AOwner: TComponent; APessoaViewModel: TPrincipalViewModel); reintroduce;
    function SelecionarPessoa: Integer;
    procedure ShowModalAuxiliar;
  end;

var
  frmAuxiliarPrincipal: TfrmAuxiliarPrincipal;

implementation

{$R *.dfm}

{ TfrmAuxiliarPessoa }

constructor TfrmAuxiliarPrincipal.Create(AOwner: TComponent;
  APessoaViewModel: TPrincipalViewModel);
begin
  inherited Create(AOwner);

  fPessoaViewModel := APessoaViewModel;
  dsPessoa.DataSet := FPessoaViewModel.GetMemTable;
end;

procedure TfrmAuxiliarPrincipal.gridAuxiliarPessoaDblClick(Sender: TObject);
begin
  if not dsPessoa.DataSet.IsEmpty then
    begin
      fSelecionado := dsPessoa.DataSet.FieldByName('Id').AsInteger;
      ModalResult  := mrOk;
    end;
end;

function TfrmAuxiliarPrincipal.SelecionarPessoa: Integer;
begin
  ShowModalAuxiliar;
  Result := fSelecionado;
end;

procedure TfrmAuxiliarPrincipal.ShowModalAuxiliar;
begin
  ShowModal;
end;

end.
