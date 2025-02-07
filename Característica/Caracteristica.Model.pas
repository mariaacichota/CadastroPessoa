unit Caracteristica.Model;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client;

type
  TCaracteristica = class
  private
    FNome : String;
    FIcone: String;
  public
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

