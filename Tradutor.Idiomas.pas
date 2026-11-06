unit Tradutor.Idiomas;

{ IRepositorioIdiomas com a lista fixa. Poderia ser trocado por um que lê de
  JSON/banco (ex.: as linguagens do lngAPL no MIMS) sem mexer na tela. }

interface

uses
  Tradutor.Interfaces;

type
  TRepositorioIdiomasFixo = class(TInterfacedObject, IRepositorioIdiomas)
  public
    function Todos: TArray<TIdioma>;
    function Filtrar(const AFiltro: string): TArray<TIdioma>;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Generics.Collections;

const
  IDIOMAS: array[0..30] of TIdioma = (
    (Codigo: 'pt';    Nome: 'Português';            Nativo: 'Português'),
    (Codigo: 'en';    Nome: 'Inglês';               Nativo: 'English'),
    (Codigo: 'es';    Nome: 'Espanhol';             Nativo: 'Español'),
    (Codigo: 'fr';    Nome: 'Francês';              Nativo: 'Français'),
    (Codigo: 'de';    Nome: 'Alemão';               Nativo: 'Deutsch'),
    (Codigo: 'it';    Nome: 'Italiano';             Nativo: 'Italiano'),
    (Codigo: 'nl';    Nome: 'Holandês';             Nativo: 'Nederlands'),
    (Codigo: 'ru';    Nome: 'Russo';                Nativo: 'Русский'),
    (Codigo: 'uk';    Nome: 'Ucraniano';            Nativo: 'Українська'),
    (Codigo: 'pl';    Nome: 'Polonês';              Nativo: 'Polski'),
    (Codigo: 'tr';    Nome: 'Turco';                Nativo: 'Türkçe'),
    (Codigo: 'ar';    Nome: 'Árabe';                Nativo: 'العربية'),
    (Codigo: 'iw';    Nome: 'Hebraico';             Nativo: 'עברית'),
    (Codigo: 'hi';    Nome: 'Hindi';                Nativo: 'हिन्दी'),
    (Codigo: 'zh-CN'; Nome: 'Chinês simplificado';  Nativo: '简体中文'),
    (Codigo: 'zh-TW'; Nome: 'Chinês tradicional';   Nativo: '繁體中文'),
    (Codigo: 'ja';    Nome: 'Japonês';              Nativo: '日本語'),
    (Codigo: 'ko';    Nome: 'Coreano';              Nativo: '한국어'),
    (Codigo: 'th';    Nome: 'Tailandês';            Nativo: 'ไทย'),
    (Codigo: 'vi';    Nome: 'Vietnamita';           Nativo: 'Tiếng Việt'),
    (Codigo: 'id';    Nome: 'Indonésio';            Nativo: 'Bahasa Indonesia'),
    (Codigo: 'el';    Nome: 'Grego';                Nativo: 'Ελληνικά'),
    (Codigo: 'sv';    Nome: 'Sueco';                Nativo: 'Svenska'),
    (Codigo: 'no';    Nome: 'Norueguês';            Nativo: 'Norsk'),
    (Codigo: 'da';    Nome: 'Dinamarquês';          Nativo: 'Dansk'),
    (Codigo: 'fi';    Nome: 'Finlandês';            Nativo: 'Suomi'),
    (Codigo: 'cs';    Nome: 'Tcheco';               Nativo: 'Čeština'),
    (Codigo: 'hu';    Nome: 'Húngaro';              Nativo: 'Magyar'),
    (Codigo: 'ro';    Nome: 'Romeno';               Nativo: 'Română'),
    (Codigo: 'sw';    Nome: 'Suaíli';               Nativo: 'Kiswahili'),
    (Codigo: 'la';    Nome: 'Latim';                Nativo: 'Latina')
  );

function TRepositorioIdiomasFixo.Todos: TArray<TIdioma>;
var
  I: Integer;
begin
  SetLength(Result, Length(IDIOMAS));
  for I := Low(IDIOMAS) to High(IDIOMAS) do
    Result[I] := IDIOMAS[I];
end;

function TRepositorioIdiomasFixo.Filtrar(const AFiltro: string): TArray<TIdioma>;
var
  Lista: TList<TIdioma>;
  Idioma: TIdioma;
begin
  if Trim(AFiltro) = '' then
    Exit(Todos);

  Lista := TList<TIdioma>.Create;
  try
    for Idioma in IDIOMAS do
      if ContainsText(Idioma.Nome, AFiltro)
        or ContainsText(Idioma.Nativo, AFiltro)
        or StartsText(AFiltro, Idioma.Codigo) then
        Lista.Add(Idioma);
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

end.
