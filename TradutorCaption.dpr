program TradutorCaption;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Tradutor.Container in 'Tradutor.Container.pas',
  Tradutor.Interfaces in 'Tradutor.Interfaces.pas',
  Tradutor.Http in 'Tradutor.Http.pas',
  Tradutor.Google in 'Tradutor.Google.pas',
  Tradutor.MyMemory in 'Tradutor.MyMemory.pas',
  Tradutor.Decorators in 'Tradutor.Decorators.pas',
  Tradutor.Idiomas in 'Tradutor.Idiomas.pas',
  Tradutor.FormRtti in 'Tradutor.FormRtti.pas',
  uPrincipal in 'uPrincipal.pas' {frmPrincipal};

{$R *.res}
{$R 'Estilos.res' 'Estilos.rc'}

/// Composition root: o ÚNICO lugar que conhece as classes concretas.
/// Para trocar de API (ex.: DeepL com chave), muda-se só aqui.
procedure RegistrarDependencias;
begin
  Container.Registrar<ITradutor>(
    function: ITradutor
    begin
      Result := TTradutorComCache.Create(
                  TTradutorComFallback.Create(
                    TTradutorGoogle.Create,
                    TTradutorMyMemory.Create));
    end);                                   // singleton: um cache para o app todo

  Container.Registrar<IRepositorioIdiomas>(
    function: IRepositorioIdiomas
    begin
      Result := TRepositorioIdiomasFixo.Create;
    end);

  Container.Registrar<ITradutorDeForm>(
    function: ITradutorDeForm
    begin
      Result := TTradutorDeForm.Create(Container.Resolver<ITradutor>);
    end, cvTransiente);                     // uma instância por tela
end;

begin
  RegistrarDependencias;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
