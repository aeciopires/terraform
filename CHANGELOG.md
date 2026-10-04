<!-- TOC -->

- [Changelog](#changelog)
  - [\[2.0.0\] - 2026-10-03](#200---2026-10-03)
    - [Adicionado](#adicionado)
    - [Alterado](#alterado)
    - [Verificado](#verificado)
  - [\[1.0.0\] - histórico](#100---histórico)

<!-- TOC -->

# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui. O formato
segue, de forma livre, o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e as versões seguem o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [2.0.0] - 2026-10-03

Trilha de aprendizado de Terraform, OpenTofu e Terragrunt em pt-BR, nos
mesmos moldes do repositório `learning-ecs`.

### Adicionado

- **Ferramentas** fixadas no `mise.toml`: Terraform 1.16.5, OpenTofu 1.13.1,
  Terragrunt 1.1.6, TFLint 0.64.0, Trivy 0.75.0, terraform-docs 0.24.0,
  pre-commit 4.6.2, ShellCheck 0.11.0, Python 3.14, uv 0.12, AWS CLI v2,
  jq 1.8.2. Pacotes Python com uv (`pyproject.toml`, `uv.lock`): boto3,
  pytest, pytest-cov, ruff, mypy.
- **Emuladores** no `docker-compose.yml`: floci 2.1.0 (AWS) e floci-gcp
  0.9.0 (GCP), com portas configuráveis, e `.env.example` que aponta
  Terraform/OpenTofu, AWS CLI, boto3 e gcloud para eles sem nenhuma linha
  de código específica.
- **10 lições** em `docs/` (IaC e Terraform vs OpenTofu, HCL, state e
  backends, providers e floci, módulos e wrappers, Terragrunt, testes,
  terraform-docs, boas práticas, verificação de recursos) e
  `docs/TROUBLESHOOTING.md` com os erros reais encontrados, todos com
  diagramas Mermaid e analogias.
- **4 labs** em `labs/`: primeiros passos sem nuvem (providers `local` e
  `random`), AWS no floci, GCP no floci-gcp e consumo de módulos (público,
  `for_each`, wrapper e instância fora do loop).
- **Módulos próprios** `modules/aws-messaging` (SNS + SQS + DLQ) e
  `modules/gcp-messaging` (Pub/Sub + dead-letter + IAM do agente de
  serviço), cada um com wrapper no padrão dos terraform-aws-modules,
  exemplo completo, testes unitários com `mock_provider`, testes de
  integração e README gerado pelo terraform-docs.
- **Stack Terragrunt** em `live/` (nuvem/conta/ambiente/região/unidade):
  AWS - VPC, S3 (wrapper do módulo público), mensageria (wrapper do módulo
  próprio e instância customizada fora do loop), ALB, ECS Fargate (nginx),
  security group e RDS PostgreSQL 17; GCP - VPC, Cloud Storage,
  mensageria, Cloud Run (nginx) e Cloud SQL PostgreSQL 17. `root.hcl` com
  backend S3 (`use_lockfile`) ou GCS, provider e versões gerados, endpoints
  do emulador por conta (`target = "floci" | "real"`), `_envcommon` por
  componente, exceções de versão de provider por unidade e `exclude` para
  o que o emulador não suporta.
- **Testes**: `fmt`, `validate`, TFLint (rulesets terraform, aws e google),
  Trivy, `terraform test`/`tofu test` unitários e de integração, smoke tests
  em Python, detecção de drift; `.pre-commit-config.yaml`.
- **Automação**: `Makefile` (emuladores, verificações, testes, Terragrunt em
  massa, listagem de recursos, documentação), `scripts/check-deps.sh`
  (Ubuntu 22.04/24.04/26.04 amd64, macOS 13+ arm64/amd64, WSL2) e
  `scripts/list_resources.py`.
- `REQUIREMENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `live/README.md`.

### Alterado

- `README.md` reescrito como página inicial da trilha (pt-BR), mantendo a
  seção de desenvolvedores e a licença GPL-3.0.
- `.gitignore` ampliado (state, caches do Terragrunt, dados dos emuladores,
  `.env`, Python).
- Os exemplos originais (Terraform 0.11) foram mantidos sem alterações e
  marcados como legados.

### Verificado

Com floci 2.1.0 e floci-gcp 0.9.0 em Ubuntu 22.04 amd64:

- `make test` com `tofu` e com `terraform`; `make test-integration`.
- `make tg-apply` de todas as stacks (24 unidades aplicadas, 4 excluídas no
  emulador), `make test-smoke` (ALB e Cloud Run respondendo HTTP 200),
  `make tg-drift`, `make tg-destroy`; ciclo completo da stack AWS `dev`
  também com `terraform`.
- As unidades GCP `network` e `cloud-sql` foram validadas com `validate`,
  mas não aplicadas (o floci-gcp 0.9.0 não emula o Compute Engine) nem
  testadas em um projeto GCP real.
- Nada foi aplicado em uma conta AWS ou projeto GCP real.

## [1.0.0] - histórico

- Exemplos de Terraform 0.11 (`aws_docker_openproject`, `docker-wordpress`,
  `docker-zabbix`, `google_cloud`) e o tutorial
  <http://blog.aeciopires.com/conhecendo-o-terraform>.
