object frmAuxiliarPessoa: TfrmAuxiliarPessoa
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'frmAuxiliarPessoa'
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
    Top = 0
    Width = 505
    Height = 231
    Align = alClient
    DataSource = dsPessoa
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = gridAuxiliarPessoaDblClick
  end
  object dsPessoa: TDataSource
    Left = 240
    Top = 136
  end
end
