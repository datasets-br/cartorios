# cartorios

Todos os cartórios do Brasil

O Ministério da Justiça (MJ) fornece em portal específico os dados supostamente atualizados, https://portal.mj.gov.br/CartorioInterConsulta/ ... Mas **parou de atualizar em 2013**. 
As buscas do site atualmente não funcionam, e, como o CSV não tem URL de arquivo estático, ficamos preocupados de amanhã também não funcionar.

Hoje os dados parecem estar em http://www.cnj.jus.br/corregedoria/justica_aberta  , pode-se comparar com os dados antigos. Ver [apresentação e relatório](http://www.cnj.jus.br/transparencia/apresentacao/327-sobre-o-cnj/corregedoria/atos-administrativos-da-corregedoria/divulgacoes/12599-cadastro-das-serventias-extrajudiciais-estaticas) do Cadastro das Serventias Extrajudiciais.

Apesar dos cartórios parecerem diferentes, alguns com longos títulos designando o que fazem, eles podem ser  agregados por *rótulos de especialidade*, também ditas **atribuições**: cada cartório pode atender a uma ou várias atribuições.

O objetivo deste repositório é tanto o de preservação digital (backup e rascreabilidade das mudanças desde 2013), como o de organizar um pouco os seus dados, tais como nomes de cidade e, princopalmente, a desagregação e padronização dos *rótulos de atribuição* e das jurisdições (áreas de serventia/abrangência).

## Preparo

1. Baixar e zipar. Manualmente (via navegador) ou via <br/>`curl -k -H "User-Agent: Mozilla/5.0 (Linux)" https://portal.mj.gov.br/CartorioInterConsulta/consulta.do?action=baixarCSVTodosCartorios | gzip > Cartorios.fonte0.csv.gz`

2. Criar a fonte UTF-8 que é o padrão Brasil (ePING)<br/>`gunzip -c Cartorios.fonte0.csv.gz | iconv -c  -t UTF-8  -f ISO-8859-1 > Cartorios~utf8.csv`

3. *checksum* adicional (o git já faz SHA1) para garantir integridade conforme padrões dos próprios cartórios. Hoje, com base no ICP-Brasil, adota-se o *SHA-256d* (double SHA 256). Você pode conferir por exemplo com o javascript-local da https://uniproof.com.br/#valide-hash

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
