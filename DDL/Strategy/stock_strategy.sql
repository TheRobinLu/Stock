CREATE DATABASE  IF NOT EXISTS `stock` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `stock`;
-- MySQL dump 10.13  Distrib 8.0.28, for Win64 (x86_64)
--

DROP TABLE IF EXISTS `strategy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strategy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `StrategyName` varchar(100) DEFAULT NULL,
  `StrategyGroup` varchar(60) DEFAULT NULL,
  `Description` varchar(400) DEFAULT NULL,
  `program` varchar(95) DEFAULT NULL,
  `buySale` int DEFAULT NULL,
  `short_buysale` int DEFAULT NULL,
  `short_risk` int DEFAULT NULL,
  `middle_buysale` int DEFAULT NULL,
  `middle_risk` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=359 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strategy`
--