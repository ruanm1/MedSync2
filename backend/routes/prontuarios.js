const express = require("express");
const router = express.Router();
const db = require("../db");

// LISTAR
router.get("/", (req, res) => {
    db.query(
        `SELECT
            prontuarios.id,
            pacientes.nome  AS paciente,
            medicos.nome    AS medico,
            consultas.data,
            prontuarios.queixa,
            prontuarios.diagnostico,
            prontuarios.prescricao,
            prontuarios.observacoes
         FROM prontuarios
         INNER JOIN consultas ON consultas.id  = prontuarios.consulta_id
         INNER JOIN pacientes ON pacientes.id  = consultas.paciente_id
         INNER JOIN medicos   ON medicos.id    = consultas.medico_id
         ORDER BY consultas.data DESC`,
        (erro, resultado) => {
            if (erro) return res.status(500).json(erro);
            res.json(resultado);
        }
    );
});

// CADASTRAR
router.post("/", (req, res) => {
    const { consulta_id, queixa, diagnostico, prescricao, observacoes } = req.body;
    db.query(
        `INSERT INTO prontuarios (consulta_id,queixa,diagnostico,prescricao,observacoes) VALUES (?,?,?,?,?)`,
        [consulta_id, queixa, diagnostico, prescricao, observacoes],
        (erro, resultado) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Prontuário salvo!", id: resultado.insertId });
        }
    );
});

// EDITAR
router.put("/:id", (req, res) => {
    const { queixa, diagnostico, prescricao, observacoes } = req.body;
    db.query(
        `UPDATE prontuarios SET queixa=?,diagnostico=?,prescricao=?,observacoes=? WHERE id=?`,
        [queixa, diagnostico, prescricao, observacoes, req.params.id],
        (erro) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Prontuário atualizado!" });
        }
    );
});

// EXCLUIR
router.delete("/:id", (req, res) => {
    db.query("DELETE FROM prontuarios WHERE id=?", [req.params.id], (erro) => {
        if (erro) return res.status(500).json(erro);
        res.json({ mensagem: "Prontuário removido!" });
    });
});

module.exports = router;
