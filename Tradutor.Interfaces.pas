unit Tradutor.Interfaces;

{ Contratos do projeto. As telas dependem SÓ destas interfaces;
  as implementações concretas são escolhidas no composition root (TradutorCaption.dpr). }

interface

uses
  System.Classes, System.SysUtils;

type
  TIdioma = record
    Codigo: string;     // ISO usado pelas APIs (en, pt, zh-CN...)
    Nome: string;       // nome em português
    Nativo: string;     // nome no próprio idioma
  end;

  /// Serviço de tradução de texto (Google, MyMemory, DeepL, falso para testes...).
  /// As implementações devem ser seguras para chamada fora da thread principal.
  ITradutor = interface
    ['{6F1D3C2A-8B4E-4A71-9D2F-3E5B7C9A1F01}']
    function Nome: string;
    function Traduzir(const ATexto, ADestino: string; const AOrigem: string = 'auto'): string;
  end;

  /// Fonte da lista de idiomas disponíveis.
  IRepositorioIdiomas = interface
    ['{6F1D3C2A-8B4E-4A71-9D2F-3E5B7C9A1F02}']
    function Todos: TArray<TIdioma>;
    function Filtrar(const AFiltro: string): TArray<TIdioma>;
  end;

  /// Traduz os textos de uma tela inteira (Caption, Hint, TextHint...) descobertos via RTTI.
  ITradutorDeForm = interface
    ['{6F1D3C2A-8B4E-4A71-9D2F-3E5B7C9A1F03}']
    /// Varre a tela via RTTI e guarda os textos originais.
    procedure Capturar(ARaiz: TComponent);
    /// Traduz em segundo plano; AoConcluir roda na thread principal com a mensagem de erro ('' = ok).
    procedure Traduzir(const ADestino: string; AoConcluir: TProc<string>);
    /// Volta todos os textos ao original.
    procedure Restaurar;
    function QuantidadeTextos: Integer;
  end;

  /// Marca um campo do form para NÃO ser traduzido pelo ITradutorDeForm.
  ///   [NaoTraduzir]            -> ignora o componente inteiro
  ///   [NaoTraduzir('Caption')] -> ignora só as propriedades listadas (separadas por vírgula)
  NaoTraduzirAttribute = class(TCustomAttribute)
  private
    FPropriedades: string;
  public
    constructor Create; overload;
    constructor Create(const APropriedades: string); overload;
    function IgnoraTudo: Boolean;
    function Ignora(const APropriedade: string): Boolean;
  end;

implementation

uses
  System.StrUtils;

{ NaoTraduzirAttribute }

constructor NaoTraduzirAttribute.Create;
begin
  FPropriedades := '';
end;

constructor NaoTraduzirAttribute.Create(const APropriedades: string);
begin
  FPropriedades := ',' + StringReplace(APropriedades, ' ', '', [rfReplaceAll]) + ',';
end;

function NaoTraduzirAttribute.IgnoraTudo: Boolean;
begin
  Result := FPropriedades = '';
end;

function NaoTraduzirAttribute.Ignora(const APropriedade: string): Boolean;
begin
  Result := IgnoraTudo or ContainsText(FPropriedades, ',' + APropriedade + ',');
end;

end.
