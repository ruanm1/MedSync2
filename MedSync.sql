CREATE DATABASE IF NOT EXISTS medsync;
USE medsync;

CREATE TABLE medicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    dias VARCHAR(100),
    horario_inicio TIME,
    horario_fim TIME
);

CREATE TABLE pacientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nascimento DATE NOT NULL,
    telefone VARCHAR(20),
    convenio VARCHAR(100)
);

CREATE TABLE consultas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    medico_id INT,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    tipo VARCHAR(50),
    status VARCHAR(50) DEFAULT 'AGENDADA',
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    FOREIGN KEY (medico_id) REFERENCES medicos(id)
);

CREATE TABLE prontuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consulta_id INT UNIQUE, -- Um prontuário por consulta
    queixa TEXT,
    diagnostico TEXT,
    prescricao TEXT,
    observacoes TEXT,
    FOREIGN KEY (consulta_id) REFERENCES consultas(id)
);


-- USUÁRIOS DO BANCO


CREATE USER IF NOT EXISTS 'usr_gerente'@'localhost' IDENTIFIED BY 'M3dSync_G3r3nt3_2026';
CREATE USER IF NOT EXISTS 'usr_medico'@'localhost' IDENTIFIED BY 'M3dSync_M3d1c0_2026';
CREATE USER IF NOT EXISTS 'usr_recepcionista'@'localhost' IDENTIFIED BY 'M3dSync_R3c3p_2026';
CREATE USER IF NOT EXISTS 'usr_paciente'@'localhost' IDENTIFIED BY 'M3dSync_P1c13nt3_2026';


-- PERMISSÕES


GRANT ALL PRIVILEGES ON medsync.* TO 'usr_gerente'@'localhost';

GRANT SELECT, INSERT, UPDATE ON medsync.consultas TO 'usr_medico'@'localhost';
GRANT SELECT, INSERT, UPDATE ON medsync.prontuarios TO 'usr_medico'@'localhost';
GRANT SELECT ON medsync.pacientes TO 'usr_medico'@'localhost';

GRANT SELECT, INSERT, UPDATE ON medsync.consultas TO 'usr_recepcionista'@'localhost';
GRANT SELECT, INSERT, UPDATE ON medsync.pacientes TO 'usr_recepcionista'@'localhost';

GRANT SELECT ON medsync.pacientes TO 'usr_paciente'@'localhost';
GRANT SELECT ON medsync.consultas TO 'usr_paciente'@'localhost';

FLUSH PRIVILEGES;


-- VIEWS


CREATE VIEW vw_agenda_medica AS
SELECT
    c.id,
    m.nome AS medico,
    p.nome AS paciente,
    c.data,
    c.horario,
    c.status
FROM consultas c
JOIN medicos m ON c.medico_id = m.id
JOIN pacientes p ON c.paciente_id = p.id;


CREATE VIEW vw_consultas_realizadas AS
SELECT *
FROM consultas
WHERE status='REALIZADA';


CREATE VIEW vw_pacientes_consultas AS
SELECT
    p.nome,
    COUNT(c.id) AS total_consultas
FROM pacientes p
LEFT JOIN consultas c ON p.id = c.paciente_id
GROUP BY p.id, p.nome;


CREATE VIEW vw_prontuarios AS
SELECT
    p.nome AS paciente,
    pr.diagnostico,
    pr.prescricao,
    pr.observacoes
FROM prontuarios pr
JOIN consultas c ON pr.consulta_id = c.id
JOIN pacientes p ON c.paciente_id = p.id;


-- PROCEDURES


DELIMITER $$

CREATE PROCEDURE sp_agendar_consulta(
    IN p_paciente INT,
    IN p_medico INT,
    IN p_data DATE,
    IN p_horario TIME,
    IN p_tipo VARCHAR(50)
)
BEGIN
    INSERT INTO consultas(paciente_id, medico_id, data, horario, tipo, status)
    VALUES(p_paciente, p_medico, p_data, p_horario, p_tipo, 'AGENDADA');
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
    -- Alterado para 'REALIZADA' para manter consistência com a View vw_consultas_realizadas
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
    INSERT INTO prontuarios(consulta_id, queixa, diagnostico, prescricao, observacoes)
    VALUES(p_consulta, p_queixa, p_diagnostico, p_prescricao, p_observacoes);
END $$


-- TRIGGERS


CREATE TRIGGER trg_status_consulta
BEFORE INSERT ON consultas
FOR EACH ROW
BEGIN
    IF NEW.data < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Não é permitido cadastrar consultas em datas passadas';
    END IF;
END $$

CREATE TRIGGER trg_medico_email
BEFORE INSERT ON medicos
FOR EACH ROW
BEGIN
    IF NEW.email IS NULL OR NEW.email='' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Email obrigatório';
    END IF;
END $$

CREATE TRIGGER trg_paciente_cpf
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.cpf) <> 14 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='CPF inválido. Certifique-se de incluir pontos e hífen (ex: 000.000.000-00)';
    END IF;
END $$

CREATE TRIGGER trg_status_delete
BEFORE DELETE ON consultas
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Consultas não podem ser apagadas. Apenas canceladas.';
END $$

DELIMITER ;


-- ÍNDICES E EXPLAIN


CREATE INDEX idx_nome_medico ON medicos(nome);
CREATE INDEX idx_nome_paciente ON pacientes(nome);
CREATE INDEX idx_consulta_data ON consultas(data);
CREATE INDEX idx_status ON consultas(status);

EXPLAIN SELECT * FROM consultas WHERE data='2026-07-01';
EXPLAIN SELECT * FROM pacientes WHERE nome='João';