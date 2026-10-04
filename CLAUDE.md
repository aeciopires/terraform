<!-- TOC -->

- [CLAUDE.md](#claudemd)
  - [1. Sobre este repositório](#1-sobre-este-repositório)
  - [2. Estrutura de diretórios e arquivos](#2-estrutura-de-diretórios-e-arquivos)
  - [3. Idiomas](#3-idiomas)
  - [4. Não invente: a regra central](#4-não-invente-a-regra-central)
  - [5. Contrato de um módulo próprio](#5-contrato-de-um-módulo-próprio)
  - [6. Contrato de uma unidade Terragrunt](#6-contrato-de-uma-unidade-terragrunt)
  - [7. Contrato de um lab](#7-contrato-de-um-lab)
  - [8. Nomes, tags e configuração (inegociável)](#8-nomes-tags-e-configuração-inegociável)
  - [9. Emuladores e nuvem real](#9-emuladores-e-nuvem-real)
  - [10. Versões](#10-versões)
  - [11. Convenções de Markdown](#11-convenções-de-markdown)
  - [12. Fluxo ao adicionar ou alterar algo](#12-fluxo-ao-adicionar-ou-alterar-algo)
  - [13. O que não fazer](#13-o-que-não-fazer)

<!-- TOC -->

# CLAUDE.md

Guia para quem mantém ou amplia este repositório - pessoas ou assistentes
de IA como o Claude Code. Leia antes de alterar um módulo, uma unidade, um
lab ou uma lição.

## 1. Sobre este repositório

`learning-terraform` é uma trilha **pública, para iniciantes**, de
Terraform, OpenTofu e Terragrunt na AWS e no Google Cloud. Tudo roda
primeiro nos emuladores [floci](https://floci.io) (AWS) e
[floci-gcp](https://github.com/floci-io/floci-gcp) (GCP), de graça, e o
**mesmo código** roda na nuvem real trocando apenas variáveis de ambiente.
Não é ligado a nenhuma empresa: nomes e tags usam o produto genérico
`learning-terraform` (prefixo `lt`).

Os diretórios `aws_docker_openproject/`, `docker-wordpress/`,
`docker-zabbix/` e `google_cloud/` são exemplos **legados** (Terraform
0.11), mantidos como histórico: não altere, não inclua no `Makefile`.

## 2. Estrutura de diretórios e arquivos

```text
.
├── README.md REQUIREMENTS.md CONTRIBUTING.md CHANGELOG.md CLAUDE.md LICENSE
├── mise.toml            # versões fixadas de TODAS as ferramentas
├── pyproject.toml uv.lock .python-version   # pacotes Python (uv)
├── docker-compose.yml   # floci 2.1.0 + floci-gcp 0.9.0
├── .env.example         # variáveis dos emuladores (valores falsos)
├── Makefile             # atalhos (REQUIREMENTS.md 5.4)
├── .tflint.hcl .terraform-docs.yml .pre-commit-config.yaml
├── docs/                # lições NN-tema.md + TROUBLESHOOTING.md
├── labs/NN-tema/        # Terraform puro, um conceito por lab
├── modules/<nuvem>-<nome>/      # módulos próprios (seção 5)
├── live/                # Terragrunt (seção 6)
├── scripts/             # check-deps.sh, list_resources.py, floci-gcp-token
└── tests/               # pytest: unitários + smoke/
```

## 3. Idiomas

- **pt-BR**: tudo o que é material didático ou documentação do repositório
  (`README.md`, `REQUIREMENTS.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, este
  arquivo, `docs/`, READMEs de `labs/` e de `live/`).
- **en-US**: código e comentários de código (`.tf`, `.hcl`, `.py`, `.sh`,
  `Makefile`, YAML) e a documentação dos módulos (`modules/**/README.md`),
  para que possam ser reutilizados fora da trilha.

## 4. Não invente: a regra central

1. **Todo recurso, argumento, comando, flag, versão, padrão e
   comportamento vem de uma fonte consultada**: a documentação do
   Terraform/OpenTofu/Terragrunt, a documentação do provider no Registry ou
   no repositório (inclusive o código-fonte, como os nomes das variáveis
   `GOOGLE_*_CUSTOM_ENDPOINT` em `google/services/<produto>/product.go`), a
   documentação da AWS/do GCP, a dos emuladores, a `--help` da ferramenta.
   Não a memória.
2. **Verifique executando.** Um comando só entra na documentação depois de
   rodar (no emulador, ou marcado como "somente nuvem real" com a fonte
   oficial). A saída mostrada é a observada.
3. **Comportamento de emulador é observado, não suposto.** Cada linha da
   tabela "floci vs nuvem real" (`REQUIREMENTS.md`, seção 10) vem de um
   `apply`/`plan` real. Cite a versão do emulador.
4. **Números e versões são o conteúdo mais arriscado**: confira a fonte
   atual (página de releases) e diga que podem mudar.
5. Se algo não puder ser verificado, deixe de fora ou diga explicitamente
   que não foi verificado (como as unidades `network` e `cloud-sql` do GCP,
   validadas com `validate` mas não aplicadas no emulador).

## 5. Contrato de um módulo próprio

`modules/<nuvem>-<nome>/` contém:

1. `versions.tf` com `required_version = ">= 1.10"` e providers com `>=`
   (nunca `=`), **sem** bloco `provider`.
2. `variables.tf`: toda variável com `description`, `type` e, quando a
   nuvem tem limites, `validation` com mensagem citando o limite. Uma
   variável `create` (bool, padrão `true`).
3. `main.tf` com um cabeçalho de comentário listando as referências
   oficiais; `for_each` para coleções.
4. `outputs.tf`: toda saída com `description`.
5. `wrappers/` no padrão dos terraform-aws-modules (`defaults` + `items`,
   `try(each.value.x, var.defaults.x, <padrão do módulo>)`; tags/labels com
   `merge`), com `wrappers/tests/unit.tftest.hcl`.
6. `examples/complete/` aplicável no emulador e na nuvem real.
7. `tests/unit.tftest.hcl` (com `mock_provider`, cobrindo nomes, lógica,
   segurança por padrão e **cada** `validation` com `expect_failures`) e
   `tests/integration.tftest.hcl` (sem mock, no emulador). Os testes do
   wrapper **não** ficam em `tests/` da raiz (TROUBLESHOOTING).
8. `README.md` em en-US: descrição, diagrama Mermaid, uso (direto,
   wrapper, Terragrunt), testes, notas - e o bloco gerado pelo
   terraform-docs entre `<!-- BEGIN_TF_DOCS -->` e `<!-- END_TF_DOCS -->`
   (`make docs`). Nunca edite o bloco gerado.
9. Achados do trivy são corrigidos ou suprimidos com
   `#trivy:ignore:<ID>` **acompanhado do motivo** em comentário.

## 6. Contrato de uma unidade Terragrunt

- Caminho: `live/<nuvem>/<conta>/<ambiente>/<região>/<unidade>/terragrunt.hcl`.
- `include "root"` (`find_in_parent_folders("root.hcl")`, `expose = true`)
  e, quando o componente existe em vários ambientes, `include "envcommon"`
  com `merge_strategy = "deep"`.
- A unidade contém **só o que é específico**; o comum vai para
  `live/_envcommon/<nuvem>/<componente>.hcl`.
- Um `_envcommon` lê `common.hcl`, `account.hcl`, `env.hcl`, `region.hcl`
  com `find_in_parent_folders` - **nunca** o `root.hcl` (TROUBLESHOOTING).
- **Nenhum `inputs` no `root.hcl`** (colide com variáveis de módulos).
- `dependency` sempre com `mock_outputs` restritos a
  `["init", "validate", "plan"]`.
- Fonte de módulo público fixada (`tfr:///...?version=X`); módulo próprio
  com `${get_repo_root()}/modules/<nome>` (ou `//wrappers`).
- Versão de provider diferente da nuvem: `provider_version_overrides` no
  `cloud.hcl`, nunca um `generate "versions"` repetido.
- Unidade que o emulador não suporta: `exclude { if = local.is_floci ... }`
  com comentário explicando a limitação e a versão do emulador.

## 7. Contrato de um lab

`labs/NN-tema/`: `versions.tf` (versões exatas), `providers.tf` (sem nada
específico de emulador), `variables.tf`, `main.tf` (cabeçalho com
referências), `outputs.tf`, `envs/*.tfvars` quando houver ambientes,
`tests/` (unitário com mock e/ou integração) e um `README.md` em pt-BR com:
objetivo, diagrama, passo a passo com a saída observada, verificação por
CLI, exercícios (executados antes de publicados), testes, nuvem real
(opcional, custo) e limpeza.

## 8. Nomes, tags e configuração (inegociável)

- Nomes: `<prefixo>-<ambiente>-<componente>[-<propósito>]`; recursos de
  nome global incluem conta/projeto e região.
- Ambientes: `dev`, `stg`, `prd`.
- Tags/labels vêm **só** do provider (`default_tags`/`default_labels`
  gerados pelo `live/root.hcl`); a lista está no `REQUIREMENTS.md`, seção 8.
- Nada de conta, região, zona, CIDR, tamanho ou porta "chumbado" em módulo:
  tudo é variável, e na stack vem da hierarquia
  `common.hcl → cloud.hcl → account.hcl → env.hcl → region.hcl`.
- Diferenças só do emulador são **variáveis com o padrão da nuvem real**,
  ativadas pelo `target = "floci"` (Terragrunt) ou por um
  `envs/floci.tfvars` (labs), com comentário explicando o porquê.

## 9. Emuladores e nuvem real

- Código nunca contém `endpoints {}`, `skip_*` ou `*_custom_endpoint`: o
  destino vem de variáveis de ambiente (`.env.example`) ou do
  `extra_arguments` do `live/root.hcl`.
- Toda API usada pelo provider Google precisa de um
  `GOOGLE_<PRODUTO>_CUSTOM_ENDPOINT` no emulador; caso contrário a chamada
  vai para o Google real.
- No floci-gcp, **não** usar `--backend-bootstrap` (TROUBLESHOOTING).
- Cada mudança é aplicada no emulador antes de ser considerada pronta:
  apply, verificação por CLI, `plan` (idempotência), destroy.

## 10. Versões

- Ferramentas no `mise.toml`, providers em `live/<nuvem>/cloud.hcl` e nos
  `versions.tf` dos labs, módulos públicos nos `_envcommon`, Python no
  `pyproject.toml`/`uv.lock`, emuladores no `docker-compose.yml`.
- Ao atualizar: ler o CHANGELOG, atualizar todos os lugares (inclusive a
  tabela "Versões utilizadas" do `README.md` e o `REQUIREMENTS.md`), rodar
  `make test-all`, aplicar `live/` no emulador e registrar no `CHANGELOG.md`.

## 11. Convenções de Markdown

- TOC manual entre marcadores `<!-- TOC -->` no topo de todo arquivo com
  mais de ~3 seções; âncoras no padrão do GitHub (minúsculas; remove tudo
  que não for letra, número, espaço, `-` ou `_`; espaços viram `-`;
  acentos são mantidos).
- Links relativos; toda lição termina com `## Referências` (só fontes
  oficiais).
- **Diagramas em Mermaid** (` ```mermaid `), que o GitHub renderiza - sem
  arquivos de imagem para manter sincronizados. Apenas `flowchart`,
  `sequenceDiagram` ou `stateDiagram-v2`; rótulos entre aspas duplas,
  `<br/>` para quebra de linha, `{placeholder}` em vez de `<placeholder>`,
  nenhum id de nó que seja palavra-chave do Mermaid (`end`, `call`,
  `class`, `style`, ...). Renderize antes de publicar
  (`npx -p @mermaid-js/mermaid-cli mmdc -i diagrama.mmd -o diagrama.svg`).
- Comandos copiáveis, com a saída esperada em comentário quando ajudar;
  placeholders como `<seu-projeto>`.
- Toda analogia acompanha o conceito técnico, nunca o substitui.

## 12. Fluxo ao adicionar ou alterar algo

1. Consulte as fontes (seção 4).
2. Escreva o código seguindo o contrato (seções 5-7).
3. `make fmt validate lint security`.
4. Escreva os testes; confira que um teste **falha** quando você quebra o
   que ele verifica.
5. Aplique no emulador, execute cada comando que vai documentar, anote
   cada diferença em relação à nuvem real, destrua.
6. Escreva/atualize a documentação; `make docs`.
7. `make test-all` (e `make test-smoke` se mexeu em `live/`).
8. Atualize `README.md`, a lição correspondente, `TROUBLESHOOTING.md` (se
   apareceu um erro novo) e `CHANGELOG.md`.
9. Git: branch padrão `master`; **não faça commit nem push sem pedido
   explícito**.

## 13. O que não fazer

- Não invente recurso, argumento, flag, versão, padrão ou comportamento.
- Não coloque bloco `provider` em módulo reutilizável, nem `inputs` no
  `root.hcl`.
- Não "chumbe" contas, regiões, CIDRs, portas ou tags.
- Não documente um comando que não executou (ou marque como "somente nuvem
  real", com a fonte).
- Não deixe `.terraform/`, lock files ou state dentro de `modules/`.
- Não use `latest` em versões fixadas, exceto onde o upstream só publica
  assim (e diga isso).
- Não altere os exemplos legados nem o `LICENSE` sem pedido.
- Não faça commit ou push sem pedido.
