unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.Themes,
  Tradutor.Interfaces, Tradutor.Tela;

type
  TfrmPrincipal = class(TForm)
    pnlCabecalho: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    tglTema: TToggleSwitch;
    pnlRodape: TPanel;
    [NaoTraduzir] lblStatus: TLabel;
    pnlIdiomas: TPanel;
    sbxBusca: TSearchBox;
    lstIdiomas: TListBox;
    pnlConteudo: TPanel;
    lblTextoOriginal: TLabel;
    [NaoTraduzir] mmoOriginal: TMemo;
    pnlAcoes: TPanel;
    btnCopiar: TButton;
    lblInterface: TLabel;
    tglInterface: TToggleSwitch;
    pnlCartao: TPanel;
    [NaoTraduzir] lblIdiomaAtual: TLabel;
    aiCarregando: TActivityIndicator;
    [NaoTraduzir] lblCaption: TLabel;
    tmrDigitacao: TTimer;
    [NaoTraduzir] lblMinimizar: TLabel;
    [NaoTraduzir] lblFechar: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnlCabecalhoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCabecalhoDblClick(Sender: TObject);
    procedure lblMinimizarClick(Sender: TObject);
    procedure lblFecharClick(Sender: TObject);
    procedure lblBotaoJanelaMouseEnter(Sender: TObject);
    procedure lblBotaoJanelaMouseLeave(Sender: TObject);
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
    FTradutor: ITradutor;               // recebido de fora (injeção de dependência)
    FTradutorDeTela: TTradutorDeTela;   // RTTI: textos da própria tela
    FIdiomaAtual: Integer;              // índice em IDIOMAS; -1 = nenhum selecionado
    FRequisicao: Integer;               // ignora respostas de traduções antigas
    FCorCartao, FCorCartaoTexto, FCorRotulo, FCorDestaque: TColor;
    FCorTextoJanela, FCorHover: TColor;
    FMaximizada: Boolean;
    FBoundsNormal: TRect;
    FListaWndProcOriginal: TWndMethod;
    procedure ListaWndProc(var Msg: TMessage);
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    function Px(AValor: Integer): Integer;
    procedure AplicarTema(AEscuro: Boolean);
    procedure FiltrarIdiomas(const AFiltro: string);
    procedure Traduzir;
    procedure MostrarOriginal;
    procedure Carregando(AAtivo: Boolean);
    procedure Status(const ATexto: string);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    /// CONCEITO 3 - INJEÇÃO DE DEPENDÊNCIA: a tela não cria o tradutor, ela o recebe.
    property Tradutor: ITradutor read FTradutor write FTradutor;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses
  System.StrUtils, System.Threading, Vcl.Clipbrd, Tradutor.Idiomas;

{ ============================================================================ }
{ Início / fim                                                                 }
{ ============================================================================ }

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FIdiomaAtual := -1;
  FListaWndProcOriginal := lstIdiomas.WindowProc;
  lstIdiomas.WindowProc := ListaWndProc;
  lblTextoOriginal.Top := 0;   // mantém o rótulo acima do memo (ambos alTop)

  // RTTI: guarda os textos da tela que podem ser traduzidos
  FTradutorDeTela := TTradutorDeTela.Create;
  FTradutorDeTela.Capturar(Self);

  FiltrarIdiomas('');
  AplicarTema(False);
  MostrarOriginal;
  Status('Selecione um idioma à esquerda');
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  lstIdiomas.WindowProc := FListaWndProcOriginal;
  FTradutorDeTela.Free;
end;

{ ============================================================================ }
{ Tradução - toda a lógica está aqui                                           }
{ ============================================================================ }

procedure TfrmPrincipal.MostrarOriginal;
begin
  Carregando(False);
  lblIdiomaAtual.Caption := 'TEXTO ORIGINAL';
  lblCaption.BiDiMode := bdLeftToRight;
  lblCaption.Caption := Trim(mmoOriginal.Text);
  FTradutorDeTela.Restaurar;
end;

procedure TfrmPrincipal.Traduzir;
var
  Servico: ITradutor;
  Idioma: TIdioma;
  Texto: string;
  TextosTela: TArray<string>;
  Requisicao: Integer;
