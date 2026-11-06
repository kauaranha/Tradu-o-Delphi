unit Tradutor.Http;

{ Utilitário HTTP compartilhado pelas implementações de ITradutor. }

interface

function HttpGetJson(const AUrl: string): string;

implementation

uses
  System.SysUtils, System.Net.HttpClient, System.Net.URLClient;

function HttpGetJson(const AUrl: string): string;
var
  Http: THTTPClient;
  Resp: IHTTPResponse;
begin
  Http := THTTPClient.Create;
  try
    Http.ConnectionTimeout := 10000;
    Http.ResponseTimeout := 10000;
    Resp := Http.Get(AUrl);
    if Resp.StatusCode <> 200 then
      raise Exception.CreateFmt('HTTP %d: %s', [Resp.StatusCode, Resp.StatusText]);
    Result := Resp.ContentAsString(TEncoding.UTF8);
  finally
    Http.Free;
  end;
end;

end.
