-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: medsync
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `consultas`
--

LOCK TABLES `consultas` WRITE;
/*!40000 ALTER TABLE `consultas` DISABLE KEYS */;
INSERT INTO `consultas` VALUES (1,1,1,'2026-07-05','08:30:00','Presencial','AGENDADA'),(2,2,2,'2026-07-05','09:30:00','Online','REALIZADA'),(3,3,3,'2026-07-06','10:00:00','Presencial','AGENDADA'),(4,4,1,'2026-07-06','11:30:00','Retorno','CANCELADA'),(5,5,2,'2026-07-07','14:00:00','Presencial','AGENDADA'),(6,6,3,'2026-07-08','15:30:00','Online','REALIZADA');
/*!40000 ALTER TABLE `consultas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `medicos`
--

LOCK TABLES `medicos` WRITE;
/*!40000 ALTER TABLE `medicos` DISABLE KEYS */;
INSERT INTO `medicos` VALUES (1,'Carlos Henrique','CRM12345','Clínico Geral','(83)99999-1111','carlos@medsync.com','Segunda,Quarta,Sexta','08:00:00','17:00:00'),(2,'Fernanda Lima','CRM23456','Cardiologia','(83)99999-2222','fernanda@medsync.com','Terça,Quinta','09:00:00','18:00:00'),(3,'João Pedro','CRM34567','Pediatria','(83)99999-3333','joao@medsync.com','Segunda a Sexta','07:30:00','16:30:00');
/*!40000 ALTER TABLE `medicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pacientes`
--

LOCK TABLES `pacientes` WRITE;
/*!40000 ALTER TABLE `pacientes` DISABLE KEYS */;
INSERT INTO `pacientes` VALUES (1,'Ana Souza','111.111.111-11','1998-04-12','(83)98888-1111','Unimed'),(2,'Bruno Silva','222.222.222-22','1993-10-20','(83)98888-2222','Hapvida'),(3,'Camila Oliveira','333.333.333-33','2000-01-15','(83)98888-3333','Particular'),(4,'Diego Santos','444.444.444-44','1987-08-03','(83)98888-4444','Unimed'),(5,'Eduarda Lima','555.555.555-55','1995-12-09','(83)98888-5555','SulAmérica'),(6,'Felipe Costa','666.666.666-66','2002-05-18','(83)98888-6666','Particular');
/*!40000 ALTER TABLE `pacientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `prontuarios`
--

LOCK TABLES `prontuarios` WRITE;
/*!40000 ALTER TABLE `prontuarios` DISABLE KEYS */;
INSERT INTO `prontuarios` VALUES (1,2,'Dor no peito','Hipertensão','Losartana 50mg','Retorno em 30 dias'),(2,6,'Febre e dor de garganta','Infecção viral','Paracetamol 750mg','Repouso e hidratação');
/*!40000 ALTER TABLE `prontuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-30 17:50:42
