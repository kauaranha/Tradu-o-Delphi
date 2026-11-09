unit Tradutor.Idiomas;

{ Lista de idiomas oferecidos na tela. }

interface

type
  TIdioma = record
    Codigo: string;     // código usado pela API (en, es, zh-CN...)
    Nome: string;       // nome em português
    Nativo: string;     // nome no próprio idioma
  end;

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

implementation

end.
