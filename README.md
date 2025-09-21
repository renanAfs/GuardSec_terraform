# Infraestrutura AWS com Terraform para Aplicação Web Altamente Disponível

Este projeto utiliza o Terraform para provisionar uma infraestrutura completa e segura na AWS, baseada no diagrama de arquitetura fornecido. O objetivo é hospedar uma aplicação web com alta disponibilidade, resiliência a falhas, segurança de borda e um pipeline de deployment inicial.

A configuração dá preferência a recursos elegíveis no **Free Tier da AWS** sempre que possível, com exceções importantes destacadas na seção de custos.

## Tabela de Conteúdos
- [Diagrama da Arquitetura](#diagrama-da-arquitetura)
- [Recursos Criados](#recursos-criados)
- [Pré-requisitos](#pré-requisitos)
- [Estrutura de Módulos](#estrutura-de-módulos)
- [Como Usar](#como-usar)
  - [1. Configurar as Variáveis](#1-configurar-as-variáveis)
  - [2. Inicializar o Terraform](#2-inicializar-o-terraform)
  - [3. Planejar e Aplicar](#3-planejar-e-aplicar)
- [Pós-Implantação: Configurando o DNS](#pós-implantação-configurando-o-dns)
- [Saídas (Outputs)](#saídas-outputs)
- [⚠️ Aviso de Custos](#️-aviso-de-custos)
- [Como Destruir a Infraestrutura](#como-destruir-a-infraestrutura)

## Diagrama da Arquitetura

A infraestrutura provisionada por este código segue o desenho abaixo:

![Diagrama da Arquitetura](Topologia.drawio.jpg)

## Recursos Criados

Este projeto cria os seguintes recursos na AWS:

- **Rede Principal (Aplicação):**
  - **VPC** com duas Zonas de Disponibilidade (AZs).
  - **Subnets Públicas** para recursos de borda (Load Balancer, NAT Gateways).
  - **Subnets Privadas** para recursos internos (Instâncias EC2, Banco de Dados RDS).
  - **Internet Gateway** para acesso à internet.
  - **NAT Gateways** (um por AZ) para permitir que recursos privados acessem a internet.
  - **Route Tables** para gerenciar o fluxo de tráfego.

- **Rede de Segurança:**
  - Uma **VPC** separada para as ferramentas da Fortinet.
  - **VPC Peering** para conectar a VPC de segurança à VPC principal.

- **Computação:**
  - **Launch Template** para definir a configuração das instâncias da aplicação.
  - **Auto Scaling Group** para gerenciar as instâncias EC2 da aplicação, garantindo alta disponibilidade e escalabilidade.

- **Banco de Dados:**
  - **Amazon RDS (PostgreSQL)** em modo **Multi-AZ** para alta disponibilidade.

- **Segurança:**
  - **Security Groups** para controlar o tráfego em nível de instância (firewall).
  - **AWS WAF** associado ao Load Balancer para proteção contra ataques web comuns.
  - **AWS Shield Standard** (habilitado por padrão) para proteção contra ataques DDoS.
  - **Instâncias Fortinet** (FortiGate e FortiManager) na VPC de segurança (*ver aviso de custos*).

- **DNS:**
  - **Amazon Route 53** para gerenciamento de DNS.
  - Uma **Hosted Zone** para o domínio da aplicação.
  - Um **Registro 'A' (Alias)** para apontar um subdomínio para o Load Balancer.

- **Monitoramento e Auditoria:**
  - **AWS CloudTrail** para registrar todas as chamadas de API na conta.

## Pré-requisitos

Antes de começar, você precisará de:

1.  **Conta na AWS:** Com as devidas permissões para criar os recursos listados acima.
2.  **AWS CLI:** Instalado e configurado com suas credenciais (`aws configure`).
3.  **Terraform:** Instalado na sua máquina (versão 1.0.0 ou superior).
4.  **Nome de Domínio Registrado:** Um domínio que você possua (ex: `meusite.com`) para configurar no Route 53.
5.  **Inscrição nas AMIs da Fortinet:**
    - Vá ao [AWS Marketplace](https://aws.amazon.com/marketplace).
    - Procure por "FortiGate" e "FortiManager".
    - Inscreva-se nos produtos para aceitar os termos e ter permissão para usar as AMIs. Anote os IDs das AMIs para a sua região.

## Estrutura de Módulos

O projeto é organizado em módulos para melhor manutenibilidade:
- **`modules/network/`**: Responsável por toda a infraestrutura de rede (VPCs, Subnets, ALB, WAF, Route 53, etc.).
- **`modules/compute/`**: Responsável pelos recursos de computação (Auto Scaling Group, RDS).
- **`modules/fortinet/`**: Responsável pelas instâncias da Fortinet na VPC de segurança.

## Como Usar

Siga os passos abaixo para implantar a infraestrutura.

### 1. Configurar as Variáveis

Crie um arquivo chamado `terraform.tfvars` na raiz do projeto. Este arquivo conterá suas configurações específicas e segredos. **Nunca adicione este arquivo ao controle de versão (Git)!**

Copie o conteúdo abaixo para o seu `terraform.tfvars` e preencha com seus dados:

```hcl
# Exemplo de terraform.tfvars

# --- Configurações Gerais ---
aws_region   = "us-east-1"
project_name = "minha-app-web"

# --- Banco de Dados RDS ---
# ATENCAO: Use uma senha forte e considere usar o AWS Secrets Manager em produção.
db_password = "SuaSenhaSuperSeguraAqui123!"

# --- Configuração do Domínio (Route 53) ---
# O domínio que você registrou.
domain_name = "seudominio.com"
# Opcional: O subdomínio para a aplicação. O padrão é "app".
# subdomain   = "www"

# --- AMIs da Fortinet (OBRIGATÓRIO) ---
# Preencha com os IDs das AMIs do AWS Marketplace para a sua região.
fortigate_ami    = "ami-xxxxxxxxxxxxxxxxx"
fortimanager_ami = "ami-yyyyyyyyyyyyyyyyy"
