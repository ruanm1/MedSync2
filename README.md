# 🏥 MedSync

Sistema de gerenciamento médico com backend Node.js/Express e frontend React.

## Estrutura do projeto

```
MedSync/
├── backend/
│   ├── routes/
│   │   ├── medicos.js
│   │   ├── pacientes.js
│   │   ├── consultas.js
│   │   ├── prontuarios.js
│   │   └── ia.js
│   ├── db.js
│   ├── server.js
│   └── .env
├── frontend/
│   ├── index.html
│   ├── script.js
│   └── style.css
├── package.json
├── .gitignore
└── README.md
```

## Como rodar

### 1. Instalar dependências
```bash
npm install
```

### 2. Configurar o `.env`
Edite o arquivo `backend/.env` com suas credenciais do banco de dados.

### 3. Iniciar o servidor
```bash
# Desenvolvimento (com auto-reload)
npm run dev

# Produção
npm start
```

### 4. Acessar
Abra o navegador em: **http://localhost:3000**

O servidor serve o frontend e a API no mesmo endereço.

## Endpoints da API

| Método | Rota             | Descrição                   |
|--------|------------------|-----------------------------|
| GET    | /medicos         | Listar médicos              |
| POST   | /medicos         | Cadastrar médico            |
| PUT    | /medicos/:id     | Editar médico               |
| DELETE | /medicos/:id     | Remover médico              |
| GET    | /pacientes       | Listar pacientes            |
| POST   | /pacientes       | Cadastrar paciente          |
| PUT    | /pacientes/:id   | Editar paciente             |
| DELETE | /pacientes/:id   | Remover paciente            |
| GET    | /consultas       | Listar consultas            |
| POST   | /consultas       | Agendar consulta            |
| PUT    | /consultas/:id   | Editar consulta             |
| DELETE | /consultas/:id   | Remover consulta            |
| GET    | /prontuarios     | Listar prontuários          |
| POST   | /prontuarios     | Criar prontuário            |
| PUT    | /prontuarios/:id | Editar prontuário           |
| DELETE | /prontuarios/:id | Remover prontuário          |
| POST   | /ia              | Consultar assistente Sr. Bill |

## Tecnologias

- **Backend:** Node.js, Express, MySQL2, dotenv, OpenAI (OpenRouter)
- **Frontend:** React (via CDN), Babel standalone
- **Dev:** Nodemon
