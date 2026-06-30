const express = require("express");
const router = express.Router();
const OpenAI = require("openai");

router.post("/", async (req, res) => {
    try {
        const { pergunta } = req.body;

        if (!pergunta) {
            return res.status(400).json({ resposta: "Pergunta não informada." });
        }

        // Client criado aqui para garantir que o .env já foi carregado
        const client = new OpenAI({
            apiKey: process.env.OPENROUTER_API_KEY,
            baseURL: "https://openrouter.ai/api/v1"
        });

        const resposta = await client.chat.completions.create({
            model: "qwen/qwen3-4b:free",
            messages: [
                {
                    role: "system",
                    content: `
Você é o Sr. Bill 🐃, assistente virtual do sistema MedSync.

Responda sempre em português do Brasil.

Nunca faça diagnóstico definitivo.

Nunca receite medicamentos.

Explique de forma simples os possíveis sintomas.

Sempre oriente procurar um profissional de saúde.

Se houver sintomas graves como dor no peito, falta de ar, convulsão, desmaio ou sangramento intenso, oriente procurar atendimento imediatamente.

Finalize todas as respostas com:

⚠️ Esta resposta é apenas informativa e não substitui uma consulta médica.
`
                },
                {
                    role: "user",
                    content: pergunta
                }
            ]
        });

        res.json({ resposta: resposta.choices[0].message.content });

    } catch (erro) {
        console.error("ERRO OPENROUTER:", erro);
        res.status(500).json({
            resposta: erro?.error?.message || erro?.message || JSON.stringify(erro)
        });
    }
});

module.exports = router;
