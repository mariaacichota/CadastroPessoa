unit ServerHorse;

interface

uses
  Horse, System.SysUtils, System.JSON, FireDAC.Comp.Client, System.Generics.Collections,
  Principal.ViewModel, Pessoa.Model, Conexao.Model, Servidor.Controller;

procedure RegistrarEndpoints;
procedure DestroyControllerServer;

implementation

var
  gController: TServidorController;

procedure ListarPessoasMemoria(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  var mPessoas := gController.ObterPessoas;
  var mJSONArray := TJSONArray.Create;
  try
    for var mPessoa in mPessoas do
      begin
        var mJSONObj := TJSONObject.Create;
        try
          mJSONObj.AddPair('Id', TJSONNumber.Create(mPessoa.Id));
          mJSONObj.AddPair('Nome', mPessoa.Nome);
          mJSONObj.AddPair('DataNascimento', DateToStr(mPessoa.DataNascimento));
          mJSONObj.AddPair('SaldoDevedor', TJSONNumber.Create(mPessoa.SaldoDevedor));
          mJSONArray.AddElement(mJSONObj);
        finally
          FreeAndNil(mJSONObj);
        end;
      end;

    mRes.Status(200).Send(mJSONArray.ToJSON);
  finally
    FreeAndNil(mPessoas);
    FreeAndNil(mJSONArray);
  end;
end;

procedure ListarPessoas(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  var mJSONArray := TJSONArray.Create;
  try
    try
      var mQuery := gController.CarregarPessoaBanco;
      try
        while (not mQuery.Eof) do
          begin
            var mJSONObj := TJSONObject.Create;
            try
              mJSONObj.AddPair('Id', TJSONNumber.Create(mQuery.FieldByName('id').AsInteger));
              mJSONObj.AddPair('Nome', mQuery.FieldByName('nome').AsString);
              mJSONObj.AddPair('DataNascimento', mQuery.FieldByName('data_nascimento').AsString);
              mJSONObj.AddPair('SaldoDevedor', TJSONNumber.Create(mQuery.FieldByName('saldo_devedor').AsFloat));

              mJSONArray.AddElement(mJSONObj);
            finally
              FreeAndNil(mJSONObj);
            end;

            mQuery.Next;
          end;

        mRes.Status(200).Send(mJSONArray.ToJSON);
      finally
        FreeAndNil(mQuery);
      end;
    except
      on E: Exception do
        mRes.Status(500).Send('Erro ao buscar pessoas no banco: ' + E.Message);
    end;
  finally
    FreeAndNil(mJSONArray);
  end;
end;

procedure AdicionarPessoa(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  if (mReq.Body.IsEmpty) then
    begin
      mRes.Status(400).Send('Corpo da requisição vazio.');
      Exit;
    end;

  var mJSONStr := mReq.Body;
  var mJSONObj := nil;
  try
    mJSONObj := TJSONObject.ParseJSONValue(mJSONStr) as TJSONObject;
    try
      if (mJSONObj = nil) then
        raise Exception.Create('JSON inválido ou mal formado.');

      var mNome, mStrDataNascimento : String;

      if (not mJSONObj.TryGetValue<string>('Nome', mNome)) then
        raise Exception.Create('Nome não encontrado ou inválido.');

      if (not mJSONObj.TryGetValue<string>('DataNascimento', mStrDataNascimento)) then
        raise Exception.Create('Data de nascimento inválida.');

      var mSaldoDevedor : Double;
      if (not mJSONObj.TryGetValue<Double>('SaldoDevedor', mSaldoDevedor)) then
        raise Exception.Create('SaldoDevedor não encontrado ou inválido.');

      gController.AdicionarPessoaBanco(mNome, StrToDate(mStrDataNascimento), mSaldoDevedor);
      mRes.Status(201).Send('Pessoa adicionada com sucesso!');
    finally
      FreeAndNil(mJSONObj);
    end;
  except
    on E: Exception do
      mRes.Status(400).Send('Erro ao adicionar pessoa: ' + E.Message);
  end;
end;

procedure AdicionarPessoaMemoriaBanco(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  try
    gController.AdicionarPessoaMemoriaBanco;
    mRes.Status(201).Send('Pessoa adicionada com sucesso!');
  except
    on E: Exception do
      mRes.Status(400).Send('Erro inesperado: ' + E.Message);
  end;
end;

procedure AdicionarPessoaMemoria(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  if mReq.Body.IsEmpty then
    begin
      mRes.Status(400).Send('Corpo da requisição vazio.');
      Exit;
    end;

  var mJSONStr := mReq.Body;
  var mJSONObj := nil;
  try
    mJSONObj := TJSONObject.ParseJSONValue(mJSONStr) as TJSONObject;
    try
      if (mJSONObj = nil) then
        raise Exception.Create('JSON inválido ou mal formado.');

      var mNome, mStrDataNascimento : String;

      if (not mJSONObj.TryGetValue<string>('Nome', var mNome)) then
        raise Exception.Create('Nome não encontrado ou inválido.');

      if (not mJSONObj.TryGetValue<string>('DataNascimento', var mStrDataNascimento)) then
        raise Exception.Create('Data de nascimento inválida.');

      var mSaldoDevedor : Double;
      if (not mJSONObj.TryGetValue<Double>('SaldoDevedor', var mSaldoDevedor)) then
        raise Exception.Create('SaldoDevedor não encontrado ou inválido.');

      gController.AdicionarPessoaMemoria(mNome, StrToDate(mStrDataNascimento), mSaldoDevedor);
      mRes.Status(201).Send('Pessoa adicionada à memória com sucesso!');
    finally
      FreeAndNil(mJSONObj);
    end;
  except
    on E: Exception do
      mRes.Status(400).Send('Erro ao adicionar pessoa: ' + E.Message);
  end;
end;

procedure ExcluirPessoa(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  var mPessoaID := mReq.Params.Items['id'].ToInteger;
  try
    gController.ExcluirPessoaPorId(mPessoaID);
    mRes.Status(200).Send('Pessoa removida com sucesso!');
  except
    on E: Exception do
      mRes.Status(400).Send('Erro inesperado: ' + E.Message);
  end;
end;

procedure ListarPessoasId(mReq: THorseRequest; mRes: THorseResponse; mNext: TProc);
begin
  var mPessoaID := mReq.Params.Items['id'].ToInteger;
  var mJSONArray := TJSONArray.Create;
  try
    try
      var mQuery := gController.CarregarPessoaBancoPorId(mPessoaID);
      try
        while (not mQuery.Eof) do
          begin
            var mJSONObj := TJSONObject.Create;
            try
              mJSONObj.AddPair('Id', TJSONNumber.Create(mQuery.FieldByName('id').AsInteger));
              mJSONObj.AddPair('Nome', mQuery.FieldByName('nome').AsString);
              mJSONObj.AddPair('DataNascimento', mQuery.FieldByName('data_nascimento').AsString);
              mJSONObj.AddPair('SaldoDevedor', TJSONNumber.Create(mQuery.FieldByName('saldo_devedor').AsFloat));
              mJSONArray.AddElement(mJSONObj);
            finally
              FreeAndNil(mJSONObj);
            end;

            mQuery.Next;
          end;

        mRes.Status(200).Send(mJSONArray.ToJSON);
      finally
        FreeAndNil(mQuery);
      end;
    except
      on E: Exception do
        mRes.Status(500).Send('Erro ao buscar pessoas no banco de dados: ' + E.Message);
    end;
  finally
    FreeAndNil(mJSONArray);
  end;
end;

procedure RegistrarEndpoints;
begin
  gController := TServidorController.Create(Conexao.Model.Connect);

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
  gController.Destroy;
end;

end.

