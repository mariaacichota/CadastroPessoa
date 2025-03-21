object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Pedidos de Venda'
  ClientHeight = 641
  ClientWidth = 1014
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
    Width = 1014
    Height = 641
    ActivePage = tabBuscaImovel
    Align = alClient
    TabOrder = 0
    object tabCadastroPessoa: TTabSheet
      Caption = 'Cadastro de Pessoa'
      ImageIndex = 1
      object gbCadastro: TGroupBox
        Left = 0
        Top = 0
        Width = 1006
        Height = 73
        Align = alTop
        Caption = 'Cadastro'
        TabOrder = 0
        object lblDataNascimento: TLabel
          Left = 405
          Top = 14
          Width = 107
          Height = 15
          Caption = 'Data de Nascimento'
        end
        object edtNome: TLabeledEdit
          Left = 8
          Top = 32
          Width = 387
          Height = 23
          EditLabel.Width = 33
          EditLabel.Height = 15
          EditLabel.Caption = 'Nome'
          TabOrder = 0
        end
        object edtSaldoDevedor: TLabeledEdit
          Left = 536
          Top = 32
          Width = 86
          Height = 23
          EditLabel.Width = 76
          EditLabel.Height = 15
          EditLabel.Caption = 'Saldo Devedor'
          TabOrder = 2
        end
        object btnAdicionar: TButton
          Left = 632
          Top = 32
          Width = 162
          Height = 25
          Caption = 'Adicionar em mem'#243'ria'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = btnAdicionarClick
        end
        object edtDataNascimento: TDateTimePicker
          Left = 405
          Top = 32
          Width = 121
          Height = 23
          Date = 45694.405760358790000000
          Time = 45694.405760358790000000
          TabOrder = 1
        end
      end
      object gbBancoDeDados: TGroupBox
        Left = 0
        Top = 73
        Width = 1006
        Height = 74
        Align = alTop
        Caption = 'Banco de Dados'
        TabOrder = 1
        object lblStatus: TLabel
          Left = 8
          Top = 48
          Width = 45
          Height = 15
          Caption = 'lblStatus'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clHotLight
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          Visible = False
        end
        object btnCarregar: TButton
          Left = 405
          Top = 18
          Width = 389
          Height = 25
          Caption = 'Carregar (banco de dados >> mem'#243'ria)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnCarregarClick
        end
        object btnExcluir: TButton
          Left = 280
          Top = 18
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
          Left = 8
          Top = 18
          Width = 266
          Height = 25
          Caption = 'Gravar (mem'#243'ria >> banco de dados)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnGravarClick
        end
      end
      object pnlFooterPessoa: TPanel
        Left = 0
        Top = 147
        Width = 1006
        Height = 59
        Align = alTop
        TabOrder = 2
        object btnMostrar: TButton
          Left = 8
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
        Width = 1006
        Height = 33
        Align = alTop
        TabOrder = 0
        object btnBuscarImoveis: TButton
          Left = 8
          Top = 3
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
        Top = 33
        Width = 1006
        Height = 578
        Align = alClient
        TabOrder = 1
        ExplicitTop = 59
        ExplicitHeight = 552
        object gridImoveis: TDBGrid
          Left = 1
          Top = 1
          Width = 1004
          Height = 576
          Align = alClient
          DataSource = dsImovel
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = 'Verdana'
          TitleFont.Style = []
        end
      end
    end
  end
  object dsImovel: TDataSource
    Left = 520
    Top = 144
  end
end
