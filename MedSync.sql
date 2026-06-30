DROP DATABASE IF EXISTS medsync;
CREATE DATABASE medsync;
USE medsync;

-- ==========================================
-- TABELA MÉDICOS
-- ==========================================

CREATE TABLE medicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100) NOT NULL,
    dias VARCHAR(100),
    horario_inicio TIME,
    horario_fim TIME
);

-- ==========================================
-- TABELA PACIENTES
-- ==========================================

CREATE TABLE pacientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nascimento DATE NOT NULL,
    telefone VARCHAR(20),
    convenio VARCHAR(100)
);

-- ==========================================
-- TABELA CONSULTAS
-- ==========================================

CREATE TABLE consultas (
    id INT AUTO_INCREMENT PRIMARY KEY,

    paciente_id INT,

    medico_id INT,

    data DATE NOT NULL,

    horario TIME NOT NULL,

    tipo VARCHAR(50),

    status VARCHAR(50) DEFAULT 'AGENDADA',

    FOREIGN KEY (paciente_id)
        REFERENCES pacientes(id),

    FOREIGN KEY (medico_id)
        REFERENCES medicos(id)
);

-- ==========================================
-- TABELA PRONTUÁRIOS
-- ==========================================

CREATE TABLE prontuarios (

    id INT AUTO_INCREMENT PRIMARY KEY,

    consulta_id INT UNIQUE,

    queixa TEXT,

    diagnostico TEXT,

    prescricao TEXT,

    observacoes TEXT,

    FOREIGN KEY (consulta_id)
        REFERENCES consultas(id)

);

-- ==========================================
-- TABELA AUDITORIA
-- ==========================================

