# **Semeia+**

O sistema foi concebido para apoiar o Programa de Distribuição de Sementes desenvolvido por órgãos públicos estaduais, visando otimizar todo o ciclo de vida das sementes — da aquisição à entrega final — com rastreabilidade, controle logístico e transparência pública.

O banco de dados reflete a realidade de um ecossistema formado por fornecedores, gestores, armazéns, cooperativas, agricultores e cidadãos, integrando todas as etapas do processo de forma padronizada e auditável.

**Contexto e Objetivo**

O SEMEIA+ tem como missão garantir o gerenciamento eficiente da distribuição de sementes, oferecendo às secretarias de agricultura uma ferramenta digital capaz de registrar, monitorar e comprovar cada etapa da cadeia produtiva.
No cenário real, o programa envolve:
- Fornecedores que entregam lotes de sementes ao Estado.
- Armazéns regionais responsáveis pelo armazenamento e movimentação dos lotes.
- Gestores públicos que planejam e supervisionam a logística.
- Cooperativas e agricultores que recebem as sementes distribuídas.
- Cidadãos e órgãos fiscalizadores, que acessam informações de transparência.

**Atores e Entidades Envolvidas**

Todos os participantes do sistema são registrados como usuários, cada um com permissões específicas conforme seu papel:
- Gestor: gerencia cadastros, expedições e relatórios.
- Operador de Armazém: lança movimentações de estoque (entradas, saídas, transferências).
- Agente de Distribuição: registra entregas a beneficiários.
- Cooperativa: solicita e recebe sementes.
- Cidadão: consulta dados públicos de distribuição.

A tabela usuario armazena dados de login e autenticação. As tabelas papel e usuario_papel determinam as funções e permissões de cada perfil. A tabela gestor detalha cargos e áreas de atuação dos gestores vinculados.

**Fornecedores, Agricultores e Cooperativas**

- Fornecedores: empresas registradas com CNPJ, responsáveis por fornecer os lotes de sementes ao Estado.
- gricultores: beneficiários finais do programa, pessoas físicas com CPF e endereço vinculado a um município.
- Cooperativas: associações ou grupos de produtores que podem receber sementes de forma coletiva.
Cada um desses grupos possui uma tabela específica de endereço (endereco_agricultor, endereco_cooperativa, endereco_fornecedor), garantindo a rastreabilidade geográfica e evitando redundâncias.

**Municípios e Armazéns**

Municípios (municipio): cadastrados com nome e UF, servem como referência para todas as operações logísticas.
Armazéns (armazem): pontos físicos de estocagem de sementes, vinculados a municípios e endereços próprios.
Esses armazéns funcionam como nós logísticos, recebendo e distribuindo sementes conforme as necessidades locais.
Cada armazém pode conter múltiplos lotes, controlados pela tabela estoque_armazem_lote.

**Espécies e Lotes**

O sistema gerencia espécies de sementes (ex.: milho, feijão, sorgo), cadastradas na tabela especie com nome comum e científico. Cada lote representa uma saca de sementes, registrada na tabela lote, associada à espécie e ao fornecedor.
Os lotes possuem: Número único (numero_lote), Quantidade de sacas, Data de validade, QR Code para identificação digital.
- O conceito de lote é central: toda movimentação, entrega ou expedição é realizada por lote, e não por peso (kg).

**Controle de Estoque e Movimentações**

Para cada armazém, o sistema registra o saldo de cada lote em estoque_armazem_lote.
As movimentações são controladas pela tabela movimentacao_esto, que registra:
- ENTRADA: quando o lote chega ao armazém.
- SAÍDA: quando o lote é retirado para entrega.
- TRANSFERÊNCIA: quando o lote é movido entre armazéns.
Cada movimentação registra o usuário responsável e a data/hora. Um gatilho (trigger) impede que o saldo de sacas fique negativo. O histórico é complementado pela tabela rastro_lote, que guarda todos os eventos relevantes (entrada, expedição, entrega, transferência), formando uma linha do tempo completa do ciclo da semente.

**Expedições e Entregas**
Ordem de Expedição (ordem_expedicao). É criada pelo gestor para planejar a remessa de lotes a determinado município.
Contém: Data prevista, Status (Planejada, Expedida, Concluída, Cancelada), Gestor responsável, Cooperativa solicitante. Os lotes incluídos nessa remessa são registrados em item_expedicao.

Entrega (entrega) registra o momento em que as sementes chegam ao destinatário final:
- Pode ser uma cooperativa ou um agricultor (mas nunca ambos ao mesmo tempo).
Essa exclusividade é garantida por um gatilho XOR, que impede inconsistências. Os lotes e suas quantidades estão em item_entrega, e o vínculo entre a entrega e a ordem de expedição está em entrega_ordem.

**Transparência e Auditoria**

A view vw_transparencia_distribuicao consolida dados de entregas: Município, Espécie de semente, Período (mês/ano), Total de sacas distribuídas. Ela serve de base para painéis públicos, relatórios de fiscalização e portais de transparência, promovendo o controle social sobre o programa.

**Regras de Negócio no Banco**

Triggers preventivos: 
- Impedem saldo negativo em estoque;
- Garantem consistência entre tipo de destinatário e campos informados em entrega;
Chaves únicas: CPF (Agricultor), CNPJ (Fornecedor e Cooperativa), Número do lote.

Relacionamentos N:N: Entre usuario e papel; Entre entrega e ordem_expedicao.
Integridade referencial: ON DELETE SET NULL para vínculos opcionais; ON DELETE RESTRICT para dados críticos (municípios, espécies, lotes).

**Síntese Geral**

O minimundo modelado no SEMEIA+ representa, de forma integrada e digitalizada, a cadeia de fornecimento e distribuição de sementes. Ele reflete a realidade de programas estaduais que buscam: 
- Garantir eficiência logística.
- Manter controle de estoque confiável.
- Assegurar rastreabilidade total das sementes.
- Promover transparência pública e prestação de contas.
