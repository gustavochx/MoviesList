# MoviesList

App iOS em SwiftUI que lista, busca e detalha filmes usando a API do [TMDB](https://developer.themoviedb.org/docs/getting-started). O projeto segue arquitetura modular: pacotes Swift locais, MVVM com coordinators e interactors, e um design system próprio.

## Funcionalidades

- **Filmes populares** com paginação infinita; se a próxima página falhar, o rodapé oferece uma nova tentativa.
- **Busca** pela barra fixa no topo, com debounce de 300 ms.
- **Detalhe do filme**: banner, pôster, título, tagline, ano, duração, gêneros, nota com número de votos, sinopse e elenco principal (até 15 pessoas).
- **Estados de tela** mapeados: carregando, vazio, erro (sem conexão, chave da API ausente ou genérico) e filme não encontrado.

## Requisitos

- Xcode 26.6 ou mais recente, com o SDK do iOS 26.5. O app tem iOS 26.5 como alvo; os pacotes em `Modules/` mantêm iOS 17 como mínimo.
- Swift 6, com checagem completa de concorrência (*complete data-race checking*).
- [SwiftLint](https://github.com/realm/SwiftLint): `brew install swiftlint`.
- `jq`, usado pelos hooks do Claude Code (já incluso no macOS recente).
- Uma chave de API do TMDB (a "API Key", não o *read access token*).

## Configuração

1. Crie o arquivo de segredos, que está no `.gitignore`, e preencha `TMDB_API_KEY`:
   ```bash
   cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
   ```
   Sem ele o app ainda compila, mas mostra o estado "TMDB API key missing".
2. Ative os git hooks (uma vez por clone):
   ```bash
   git config core.hooksPath tools/git-hooks
   ```

A chave acaba embutida no binário do app, então trate-a como uma chave de cliente pública: os cuidados abaixo evitam que ela vá parar no repositório, não que seja extraída do app.

## Executar e testar

Abra `MoviesList.xcodeproj` e rode o scheme `MoviesList`, ou use a linha de comando. Se o `xcode-select` apontar para as CommandLineTools, prefixe os comandos com `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

```bash
# App e testes de integração (MoviesListTests)
xcodebuild -project MoviesList.xcodeproj -scheme MoviesList -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Pacotes: o scheme tem o nome do pacote; Cores tem vários produtos e usa Cores-Package
(cd Modules/Interfaces && xcodebuild test -scheme Interfaces -destination 'platform=iOS Simulator,name=iPhone 17 Pro')
(cd Modules/Cores && xcodebuild test -scheme Cores-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro')
(cd Modules/Experiences && xcodebuild test -scheme Experiences -destination 'platform=iOS Simulator,name=iPhone 17 Pro')
(cd Modules/UI && xcodebuild test -scheme UI -destination 'platform=iOS Simulator,name=iPhone 17 Pro')

# Uma única suíte: acrescente -only-testing:<TestTarget>/<Suite>, por exemplo
# -only-testing:MovieListFeatureTests/LoadFailureTests

sh tools/architecture/check.sh   # regras de dependência entre módulos
sh tools/lint.sh                 # SwiftLint em modo estrito
```

Uma mudança está pronta quando o app compila e seus testes passam, os testes de todo pacote alterado passam, o `check.sh` reporta 0 erros e o `lint.sh` reporta 0 violações.

## Arquitetura

O código fica em pacotes Swift locais dentro de `Modules/`; o app é a raiz de composição.

| Pacote | Módulos | Papel | Quem pode importar |
|---|---|---|---|
| `Interfaces` | `MoviesDomainInterface` | modelos e protocolos (`MoviesService`, `MovieRepository`) | todos |
| `Cores` | `MoviesDomain` | regras de domínio (`LiveMoviesService`) | só o app e os testes |
| `Cores` | `MoviesData` | acesso ao TMDB (`TMDBMovieRepository`, `HTTPClient`, DTOs e mappers) | só o app e os testes |
| `Cores` | `FoundationExtensions` | extensões fundacionais da Foundation | cores, UI, features, app e testes |
| `Experiences` | `MovieListFeature` | a feature de lista, busca e detalhe | só o app |
| `UI` | `DesignSystem` | tokens e componentes visuais genéricos | features e app |

Cada tela segue MVVM + Coordinators + Interactors:

```
AppCoordinator (app)  ──cria──▶  <Feature>FeatureEntry(dependencies, outputs)
                                       │
                                <Feature>Coordinator   navegação dentro da feature
                                       │ cria
                   View ──▶ ViewModel ──▶ Interactor ──▶ MoviesService (interface) ──▶ MovieRepository (interface) ◀── MoviesData
```

- A **View** só renderiza o estado e repassa as ações do usuário.
- O **ViewModel** (`@Observable`, `@MainActor`) conversa apenas com o protocolo do interactor.
- O **Interactor** chama o domínio pelas interfaces.
- O **Coordinator** cuida da navegação dentro da feature; sair dela passa pelos `Outputs`.
- O **`AppCoordinator`** cria as implementações concretas e monta cada feature.

Features importam só módulos `*Interface`, o `DesignSystem` e cores fundacionais, nunca outras features nem cores concretos. Os detalhes (regras, estrutura de pastas, como criar uma feature) estão em [docs/architecture.md](docs/architecture.md), em inglês.

## Design system

O `DesignSystem` (`Modules/UI`) reúne os tokens (`DSSpacing`, `DSRadius`, `DSColor`, `DSFont`) e componentes como `LoadingStateView`, `EmptyStateView`, `ErrorStateView`, `LoadFailureView`, `RatingView`, as variações de `RemoteImage` e `TitledSection`. Features e app usam esses tokens e componentes em vez de valores literais; as regras e um grep de verificação estão em [.claude/rules/design-system.md](.claude/rules/design-system.md). O módulo importa só SwiftUI e não conhece tipos de domínio nem textos do app.

## Qualidade e segurança

- **SwiftLint** em modo estrito (`tools/lint.sh`), configurado em `.swiftlint.yml`; também roda como fase de build no Xcode.
- **`check.sh`** valida o grafo de módulos. Ele usa uma skill local do mantenedor (`ios-modularization`) e é pulado quando ela não está instalada.
- **Proteção da chave do TMDB**, em camadas. Funcionam como rede de segurança contra acidentes, não como garantia:
  - git hooks `pre-commit` e `pre-push`, que rodam `tools/secrets/scan.sh` nas mudanças;
  - hooks do Claude Code em `.claude/hooks/`, que bloqueiam a leitura do arquivo de segredos pelo nome;
  - o workflow `pr-checks` no CI, que repete a varredura em cada PR.
- **Template de PR** (`.github/pull_request_template.md`): o mesmo workflow confere se as seções foram mantidas, se o resumo foi preenchido e se algum tipo foi marcado.
- Para que essas verificações bloqueiem o merge, a branch `main` precisa de uma regra de proteção que exija os checks `template` e `secrets`. Isso é configurado manualmente no GitHub.

## Desenvolvimento com Claude Code

O repositório traz configuração para o [Claude Code](https://claude.com/claude-code):

- agentes especializados em `.claude/agents/` (arquitetura, SwiftUI, concorrência, testes e revisão);
- os comandos `/ios-review`, que revisa a branch, e `/branch-report`, que gera um relatório de antes e depois (este depende de uma skill local do mantenedor);
- skills vendorizadas em `.claude/skills/`, com origem e versão em `.claude/skills/UPSTREAM.md`.

As convenções do projeto para o Claude estão no [CLAUDE.md](CLAUDE.md).

## Contribuindo

- Crie branches no formato `feature/<nome>` e abra PRs para `main` usando o template.
- Testes usam Swift Testing (`import Testing`), não XCTest.
- Rode os comandos de "Executar e testar" antes de abrir o PR.

## Créditos

Dados e imagens de filmes fornecidos pelo [TMDB](https://www.themoviedb.org).

> This product uses the TMDB API but is not endorsed or certified by TMDB.
>
> (Este produto usa a API do TMDB, mas não é endossado nem certificado pelo TMDB.)

## Próximos passos

Com mais tempo, eu levaria o app a funcionar bem sem internet e daria ao usuário uma forma de guardar os filmes de que gosta.
A arquitetura atual já deixa espaço para isso sem mexer nas features existentes.

### Offline e cache das respostas

- **Começar pelo cache HTTP do sistema:** aumentar o `URLCache.shared` na inicialização do app, com limites modestos (por exemplo, 20 MB em memória e 100 MB em disco; são tetos, não espaço reservado, e o iOS pode liberá-lo quando precisar). As respostas da API e as imagens carregadas pelo `AsyncImage` do `RemoteImage` ficam salvas em disco, sem código novo para imagens, e o app deixa de baixar de novo o que já tem, o que reduz o consumo de dados.
- **Usar o cache quando não houver rede:** no `TMDBMovieRepository`, quando a requisição falhar com `MoviesError.offline`, repetir a mesma `URLRequest` com `cachePolicy = .returnCacheDataDontLoad` e devolver o que estiver salvo. São poucas linhas em um único lugar; domínio, interactors e telas não mudam.
- **Experiência sem internet:** em vez da tela de erro "Você está offline", mostrar o conteúdo salvo com um aviso discreto ("Sem conexão — exibindo dados salvos") e atualizar sozinho quando a conexão voltar (monitorando a rede com `NWPathMonitor`, atrás de uma interface).
- **Quando evoluir:** se o app precisar de mais controle do que o `URLCache` oferece (validade por tipo de dado, saber o que está salvo, busca offline nos dados guardados), aí sim um `CachingMovieRepository` como decorator do `MovieRepository`, com persistência própria em um core fundacional. A troca fica restrita ao `AppCoordinator`.

### Favoritos

- **Novo par de módulos** `FavoritesInterface` (protocolo `FavoritesStore`: favoritar, desfavoritar, listar e observar mudanças) e `FavoritesDomain` (implementação persistida localmente). Assim as features continuam dependendo só de interfaces.
- **Favoritar no detalhe:** um botão de coração no detalhe do filme e uma marca na linha da lista.
- **Lista de favoritos** como uma nova feature (`FavoritesFeature`), montada pelo `AppCoordinator` em abas ao lado da lista, sem uma feature importar a outra.
- **Funciona offline:** cada favorito guarda os dados necessários para exibir o filme (título, ano, nota, pôster), não só o id.

### Localization (i18n)

- **Base pronta:** os textos já usam `LocalizedStringKey` e `String(localized:)`, e números e datas já seguem a região do aparelho. Falta só traduzir: criar um String Catalog (`Localizable.xcstrings`) e acrescentar o pt-BR.
- **Textos dos pacotes:** declarar `defaultLocalization` nos pacotes `Experiences` e `UI`, cada um com o próprio catálogo, e usar `bundle: .module`. Hoje esses textos são procurados no bundle do app.
- **Conteúdo do TMDB no idioma do usuário:** trocar o `language` fixo em `en-US` do `TMDBConfiguration` pelo idioma preferido do aparelho, tratando sinopses que vierem vazias quando não houver tradução.

### Cuidados

- Confirmar se os cabeçalhos de cache do TMDB permitem armazenar as respostas e definir quanto tempo cada dado vale, sem mostrar dados velhos como se fossem atuais.
- Cobrir com Swift Testing: o fallback para o cache com um `HTTPClient` falso que simula a falta de rede e confere a segunda requisição, e o `FavoritesStore` com um armazenamento em memória.

