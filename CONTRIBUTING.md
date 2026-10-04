<!-- TOC -->

- [Contribuindo](#contribuindo)
  - [Regras básicas](#regras-básicas)
  - [Fluxo de desenvolvimento](#fluxo-de-desenvolvimento)
  - [Adicionando um lab, um módulo ou uma unidade](#adicionando-um-lab-um-módulo-ou-uma-unidade)
  - [Atualizando versões](#atualizando-versões)
  - [Abrindo um pull request](#abrindo-um-pull-request)
  - [Reportando problemas](#reportando-problemas)

<!-- TOC -->

# Contribuindo

Obrigado pelo interesse! Esta é uma trilha para iniciantes em Terraform,
OpenTofu e Terragrunt. Toda contribuição é bem-vinda: um erro de digitação,
uma explicação mais clara, uma analogia melhor, um comando que faltou, um
comportamento novo do floci que você observou, um módulo ou um lab novo.

## Regras básicas

1. **Primeiro nos emuladores.** Todo código roda no floci/floci-gcp; a
   nuvem real é opcional e o custo deve ser dito
   ([`REQUIREMENTS.md`](REQUIREMENTS.md)).
2. **Não invente.** Recursos, argumentos, comandos, versões e
   comportamentos vêm de uma fonte consultada, e os comandos documentados
   foram executados ([`CLAUDE.md`, seção 4](CLAUDE.md#4-não-invente-a-regra-central)).
3. **Mesmo código para emulador e nuvem real**: sem `endpoints {}` ou
   `skip_*` no código ([`CLAUDE.md`, seção 9](CLAUDE.md#9-emuladores-e-nuvem-real)).
4. **Siga os contratos** de módulo, unidade e lab
   ([`CLAUDE.md`, seções 5-7](CLAUDE.md#5-contrato-de-um-módulo-próprio)).
5. **Idiomas:** documentação didática em pt-BR; código, comentários e
   READMEs de módulos em en-US ([`CLAUDE.md`, seção 3](CLAUDE.md#3-idiomas)).

## Fluxo de desenvolvimento

```bash
mise install && make install        # ferramentas e pacotes
make check                          # sistema e ferramentas
cp .env.example .env
make floci-start floci-bootstrap    # emuladores e buckets de state
pre-commit install                  # hooks (opcional, recomendado)

make test                           # fmt, validate, lint, security, docs, unitários, Python
make test-integration               # módulos e labs nos emuladores
make tg-apply ENV=dev && make test-smoke && make tg-destroy ENV=dev
make test-all                       # tudo, com tofu e terraform
```

## Adicionando um lab, um módulo ou uma unidade

1. Leia o [`CLAUDE.md`](CLAUDE.md) e um exemplo existente do mesmo tipo.
2. Consulte a documentação de cada recurso/módulo que vai usar.
3. Crie os arquivos seguindo o contrato; escreva os testes.
4. Aplique no emulador, rode cada comando que vai documentar e anote
   diferenças em relação à nuvem real na tabela do
   [`REQUIREMENTS.md`, seção 10](REQUIREMENTS.md#10-floci-vs-nuvem-real).
5. `make docs` (módulos) e `make test-all`.
6. Atualize a lição correspondente, o [`README.md`](README.md), o
   [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) (se apareceu um
   erro novo) e o [`CHANGELOG.md`](CHANGELOG.md), em "Não lançado".

## Atualizando versões

- **Ferramentas** ([`mise.toml`](mise.toml)): confira a página de release,
  leia o CHANGELOG, atualize o `mise.toml`, o
  [`scripts/check-deps.sh`](scripts/check-deps.sh) e as tabelas do
  `README.md`/`REQUIREMENTS.md`; `mise install && make test-all`.
- **Providers** ([`live/aws/cloud.hcl`](live/aws/cloud.hcl),
  [`live/gcp/cloud.hcl`](live/gcp/cloud.hcl) e os `versions.tf` dos labs e
  exemplos): `make tg-plan` em todas as stacks para ver o efeito.
- **Módulos públicos** (`live/_envcommon/`): leia o CHANGELOG do módulo
  (*major* muda a interface), confira o `versions.tf` dele (restrições de
  provider) e rode `make tg-plan`.
- **Emuladores** ([`docker-compose.yml`](docker-compose.yml)): reaplique
  todas as stacks, refaça a tabela "floci vs nuvem real" e reveja as
  exclusões/ajustes feitos só para o emulador (por exemplo, a unidade
  `network` do GCP, se o Compute Engine passar a existir).

## Abrindo um pull request

1. Crie uma branch a partir de `master`.
2. Siga as regras básicas e rode as verificações acima.
3. Explique **por que** a mudança é útil e cite as fontes oficiais usadas.

## Reportando problemas

Abra uma *issue* no GitHub com: o lab/unidade/módulo, o comando exato, a
saída completa, o sistema operacional, a saída de `make check` e se foi no
emulador (com a versão) ou na nuvem real.
