unit Tradutor.MyMemory;

// ITradutor usando a API pública MyMemory (sem chave; limite diário por IP).
// Resposta: {"responseData":{"translatedText":"..."},"responseStatus":200,...}

interface

uses
  Tradutor.Interfaces;

type
  TTradutorMyMemory = class(TInterfacedObject, ITradutor)
  private
    function CodigoMyMemory(const ACodigo: string): string;
  public
    function Nome: string;
    function Traduzir(const ATexto, ADestino: string; const AOrigem: string = 'auto'): string;
  end;

implementation

uses
  System.SysUtils, System.JSON, System.NetEncoding, Tradutor.Http;

const
  URL = 'https://api.mymemory.translated.net/get?q=%s&langpair=%s%%7C%s';

function TTradutorMyMemory.Nome: string;
begin
  Result := 'MyMemory';
end;

function TTradutorMyMemory.CodigoMyMemory(const ACodigo: string): string;
begin
  if SameText(ACodigo, 'auto') then
    Result := 'Autodetect'
  else if SameText(ACodigo, 'iw') then
    Result := 'he'                    // Google usa "iw" para hebraico; MyMemory usa "he"
  else
    Result := ACodigo;
end;

function TTradutorMyMemory.Traduzir(const ATexto, ADestino, AOrigem: string): string;
var
  Json, Status: TJSONValue;
begin
  if Trim(ATexto) = '' then
    Exit(ATexto);

  Json := TJSONObject.ParseJSONValue(HttpGetJson(Format(URL,
    [TNetEncoding.URL.Encode(ATexto), CodigoMyMemory(AOrigem), CodigoMyMemory(ADestino)])));
  if Json = nil then
    raise Exception.Create('MyMemory: resposta inválida.');
  try
    Status := Json.FindValue('responseStatus');
    if (Status = nil) or (Status.Value <> '200') then
      raise Exception.Create('MyMemory: ' + Json.GetValue<string>('responseDetails', 'erro desconhecido'));
    Result := Json.GetValue<string>('responseData.translatedText');
  finally
    Json.Free;
  end;
end;

end.
