unit Pessoa.Auxiliar.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, Pessoa.ViewModel;

type
  TfrmAuxiliarPessoa = class(TForm)
    gridAuxiliarPessoa: TDBGrid;
    dsPessoa: TDataSource;
    procedure gridAuxiliarPessoaDblClick(Sender: TObject);
  private
    FPessoaViewModel: TPessoaViewModel;
    FSelecionado: Integer;
  public
    constructor Create(AOwner: TComponent; APessoaViewModel: TPessoaViewModel); reintroduce;
    function SelecionarPessoa: Integer;
    procedure ShowModalAuxiliar;
  end;

var
  frmAuxiliarPessoa: TfrmAuxiliarPessoa;

implementation

{$R *.dfm}

{ TfrmAuxiliarPessoa }

constructor TfrmAuxiliarPessoa.Create(AOwner: TComponent;
  APessoaViewModel: TPessoaViewModel);
begin
  inherited Create(AOwner);
  FPessoaViewModel := APessoaViewModel;
  dsPessoa.DataSet := FPessoaViewModel.GetMemTable;
end;

procedure TfrmAuxiliarPessoa.gridAuxiliarPessoaDblClick(Sender: TObject);
begin
  if not dsPessoa.DataSet.IsEmpty then
  begin
    FSelecionado := dsPessoa.DataSet.FieldByName('Id').AsInteger;
    ModalResult := mrOk;
  end;
end;

function TfrmAuxiliarPessoa.SelecionarPessoa: Integer;
begin
  ShowModalAuxiliar;
  Result := FSelecionado;
end;

procedure TfrmAuxiliarPessoa.ShowModalAuxiliar;
begin
  ShowModal;
end;

end.
