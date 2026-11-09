# Tradução Delphi

Tela VCL (Delphi 12) que traduz um texto — e a própria interface — para 31 idiomas em tempo de execução.

Projeto de estudo de três conceitos: **interface**, **RTTI** e **injeção de dependência**.

## Como abrir

Abra `TradutorCaption.dpr` no RAD Studio 12, compile (Win32) e execute. Precisa de internet.

## Arquivos

| Unit | O que faz |
|---|---|
| `Tradutor.Interfaces` | A interface `ITradutor` e o atributo `[NaoTraduzir]` |
| `Tradutor.Servicos` | `TTradutorGoogle` (internet) e `TTradutorFalso` (offline, para testar) |
| `Tradutor.Tela` | `TTradutorDeTela`: lê e grava os textos do form via RTTI |
| `Tradutor.Idiomas` | Lista dos idiomas |
| `uPrincipal` | A tela |

## Os três conceitos

**1. Interface** — a tela só conhece o contrato, não sabe quem traduz:

```pascal
ITradutor = interface
  function Nome: string;
  function Traduzir(const ATexto, AIdioma: string): string;
end;
```

**2. RTTI** — `TTradutorDeTela` percorre os componentes do form e pergunta a cada um
"você tem `Caption`, `Hint` ou `TextHint`?". Quem não deve ser traduzido é marcado no form:

```pascal
[NaoTraduzir] lblCaption: TLabel;
```

**3. Injeção de dependência** — a tela não cria o tradutor; o `.dpr` entrega pronto:

```pascal
frmPrincipal.Tradutor := TTradutorGoogle.Create;
// frmPrincipal.Tradutor := TTradutorFalso.Create;   // testar sem internet
```

## Fluxo da tradução (`TfrmPrincipal.Traduzir`)

1. Sem idioma escolhido (ou Português)? Mostra o texto original.
2. Separa o texto do cartão e, se a chave "Traduzir interface" estiver ligada, os textos da tela.
3. Traduz tudo em segundo plano (`TTask.Run`), sem travar a tela.
4. Mostra o resultado na thread principal (`TThread.Queue`).

> O endpoint do Google usado aqui não é oficial e pode limitar requisições.
