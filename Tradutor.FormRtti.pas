unit Tradutor.FormRtti;

{ ITradutorDeForm genérico: descobre via RTTI os textos de QUALQUER tela
  (Caption, Hint, TextHint, StateCaptions.CaptionOn/Off...) e os traduz.
  Nenhum componente precisa ser registrado à mão; exceções são marcadas
  no próprio form com o atributo [NaoTraduzir]. }

interface

uses
  System.Classes, System.SysUtils, System.Rtti, System.Generics.Collections,
  Tradutor.Interfaces;

type
  TTradutorDeForm = class(TInterfacedObject, ITradutorDeForm)
  private type
    TTextoTraduzivel = record
      Instancia: TObject;      // componente (ou sub-objeto, ex.: StateCaptions)
      Propriedade: string;     // nome da propriedade string
      Original: string;
    end;
  private
    FTradutor: ITradutor;
    FContexto: TRttiContext;
    FTextos: TList<TTextoTraduzivel>;
    FRequisicao: Integer;
    procedure LerAtributos(ARaiz: TComponent; AExcecoes: TDictionary<TObject, NaoTraduzirAttribute>);
    procedure CapturarObjeto(AObjeto: TObject; AExcecao: NaoTraduzirAttribute; ANivel: Integer);
    procedure Aplicar(const ATextos: TArray<string>);
  public
    constructor Create(const ATradutor: ITradutor);
    destructor Destroy; override;
    procedure Capturar(ARaiz: TComponent);
    procedure Traduzir(const ADestino: string; AoConcluir: TProc<string>);
    procedure Restaurar;
    function QuantidadeTextos: Integer;
  end;

implementation

uses
  System.TypInfo, System.StrUtils, System.Threading;

const
  // Propriedades string consideradas "texto de interface"
  PROPRIEDADES_TEXTO: array[0..4] of string = ('Caption', 'Hint', 'TextHint', 'CaptionOn', 'CaptionOff');
  // Profundidade de sub-objetos (TPersistent) visitados: 1 = Componente.SubObjeto.Prop
  NIVEL_MAXIMO = 1;

{ TTradutorDeForm }

constructor TTradutorDeForm.Create(const ATradutor: ITradutor);
begin
  inherited Create;
  FTradutor := ATradutor;
  FContexto := TRttiContext.Create;
  FTextos := TList<TTextoTraduzivel>.Create;
end;

destructor TTradutorDeForm.Destroy;
begin
  FTextos.Free;
  FContexto.Free;
  inherited;
end;

function TTradutorDeForm.QuantidadeTextos: Integer;
begin
  Result := FTextos.Count;
end;

procedure TTradutorDeForm.LerAtributos(ARaiz: TComponent;
  AExcecoes: TDictionary<TObject, NaoTraduzirAttribute>);
var
  Campo: TRttiField;
  Atributo: TCustomAttribute;
  Componente: TObject;
begin
  // Percorre os CAMPOS da classe do form procurando [NaoTraduzir]
  for Campo in FContexto.GetType(ARaiz.ClassType).GetFields do
  begin
    if (Campo.FieldType = nil) or not Campo.FieldType.IsInstance then
      Continue;
    for Atributo in Campo.GetAttributes do
      if Atributo is NaoTraduzirAttribute then
      begin
        Componente := Campo.GetValue(ARaiz).AsObject;
        if Componente <> nil then
          AExcecoes.AddOrSetValue(Componente, NaoTraduzirAttribute(Atributo));
      end;
  end;
end;

procedure TTradutorDeForm.CapturarObjeto(AObjeto: TObject; AExcecao: NaoTraduzirAttribute;
  ANivel: Integer);
var
  Propriedade: TRttiProperty;
  Texto: TTextoTraduzivel;
  SubObjeto: TObject;
