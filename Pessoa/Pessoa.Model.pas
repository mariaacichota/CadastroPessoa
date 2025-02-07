unit Pessoa.Model;

interface

uses
  System.SysUtils;

type
  TPessoa = class
  private
    FNome           : String;
    FDataNascimento : TDate;
    FSaldoDevedor   : Double;
  public
    constructor Create(const Nome: string; DataNascimento: TDate; SaldoDevedor: Double);
    function ToString: string; override;

    property Nome           : String read FNome           write FNome;
    property DataNascimento : TDate  read FDataNascimento write FDataNascimento;
    property SaldoDevedor   : Double read FSaldoDevedor   write FSaldoDevedor;
  end;

implementation

constructor TPessoa.Create(const Nome: string; DataNascimento: TDate;
  SaldoDevedor: Double);
begin
  FNome           := Nome;
  FDataNascimento := DataNascimento;
  FSaldoDevedor   := SaldoDevedor;
end;

function TPessoa.ToString: string;
begin
  Result := Format('Nome: %s, Data de Nascimento: %s, Saldo Devedor: %.2f', [FNome
                                      , DateToStr(FDataNascimento), FSaldoDevedor]);
end;

end.

