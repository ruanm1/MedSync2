const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

const app = express();

// ── Middlewares ──────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Servir o frontend estático ───────────────────────────────
app.use(express.static(path.join(__dirname, "../frontend")));

// ── Rotas da API ─────────────────────────────────────────────
const medicos    = require("./routes/medicos");
const pacientes  = require("./routes/pacientes");
const consultas  = require("./routes/consultas");
const prontuarios = require("./routes/prontuarios");
const ia         = require("./routes/ia");

app.use("/medicos",     medicos);
app.use("/pacientes",   pacientes);
app.use("/consultas",   consultas);
app.use("/prontuarios", prontuarios);
app.use("/ia",          ia);

// ── Health-check ─────────────────────────────────────────────
app.get("/api/status", (req, res) => {
    res.json({ status: "ok", sistema: "MedSync API" });
});

// ── Fallback: todas as outras rotas servem o frontend ────────
app.get("/{*path}", (req, res) => {
    res.sendFile(path.join(__dirname, "../frontend/index.html"));
});

// ── Inicialização ─────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 MedSync rodando em http://localhost:${PORT}`);
});
