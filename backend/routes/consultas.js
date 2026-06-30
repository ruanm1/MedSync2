const express = require("express");
const router = express.Router();
const db = require("../db");

// LISTAR
router.get("/", (req, res) => {
    db.query(
        `SELECT
            consultas.id,
            pacientes.nome AS paciente,
            medicos.nome   AS medico,
            consultas.data,
            consultas.horario,
            consultas.tipo,
            consultas.status
         FROM consultas
         INNER JOIN pacientes ON pacientes.id = consultas.paciente_id
         INNER JOIN medicos   ON medicos.id   = consultas.medico_id
         ORDER BY consultas.data, consultas.horario`,
        (erro, resultado) => {
            if (erro) return res.status(500).json(erro);
            res.json(resultado);
        }
    );
});

// CADASTRAR
router.post("/", (req, res) => {
    const { paciente_id, medico_id, data, horario, tipo, status } = req.body;
    db.query(
        `INSERT INTO consultas (paciente_id,medico_id,data,horario,tipo,status) VALUES (?,?,?,?,?,?)`,
        [paciente_id, medico_id, data, horario, tipo, status],
        (erro, resultado) => {
            if (erro) return res.status(500).json(erro);
            res.json({ mensagem: "Consulta cadastrada!", id: resultado.insertId });
        }
    );
});

/// EDITAR / CANCELAR CONSULTA
router.put("/:id", (req, res) => {

    // Se veio só o status, faz apenas o cancelamento
    if (Object.keys(req.body).length === 1 && req.body.status) {

        db.query(
            "UPDATE consultas SET status=? WHERE id=?",
            [req.body.status, req.params.id],
            (erro) => {

                if (erro) return res.status(500).json(erro);

                res.json({ mensagem: "Consulta cancelada!" });

            }
        );

        return;
    }

    // Atualização completa
    const {
        paciente_id,
        medico_id,
        data,
        horario,
        tipo,
        status
    } = req.body;

    db.query(
        `UPDATE consultas
         SET paciente_id=?,
             medico_id=?,
             data=?,
             horario=?,
             tipo=?,
             status=?
         WHERE id=?`,
        [
            paciente_id,
            medico_id,
            data,
            horario,
            tipo,
            status,
            req.params.id
        ],
        (erro) => {

            if (erro) return res.status(500).json(erro);

            res.json({ mensagem: "Consulta atualizada!" });

        }
    );

});

module.exports = router;
