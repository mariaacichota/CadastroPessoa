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
    ExplicitHeight = 324
    object tabCadastroPessoa: TTabSheet
      Caption = 'Cadastro de Pessoa'
      ImageIndex = 1
      ExplicitHeight = 294
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
        end
        object btnAdicionar: TButton
          Left = 663
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
        end
        object DateTimePicker1: TDateTimePicker
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
        ExplicitTop = 153
        object Panel2: TPanel
          Left = 2
          Top = 17
          Width = 1036
          Height = 61
          Align = alClient
          TabOrder = 0
          object btnGravar: TButton
            Left = 23
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
          end
          object btnExcluir: TButton
            Left = 295
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
          end
          object btnCarregar: TButton
            Left = 416
            Top = 18
            Width = 266
            Height = 25
            Caption = 'Carregar (banco de dados >> mem'#243'ria)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 2
          end
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 177
        Width = 1040
        Height = 59
        Align = alTop
        TabOrder = 2
        ExplicitTop = 233
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
        end
      end
    end
    object tabBuscaImovel: TTabSheet
      Caption = 'Im'#243'veis'
      ImageIndex = 2
      ExplicitHeight = 294
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
        end
      end
      object pnlGridImoveis: TPanel
        Left = 0
        Top = 59
        Width = 1040
        Height = 181
        Align = alClient
        TabOrder = 1
        ExplicitHeight = 235
        object gridImoveis: TDBGrid
          Left = 1
          Top = 1
          Width = 1038
          Height = 179
          Align = alClient
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
end
