unit Tradutor.Interfaces;

{ CONCEITO 1 - INTERFACE
  A tela só conhece este contrato. Quem traduz de verdade (Google, DeepL,
  um tradutor falso para testes...) fica escondido atrás dele. }

interface

type
  ITradutor = interface
    ['{6F1D3C2A-8B4E-4A71-9D2F-3E5B7C9A1F01}']
    function Nome: string;
    function Traduzir(const ATexto, AIdioma: string): string;
  end;

  { CONCEITO 2 - RTTI (atributo)
    Marque um componente do form com [NaoTraduzir] para que a tradução
    automática da tela não mexa nele. }
  NaoTraduzirAttribute = class(TCustomAttribute);

implementation

end.
