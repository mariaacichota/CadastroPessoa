unit Imovel.Model;

interface

uses
  SysUtils, Classes, Caracteristica.Model, Avaliacao.Model, FireDAC.Comp.Client,
  System.Generics.Collections;

type
  TImovel = class
  private
    FId              : Integer;
    FHospedes        : Integer;
    FCodigo          : String;
    FDescricao       : String;
    FUrl             : String;
    FNome            : String;
    FImagem          : String;
    FPreco           : Double;
    FCaracteristicas : TObjectList<TCaracteristica>;
    FAvaliacao       : TAvaliacao;

  public
    constructor Create(Id, Hospedes: Integer; Url, Nome, Codigo, Imagem, Descricao: String;
                          Preco: Double; Caracteristica: TObjectList<TCaracteristica>; Avaliacao: TAvaliacao);
    destructor Destroy;

    property Id              : Integer                      read FId              write FId;
    property Hospedes        : Integer                      read FHospedes        write FHospedes;
    property Codigo          : String                       read FCodigo          write FCodigo;
    property Descricao       : String                       read FDescricao       write FDescricao;
    property Url             : String                       read FUrl             write FUrl;
    property Nome            : String                       read FNome            write FNome;
    property Imagem          : String                       read FImagem          write FImagem;
    property Preco           : Double                       read FPreco           write FPreco;
    property Caracteristicas : TObjectList<TCaracteristica> read FCaracteristicas write FCaracteristicas;
    property Avaliacao       : TAvaliacao                   read FAvaliacao       write FAvaliacao;
  end;

implementation


{ TImovel }

constructor TImovel.Create(Id, Hospedes: Integer; Url, Nome,
  Codigo, Imagem, Descricao: String; Preco: Double;
  Caracteristica: TObjectList<TCaracteristica>; Avaliacao: TAvaliacao);
begin
  inherited Create;
  FId        := Id;
  FHospedes  := Hospedes;
  FUrl       := Url;
  FNome      := Nome;
  FCodigo    := Codigo;
  FImagem    := Imagem;
  FDescricao := Descricao;
  FPreco     := Preco;
  FAvaliacao := Avaliacao;

  if Assigned(Caracteristicas) then
    FCaracteristicas := Caracteristicas
  else
    FCaracteristicas := TObjectList<TCaracteristica>.Create;
end;

destructor TImovel.Destroy;
begin
  FCaracteristicas.Free;
  FAvaliacao.Free;
  inherited;
end;

end.

