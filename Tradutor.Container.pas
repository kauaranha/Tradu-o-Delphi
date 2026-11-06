unit Tradutor.Container;

{ Container de injeção de dependência mínimo (sem bibliotecas externas).

    Registrar:  Container.Registrar<ITradutor>(function: ITradutor begin ... end);
    Resolver:   Tradutor := Container.Resolver<ITradutor>;

  Singleton = a fábrica roda uma vez e a mesma instância é devolvida sempre.
  Transiente = a fábrica roda a cada Resolver. }

interface

uses
  System.SysUtils, System.TypInfo, System.Generics.Collections;

type
  TCicloDeVida = (cvSingleton, cvTransiente);

  TContainer = class
  private type
    TRegistro = class
      Fabrica: TFunc<IInterface>;
      CicloDeVida: TCicloDeVida;
      Instancia: IInterface;
    end;
  private
    FRegistros: TObjectDictionary<PTypeInfo, TRegistro>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Registrar<T: IInterface>(const AFabrica: TFunc<T>;
      ACicloDeVida: TCicloDeVida = cvSingleton);
    function Resolver<T: IInterface>: T;
    function EstaRegistrado<T: IInterface>: Boolean;
  end;

/// Instância global usada pelo composition root (.dpr) e pelos forms criados pela VCL.
function Container: TContainer;

implementation

var
  GContainer: TContainer;

function Container: TContainer;
begin
  if GContainer = nil then
    GContainer := TContainer.Create;
  Result := GContainer;
end;

{ TContainer }

constructor TContainer.Create;
begin
  inherited;
  FRegistros := TObjectDictionary<PTypeInfo, TRegistro>.Create([doOwnsValues]);
end;

destructor TContainer.Destroy;
begin
  FRegistros.Free;
  inherited;
end;

procedure TContainer.Registrar<T>(const AFabrica: TFunc<T>; ACicloDeVida: TCicloDeVida);
var
  Registro: TRegistro;
  Fabrica: TFunc<T>;
begin
  Fabrica := AFabrica;
  Registro := TRegistro.Create;
  Registro.CicloDeVida := ACicloDeVida;
  Registro.Fabrica :=
    function: IInterface
    begin
      Result := Fabrica();
    end;
  FRegistros.AddOrSetValue(TypeInfo(T), Registro);
end;

function TContainer.Resolver<T>: T;
var
  Registro: TRegistro;
  Instancia: IInterface;
begin
  if not FRegistros.TryGetValue(TypeInfo(T), Registro) then
    raise Exception.CreateFmt('Container: %s não foi registrado.', [GetTypeName(TypeInfo(T))]);

  if Registro.CicloDeVida = cvSingleton then
  begin
    if Registro.Instancia = nil then
      Registro.Instancia := Registro.Fabrica();
    Instancia := Registro.Instancia;
  end
  else
    Instancia := Registro.Fabrica();

  if not Supports(Instancia, GetTypeData(TypeInfo(T))^.Guid, Result) then
    raise Exception.CreateFmt('Container: a fábrica de %s devolveu um tipo incompatível.',
      [GetTypeName(TypeInfo(T))]);
end;

function TContainer.EstaRegistrado<T>: Boolean;
begin
  Result := FRegistros.ContainsKey(TypeInfo(T));
end;

initialization

finalization
  FreeAndNil(GContainer);

end.