begin
  for Propriedade in FContexto.GetType(AObjeto.ClassType).GetProperties do
  begin
    if (Propriedade.Visibility <> mvPublished) or not Propriedade.IsReadable
      or (Propriedade.PropertyType = nil) then
      Continue;
    // [NaoTraduzir('Caption')] vale para as propriedades do próprio componente
    if (ANivel = 0) and (AExcecao <> nil) and AExcecao.Ignora(Propriedade.Name) then
      Continue;

    case Propriedade.PropertyType.TypeKind of
      tkUString, tkString, tkLString, tkWString:
        if Propriedade.IsWritable and MatchText(Propriedade.Name, PROPRIEDADES_TEXTO) then
        begin
          Texto.Instancia := AObjeto;
          Texto.Propriedade := Propriedade.Name;
          Texto.Original := Propriedade.GetValue(AObjeto).AsString;
          if Trim(Texto.Original) <> '' then
            FTextos.Add(Texto);
        end;

      tkClass:
        if ANivel < NIVEL_MAXIMO then
        begin
          // Sub-objetos como TToggleSwitch.StateCaptions (não componentes, que já são visitados)
          SubObjeto := Propriedade.GetValue(AObjeto).AsObject;
          if (SubObjeto is TPersistent) and not (SubObjeto is TComponent) then
            CapturarObjeto(SubObjeto, nil, ANivel + 1);
        end;
    end;
  end;
end;

procedure TTradutorDeForm.Capturar(ARaiz: TComponent);
var
  Excecoes: TDictionary<TObject, NaoTraduzirAttribute>;
  Excecao: NaoTraduzirAttribute;
  I: Integer;
  Componente: TComponent;
begin
  Inc(FRequisicao);
  FTextos.Clear;
  Excecoes := TDictionary<TObject, NaoTraduzirAttribute>.Create;
  try
    LerAtributos(ARaiz, Excecoes);

    // A própria tela (Caption/Hint do form) e depois cada componente que ela possui
    CapturarObjeto(ARaiz, nil, 0);
    for I := 0 to ARaiz.ComponentCount - 1 do
    begin
      Componente := ARaiz.Components[I];
      if not Excecoes.TryGetValue(Componente, Excecao) then
        Excecao := nil;
      if (Excecao <> nil) and Excecao.IgnoraTudo then
        Continue;
      CapturarObjeto(Componente, Excecao, 0);
    end;
  finally
    Excecoes.Free;
  end;
end;

procedure TTradutorDeForm.Aplicar(const ATextos: TArray<string>);
var
  I: Integer;
begin
  for I := 0 to FTextos.Count - 1 do
    FContexto.GetType(FTextos[I].Instancia.ClassType)
      .GetProperty(FTextos[I].Propriedade)
      .SetValue(FTextos[I].Instancia, ATextos[I]);
end;

procedure TTradutorDeForm.Restaurar;
var
  Originais: TArray<string>;
  I: Integer;
begin
  Inc(FRequisicao);   // descarta traduções ainda em andamento
  SetLength(Originais, FTextos.Count);
  for I := 0 to FTextos.Count - 1 do
    Originais[I] := FTextos[I].Original;
  Aplicar(Originais);
end;

procedure TTradutorDeForm.Traduzir(const ADestino: string; AoConcluir: TProc<string>);
var
  Destino: string;
  Originais: TArray<string>;
  Requisicao, I: Integer;
  Servico: ITradutor;
  Proprio: ITradutorDeForm;
begin
  Destino := ADestino;
  Servico := FTradutor;
  Proprio := Self;            // mantém o serviço vivo enquanto a tarefa roda
  Inc(FRequisicao);
  Requisicao := FRequisicao;

  SetLength(Originais, FTextos.Count);
  for I := 0 to FTextos.Count - 1 do
    Originais[I] := FTextos[I].Original;

  TTask.Run(
    procedure
    var
      Traduzidos: TArray<string>;
      J: Integer;
      Erro: string;
    begin
      SetLength(Traduzidos, Length(Originais));
      try
        for J := 0 to High(Originais) do
          Traduzidos[J] := Servico.Traduzir(Originais[J], Destino, 'pt');
      except
        on E: Exception do
          Erro := E.Message;
      end;

      TThread.Queue(nil,
        procedure
        begin
          if (Proprio = nil) or (Requisicao <> FRequisicao) then
            Exit;           // idioma trocado / restaurado no meio do caminho
          if Erro = '' then
            Aplicar(Traduzidos);
          if Assigned(AoConcluir) then
            AoConcluir(Erro);
        end);
    end);
end;

end.
