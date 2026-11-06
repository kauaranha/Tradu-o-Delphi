object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Tradutor de Caption'
  ClientHeight = 580
  ClientWidth = 920
  Color = clBtnFace
  Padding.Left = 4
  Padding.Top = 4
  Padding.Right = 4
  Padding.Bottom = 4
  Constraints.MinHeight = 480
  Constraints.MinWidth = 760
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 17
  object pnlCabecalho: TPanel
    Left = 4
    Top = 4
    Width = 912
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    OnDblClick = pnlCabecalhoDblClick
    OnMouseDown = pnlCabecalhoMouseDown
    object lblMinimizar: TLabel
      Left = 820
      Top = 0
      Width = 46
      Height = 32
      Cursor = crHandPoint
      Hint = 'Minimizar'
      Alignment = taCenter
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = #59681
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -10
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      StyleElements = []
      OnClick = lblMinimizarClick
      OnMouseEnter = lblBotaoJanelaMouseEnter
      OnMouseLeave = lblBotaoJanelaMouseLeave
    end
    object lblFechar: TLabel
      Left = 866
      Top = 0
      Width = 46
      Height = 32
      Cursor = crHandPoint
      Hint = 'Fechar'
      Alignment = taCenter
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = #59579
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -10
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      StyleElements = []
      OnClick = lblFecharClick
      OnMouseEnter = lblBotaoJanelaMouseEnter
      OnMouseLeave = lblBotaoJanelaMouseLeave
    end
    object lblTitulo: TLabel
      Left = 24
      Top = 10
      Width = 84
      Height = 30
      Caption = 'Tradutor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -22
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
      OnDblClick = pnlCabecalhoDblClick
      OnMouseDown = pnlCabecalhoMouseDown
    end
    object lblSubtitulo: TLabel
      Left = 24
      Top = 42
      Width = 375
      Height = 17
      Caption = 'Traduza textos para mais de 30 idiomas em tempo de execu'#231#227'o'
      OnDblClick = pnlCabecalhoDblClick
      OnMouseDown = pnlCabecalhoMouseDown
    end
    object tglTema: TToggleSwitch
      Left = 690
      Top = 21
      Width = 95
      Height = 33
      Anchors = [akTop, akRight]
      StateCaptions.CaptionOn = 'Escuro'
      StateCaptions.CaptionOff = 'Claro'
      TabOrder = 0
      OnClick = tglTemaClick
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 552
    Width = 920
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object lblStatus: TLabel
      AlignWithMargins = True
      Left = 24
      Top = 0
      Width = 872
      Height = 28
      Margins.Left = 24
      Margins.Top = 0
      Margins.Right = 24
      Margins.Bottom = 0
      Align = alClient
      Layout = tlCenter
      ExplicitWidth = 4
      ExplicitHeight = 17
    end
  end
  object pnlIdiomas: TPanel
    Left = 0
    Top = 72
    Width = 280
    Height = 480
    Align = alLeft
    BevelOuter = bvNone
    Padding.Left = 16
    Padding.Right = 8
    Padding.Bottom = 16
    TabOrder = 1
    object sbxBusca: TSearchBox
      AlignWithMargins = True
      Left = 16
      Top = 0
      Width = 256
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      TabOrder = 0
      TextHint = 'Buscar idioma...'
      OnChange = sbxBuscaChange
    end
    object lstIdiomas: TListBox
      Left = 16
      Top = 33
      Width = 256
      Height = 431
      Style = lbOwnerDrawFixed
      Align = alClient
      BorderStyle = bsNone
      ItemHeight = 52
      TabOrder = 1
      OnClick = lstIdiomasClick
      OnDrawItem = lstIdiomasDrawItem
    end
  end
  object pnlConteudo: TPanel
    Left = 280
    Top = 72
    Width = 640
    Height = 480
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Right = 24
    Padding.Bottom = 16
    TabOrder = 2
    object lblTextoOriginal: TLabel
      Left = 8
      Top = 0
      Width = 608
      Height = 17
      Align = alTop
      Caption = 'Texto original'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 32
      ExplicitTop = 24
    end
    object mmoOriginal: TMemo
      AlignWithMargins = True
      Left = 8
      Top = 21
      Width = 608
      Height = 90
      Margins.Left = 0
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 12
      Align = alTop
      Lines.Strings = (
        
          'Bem-vindo ao sistema! Selecione um idioma para traduzir este tex' +
          'to.')
      ScrollBars = ssVertical
      TabOrder = 0
      OnChange = mmoOriginalChange
      ExplicitTop = 21
    end
    object pnlAcoes: TPanel
      Left = 8
      Top = 416
      Width = 608
      Height = 48
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      DesignSize = (
        608
        48)
      object lblInterface: TLabel
        Left = 340
        Top = 14
        Width = 200
        Height = 17
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 'Traduzir interface tamb'#233'm'
      end
      object btnCopiar: TButton
        Left = 0
        Top = 8
        Width = 150
        Height = 32
        Caption = 'Copiar tradu'#231#227'o'
        TabOrder = 0
        OnClick = btnCopiarClick
      end
      object tglInterface: TToggleSwitch
        Left = 556
        Top = 13
        Width = 50
        Height = 28
        Anchors = [akTop, akRight]
        ShowStateCaption = False
        TabOrder = 1
        OnClick = tglInterfaceClick
      end
    end
    object pnlCartao: TPanel
      Left = 8
      Top = 123
      Width = 608
      Height = 293
      Align = alClient
      BevelOuter = bvNone
      Color = 16774895
      Padding.Left = 24
      Padding.Top = 20
      Padding.Right = 24
      Padding.Bottom = 20
      ParentBackground = False
      TabOrder = 1
      StyleElements = []
      DesignSize = (
        608
        293)
      object lblIdiomaAtual: TLabel
        Left = 24
        Top = 20
        Width = 560
        Height = 15
        Align = alTop
        Caption = 'TEXTO ORIGINAL'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15426341
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        StyleElements = [seClient, seBorder]
        ExplicitWidth = 94
      end
      object lblCaption: TLabel
        Left = 24
        Top = 35
        Width = 560
        Height = 238
        Align = alClient
        Alignment = taCenter
        AutoSize = False
        Caption = 'lblCaption'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 9058846
        Font.Height = -29
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        WordWrap = True
        StyleElements = [seClient, seBorder]
        ExplicitTop = 37
        ExplicitHeight = 236
      end
      object aiCarregando: TActivityIndicator
        Left = 560
        Top = 16
        Anchors = [akTop, akRight]
        IndicatorSize = aisSmall
        IndicatorType = aitSectorRing
      end
    end
  end
  object tmrDigitacao: TTimer
    Enabled = False
    Interval = 700
    OnTimer = tmrDigitacaoTimer
  end
end
