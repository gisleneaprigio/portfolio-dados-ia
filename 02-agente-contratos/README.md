# 02 · Agente de Contratos

> Agente de IA criado no **Microsoft Copilot Studio** que consulta a base de contratos e responde em linguagem natural sobre prazos, valores, reajustes e cláusulas, sempre citando a fonte.
> *A demonstração usa contratos, fornecedores e valores fictícios.*

## Resultado

> ⏱️ **Redução de 87,5% no tempo de análise.** Análises que levavam **2 dias** passaram a levar **no máximo 2 horas**.

![Exemplo de conversa](imagens/exemplo-conversa.png)

## O problema

A gestão de contratos envolvia centenas de documentos em PDF. Perguntas simples exigiam abrir arquivo por arquivo, por exemplo:

- *"O que vence no próximo trimestre?"*
- *"Quais contratos têm renovação automática?"*
- *"Qual índice de reajuste se aplica?"*

Cada análise levava cerca de dois dias de trabalho. O risco mais caro era **perder o prazo de aviso de não renovação**.

## A solução

![Arquitetura](imagens/arquitetura.png)

| Componente (Copilot Studio) | Função |
|---|---|
| **Fontes de conhecimento** | Contratos em PDF numa biblioteca do SharePoint, mais a base de contratos (lista ou planilha) |
| **Instruções** | Definem o papel do agente, o tom e os limites. Ele não inventa informações e sempre cita a cláusula de origem |
| **Tópicos** | Fluxos guiados para as perguntas mais comuns: vencimentos, reajustes e cláusulas específicas |
| **Respostas generativas** | Atendem perguntas livres sobre o conteúdo dos contratos |
| **Ações (Power Automate)** | Enviam alertas de vencimento e exportam uma tabela consolidada para o painel de contratos no Power BI |

![Contratos por faixa de vencimento](imagens/faixas-vencimento.png)

## Decisões de projeto

- **Resposta sempre com a fonte:** o agente cita o contrato e a cláusula, para que a pessoa confira antes de agir.
- **Tópicos para o que é recorrente:** as perguntas mais frequentes seguem um fluxo fixo, e o resultado fica previsível.
- **Humano no circuito:** o agente acelera a análise, mas a decisão continua com a equipe.

## Ferramentas

`Microsoft Copilot Studio` · `Power Automate` · `SharePoint` · `Power BI`

<sub>Cálculo: 2 dias úteis ≈ 16 horas → 2 horas = redução de 87,5%.</sub>
