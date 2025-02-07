unit Caracteristica.Model;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client;

type
  TCaracteristica = class
  private
    FNome : String;
    FIcone: String;
    FId: Integer;
  public
    constructor Create(Id: Integer; Nome, Icone: String);

    property Id   : Integer read FId    write FId;
    property Nome : String  read FNome  write FNome;
    property Icone: String  read FIcone write FIcone;

  end;

implementation


{ TCaracteristica }

constructor TCaracteristica.Create(Id: Integer; Nome, Icone: String);
begin
  FId    := Id;
  FNome  := Nome;
  FIcone := Icone;
end;

end.

