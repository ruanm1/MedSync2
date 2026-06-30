const express = require("express");
const router = express.Router();
const db = require("../db");

// LISTAR
router.get("/", (req, res) => {
    db.query("SELECT * FROM pacientes ORDER BY nome", (erro, resultado) => {
        if (erro) return res.status(500).json(erro);
        res.json(resultado);
    });
});

// CADASTRAR
router.post("/", (req, res) => {
    const { nome, cpf, nascimento, telefone, convenio } = req.body;
    db.query(
        `INSERT INTO pacientes (nome,cpf,nascimento,telefone,convenio) VALUES (?,?,?,?,?)`,
        [nome, cpf, nascimento, telefone, convenio],
        (erro, resultado) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Paciente cadastrado!", id: resultado.insertId });
        }
    );
});

// EDITAR
router.put("/:id", (req, res) => {
    const { nome, cpf, nascimento, telefone, convenio } = req.body;
    db.query(
        `UPDATE pacientes SET nome=?,cpf=?,nascimento=?,telefone=?,convenio=? WHERE id=?`,
        [nome, cpf, nascimento, telefone, convenio, req.params.id],
        (erro) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Paciente atualizado!" });
        }
    );
});

// EXCLUIR
router.delete("/:id", (req, res) => {
    db.query("DELETE FROM pacientes WHERE id=?", [req.params.id], (erro) => {
        if (erro) return res.status(500).json(erro);
        res.json({ mensagem: "Paciente removido!" });
    });
});

module.exports = router;
