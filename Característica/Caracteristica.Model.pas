unit Caracteristica.Model;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client;

type
  TCaracteristica = class
  private
    FNome : String;
    FIcone : String;
    FId : Integer;
  public
    constructor Create(mId: Integer; mNome, mIcone: String);

    property Id : Integer read FId write FId;
    property Nome : String read FNome write FNome;
    property Icone : String read FIcone write FIcone;
  end;

implementation

{ TCaracteristica }

constructor TCaracteristica.Create(mId: Integer; mNome, mIcone: String);
begin
  FId    := mId;
  FNome  := mNome;
  FIcone := mIcone;
end;

end.

