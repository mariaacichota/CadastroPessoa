unit Imovel.Model;

interface

uses
  SysUtils, Classes, Caracteristica.Model, Avaliacao.Model, FireDAC.Comp.Client,
  System.Generics.Collections;

type
  TImovel = class
  private
    FId : Integer;
    FHospedes : Integer;
    FCodigo : String;
    FDescricao : String;
    FUrl : String;
    FNome : String;
    FImagem : String;
    FPreco : Double;
    FCaracteristicas : TObjectList<TCaracteristica>;
    FAvaliacao : TAvaliacao;
  public
    constructor Create(mId, mHospedes: Integer; mUrl, mNome, mCodigo, mImagem, mDescricao: String;
                       mPreco: Double; mCaracteristica: TObjectList<TCaracteristica>; mAvaliacao: TAvaliacao);
    destructor Destroy;

    property Id : Integer read FId write FId;
    property Hospedes : Integer read FHospedes write FHospedes;
    property Codigo : String read FCodigo write FCodigo;
    property Descricao : String read FDescricao write FDescricao;
    property Url : String read FUrl write FUrl;
    property Nome : String read FNome write FNome;
    property Imagem : String read FImagem write FImagem;
    property Preco : Double read FPreco  write FPreco;
    property Caracteristicas : TObjectList<TCaracteristica> read FCaracteristicas write FCaracteristicas;
    property Avaliacao : TAvaliacao read FAvaliacao write FAvaliacao;
  end;

implementation

{ TImovel }

constructor TImovel.Create(mId, mHospedes: Integer; mUrl, mNome, mCodigo, mImagem, mDescricao: String;
                           mPreco: Double; mCaracteristica: TObjectList<TCaracteristica>; mAvaliacao: TAvaliacao);
begin
  inherited Create;

  FId        := mId;
  FHospedes  := mHospedes;
  FUrl       := mUrl;
  FNome      := mNome;
  FCodigo    := mCodigo;
  FImagem    := mImagem;
  FDescricao := mDescricao;
  FPreco     := mPreco;
  FAvaliacao := mAvaliacao;

  FCaracteristicas := TObjectList<TCaracteristica>.Create;
  if Assigned(mCaracteristica) then
    FCaracteristicas.AddRange(mCaracteristica);
end;

destructor TImovel.Destroy;
begin
  FreeAndNil(FCaracteristicas);
  FreeAndNil(FAvaliacao);

  inherited;
end;

end.

