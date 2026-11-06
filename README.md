# Tradução Delphi

Tela VCL (Delphi 12) que traduz um texto — e a própria interface — para 31 idiomas em tempo de execução, usando API de tradução.

Projeto de estudo de **interfaces**, **RTTI + atributos** e **injeção de dependência** em Delphi.

## Como abrir

1. Abra `TradutorCaption.dpr` no RAD Studio 12.
2. Build (Win32) e execute. Precisa de internet para traduzir.

## Como funciona

```
Usuário escolhe idioma → ITradutor → Cache → Google → (falhou?) MyMemory → caption
```

A chamada HTTP roda em `TTask.Run` e o resultado volta pela `TThread.Queue`, então a tela não trava.

| Unit | Responsabilidade |
|---|---|
| `Tradutor.Interfaces` | Contratos `ITradutor`, `IRepositorioIdiomas`, `ITradutorDeForm` e o atributo `[NaoTraduzir]` |
| `Tradutor.Google` | Endpoint público do Google Translate (sem chave, não oficial) |
| `Tradutor.MyMemory` | API MyMemory, usada como reserva (sem chave) |
| `Tradutor.Decorators` | `TTradutorComCache` (thread-safe) e `TTradutorComFallback` |
| `Tradutor.Idiomas` | Lista dos idiomas e filtro da busca |
| `Tradutor.FormRtti` | Descobre e traduz os textos de qualquer form via RTTI |
| `Tradutor.Container` | Container de DI próprio (`Registrar<T>` / `Resolver<T>`) |
| `Tradutor.Http` | GET HTTP compartilhado |
| `uPrincipal` | A tela |

### Injeção de dependência

O `TradutorCaption.dpr` é o único lugar que conhece as classes concretas:

```pascal
Container.Registrar<ITradutor>(
  function: ITradutor
  begin
    Result := TTradutorComCache.Create(
      TTradutorComFallback.Create(TTradutorGoogle.Create, TTradutorMyMemory.Create));
  end);
```

Trocar de API (ex.: DeepL com chave) é mudar só esse trecho.

### RTTI

`FTradutorDeForm.Capturar(Self)` percorre os componentes e encontra sozinho `Caption`, `Hint`, `TextHint` e `StateCaptions`. O form só marca as exceções:

```pascal
[NaoTraduzir] lblCaption: TLabel;            // ignora o componente
[NaoTraduzir('Caption')] lblFechar: TLabel;  // ignora só o Caption (o Hint traduz)
```

## Observação

O endpoint do Google usado aqui não é oficial e pode limitar requisições. Para produção, implemente `ITradutor` com uma API oficial (Google Cloud Translation, DeepL, Azure Translator).
