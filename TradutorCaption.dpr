program TradutorCaption;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Tradutor.Interfaces in 'Tradutor.Interfaces.pas',
  Tradutor.Servicos in 'Tradutor.Servicos.pas',
  Tradutor.Tela in 'Tradutor.Tela.pas',
  Tradutor.Idiomas in 'Tradutor.Idiomas.pas',
  uPrincipal in 'uPrincipal.pas' {frmPrincipal};

{$R *.res}
{$R 'Estilos.res' 'Estilos.rc'}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);

  // CONCEITO 3 - INJEÇÃO DE DEPENDÊNCIA
  // Quem escolhe o tradutor é o programa, não a tela. Para testar sem internet,
  // troque pela linha de baixo: a tela continua igual.
  frmPrincipal.Tradutor := TTradutorGoogle.Create;
  // frmPrincipal.Tradutor := TTradutorFalso.Create;

  Application.Run;
end.
