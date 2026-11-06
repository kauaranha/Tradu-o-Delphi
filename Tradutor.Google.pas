unit Tradutor.Google;

{ ITradutor usando o endpoint público do Google Translate (sem chave, NÃO oficial).
  Resposta: [[["traduzido","original",...],...],null,"idioma-detectado",...] }

interface

uses
  Tradutor.Interfaces;

type
  TTradutorGoogle = class(TInterfacedObject, ITradutor)
  public
    function Nome: string;
    function Traduzir(const ATexto, ADestino: string; const AOrigem: string = 'auto'): string;
  end;

implementation

uses
  System.SysUtils, System.JSON, System.NetEncoding, Tradutor.Http;

const
  URL = 'https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=%s&tl=%s&q=%s';

function TTradutorGoogle.Nome: string;
begin
  Result := 'Google';
end;

function TTradutorGoogle.Traduzir(const ATexto, ADestino, AOrigem: string): string;
var
  Json: TJSONValue;
  Trechos: TJSONArray;
  I: Integer;
begin
  if Trim(ATexto) = '' then
    Exit(ATexto);

  Json := TJSONObject.ParseJSONValue(HttpGetJson(Format(URL,
    [AOrigem, ADestino, TNetEncoding.URL.Encode(ATexto)])));
  if Json = nil then
    raise Exception.Create('Google: resposta inválida.');
  try
    // O texto pode vir em vários trechos (um por frase): concatena todos
    Result := '';
    Trechos := (Json as TJSONArray).Items[0] as TJSONArray;
    for I := 0 to Trechos.Count - 1 do
      Result := Result + (Trechos.Items[I] as TJSONArray).Items[0].Value;
  finally
    Json.Free;
  end;
end;

end.
