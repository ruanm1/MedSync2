const express = require("express");
const router = express.Router();
const db = require("../db");

// LISTAR
router.get("/", (req, res) => {
    db.query("SELECT * FROM medicos ORDER BY nome", (erro, resultado) => {
        if (erro) return res.status(500).json(erro);
        res.json(resultado);
    });
});

// CADASTRAR
router.post("/", (req, res) => {
    const { nome, crm, especialidade, telefone, email, dias, horario_inicio, horario_fim } = req.body;
    db.query(
        `INSERT INTO medicos (nome,crm,especialidade,telefone,email,dias,horario_inicio,horario_fim)
         VALUES (?,?,?,?,?,?,?,?)`,
        [nome, crm, especialidade, telefone, email, dias, horario_inicio, horario_fim],
        (erro, resultado) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Médico cadastrado!", id: resultado.insertId });
        }
    );
});

// EDITAR
router.put("/:id", (req, res) => {
    const { nome, crm, especialidade, telefone, email, dias, horario_inicio, horario_fim } = req.body;
    db.query(
        `UPDATE medicos SET nome=?,crm=?,especialidade=?,telefone=?,email=?,dias=?,horario_inicio=?,horario_fim=?
         WHERE id=?`,
        [nome, crm, especialidade, telefone, email, dias, horario_inicio, horario_fim, req.params.id],
        (erro) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Médico atualizado." });
        }
    );
});

// EXCLUIR
router.delete("/:id", (req, res) => {
    db.query("DELETE FROM medicos WHERE id=?", [req.params.id], (erro) => {
        if (erro) return res.status(500).json(erro);
        res.json({ mensagem: "Médico removido." });
    });
});

module.exports = router;
