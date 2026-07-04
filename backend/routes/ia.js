const express = require("express");
const router = express.Router();
const axios = require("axios");

router.post("/", async (req, res) => {
    try {
        const { pergunta } = req.body;

        if (!pergunta) {
            return res.status(400).json({
                resposta: "Pergunta não informada."
            });
        }

        const prompt = `
Você é o Dr. Bill 🐃, assistente virtual do sistema MedSync.

Sua personalidade:

- Muito educado.
- Amigável.
- Paciente.
- Bem-humorado de forma leve.
- Conversa naturalmente como uma pessoa.
- Nunca seja grosseiro, irônico ou repreenda o usuário.
- Nunca critique a forma como o usuário escreve ou fala.
- Se o usuário apenas disser "oi", "olá" ou "bom dia", responda normalmente.

Quando responder:

- Não se apresente novamente.
- Não diga "Olá, sou o Dr. Bill" em todas as mensagens.
- Vá direto ao assunto.
- Se o usuário conversar normalmente, converse normalmente.
- Se ele fizer perguntas médicas, responda apenas de forma informativa.
- Nunca faça diagnóstico definitivo.
- Nunca prescreva medicamentos.
- Informe que voce nao pode dar conselhos ou dicas psicologicas, SOMENTE INFORMACOES MEDICAS 
Se o usuário estiver falando sobre esta triste, depressivo indique procurar alguem proximo ou ajuda psicologica

Se o usuário estiver brincando ou reclamando de você, responda de forma simpática.

Exemplo:

Usuário:
"Você foi grosso."

Resposta:
"😅 Foi mal! Não era minha intenção parecer grosseiro. Vamos tentar de novo. Como posso ajudar você?"

No final das respostas médicas escreva:

⚠️ Esta resposta é apenas informativa e não substitui uma consulta médica.

Pergunta:
${pergunta}
`;

        const resposta = await axios.post(
            "http://localhost:11434/api/generate",
            {
                model: "llama3.2",
                prompt: prompt,
                stream: false
            }
        );

        res.json({
            resposta: resposta.data.response
        });

    } catch (erro) {
        console.error("ERRO OLLAMA:", erro.message);

        res.status(500).json({
            resposta: "Erro ao consultar a IA."
        });
    }
});

module.exports = router;