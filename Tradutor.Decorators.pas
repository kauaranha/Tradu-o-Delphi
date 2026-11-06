unit Tradutor.Decorators;

{ Decorators: também implementam ITradutor e embrulham outro ITradutor,
  acrescentando comportamento sem que a tela (ou a API) saiba disso.

    Cache(Fallback(Google, MyMemory))  ->  montado no composition root }

interface

uses
  System.SysUtils, System.Generics.Collections, Tradutor.Interfaces;

type
  /// Guarda traduções já feitas em memória (thread-safe).
  TTradutorComCache = class(TInterfacedObject, ITradutor)
  private
    FInterno: ITradutor;
    FCache: TDictionary<string, string>;
  public
    constructor Create(const AInterno: ITradutor);
    destructor Destroy; override;
    function Nome: string;
    function Traduzir(const ATexto, ADestino: string; const AOrigem: string = 'auto'): string;
  end;

  /// Tenta o principal; se falhar (limite, rede, bloqueio), usa o reserva.
  TTradutorComFallback = class(TInterfacedObject, ITradutor)
  private
    FPrincipal: ITradutor;
    FReserva: ITradutor;
  public
    constructor Create(const APrincipal, AReserva: ITradutor);
    function Nome: string;
    function Traduzir(const ATexto, ADestino: string; const AOrigem: string = 'auto'): string;
  end;

implementation

{ TTradutorComCache }

constructor TTradutorComCache.Create(const AInterno: ITradutor);
begin
  inherited Create;
  FInterno := AInterno;
  FCache := TDictionary<string, string>.Create;
end;

destructor TTradutorComCache.Destroy;
begin
  FCache.Free;
  inherited;
end;

function TTradutorComCache.Nome: string;
begin
  Result := FInterno.Nome + ' + cache';
end;

function TTradutorComCache.Traduzir(const ATexto, ADestino, AOrigem: string): string;
var
  Chave: string;
  Achou: Boolean;
begin
  Chave := AOrigem + '>' + ADestino + '|' + ATexto;

  TMonitor.Enter(FCache);
  try
    Achou := FCache.TryGetValue(Chave, Result);
  finally
    TMonitor.Exit(FCache);
  end;
  if Achou then
    Exit;

  Result := FInterno.Traduzir(ATexto, ADestino, AOrigem);   // fora do lock: chamada HTTP

  TMonitor.Enter(FCache);
  try
    FCache.AddOrSetValue(Chave, Result);
  finally
    TMonitor.Exit(FCache);
  end;
end;

{ TTradutorComFallback }

constructor TTradutorComFallback.Create(const APrincipal, AReserva: ITradutor);
begin
  inherited Create;
  FPrincipal := APrincipal;
  FReserva := AReserva;
end;

function TTradutorComFallback.Nome: string;
begin
  Result := FPrincipal.Nome + ' (reserva: ' + FReserva.Nome + ')';
end;

function TTradutorComFallback.Traduzir(const ATexto, ADestino, AOrigem: string): string;
var
  ErroPrincipal: string;
begin
  try
    Exit(FPrincipal.Traduzir(ATexto, ADestino, AOrigem));
  except
    on E: Exception do
      ErroPrincipal := E.Message;
  end;

  try
    Result := FReserva.Traduzir(ATexto, ADestino, AOrigem);
  except
    on E: Exception do
      raise Exception.CreateFmt('%s falhou (%s) e %s também (%s)',
        [FPrincipal.Nome, ErroPrincipal, FReserva.Nome, E.Message]);
  end;
end;

end.
