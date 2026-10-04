<!-- TOC -->

- [09 - Boas práticas](#09---boas-práticas)
  - [Código](#código)
  - [Módulos](#módulos)
  - [Versões e dependências](#versões-e-dependências)
  - [State](#state)
  - [Terragrunt e DRY](#terragrunt-e-dry)
  - [Segurança](#segurança)
  - [Nomes, tags e custos](#nomes-tags-e-custos)
  - [Testes e qualidade](#testes-e-qualidade)
  - [Fluxo de trabalho](#fluxo-de-trabalho)
  - [Referências](#referências)

<!-- TOC -->

# 09 - Boas práticas

Cada prática traz **por quê** e **onde** ela aparece neste repositório.
Uma prática sem motivo vira ritual; com motivo, vira critério.

## Código

| Prática | Por quê | Onde |
|---|---|---|
| `terraform fmt` sempre | diffs pequenos e revisões focadas no que importa | `make fmt`, pre-commit |
| arquivos separados: `versions.tf`, `variables.tf`, `outputs.tf`, `main.tf` | qualquer pessoa sabe onde procurar | todos os módulos e labs |
| `for_each` para coleções, `count` só para ligar/desligar | remover um item não recria os outros | [lição 02](02-hcl-basico.md#count-vs-for_each) |
| `validation` nas variáveis com os limites da nuvem | erro no `plan`, com mensagem clara, antes de qualquer chamada | `modules/*/variables.tf` |
| `description` em toda variável e saída | vira documentação (terraform-docs) | tflint exige |
| `locals` para expressões repetidas | uma fonte da verdade | `name_prefix` |
| `moved`/`import`/`removed` em vez de `state mv/rm` | refatoração revisável em *pull request* | [lição 03](03-state-e-backends.md) |
| comentários explicam o **porquê**, não o quê | o código já diz o quê | `_envcommon/*.hcl` |

## Módulos

| Prática | Por quê | Onde |
|---|---|---|
| sem bloco `provider` em módulo reutilizável | quem chama decide região, conta e endpoint (é o que permite rodar no floci e na nuvem) | `modules/` |
| `required_providers` com `>=` no módulo, `=` no root | módulos combináveis; root reprodutível | [lição 04](04-providers-e-floci.md#fixando-versões) |
| interface pequena com padrões seguros (`optional(tipo, padrão)`) | quem usa escreve só o que difere | `queues`, `subscriptions` |
| interruptor `create` | desligar uma instância sem apagar a configuração; usado pelo wrapper | `aws-messaging`, `gcp-messaging` |
| wrapper para muitas instâncias | DRY e uma unidade Terragrunt para N instâncias | `modules/*/wrappers` |
| instância "diferente" fora do loop | o wrapper não vira um saco de exceções | unidade `orders-messaging` |
| `examples/` aplicáveis | documentação que comprovadamente funciona | `examples/complete` |
| prefira módulos públicos maduros para o comum | menos código para manter | `terraform-aws-modules`, `terraform-google-modules` |
| leia o `versions.tf` dos módulos públicos | descobrir limites como `google < 8` antes do erro | [lição 06](06-terragrunt.md#versões-de-provider-por-unidade) |

## Versões e dependências

| Prática | Por quê | Onde |
|---|---|---|
| fixar as ferramentas (mise) | todos rodam as mesmas versões | [`mise.toml`](../mise.toml) |
| fixar providers e módulos (`version`, `?ref=`, `?version=`) | `init` amanhã = `init` hoje | todo o repositório |
| versionar o `.terraform.lock.hcl` dos root modules | garante os mesmos binários (hashes) | **exceção consciente aqui**: dois binários, dois registries ([lição 04](04-providers-e-floci.md#o-lock-file)) |
| atualizar com intenção: ler o CHANGELOG, depois `plan` | upgrades de *major* mudam comportamento | [`CONTRIBUTING.md`](../CONTRIBUTING.md#atualizando-versões) |

## State

| Prática | Por quê | Onde |
|---|---|---|
| backend remoto com lock (`use_lockfile`), versionamento e criptografia | trabalho em equipe, "desfazer", segredos protegidos | `live/root.hcl` |
| um state por unidade | raio de explosão pequeno, planos rápidos | `key = path_relative_to_include()` |
| nunca versionar `*.tfstate` | contém segredos e muda a cada apply | [`.gitignore`](../.gitignore) |
| bucket de state com acesso restrito | quem lê o state lê as senhas geradas | - |

## Terragrunt e DRY

| Prática | Por quê | Onde |
|---|---|---|
| `root.hcl` (não `terragrunt.hcl`) na raiz | recomendação atual do Terragrunt; deixa claro o que é unidade | [`live/root.hcl`](../live/root.hcl) |
| hierarquia nuvem/conta/ambiente/região, um arquivo por nível | cada valor tem um único lugar | [lição 06](06-terragrunt.md#a-hierarquia-nuvem--conta--ambiente--região) |
| `_envcommon` por componente | ambientes iguais por construção | `live/_envcommon/` |
| unidade mínima (só o que é específico) | revisão rápida; diferenças entre ambientes saltam aos olhos | `live/*/*/*/*/*/terragrunt.hcl` |
| nada de `inputs` globais no root | podem colidir com variáveis de módulos públicos | [TROUBLESHOOTING](TROUBLESHOOTING.md#name-conflicts-with-name_prefix-no-módulo-alb) |
| `mock_outputs` restritos a `init`/`validate`/`plan` | planejar antes de aplicar, sem aplicar valores falsos | `_envcommon/aws/*.hcl` |
| `exclude` em vez de apagar unidades | a mesma árvore serve a ambientes diferentes | `network`, `cloud-sql` |
| a conta decide o destino das chamadas (`extra_arguments`) | nada de "esqueci o `AWS_ENDPOINT_URL` no shell" | `live/root.hcl` |

## Segurança

| Prática | Por quê | Onde |
|---|---|---|
| `allowed_account_ids` no provider AWS | impede aplicar na conta errada | `live/root.hcl` |
| criptografia em repouso por padrão | requisito básico de quase toda norma | SSE-SQS, SSE-S3, `ssl_mode` no Cloud SQL |
| bloqueio de acesso público em buckets | vazamento de dados por bucket público é clássico | `_envcommon/aws/s3.hcl`, `public_access_prevention` |
| privilégio mínimo entre componentes | o banco aceita só o serviço que precisa dele | `sg-database` (5432 só do ECS) |
| senhas geradas e guardadas pelo serviço | nada de senha em `.tfvars` ou no git | RDS `manage_master_user_password` (Secrets Manager) |
| `trivy config` e decisões registradas | achados tratados ou justificados, nunca ignorados em silêncio | `#trivy:ignore:AWS-0095` comentado |
| `deletion_protection`/`prevent_destroy` em produção | erro humano não apaga dados | `rds`, `cloud-sql`, `alb` com `is_prd` |
| nunca credenciais no código | use SSO/perfis, `gcloud auth`, OIDC na CI | `.env` só com valores falsos do emulador |

## Nomes, tags e custos

| Prática | Por quê | Onde |
|---|---|---|
| convenção de nomes `<prefixo>-<ambiente>-<componente>` | dá para listar e filtrar tudo de um ambiente | `list_resources.py --prefix lt-dev` |
| nomes globais com conta/projeto e região | buckets precisam ser únicos no mundo | `lt-dev-000000000000-us-east-1-assets` |
| tags/labels padrão pelo provider | ninguém esquece; custo por produto/time/ambiente | `default_tags`, `default_labels` |
| economizar fora de produção | NAT único, instâncias menores, sem Multi-AZ em `dev` | `single_nat_gateway`, `env.hcl` |
| destruir o que não usa | nuvem cobra por hora | `make tg-destroy` |

## Testes e qualidade

| Prática | Por quê | Onde |
|---|---|---|
| a pirâmide: barato e frequente embaixo | feedback rápido; integração só quando vale | [lição 07](07-testes.md) |
| testes unitários com mocks em todo módulo | lógica testada em segundos, sem nuvem | `tests/unit.tftest.hcl` |
| testar as validações (`expect_failures`) | uma validação nunca testada pode estar errada | todos os módulos |
| integração em emulador antes da nuvem | errar de graça | `make test-integration` |
| idempotência (`plan` limpo após `apply`) | prova que o código descreve a realidade | `make tg-drift` |
| documentação gerada e verificada | README nunca desatualizado | `make docs-check` |
| hooks de pre-commit | os problemas param antes do commit | [`.pre-commit-config.yaml`](../.pre-commit-config.yaml) |

## Fluxo de trabalho

1. Crie uma branch.
2. Escreva o código e os testes; `make test`.
3. Aplique no emulador: `make tg-apply ENV=dev`, `make test-smoke`.
4. Abra o *pull request* com o `plan` da nuvem real (quando houver) para revisão.
5. Depois de aprovado, aplique primeiro em `dev`, depois `stg`, depois `prd`.
6. Registre a mudança no [`CHANGELOG.md`](../CHANGELOG.md).

## Referências

- Terraform - guia de estilo: <https://developer.hashicorp.com/terraform/language/style>
- Terraform - estrutura de módulos: <https://developer.hashicorp.com/terraform/language/modules/develop/structure>
- Terraform - recomendações de uso (workflow): <https://developer.hashicorp.com/terraform/tutorials/recommended-patterns>
- Terragrunt - padrões: <https://docs.terragrunt.com/guides/patterns/>
- Google Cloud - boas práticas para Terraform: <https://cloud.google.com/docs/terraform/best-practices/general-style-structure>
- AWS Prescriptive Guidance - boas práticas com Terraform: <https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html>