begin
  Inc(FRequisicao);
  Requisicao := FRequisicao;

  // 1. Nada para traduzir? Mostra o original.
  if (FIdiomaAtual < 0) or (IDIOMAS[FIdiomaAtual].Codigo = 'pt') or (Trim(mmoOriginal.Text) = '') then
  begin
    MostrarOriginal;
    Exit;
  end;

  if FTradutor = nil then
  begin
    Status('Nenhum tradutor foi configurado (veja o .dpr)');
    Exit;
  end;

  // 2. Separa o que vai ser traduzido
  Servico := FTradutor;
  Idioma := IDIOMAS[FIdiomaAtual];
  Texto := Trim(mmoOriginal.Text);
  if tglInterface.State = tssOn then
    TextosTela := FTradutorDeTela.Originais
  else
  begin
    TextosTela := nil;
    FTradutorDeTela.Restaurar;
  end;

  lblIdiomaAtual.Caption := AnsiUpperCase(Idioma.Nome) + '   •   ' + Idioma.Nativo;
  if (Idioma.Codigo = 'ar') or (Idioma.Codigo = 'iw') then
    lblCaption.BiDiMode := bdRightToLeft     // árabe e hebraico: direita para a esquerda
  else
    lblCaption.BiDiMode := bdLeftToRight;
  Carregando(True);
  Status('Traduzindo para ' + Idioma.Nome + '...');

  // 3. Traduz em segundo plano (a tela não trava)...
  TTask.Run(
    procedure
    var
      Resultado, Erro: string;
      Traduzidos: TArray<string>;
      I: Integer;
    begin
      try
        Resultado := Servico.Traduzir(Texto, Idioma.Codigo);
        SetLength(Traduzidos, Length(TextosTela));
        for I := 0 to High(TextosTela) do
          Traduzidos[I] := Servico.Traduzir(TextosTela[I], Idioma.Codigo);
      except
        on E: Exception do
          Erro := E.Message;
      end;

      // 4. ...e mostra o resultado na thread principal
      TThread.Queue(nil,
        procedure
        begin
          if Requisicao <> FRequisicao then
            Exit;   // o usuário já pediu outra tradução
          Carregando(False);
          if Erro <> '' then
          begin
            Status('Falha ao traduzir: ' + Erro);
            Exit;
          end;
          lblCaption.Caption := Resultado;
          if Length(Traduzidos) > 0 then
            FTradutorDeTela.Aplicar(Traduzidos);
          Status('Traduzido para ' + Idioma.Nome + '  •  serviço: ' + Servico.Nome);
        end);
    end);
end;

procedure TfrmPrincipal.lstIdiomasClick(Sender: TObject);
begin
  if lstIdiomas.ItemIndex >= 0 then
  begin
    FIdiomaAtual := NativeInt(lstIdiomas.Items.Objects[lstIdiomas.ItemIndex]);
    Traduzir;
  end;
end;

procedure TfrmPrincipal.tglInterfaceClick(Sender: TObject);
begin
  Traduzir;
end;

procedure TfrmPrincipal.mmoOriginalChange(Sender: TObject);
begin
  // Espera o usuário parar de digitar antes de traduzir
  tmrDigitacao.Enabled := False;
  tmrDigitacao.Enabled := True;
end;

procedure TfrmPrincipal.tmrDigitacaoTimer(Sender: TObject);
begin
  tmrDigitacao.Enabled := False;
  Traduzir;
end;

procedure TfrmPrincipal.btnCopiarClick(Sender: TObject);
begin
  Clipboard.AsText := lblCaption.Caption;
  Status('Texto copiado');
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

{ ============================================================================ }
{ Lista de idiomas                                                             }
{ ============================================================================ }

procedure TfrmPrincipal.FiltrarIdiomas(const AFiltro: string);
var
  I: Integer;
begin
  lstIdiomas.Items.BeginUpdate;
  try
    lstIdiomas.Items.Clear;
    for I := Low(IDIOMAS) to High(IDIOMAS) do
      if (AFiltro = '') or ContainsText(IDIOMAS[I].Nome, AFiltro)
        or ContainsText(IDIOMAS[I].Nativo, AFiltro) or StartsText(AFiltro, IDIOMAS[I].Codigo) then
      begin
        lstIdiomas.Items.AddObject(IDIOMAS[I].Nome, TObject(NativeInt(I)));  // guarda o índice
        if I = FIdiomaAtual then
          lstIdiomas.ItemIndex := lstIdiomas.Items.Count - 1;
      end;
  finally
    lstIdiomas.Items.EndUpdate;
  end;
