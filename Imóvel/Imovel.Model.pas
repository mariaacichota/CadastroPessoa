unit Imovel.Model;

interface

uses
  SysUtils, Classes, Caracteristica.Model, Avaliacao.Model, FireDAC.Comp.Client,
  System.Generics.Collections;

type
  TImovel = class
  private
    FCodigo          : Integer;
    FDescricao       : String;
    FUrl             : String;
    FNome            : String;
    FPreco           : Double;
    FHospedes        : Integer;
    FCaracteristicas : TObjectList<TCaracteristica>;
    FAvaliacao       : TAvaliacao;

  public
    constructor Create(Codigo, Hospedes: Integer; Url, Nome, Descricao: String;
                        Preco: Double; Caracteristica: TCaracteristica; Avaliacao: TAvaliacao);
    destructor Destroy;

    property Codigo          : Integer                      read FCodigo          write FCodigo;
    property Descricao       : String                       read FDescricao       write FDescricao;
    property Url             : String                       read FUrl             write FUrl;
    property Nome            : String                       read FNome            write FNome;
    property Preco           : Double                       read FPreco           write FPreco;
    property Hospedes        : Integer                      read FHospedes        write FHospedes;
    property Caracteristicas : TObjectList<TCaracteristica> read FCaracteristicas write FCaracteristicas;
    property Avaliacao       : TAvaliacao                   read FAvaliacao       write FAvaliacao;
  end;

implementation


{ TImovel }

constructor TImovel.Create(Codigo, Hospedes: Integer; Url, Nome, Descricao: String;
  Preco: Double; Caracteristica: TObjectList<TCaracteristica>; Avaliacao: TAvaliacao);
begin
  FCodigo          := Codigo;
  FHospedes        := Hospedes;
  FUrl             := Url;
  FNome            := Nome;
  FDescricao       := Descricao;
  FPreco           := Preco;
  FCaracteristicas := TObjectList<TCaracteristica>.Create;
  FAvaliacao       := Avaliacao;
end;

destructor TImovel.Destroy;
begin
  FCaracteristicas.Free;
  FAvaliacao.Free;
  inherited;
end;

end.

