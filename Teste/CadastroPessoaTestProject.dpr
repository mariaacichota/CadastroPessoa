program CadastroPessoaTestProject;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  CadastroPessoaTest in 'CadastroPessoaTest.pas',
  Imovel.Model in '..\Imóvel\Imovel.Model.pas',
  Caracteristica.Model in '..\Característica\Caracteristica.Model.pas',
  Avaliacao.Model in '..\Avaliação\Avaliacao.Model.pas',
  Principal.ViewModel in '..\Principal\Principal.ViewModel.pas',
  Pessoa.Model in '..\Pessoa\Pessoa.Model.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger: ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    // Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;

    // Create the test runner
    runner := TDUnitX.CreateRunner;

    // Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;

    // Tell the runner how we will log things
    // Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);

    // Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    runner.FailsOnNoAsserts := False; // When true, Assertions must be made during tests

    // Run tests
    results := runner.Execute;

    // If not all tests passed, set exit code to indicate errors
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    WriteLn('Press <Enter> to exit...');
    ReadLn;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.

