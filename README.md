# cartorios

Todos os cartórios do Brasil

O Ministério da Justiça (MJ) fornece em portal específico os dados supostamente atualizados, https://portal.mj.gov.br/CartorioInterConsulta/ .

As buscas do site atualmente não funcionam, e, como o CSV não tem URL de arquivo estático, ficamos preocupados de amanhã também não funcionar.

Apesar dos cartórios parecerem diferentes nos seus longos títulos, na verdade o título formal de deve ser lido como um agregado de *rótulos de especialidade*: cada cartório pode atender a uma ou várias especialidades.

O objetivo deste repositório é tanto o de preservação digital (backup do ministério e rascreabilidade das mudanças), como o de organizar um pouco os seus dados, tais como nomes de cidade e, princopalmente, a desagregação e padronização dos *rótulos de especialidades*.

## Preparo

1. Baixar e zipar. Manualmente (via navegador) ou via <br/>`curl -k -H "User-Agent: Mozilla/5.0 (Linux)" https://portal.mj.gov.br/CartorioInterConsulta/consulta.do?action=baixarCSVTodosCartorios | gzip > Cartorios.fonte0.csv.gz`

2. Criar a fonte UTF-8 mais universal e correta que a <br/>`gunzip -c Cartorios.fonte0.csv.gz | iconv -c  -t UTF-8  -f ISO-8859-1 > Cartorios~utf8.csv`

3. *checksum* adicional (o git já faz SHA1) para garantir integridade conforme padrões dos próprios cartórios. Hoje, com base no ICP-Brasil, adota-se o *SHA-256d* (double SHA 256). Você pode conferir por exemplo com o javascript da http://Uniproof.com.br

## Outros problemas com o site

O domínio `mj.gov.br` redireciona para `justica.gov.br`, o que sugere que realmente anda meio abandonado.

Ao tentar o procedimento mais simples, `wget -c   http://portal.mj.gov.br/CartorioInterConsulta/consulta.do?action=baixarCSVTodosCartorios`, nos deparamos com o seguinte aviso:

```
https://portal.mj.gov.br/CartorioInterConsulta/consulta.do?action=baixarCSVTodosCartorios
Resolvendo portal.mj.gov.br (portal.mj.gov.br)... 189.9.0.119
Conectando-se a portal.mj.gov.br (portal.mj.gov.br)|189.9.0.119|:443... conectado.
ERRO: não foi possível verificar o certificado de portal.mj.gov.br, emitido por “CN=GlobalSign Organization Validation CA - SHA256 - G2,O=GlobalSign nv-sa,C=BE”:
  Não foi possível verificar localmente a autoridade do emissor.
Para se conectar a portal.mj.gov.br de forma insegura, use "--no-check-certificate".
```