end;

procedure TfrmPrincipal.sbxBuscaChange(Sender: TObject);
begin
  FiltrarIdiomas(Trim(sbxBusca.Text));
end;

procedure TfrmPrincipal.lstIdiomasDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  C: TCanvas;
  Idioma: TIdioma;
  R, Chip: TRect;
  CorTexto, CorSecundaria, CorChip: TColor;
  LarguraChip: Integer;
begin
  C := lstIdiomas.Canvas;
  Idioma := IDIOMAS[NativeInt(lstIdiomas.Items.Objects[Index])];

  C.Brush.Color := StyleServices.GetSystemColor(clWindow);
  C.FillRect(Rect);

  R := Rect;
  InflateRect(R, -Px(4), -Px(3));
  if odSelected in State then
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

  // Etiqueta com o código à direita
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

  // Nome em português e nome nativo
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
  // Tira o estado de foco do item para não desenhar o retângulo preto
  if Msg.Msg = CN_DRAWITEM then
    with TWMDrawItem(Msg).DrawItemStruct^ do
      itemState := itemState and not ODS_FOCUS;
  FListaWndProcOriginal(Msg);
end;

{ ============================================================================ }
{ Aparência: tema claro/escuro                                                 }
{ ============================================================================ }

function TfrmPrincipal.Px(AValor: Integer): Integer;
begin
  Result := MulDiv(AValor, CurrentPPI, 96);   // acompanha a escala (DPI) do monitor
end;

procedure TfrmPrincipal.AplicarTema(AEscuro: Boolean);
var
  Nome: string;
begin
  for Nome in TStyleManager.StyleNames do
    if ((Pos('Dark', Nome) > 0) = AEscuro) and not SameText(Nome, 'Windows') then
    begin
      TStyleManager.TrySetStyle(Nome, False);
      Break;
    end;

  FCorDestaque := $00EB6325;
  if AEscuro then
  begin
    FCorCartao := $003B291E;
    FCorCartaoTexto := $00FEDBBF;
    FCorRotulo := $00FAA560;
    FCorHover := $00404040;
    aiCarregando.IndicatorColor := aicWhite;
  end
  else
  begin
    FCorCartao := $00FFF6EF;
    FCorCartaoTexto := $008A3A1E;
    FCorRotulo := $00EB6325;
    FCorHover := $00E5E5E5;
    aiCarregando.IndicatorColor := aicBlack;
  end;

  pnlCartao.Color := FCorCartao;
  lblCaption.Font.Color := FCorCartaoTexto;
  lblIdiomaAtual.Font.Color := FCorRotulo;
  FCorTextoJanela := StyleServices.GetSystemColor(clWindowText);
  lblMinimizar.Font.Color := FCorTextoJanela;
  lblFechar.Font.Color := FCorTextoJanela;
  lstIdiomas.Invalidate;
end;

procedure TfrmPrincipal.tglTemaClick(Sender: TObject);
begin
  AplicarTema(tglTema.State = tssOn);
end;

{ ============================================================================ }
{ Janela sem barra de título                                                   }
{ ============================================================================ }

procedure TfrmPrincipal.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WindowClass.style := Params.WindowClass.style or CS_DROPSHADOW;   // sombra
  Params.Style := Params.Style or WS_SYSMENU or WS_MINIMIZEBOX;            // barra de tarefas
end;

procedure TfrmPrincipal.WMNCHitTest(var Msg: TWMNCHitTest);
var
  P: TPoint;
  Esq, Dir, Cima, Baixo: Boolean;
begin
  inherited;
  if FMaximizada then
    Exit;
  // A margem (Padding) do form funciona como borda para redimensionar
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
  if (Button = mbLeft) and not (ssDouble in Shift) and not FMaximizada then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);   // arrasta a janela
  end;
end;

procedure TfrmPrincipal.pnlCabecalhoDblClick(Sender: TObject);
begin
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
    L.Color := $002311E8;
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

end.
