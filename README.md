# Desafio DevOps - QR Capital

Nesse repositório está contido código terraform para resolver o problema proposto no desafio de DevOps da QR Capital

Essa atividade foi realizada usando recursos do AWS no terraform sem o uso de módulos, tanto para demonstrar o conhecimento das peças de infraestrutura da AWS quanto para realizar a atividade de forma extensa permitindo a apresentação de código funcional.

## Execução

Instalar Terraform 1.1.8

Para executar o código e gerar a infraestrutura na AWS:

- `terraform init` para instalar as dependencias do provider
- `terraform plan` para gerar o plano de modificações a serem aplicadas
- `terraform apply` para aplicar as modificações 

## Design da infraestrutura

![Metabase Architecture](https://user-images.githubusercontent.com/11475695/163426580-a8e6a6dd-ad87-4a11-a407-c68fba716e74.png)

Na arquitetura apresentada acima, temos uma aplicação dividida em três camadas:
- Dados
- Aplicação
- LoadBalancer

O fluxo de dados de entrada na aplicação só ocorre por meio do Load Balancer, sendo que a task no ECS não possuí um endereço de IP público, sendo assim, essa não pode ser acessada diretamente.

Como o ECS precisa de acesso a internet para fazer o download da imagem no DockerHub e a aplicação `Metabase` também precisará de acesso externo para buscar dados de alguma base de dados externa para executar sua tarefa, foi criado um NAT Gateway, que permite que os elementos de nossa arquitetura se conectem à internet sem se expor, por meio de uma tradução de endereçamento IP (NAT).

**OBS:** Em caso de uma aplicação em produção, a imagem docker seria hospedada no AWS ECR e as possíveis bases de dados que o Metabase acessaria estariam dentro da própria rede, fazendo assim com que não seja necessário conectar a aplicação na internet (mitigando assim qualquer risco por deixar a aplicação aberta)

## Considerações sobre a arquitetura

Foram utilizados recursos de forma economica na AWS de forma a caber o máximo possível no `Free Tier` e assim ter-se o minímo custo possível com a execução dessa atividade, por conta disso nota-se alguns pontos que seriam importantes para garantir a escalabilidade da arquitetura proposta, como:
- Número maior de tasks em execução (`1`)
- Criação de uma replica do banco de dados em outro AZ (caso seja necessário downtime próximo de 0 no caso de uma eventual catástrofe)
- Maior número de AZs cobertas para alta disponibilidade
