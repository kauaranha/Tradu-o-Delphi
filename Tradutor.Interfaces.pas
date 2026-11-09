unit Tradutor.Interfaces;

interface

type
  ITradutor = interface
    ['{6F1D3C2A-8B4E-4A71-9D2F-3E5B7C9A1F01}']
    function Nome: string;
    function Traduzir(const ATexto, AIdioma: string): string;
  end;

  NaoTraduzirAttribute = class(TCustomAttribute);

implementation

end.
