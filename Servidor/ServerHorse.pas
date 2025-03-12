unit ServerHorse;

interface

uses
  Horse, System.SysUtils, System.JSON, FireDAC.Comp.Client, System.Generics.Collections,
  Principal.ViewModel, Pessoa.Model, Conexao.Model, Servidor.Controller;

procedure RegistrarEndpoints;
procedure DestroyControllerServer;

implementation

var
  Controller: TServidorController;

procedure ListarPessoasMemoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  var mPessoas := Controller.ObterPessoas;
  var mJSONArray := TJSONArray.Create;
  try
    for var Pessoa in mPessoas do
      begin
        var mJSONObj := TJSONObject.Create;
        mJSONObj.AddPair('Id', TJSONNumber.Create(Pessoa.Id));
        mJSONObj.AddPair('Nome', Pessoa.Nome);
        mJSONObj.AddPair('DataNascimento', DateToStr(Pessoa.DataNascimento));
        mJSONObj.AddPair('SaldoDevedor', TJSONNumber.Create(Pessoa.SaldoDevedor));
        mJSONArray.AddElement(mJSONObj);
      end;

    Res.Status(200).Send(mJSONArray.ToJSON);
  finally
    mJSONArray.Free;
  end;
end;

procedure ListarPessoas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  var mJSONArray := TJSONArray.Create;
  try
    var mQuery := Controller.CarregarPessoaBanco;
    try
      while not mQuery.Eof do
        begin
          var mJSONObj := TJSONObject.Create;
          mJSONObj.AddPair('Id', TJSONNumber.Create(mQuery.FieldByName('id').AsInteger));
          mJSONObj.AddPair('Nome', mQuery.FieldByName('nome').AsString);
          mJSONObj.AddPair('DataNascimento', mQuery.FieldByName('data_nascimento').AsString);
          mJSONObj.AddPair('SaldoDevedor', TJSONNumber.Create(mQuery.FieldByName('saldo_devedor').AsFloat));

          mJSONArray.AddElement(mJSONObj);
          mQuery.Next;
        end;

      Res.Status(200).Send(mJSONArray.ToJSON);
    finally
      mQuery.Free;
    end;
  except
    on E: Exception do
      Res.Status(500).Send('Erro ao buscar pessoas no banco: ' + E.Message);
  end;
end;

procedure AdicionarPessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  if Req.Body.IsEmpty then
  begin
    Res.Status(400).Send('Corpo da requisição vazio.');
    Exit;
  end;

  var mJSONStr := Req.Body;
  var mJSONObj := nil;

  try
    mJSONObj := TJSONObject.ParseJSONValue(mJSONStr) as TJSONObject;
    if mJSONObj = nil then
      raise Exception.Create('JSON inválido ou mal formado.');

    var mNome, mStrDataNascimento : String;

    if not mJSONObj.TryGetValue<string>('Nome', mNome) then
      raise Exception.Create('Nome não encontrado ou inválido.');


    if not mJSONObj.TryGetValue<string>('DataNascimento', mStrDataNascimento) then
      raise Exception.Create('Data de nascimento inválida.');

    var mSaldoDevedor : Double;
    if not mJSONObj.TryGetValue<Double>('SaldoDevedor', mSaldoDevedor) then
      raise Exception.Create('SaldoDevedor não encontrado ou inválido.');

    Controller.AdicionarPessoaBanco(mNome, StrToDate(mStrDataNascimento), mSaldoDevedor);
    Res.Status(201).Send('Pessoa adicionada com sucesso!');
  except
    on E: Exception do
      Res.Status(400).Send('Erro ao adicionar pessoa: ' + E.Message);
  end;

  mJSONObj.Free;
end;

procedure AdicionarPessoaMemoriaBanco(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    Controller.AdicionarPessoaMemoriaBanco;
    Res.Status(201).Send('Pessoa adicionada com sucesso!');
  except
    on E: Exception do
      Res.Status(400).Send('Erro inesperado: ' + E.Message);
  end;
end;

procedure AdicionarPessoaMemoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  if Req.Body.IsEmpty then
    begin
      Res.Status(400).Send('Corpo da requisição vazio.');
      Exit;
    end;

  var mJSONStr := Req.Body;
  var mJSONObj := nil;

  try
    mJSONObj := TJSONObject.ParseJSONValue(mJSONStr) as TJSONObject;
    if mJSONObj = nil then
      raise Exception.Create('JSON inválido ou mal formado.');

    var mNome, mStrDataNascimento : String;

    if not mJSONObj.TryGetValue<string>('Nome', var mNome) then
      raise Exception.Create('Nome não encontrado ou inválido.');

    if not mJSONObj.TryGetValue<string>('DataNascimento', var mStrDataNascimento) then
      raise Exception.Create('Data de nascimento inválida.');

    var mSaldoDevedor : Double;
    if not mJSONObj.TryGetValue<Double>('SaldoDevedor', var mSaldoDevedor) then
      raise Exception.Create('SaldoDevedor não encontrado ou inválido.');

    Controller.AdicionarPessoaMemoria(mNome, StrToDate(mStrDataNascimento), mSaldoDevedor);
    Res.Status(201).Send('Pessoa adicionada à memória com sucesso!');
  except
    on E: Exception do
      Res.Status(400).Send('Erro ao adicionar pessoa: ' + E.Message);
  end;

  mJSONObj.Free;
end;

procedure ExcluirPessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  var mPessoaID := Req.Params.Items['id'].ToInteger;
  try
    Controller.ExcluirPessoaPorId(mPessoaID);
    Res.Status(200).Send('Pessoa removida com sucesso!');
  except
    on E: Exception do
      Res.Status(400).Send('Erro inesperado: ' + E.Message);
  end;
end;

procedure ListarPessoasId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Query: TFDQuery;
  JSONObj: TJSONObject;
begin
  var mPessoaID := Req.Params.Items['id'].ToInteger;
  var mJSONArray := TJSONArray.Create;
  try
    var mQuery := Controller.CarregarPessoaBancoPorId(mPessoaID);
    try
      while not Query.Eof do
        begin
          var mJSONObj := TJSONObject.Create;
          mJSONObj.AddPair('Id', TJSONNumber.Create(mQuery.FieldByName('id').AsInteger));
          mJSONObj.AddPair('Nome', mQuery.FieldByName('nome').AsString);
          mJSONObj.AddPair('DataNascimento', mQuery.FieldByName('data_nascimento').AsString);
          mJSONObj.AddPair('SaldoDevedor', TJSONNumber.Create(mQuery.FieldByName('saldo_devedor').AsFloat));

          mJSONArray.AddElement(mJSONObj);
          mQuery.Next;
        end;

      Res.Status(200).Send(mJSONArray.ToJSON);
    finally
      Query.Free;
    end;
  except
    on E: Exception do
      Res.Status(500).Send('Erro ao buscar pessoas no banco de dados: ' + E.Message);
  end;
end;

procedure RegistrarEndpoints;
begin
  Controller := TServidorController.Create(Conexao.Model.Connect);

  THorse.Get('/pessoas', ListarPessoas);
  THorse.Get('/pessoas/:id', ListarPessoasId);
  THorse.Get('/pessoas/memoria', ListarPessoasMemoria);
  THorse.Post('/pessoas', AdicionarPessoa);
  THorse.Post('pessoas/memoria', AdicionarPessoaMemoria);
  THorse.Post('/pessoas/memoria/banco', AdicionarPessoaMemoriaBanco);
  THorse.Delete('/pessoas/:id', ExcluirPessoa);
end;

procedure DestroyControllerServer;
begin
  Controller.Destroy;
end;

end.

