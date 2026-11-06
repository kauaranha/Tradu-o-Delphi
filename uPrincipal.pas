unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.Themes,
  Tradutor.Interfaces;   // contratos + atributo [NaoTraduzir] (precisa estar na interface)

type
  TfrmPrincipal = class(TForm)
    pnlCabecalho: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    tglTema: TToggleSwitch;
    pnlRodape: TPanel;
    [NaoTraduzir] lblStatus: TLabel;                     // mensagens dinâmicas
    pnlIdiomas: TPanel;
    sbxBusca: TSearchBox;
    lstIdiomas: TListBox;
    pnlConteudo: TPanel;
    lblTextoOriginal: TLabel;
    [NaoTraduzir] mmoOriginal: TMemo;                    // conteúdo do usuário
    pnlAcoes: TPanel;
    btnCopiar: TButton;
    lblInterface: TLabel;
    [NaoTraduzir('StateCaptions')] tglInterface: TToggleSwitch;  // legenda oculta
    pnlCartao: TPanel;
    [NaoTraduzir] lblIdiomaAtual: TLabel;                // preenchido pelo código
    aiCarregando: TActivityIndicator;
    [NaoTraduzir] lblCaption: TLabel;                    // tem fluxo de tradução próprio
    tmrDigitacao: TTimer;
    [NaoTraduzir('Caption')] lblMinimizar: TLabel;       // Caption é ícone; Hint traduz
    [NaoTraduzir('Caption')] lblFechar: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure pnlCabecalhoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCabecalhoDblClick(Sender: TObject);
    procedure lblMinimizarClick(Sender: TObject);
    procedure lblFecharClick(Sender: TObject);
    procedure lblBotaoJanelaMouseEnter(Sender: TObject);
    procedure lblBotaoJanelaMouseLeave(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbxBuscaChange(Sender: TObject);
    procedure lstIdiomasClick(Sender: TObject);
    procedure lstIdiomasDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure mmoOriginalChange(Sender: TObject);
    procedure tmrDigitacaoTimer(Sender: TObject);
    procedure btnCopiarClick(Sender: TObject);
    procedure tglTemaClick(Sender: TObject);
    procedure tglInterfaceClick(Sender: TObject);
  private
    // Dependências (injetadas pelo construtor)
    FTradutor: ITradutor;
    FIdiomas: IRepositorioIdiomas;
    FTradutorDeForm: ITradutorDeForm;

    FIdiomasVisiveis: TArray<TIdioma>;          // itens exibidos na lista (após filtro)
    FIdiomaAtual: TIdioma;
    FTemIdioma: Boolean;                        // False = mostrando o texto original
    FRequisicao: Integer;                       // descarta respostas antigas do caption
    FCorCartao, FCorCartaoTexto, FCorRotulo, FCorDestaque: TColor;
    FCorTextoJanela, FCorHover: TColor;
    FMaximizada: Boolean;
    FBoundsNormal: TRect;
    FListaWndProcOriginal: TWndMethod;
    procedure ListaWndProc(var Msg: TMessage);
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    function Px(AValor: Integer): Integer;
    procedure AplicarTema(AEscuro: Boolean);
    procedure FiltrarIdiomas(const AFiltro: string);
    procedure TraduzirCaption;
    procedure TraduzirInterface;
    procedure Carregando(AAtivo: Boolean);
    procedure Status(const ATexto: string);
  public
    /// Usado pela VCL (Application.CreateForm): resolve as dependências no container.
    constructor Create(AOwner: TComponent); overload; override;
    /// Injeção explícita (testes, outro container, outra composição).
    constructor Create(AOwner: TComponent; const ATradutor: ITradutor;
      const AIdiomas: IRepositorioIdiomas; const ATradutorDeForm: ITradutorDeForm); reintroduce; overload;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses
  System.Threading, Vcl.Clipbrd, Tradutor.Container;

{ ---------------------------------------------------------------------------- }
{ Construção / injeção de dependência                                          }
{ ---------------------------------------------------------------------------- }

constructor TfrmPrincipal.Create(AOwner: TComponent);
begin
  Create(AOwner,
    Container.Resolver<ITradutor>,
    Container.Resolver<IRepositorioIdiomas>,
    Container.Resolver<ITradutorDeForm>);
end;

constructor TfrmPrincipal.Create(AOwner: TComponent; const ATradutor: ITradutor;
  const AIdiomas: IRepositorioIdiomas; const ATradutorDeForm: ITradutorDeForm);
begin
  // Atribuídos ANTES do inherited: o OnCreate (FormCreate) já encontra tudo pronto
  FTradutor := ATradutor;
  FIdiomas := AIdiomas;
  FTradutorDeForm := ATradutorDeForm;
  inherited Create(AOwner);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FListaWndProcOriginal := lstIdiomas.WindowProc;
  lstIdiomas.WindowProc := ListaWndProc;

  // Garante o rótulo "Texto original" acima do memo (ambos alTop)
  lblTextoOriginal.Top := 0;

  // RTTI: descobre sozinho os textos traduzíveis da tela (respeitando [NaoTraduzir])
  FTradutorDeForm.Capturar(Self);

  FiltrarIdiomas('');
  AplicarTema(False);
  Carregando(False);
  TraduzirCaption;
  Status(Format('%d idiomas  •  serviço: %s  •  %d textos da tela encontrados via RTTI',
    [Length(FIdiomas.Todos), FTradutor.Nome, FTradutorDeForm.QuantidadeTextos]));
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  lstIdiomas.WindowProc := FListaWndProcOriginal;
end;

{ ---------------------------------------------------------------------------- }
{ Aparência                                                                    }
{ ---------------------------------------------------------------------------- }

function TfrmPrincipal.Px(AValor: Integer): Integer;
begin
  Result := MulDiv(AValor, CurrentPPI, 96);   // respeita escala de DPI do monitor
end;

procedure TfrmPrincipal.AplicarTema(AEscuro: Boolean);
var
  Nome: string;
begin
  // Estilos embutidos via Estilos.rc: "Windows10" (claro) e "Windows10 Dark" (escuro)
  for Nome in TStyleManager.StyleNames do
    if ((Pos('Dark', Nome) > 0) = AEscuro) and not SameText(Nome, 'Windows') then
    begin
      TStyleManager.TrySetStyle(Nome, False);
      Break;
    end;

  FCorDestaque := $00EB6325;                    // azul (RGB 37,99,235)
  if AEscuro then
  begin
    FCorCartao      := $003B291E;               // RGB 30,41,59
    FCorCartaoTexto := $00FEDBBF;               // RGB 191,219,254
    FCorRotulo      := $00FAA560;               // RGB 96,165,250
    aiCarregando.IndicatorColor := aicWhite;
  end
  else
  begin
    FCorCartao      := $00FFF6EF;               // RGB 239,246,255
    FCorCartaoTexto := $008A3A1E;               // RGB 30,58,138
    FCorRotulo      := $00EB6325;
    aiCarregando.IndicatorColor := aicBlack;
  end;

  pnlCartao.Color := FCorCartao;
  lblCaption.Font.Color := FCorCartaoTexto;
  lblIdiomaAtual.Font.Color := FCorRotulo;

  // Botões da janela acompanham o tema
  FCorTextoJanela := StyleServices.GetSystemColor(clWindowText);
  if AEscuro then
    FCorHover := $00404040
  else
    FCorHover := $00E5E5E5;
  lblMinimizar.Font.Color := FCorTextoJanela;
  lblFechar.Font.Color := FCorTextoJanela;

  lstIdiomas.Invalidate;
end;

procedure TfrmPrincipal.tglTemaClick(Sender: TObject);
begin
  AplicarTema(tglTema.State = tssOn);
end;

procedure TfrmPrincipal.Carregando(AAtivo: Boolean);
begin
  aiCarregando.Visible := AAtivo;
  aiCarregando.Animate := AAtivo;
end;

procedure TfrmPrincipal.Status(const ATexto: string);
begin
  lblStatus.Caption := ATexto;
end;

{ ---------------------------------------------------------------------------- }
{ Janela sem barra de título                                                   }
{ ---------------------------------------------------------------------------- }

procedure TfrmPrincipal.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // Sombra + menu de sistema/minimizar (para o clique na barra de tarefas funcionar)
  Params.WindowClass.style := Params.WindowClass.style or CS_DROPSHADOW;
  Params.Style := Params.Style or WS_SYSMENU or WS_MINIMIZEBOX;
end;

procedure TfrmPrincipal.WMNCHitTest(var Msg: TWMNCHitTest);
var
  P: TPoint;
  Esq, Dir, Cima, Baixo: Boolean;
begin
  inherited;
  if FMaximizada then
    Exit;

  // A margem (Padding) do form é a "borda" que permite redimensionar
  P := ScreenToClient(Point(Msg.XPos, Msg.YPos));
  Esq := P.X < Padding.Left;
  Dir := P.X >= ClientWidth - Padding.Right;
  Cima := P.Y < Padding.Top;
  Baixo := P.Y >= ClientHeight - Padding.Bottom;

  if Cima and Esq then Msg.Result := HTTOPLEFT
  else if Cima and Dir then Msg.Result := HTTOPRIGHT
  else if Baixo and Esq then Msg.Result := HTBOTTOMLEFT
  else if Baixo and Dir then Msg.Result := HTBOTTOMRIGHT
  else if Cima then Msg.Result := HTTOP
  else if Baixo then Msg.Result := HTBOTTOM
  else if Esq then Msg.Result := HTLEFT
  else if Dir then Msg.Result := HTRIGHT;
end;

procedure TfrmPrincipal.pnlCabecalhoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  // Arrastar a janela pelo cabeçalho
  if (Button = mbLeft) and not (ssDouble in Shift) and not FMaximizada then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TfrmPrincipal.pnlCabecalhoDblClick(Sender: TObject);
begin
  // Maximiza na área de trabalho (sem cobrir a barra de tarefas) / restaura
  if FMaximizada then
    BoundsRect := FBoundsNormal
  else
  begin
    FBoundsNormal := BoundsRect;
    BoundsRect := Screen.MonitorFromWindow(Handle).WorkareaRect;
  end;
  FMaximizada := not FMaximizada;
end;

procedure TfrmPrincipal.lblMinimizarClick(Sender: TObject);
begin
  WindowState := wsMinimized;
end;

procedure TfrmPrincipal.lblFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.lblBotaoJanelaMouseEnter(Sender: TObject);
var
  L: TLabel;
begin
  L := Sender as TLabel;
  L.Transparent := False;
  if L = lblFechar then
  begin
    L.Color := $002311E8;          // vermelho do "fechar" do Windows
    L.Font.Color := clWhite;
  end
  else
    L.Color := FCorHover;
end;

procedure TfrmPrincipal.lblBotaoJanelaMouseLeave(Sender: TObject);
var
  L: TLabel;
begin
  L := Sender as TLabel;
  L.Transparent := True;
  L.Font.Color := FCorTextoJanela;
end;

{ ---------------------------------------------------------------------------- }
{ Lista de idiomas                                                             }
{ ---------------------------------------------------------------------------- }

procedure TfrmPrincipal.FiltrarIdiomas(const AFiltro: string);
var
  I: Integer;
begin
  FIdiomasVisiveis := FIdiomas.Filtrar(AFiltro);
  lstIdiomas.Items.BeginUpdate;
  try
    lstIdiomas.Items.Clear;
    for I := 0 to High(FIdiomasVisiveis) do
    begin
      lstIdiomas.Items.Add(FIdiomasVisiveis[I].Nome);
      if FTemIdioma and (FIdiomasVisiveis[I].Codigo = FIdiomaAtual.Codigo) then
        lstIdiomas.ItemIndex := I;
    end;
  finally
    lstIdiomas.Items.EndUpdate;
  end;
end;

procedure TfrmPrincipal.sbxBuscaChange(Sender: TObject);
begin
  FiltrarIdiomas(Trim(sbxBusca.Text));
end;

procedure TfrmPrincipal.lstIdiomasClick(Sender: TObject);
begin
  if lstIdiomas.ItemIndex < 0 then
    Exit;
  FIdiomaAtual := FIdiomasVisiveis[lstIdiomas.ItemIndex];
  FTemIdioma := True;
  TraduzirCaption;
  TraduzirInterface;
end;

procedure TfrmPrincipal.lstIdiomasDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  C: TCanvas;
  Idioma: TIdioma;
  Selecionado: Boolean;
  R, Chip: TRect;
  CorTexto, CorSecundaria, CorChip: TColor;
  LarguraChip: Integer;
begin
  if (Index < 0) or (Index > High(FIdiomasVisiveis)) then
    Exit;
  C := lstIdiomas.Canvas;
  Idioma := FIdiomasVisiveis[Index];
  Selecionado := odSelected in State;

  // Fundo
  C.Brush.Color := StyleServices.GetSystemColor(clWindow);
  C.FillRect(Rect);

  R := Rect;
  InflateRect(R, -Px(4), -Px(3));
  if Selecionado then
  begin
    C.Brush.Color := FCorDestaque;
    C.Pen.Color := FCorDestaque;
    C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Px(12), Px(12));
    CorTexto := clWhite;
    CorSecundaria := $00FEDBBF;
    CorChip := $00C84E1D;
  end
  else
  begin
    CorTexto := StyleServices.GetSystemColor(clWindowText);
    CorSecundaria := StyleServices.GetSystemColor(clGrayText);
    CorChip := StyleServices.GetSystemColor(clBtnFace);
  end;

  // Chip com o código ISO à direita
  C.Font.Name := 'Segoe UI';
  C.Font.Style := [fsBold];
  C.Font.Height := -Px(11);
  LarguraChip := C.TextWidth(Idioma.Codigo) + Px(14);
  Chip := TRect.Create(R.Right - LarguraChip - Px(10), R.Top + (R.Height - Px(20)) div 2, 0, 0);
  Chip.Right := Chip.Left + LarguraChip;
  Chip.Bottom := Chip.Top + Px(20);
  C.Brush.Color := CorChip;
  C.Pen.Color := CorChip;
  C.RoundRect(Chip.Left, Chip.Top, Chip.Right, Chip.Bottom, Px(10), Px(10));
  C.Brush.Style := bsClear;
  C.Font.Color := CorSecundaria;
  DrawText(C.Handle, PChar(Idioma.Codigo), -1, Chip, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

  // Nome (pt) e nome nativo
  C.Font.Name := 'Segoe UI Semibold';
  C.Font.Style := [];
  C.Font.Height := -Px(14);
  C.Font.Color := CorTexto;
  C.TextOut(R.Left + Px(14), R.Top + Px(5), Idioma.Nome);

  C.Font.Name := 'Segoe UI';
  C.Font.Height := -Px(12);
  C.Font.Color := CorSecundaria;
  C.TextOut(R.Left + Px(14), R.Top + Px(25), Idioma.Nativo);

  C.Brush.Style := bsSolid;
end;

procedure TfrmPrincipal.ListaWndProc(var Msg: TMessage);
begin
  // Remove o estado de foco antes do VCL processar o desenho do item:
  // assim o retângulo preto de foco nunca é desenhado na lista
  if Msg.Msg = CN_DRAWITEM then
    with TWMDrawItem(Msg).DrawItemStruct^ do
      itemState := itemState and not ODS_FOCUS;
  FListaWndProcOriginal(Msg);
end;

{ ---------------------------------------------------------------------------- }
{ Tradução do caption                                                          }
{ ---------------------------------------------------------------------------- }

procedure TfrmPrincipal.mmoOriginalChange(Sender: TObject);
begin
  // Espera o usuário parar de digitar antes de chamar a API
  tmrDigitacao.Enabled := False;
  tmrDigitacao.Enabled := True;
end;

procedure TfrmPrincipal.tmrDigitacaoTimer(Sender: TObject);
begin
  tmrDigitacao.Enabled := False;
  TraduzirCaption;
end;

procedure TfrmPrincipal.TraduzirCaption;
var
  Texto: string;
  Idioma: TIdioma;
  Requisicao: Integer;
  Servico: ITradutor;
begin
  Texto := Trim(mmoOriginal.Text);
  Inc(FRequisicao);
  Requisicao := FRequisicao;

  if not FTemIdioma or (Texto = '') then
  begin
    Carregando(False);
    lblIdiomaAtual.Caption := 'TEXTO ORIGINAL';
    lblCaption.BiDiMode := bdLeftToRight;
    lblCaption.Caption := Texto;
    Exit;
  end;

  Idioma := FIdiomaAtual;
  lblIdiomaAtual.Caption := AnsiUpperCase(Idioma.Nome) + '   •   ' + Idioma.Nativo;

  // Árabe e hebraico são escritos da direita para a esquerda
  if (Idioma.Codigo = 'ar') or (Idioma.Codigo = 'iw') then
    lblCaption.BiDiMode := bdRightToLeft
  else
    lblCaption.BiDiMode := bdLeftToRight;

  Carregando(True);
  Status('Traduzindo para ' + Idioma.Nome + '...');

  // A tela não sabe qual API, cache ou fallback está por trás: só conhece ITradutor
  Servico := FTradutor;
  TTask.Run(
    procedure
    var
      Resultado, Erro: string;
    begin
      try
        Resultado := Servico.Traduzir(Texto, Idioma.Codigo);
      except
        on E: Exception do
          Erro := E.Message;
      end;

      TThread.Queue(nil,
        procedure
        begin
          if Requisicao <> FRequisicao then
            Exit;   // usuário já trocou de idioma/texto: ignora resposta antiga
          Carregando(False);
          if Erro <> '' then
          begin
            Status('Falha ao traduzir: ' + Erro);
            Exit;
          end;
          lblCaption.Caption := Resultado;
          Status('Traduzido para ' + Idioma.Nome + '  •  ' + Idioma.Codigo + '  •  ' + Servico.Nome);
        end);
    end);
end;

procedure TfrmPrincipal.btnCopiarClick(Sender: TObject);
begin
  Clipboard.AsText := lblCaption.Caption;
  Status('Texto copiado para a área de transferência');
end;

{ ---------------------------------------------------------------------------- }
{ Tradução da interface (delegada ao ITradutorDeForm / RTTI)                   }
{ ---------------------------------------------------------------------------- }

procedure TfrmPrincipal.tglInterfaceClick(Sender: TObject);
begin
  TraduzirInterface;
end;

procedure TfrmPrincipal.TraduzirInterface;
begin
  if (tglInterface.State <> tssOn) or not FTemIdioma or (FIdiomaAtual.Codigo = 'pt') then
  begin
    FTradutorDeForm.Restaurar;
    Exit;
  end;

  FTradutorDeForm.Traduzir(FIdiomaAtual.Codigo,
    procedure(Erro: string)
    begin
      if Erro <> '' then
        Status('Falha ao traduzir a interface: ' + Erro);
    end);
end;

end.
