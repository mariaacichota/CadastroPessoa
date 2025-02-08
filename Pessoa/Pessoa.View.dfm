object frmPessoa: TfrmPessoa
  Left = 0
  Top = 0
  Caption = 'Pedidos de Venda'
  ClientHeight = 270
  ClientWidth = 1048
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object pgcGeral: TPageControl
    Left = 0
    Top = 0
    Width = 1048
    Height = 270
    ActivePage = tabCadastroPessoa
    Align = alClient
    TabOrder = 0
    object tabCadastroPessoa: TTabSheet
      Caption = 'Cadastro de Pessoa'
      ImageIndex = 1
      object gbCadastro: TGroupBox
        Left = 0
        Top = 0
        Width = 1040
        Height = 97
        Align = alTop
        Caption = 'Cadastro'
        TabOrder = 0
        object lblDataNascimento: TLabel
          Left = 428
          Top = 27
          Width = 107
          Height = 15
          Caption = 'Data de Nascimento'
        end
        object edtNome: TLabeledEdit
          Left = 25
          Top = 48
          Width = 387
          Height = 23
          EditLabel.Width = 33
          EditLabel.Height = 15
          EditLabel.Caption = 'Nome'
          TabOrder = 0
        end
        object edtSaldoDevedor: TLabeledEdit
          Left = 563
          Top = 48
          Width = 86
          Height = 23
          EditLabel.Width = 76
          EditLabel.Height = 15
          EditLabel.Caption = 'Saldo Devedor'
          TabOrder = 1
          OnExit = edtSaldoDevedorExit
        end
        object btnAdicionar: TButton
          Left = 655
          Top = 47
          Width = 162
          Height = 25
          Caption = 'Adicionar em mem'#243'ria'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnAdicionarClick
        end
        object edtDataNascimento: TDateTimePicker
          Left = 428
          Top = 48
          Width = 121
          Height = 23
          Date = 45694.405760358790000000
          Time = 45694.405760358790000000
          TabOrder = 3
        end
      end
      object gbBancoDeDados: TGroupBox
        Left = 0
        Top = 97
        Width = 1040
        Height = 80
        Align = alTop
        Caption = 'Banco de Dados'
        TabOrder = 1
        object btnCarregar: TButton
          Left = 418
          Top = 30
          Width = 266
          Height = 25
          Caption = 'Carregar (banco de dados >> mem'#243'ria)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnCarregarClick
        end
        object btnExcluir: TButton
          Left = 297
          Top = 30
          Width = 115
          Height = 25
          Caption = 'Excluir por Id'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnExcluirClick
        end
        object btnGravar: TButton
          Left = 25
          Top = 30
          Width = 266
          Height = 25
          Caption = 'Gravar (mem'#243'ria >> banco de dados)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnGravarClick
        end
      end
      object pnlFooterPessoa: TPanel
        Left = 0
        Top = 177
        Width = 1040
        Height = 59
        Align = alTop
        TabOrder = 2
        object btnMostrar: TButton
          Left = 25
          Top = 18
          Width = 266
          Height = 25
          Caption = 'Mostrar "pessoas" em mem'#243'ria'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnMostrarClick
        end
      end
    end
    object tabBuscaImovel: TTabSheet
      Caption = 'Im'#243'veis'
      ImageIndex = 2
      object pnlTopImoveis: TPanel
        Left = 0
        Top = 0
        Width = 1040
        Height = 59
        Align = alTop
        TabOrder = 0
        object btnBuscarImoveis: TButton
          Left = 16
          Top = 18
          Width = 115
          Height = 25
          Caption = 'Buscar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnBuscarImoveisClick
        end
      end
      object pnlGridImoveis: TPanel
        Left = 0
        Top = 59
        Width = 1040
        Height = 181
        Align = alClient
        TabOrder = 1
        object gridImoveis: TDBGrid
          Left = 1
          Top = 1
          Width = 1038
          Height = 179
          Align = alClient
          DataSource = dsImovel
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
  end
  object dsImovel: TDataSource
    Left = 520
    Top = 144
  end
  object Conexao: TFDConnection
    Params.Strings = (
      'Database=CadastroPessoa'
      'OSAuthent=Yes'
      'Server=DESKTOP-LQTA0BU\SQLEXPRESS'
      'DriverID=MSSQL')
    Left = 576
    Top = 168
  end
end
