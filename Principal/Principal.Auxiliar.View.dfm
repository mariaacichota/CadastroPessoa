object frmAuxiliarPrincipal: TfrmAuxiliarPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Formul'#225'rio Auxiliar'
  ClientHeight = 231
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object gridAuxiliarPessoa: TDBGrid
    Left = 0
    Top = 25
    Width = 505
    Height = 206
    Align = alClient
    DataSource = dsPessoa
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Verdana'
    TitleFont.Style = []
    OnDblClick = gridAuxiliarPessoaDblClick
  end
  object pnlTipExcluir: TPanel
    Left = 0
    Top = 0
    Width = 505
    Height = 25
    Align = alTop
    TabOrder = 1
    Visible = False
    object lblTipExcluir: TLabel
      Left = 8
      Top = 3
      Width = 324
      Height = 13
      Caption = 'Clique duas vezes para selecionar o Id que deseja excluir.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
  end
  object dsPessoa: TDataSource
    Left = 240
    Top = 136
  end
end
