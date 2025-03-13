unit Avaliacao.Model;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client;

type
  TAvaliacao = class
  private
    FNota : Double;
    FQuantidade : Integer;
  public
    constructor Create(mNota: Double; mQuantidade: Integer);

    property Nota : Double read FNota write FNota;
    property Quantidade : Integer read FQuantidade write FQuantidade;
  end;

implementation

{ TAvaliacao }

constructor TAvaliacao.Create(mNota: Double; mQuantidade: Integer);
begin
  FNota       := mNota;
  FQuantidade := mQuantidade;
end;

end.

