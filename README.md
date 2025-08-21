# GS_2S_Renan
# Objetivos
Desenvolver o código IaC em módulos relativo à infraestrutura de TI fornecida e criar os recursos de TI na AWS e na Azure, utilizando a ferramenta Terraform via GitHub Actions.
Demonstrar testes com a ferramenta de Infraestrutura como Código Terraform utilizando pipelines automatizados via GitHub Actions.

# Infraestrutura de TI

![thumbnail](https://github.com/user-attachments/assets/1e193168-5d35-429e-b8ab-2c24161cb3e2)


# Pré-requisitos

Logue no GitHub com sua conta da FIAP, crie um novo repositório público, faça clone desse novo repositório na sua máquina local e inicie a atividade.

# Entrega

Poste no assignment do Teams um arquivo contendo:
A url do seu repositório público no GitHub
Para o item 01 abaixo:
Evidência que a url do balanceador está direcionando o tráfego para cada uma das máquinas virtuais. Tanto o balanceador da AWS quanto o balanceador da Azure.
Para o item 02 abaixo:
url do pipeline com o terraform validate
url do pipeline com o checkov
url do pipeline com a validação de variável

Item 01: Seu repositório no GitHub deverá conter o código Terraform em módulos relativo aos recursos de TI conforme o desenho de infraestrutura fornecido:

Módulo rede:
0,5 pontos: Rede e Subredes
0,5 pontos: Rotas e Firewalls
Módulo compute:
2,0 ponto: Load Balancer
2,0 pontos: Máquinas virtuais
2,0 pontos: App dinâmica

Item 02: (O item 01 é pré-requisito para esse item) Execute o pipeline via GitHub Actions, validando os recursos com "terraform validate", "checkov" e "validação de variável".
0,5 ponto: terraform validate
0,5 pontos: checkov
2,0 pontos: validação de variável

IMPORTANTE !!!
Itens não evidenciados na entrega terão deflatores aplicados.
Ao término da atividade, destrua os recursos para evitar consumo de recursos desnecessários.
