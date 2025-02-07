unit Caracteristica.Model;

interface

uses
  SysUtils, Classes, Database.Model, FireDAC.Comp.Client;

type
  TCaracteristica = class
  private
    FNome : String;
    FIcone: String;
  public
//    function ObterProduto(CodigoProduto: Integer): IProduto;
    constructor Create(Nome, Icone: String);

    property Nome : String read FNome  write FNome;
    property Icone: String read FIcone write FIcone;

  end;

implementation


{ TCaracteristica }

constructor TCaracteristica.Create(Nome, Icone: String);
begin
  FNome  := Nome;
  FIcone := Icone;
end;

end.

