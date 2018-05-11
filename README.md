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

Demais preparos no [SQL](src/analise.sql).
