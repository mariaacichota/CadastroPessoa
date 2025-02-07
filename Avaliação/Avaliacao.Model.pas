unit Avaliacao.Model;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client;

type
  TAvaliacao = class
  private
    FNota       : Double;
    FQuantidade : Integer;

  public
    constructor Create(Nota: Double; Quantidade: Integer);

    property Nota       : Double  read FNota       write FNota;
    property Quantidade : Integer read FQuantidade write FQuantidade;
  end;

implementation


{ TAvaliacao }

constructor TAvaliacao.Create(Nota: Double; Quantidade: Integer);
begin
  FNota       := Nota;
  FQuantidade := Quantidade;
end;

end.