CREATE TABLE auditoria (

    id INT AUTO_INCREMENT PRIMARY KEY,

    tabela_afetada VARCHAR(50),

    operacao VARCHAR(30),

    usuario VARCHAR(100),

    descricao TEXT,

    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
DROP USER IF EXISTS 'usr_admin'@'localhost';
DROP USER IF EXISTS 'usr_paciente'@'localhost';
-- ==========================================
-- USUÁRIOS
-- ==========================================

CREATE USER IF NOT EXISTS 'usr_admin'@'localhost'
IDENTIFIED BY 'Admin123!';

CREATE USER IF NOT EXISTS 'usr_paciente'@'localhost'
IDENTIFIED BY 'Paciente123!';

-- ==========================================
-- PERMISSÕES
-- ==========================================

GRANT ALL PRIVILEGES
ON medsync.*
TO 'usr_admin'@'localhost';

GRANT SELECT
ON medsync.medicos
TO 'usr_paciente'@'localhost';

GRANT SELECT
ON medsync.pacientes
TO 'usr_paciente'@'localhost';

GRANT SELECT, INSERT, UPDATE
ON medsync.consultas
TO 'usr_paciente'@'localhost';

GRANT SELECT
ON medsync.prontuarios
TO 'usr_paciente'@'localhost';

FLUSH PRIVILEGES;

-- ==========================================
-- VIEWS
-- ==========================================

CREATE VIEW vw_agenda_medica AS
SELECT
    c.id,
    m.nome AS medico,
    p.nome AS paciente,
    c.data,
    c.horario,
    c.tipo,
    c.status
FROM consultas c
JOIN medicos m ON c.medico_id = m.id
JOIN pacientes p ON c.paciente_id = p.id;


CREATE VIEW vw_consultas_realizadas AS
SELECT
    c.id,
    p.nome AS paciente,
    m.nome AS medico,
    c.data,
    c.horario
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
WHERE c.status='REALIZADA';


CREATE VIEW vw_pacientes_consultas AS
SELECT
    p.id,
    p.nome,
    COUNT(c.id) AS total_consultas
FROM pacientes p
LEFT JOIN consultas c
ON p.id=c.paciente_id
GROUP BY p.id,p.nome;


CREATE VIEW vw_prontuarios AS
SELECT
    p.nome AS paciente,
    m.nome AS medico,
    pr.queixa,
    pr.diagnostico,
    pr.prescricao,
    pr.observacoes
FROM prontuarios pr
JOIN consultas c
ON pr.consulta_id=c.id
JOIN pacientes p
ON c.paciente_id=p.id
JOIN medicos m
ON c.medico_id=m.id;


-- ==========================================
-- PROCEDURES
-- ==========================================

DELIMITER $$

CREATE PROCEDURE sp_agendar_consulta(

IN p_paciente INT,
IN p_medico INT,
IN p_data DATE,
IN p_horario TIME,
IN p_tipo VARCHAR(50)

)
BEGIN

START TRANSACTION;

IF EXISTS(

SELECT 1
FROM consultas
WHERE medico_id=p_medico
AND data=p_data
AND horario=p_horario
AND status='AGENDADA'

)

THEN

SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Médico indisponível neste horário';

END IF;

INSERT INTO consultas(

paciente_id,
medico_id,
data,
horario,
tipo,
status

)

VALUES(

p_paciente,
p_medico,
p_data,
p_horario,
p_tipo,
'AGENDADA'

);

COMMIT;

END $$


CREATE PROCEDURE sp_cancelar_consulta(

IN p_consulta INT

)

BEGIN

UPDATE consultas

SET status='CANCELADA'

WHERE id=p_consulta;

END $$


CREATE PROCEDURE sp_finalizar_consulta(

IN p_consulta INT

)

BEGIN

UPDATE consultas

SET status='REALIZADA'

WHERE id=p_consulta;

END $$


CREATE PROCEDURE sp_prontuario(

IN p_consulta INT,
IN p_queixa TEXT,
IN p_diagnostico TEXT,
IN p_prescricao TEXT,
IN p_observacoes TEXT

)

BEGIN

INSERT INTO prontuarios(

consulta_id,
queixa,
diagnostico,
prescricao,
observacoes

)

VALUES(

p_consulta,
p_queixa,
p_diagnostico,
p_prescricao,
p_observacoes

);

END $$
-- ==========================================
-- TRIGGERS
-- ==========================================

CREATE TRIGGER trg_auditoria_cancelamento
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN

    IF NEW.status = 'CANCELADA'
       AND OLD.status <> 'CANCELADA'
    THEN

        INSERT INTO auditoria (
            tabela_afetada,
            operacao,
            usuario,
            descricao
        )
        VALUES (
            'consultas',
            'UPDATE',
            CURRENT_USER(),
            CONCAT(
                'Consulta ',
                NEW.id,
                ' cancelada pelo usuário do banco.'
            )
        );

    END IF;

END $$


CREATE TRIGGER trg_status_consulta
BEFORE INSERT ON consultas
FOR EACH ROW
BEGIN

    IF NEW.data < CURDATE() THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Não é permitido agendar consultas em datas passadas';

    END IF;

END $$


CREATE TRIGGER trg_medico_email
BEFORE INSERT ON medicos
FOR EACH ROW
BEGIN

    IF NEW.email IS NULL
       OR NEW.email = ''
    THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='O médico deve possuir um e-mail cadastrado';

    END IF;

END $$


CREATE TRIGGER trg_paciente_cpf
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN

    IF LENGTH(NEW.cpf) <> 14 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='CPF inválido. Utilize o formato 000.000.000-00';

    END IF;

END $$


CREATE TRIGGER trg_status_delete
BEFORE DELETE ON consultas
FOR EACH ROW
BEGIN

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Consultas não podem ser excluídas. Utilize o cancelamento.';

END $$

DELIMITER ;
-- ==========================================
-- ÍNDICES
-- ==========================================

CREATE INDEX idx_nome_medico
ON medicos(nome);

CREATE INDEX idx_nome_paciente
ON pacientes(nome);

CREATE INDEX idx_consulta_data
ON consultas(data);

CREATE INDEX idx_consulta_status
ON consultas(status);

CREATE INDEX idx_consulta_medico
ON consultas(medico_id);

CREATE INDEX idx_consulta_paciente
ON consultas(paciente_id);


-- ==========================================
-- EXPLAIN
-- ==========================================

EXPLAIN
SELECT *
FROM consultas
WHERE data='2026-07-01';

EXPLAIN
SELECT *
FROM pacientes
WHERE nome='João';

EXPLAIN
SELECT *
FROM medicos
WHERE nome='Carlos';

EXPLAIN
SELECT *
FROM consultas
WHERE medico_id=1
AND status='AGENDADA';

INSERT INTO medicos
(nome, crm, especialidade, telefone, email, dias, horario_inicio, horario_fim)
VALUES
('Carlos Henrique', 'CRM12345', 'Clínico Geral', '(83)99999-1111', 'carlos@medsync.com', 'Segunda,Quarta,Sexta', '08:00:00', '17:00:00'),

('Fernanda Lima', 'CRM23456', 'Cardiologia', '(83)99999-2222', 'fernanda@medsync.com', 'Terça,Quinta', '09:00:00', '18:00:00'),

('João Pedro', 'CRM34567', 'Pediatria', '(83)99999-3333', 'joao@medsync.com', 'Segunda a Sexta', '07:30:00', '16:30:00');

INSERT INTO pacientes
(nome, cpf, nascimento, telefone, convenio)
VALUES
('Ana Souza', '111.111.111-11', '1998-04-12', '(83)98888-1111', 'Unimed'),

('Bruno Silva', '222.222.222-22', '1993-10-20', '(83)98888-2222', 'Hapvida'),

('Camila Oliveira', '333.333.333-33', '2000-01-15', '(83)98888-3333', 'Particular'),

('Diego Santos', '444.444.444-44', '1987-08-03', '(83)98888-4444', 'Unimed'),

('Eduarda Lima', '555.555.555-55', '1995-12-09', '(83)98888-5555', 'SulAmérica'),

('Felipe Costa', '666.666.666-66', '2002-05-18', '(83)98888-6666', 'Particular');

INSERT INTO consultas
(paciente_id, medico_id, data, horario, tipo, status)
VALUES
(1,1,'2026-07-05','08:30:00','Presencial','AGENDADA'),

(2,2,'2026-07-05','09:30:00','Online','REALIZADA'),

(3,3,'2026-07-06','10:00:00','Presencial','AGENDADA'),

(4,1,'2026-07-06','11:30:00','Retorno','CANCELADA'),

(5,2,'2026-07-07','14:00:00','Presencial','AGENDADA'),

(6,3,'2026-07-08','15:30:00','Online','REALIZADA');

INSERT INTO prontuarios
(consulta_id, queixa, diagnostico, prescricao, observacoes)
VALUES
(2,
'Dor no peito',
'Hipertensão',
'Losartana 50mg',
'Retorno em 30 dias'),

(6,
'Febre e dor de garganta',
'Infecção viral',
'Paracetamol 750mg',
'Repouso e hidratação');
