CREATE DATABASE  IF NOT EXISTS `stock` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `stock`;
-- MySQL dump 10.13  Distrib 8.0.28, for Win64 (x86_64)
--
-- Host: localhost    Database: stock
-- ------------------------------------------------------
-- Server version	8.0.28

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
-- Table structure for table `equity`
--

DROP TABLE IF EXISTS `equity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equity` (
  `code` varchar(20) NOT NULL,
  `equityName` varchar(120) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `currency` varchar(3) DEFAULT NULL,
  `yahooCode` varchar(20) DEFAULT NULL,
  `inverstingCode` varchar(20) DEFAULT NULL,
  `iTradeCode` varchar(20) DEFAULT NULL,
  `IBCode` varchar(20) DEFAULT NULL,
  `active` tinyint DEFAULT '1',
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equity`
--

LOCK TABLES `equity` WRITE;
/*!40000 ALTER TABLE `equity` DISABLE KEYS */;
INSERT INTO `equity` VALUES ('AAPL','Apple Inc','Share','USD','AAPL',NULL,NULL,NULL,1),('ACQ','Autocanada Inc','Share','CAD','ACQ.TO','','','',1),('AEM','Agnico Eagle Mines Limited','Share','CAD','AEM.TO',NULL,NULL,NULL,1),('AMD','Advanced Micro Devices, Inc','Share','USD','AMD',NULL,NULL,NULL,1),('AMZN','Amazon.com Inc','Share','USD','AMZN',NULL,NULL,NULL,1),('AQN','Algonquin Power & Utilities Corp. ','Share','CAD','AQN.TO',NULL,NULL,NULL,1),('ARE','Aecon Group','Share','CAD','ARE.TO',NULL,NULL,NULL,1),('ARKK','ARK Innovation ETF','ETF','USD','ARKK','ARKK','','',1),('ARKW','ARK Next Generation Internet ETF','ETF','USD','ARKW','ARKW','','',1),('AYM','Atalaya Mining Ltd','Share','CAD','AYM.TO',NULL,NULL,NULL,1),('BAM-A','Brookfield Asset Management Inc','Share','CAD','BAM-A.TO',NULL,NULL,NULL,1),('BB','BlackBerry Limited ','Share','CAD','BB.TO',NULL,NULL,NULL,1),('BBD-B','Bombardier Inc.','Share','CAD','BBD-B.TO',NULL,NULL,NULL,1),('BEP-UN','Brookfield Renewable','Share','CAD','BEP-UN.TO','','','',1),('BIDU','BAIDU Inc','Share','USD','BIDU',NULL,NULL,NULL,1),('BLDP','Ballard','Share','USD','BLDP','','','',1),('BLDPT','Ballard','Share','CAD','BLDP.TO','','','',1),('BNS','Scotia Bank','Share','CAD','BNS.TO',NULL,NULL,NULL,1),('BOS','AirBoss of America Corp.','Share','CAD','BOS.TO',NULL,NULL,NULL,1),('CAE','CAE Inc.','Share','USD','CAE','','','',1),('CAET','CAE Inc.','Share','CAD','CAE.TO','','','',1),('CCO','Cameco','Share','CAD','CCO.TO',NULL,NULL,NULL,1),('CF','Canaccord Genuity','Share','CAD','CF.TO','','','',1),('CFX','Canfor Pulp Products','Share','CAD','CFX.TO','','','',1),('CJT','CargoJet Inc','Share','CAD','CJT.TO',NULL,NULL,NULL,1),('CLIQ','Alcanna','Share','CAD','CLIQ.TO','','','',1),('CM','Canadian Imperial Bank of Commerce','Share','CAD','CM.TO',NULL,NULL,NULL,1),('CNQ','Canadian Natural Resources','Share','CAD','CNQ.TO',NULL,NULL,NULL,1),('CP','Canadian Pacific Railway Limited ','Share','CAD','CP.TO',NULL,NULL,NULL,1),('CPG','Crescent Point Energy Corp. ','Share','CAD','CPG.TO',NULL,NULL,NULL,1),('CRSP','CRISPR THERAPEUTICS AG','Share','USD','CRSP','CRSP','','',1),('CSU','Constellation Software Inc.','Share','CAD','CSU.TO',NULL,NULL,NULL,1),('CTS','Converge Technology Solutions Corp. ','Share','CAD','CTS.TO',NULL,NULL,NULL,1),('CWEB','Charlotte\'s Web','Share','CAD','CWEB.TO','','','',1),('CWEBT','Direxion Shares ETF Trust - Direxion Daily CSI China Internet Index Bull 2X Shares','ETF','USD','CWEB','','','',1),('DCBO','Docebo','Share','USD','DCBO','','','',1),('DCBOT','Docebo','Share','CAD','DCBO.TO','','','',1),('DE','Deere & Co','Share','USD','DE',NULL,NULL,NULL,1),('DII-B','Dorel Industries','Share','CAD','DII-B.TO','','','',1),('DND','Dye & Durham Ltd','Share','CAD','DND.TO',NULL,NULL,NULL,1),('DOC','CloudMD Software','Share','CAD','DOC.V',NULL,NULL,NULL,1),('DR','Medical Facilities','Share','CAD','DR.TO','','','',1),('EAAI','EMERGE ARK AI & BIG DATA ETF','ETF','CAD','EAAI.NE','EAAI','','',1),('EARK','EMERGE ARK GLOBAL DISRUPTIVE IN','ETF','CAD','EARK.NE','EARK','','',1),('EDIT','EDITAS MEDICINE INC','Share','USD','EDIT','EDIT','','',1),('EFX','Enerflex','Share','CAD','EFX.TO','','','',1),('EMA','Emera Inc','Share','CAD','EMA.TO',NULL,NULL,NULL,1),('FB','FACEBOOK INC','Share','USD','FB','FB','','',1),('FOOD','Goodfood inc','Share','CAD','FOOD.TO','','','',1),('FSLY','FASTLY INC','Share','USD','FSLY','FSLY','','',1),('FTS','Fortis Inc','Share','CAD','FTS.TO',NULL,NULL,NULL,1),('GLXY','Galaxy Digital','Share','CAD','GLXY.TO','','','',1),('GOOS','Canada Goose','Share','USD','GOOS','','','',1),('GOOST','Canada Goose','Share','CAD','GOOS.TO','','','',1),('GPV','GreenPower Motor Company Inc.','Share','CAD','GPV.V',NULL,NULL,NULL,1),('GSY','Goeasy Ltd.','Share','CAD','GSY.TO',NULL,NULL,NULL,1),('HEXO','HEXO','Share','CAD','HEXO.TO',NULL,NULL,NULL,1),('HQD','BetaPro NASDAQ -2x Daily Bear ETF','ETF','CAD','HQD.TO','','','',1),('HSD','BetaPro S&P 500 -2x Daily Bear ETF','ETF','CAD','HSD.TO','','','',1),('HUYA','HUYA Inc.','Share','USD','HUYA','HUYA','','',1),('INTU','INTUIT Inc','Share','USD','INTU',NULL,NULL,NULL,1),('IOVA','IOVANCE BIOTHERAPEUTICS INC','Share','USD','IOVA','IOVA','','',1),('KXS','Kinaxis Inc. ','Share','CAD','KXS.TO',NULL,NULL,NULL,1),('LSPD','Lightspeed POS','Share','USD','LSPD','','','',1),('LSPDT','Lightspeed POS','Share','CAD','LSPD.TO','','','',1),('MAXR','Maxar Tech','Share','USD','MAXR','','','',1),('MAXRT','Maxar Tech','Share','CAD','MAXR.TO','','','',1),('MDB','MongoDB, Inc.','Share','USD','MDB',NULL,NULL,NULL,1),('MEOH','Methanex','Share','USD','MEOH','','','',1),('MFC','Manulife Financial Corporation','Share','CAD','MFC.TO',NULL,NULL,NULL,1),('MG','Magna International Inc','Share','CAD','MG.TO',NULL,NULL,NULL,1),('MOGO','Mogo Inc','Share','CAD','MOGO.TO',NULL,NULL,NULL,1),('MRU','Metro Inc','Share','CAD','MRU.TO',NULL,NULL,NULL,1),('MSFT','Microsoft Inc','Share','USD','MSFT',NULL,NULL,NULL,1),('MX','Methanex','Share','CAD','MX.TO','','','',1),('NVEI','Nuvei Corporation','Share','CAD','NVEI.TO',NULL,NULL,NULL,1),('NVTA','INVITAE CORP','Share','USD','NVTA','NVTA','','',1),('PBL','Pollard Banknote','Share','CAD','PBL.TO',NULL,NULL,NULL,1),('PD','PAGERDUTY INC','Share','USD','PD','PD','','',1),('PINS','PINS INC','Share','USD','PINS','PINS','','',1),('PLTR','Palantir Tech','Share','USD','PLTR',NULL,NULL,NULL,1),('PMTS','CPI Card Group Inc','Share','CAD','PMTS.TO',NULL,NULL,NULL,1),('PPL','Pembina Pipeline Corporation','Share','CAD','PPL.TO',NULL,NULL,NULL,1),('PRLB','PROTO LABS INC','Share','USD','PRLB','PRLB','','',1),('PSTG','PURE STORAGE INC - CLASS A','Share','USD','PSTG','PSTG','','',1),('PYPL','PAYPAL HOLDINGS INC','Share','USD','PYPL','PYPL','','',1),('PYR','PyroGenesis Canada Inc.','Share','CAD','PYR.TO',NULL,NULL,NULL,1),('RDFN','Redfin Corporation','Share','USD',NULL,NULL,NULL,NULL,1),('ROKU','ROKU INC','Share','USD','ROKU','ROKU','','',1),('RY','Royal Bank of Canada','Share','USD','RY.TO',NULL,NULL,NULL,1),('SCL','ShawCor','Share','CAD','SCL.TO','','','',1),('SHOP','Shopify Inc','Share','USD','SHOP','','','',1),('SHOPT','Shopify Inc','Share','CAD','SHOP.TO','','','',1),('SI','Silvergate Capital Corp','Share','USD','SI',NULL,NULL,NULL,1),('SNAP','SNAP INC','Share','USD','SNAP','SNAP','','',1),('SPOT','SPOTIFY TECHNOLOGY SA','Share','USD','SPOT','SPOT','','',1),('SQ','SQUARE INC - A','Share','USD','SQ','SQ','','',1),('SU','Suncor Energy Inc. ','Share','CAD','SU.TO',NULL,NULL,NULL,1),('T','Telus Corp','Share','CAD','T.TO',NULL,NULL,NULL,1),('TCS','TECSYS Inc.','Share','CAD','TCS.TO','','','',1),('TDOC','TELADOC HEALTH INC','Share','USD','TDOC','TDOC','','',1),('TFII','TFI International Inc.','Share','CAD','TFII.TO',NULL,NULL,NULL,1),('TOU','Tourmaline Oil','Share','CAD','TOU.TO',NULL,NULL,NULL,1),('TRP','TC Energy Corporation','Share','CAD','TRP.TO',NULL,NULL,NULL,1),('TSLA','TESLA INC','Share','USD','TSLA','TSLA','','',1),('TTD','Trade desk Inc','Share','USD','TTD',NULL,NULL,NULL,1),('TWLO','TWILIO INC','Share','USD','TWLO','TWLO','','',1),('UFS','Domtar Corporation','Share','USD','UFS','','','',1),('UFST','Domtar Corporation','Share','CAD','UFS.TO','','','',1),('UNS','Uni-Select Inc.','Share','CAD','UNS.TO','','','',1),('VEEV','Veeva System Inc','Share','USD','VEEV',NULL,NULL,NULL,1),('VFF','Village Farms International Inc','Share','USD','VFF','','','',1),('VFFT','Village Farms International Inc','Share','CAD','VFF.TO','','','',1),('VUZI','VUZIX CORP','Share','USD','VUZI',NULL,NULL,NULL,1),('WCP','Whitecap Resources','Share','CAD','WCP.TO','','','',1),('WELL','WELL Health','Share','CAD','WELL.TO','','','',1),('WPRT','Westport Fuel','Share','USD','WPRT','','','',1),('WPRTT','Westport Fuel','Share','CAD','WPRT.TO','','','',1),('XQQ','iShares NASDAQ 100 Index ETF','ETF','CAD','XQQ.TO','','','',1),('XSP','iShares Core S&P 500 Index ETF','ETF','CAD','XSP.TO','','','',1),('Z','ZILLOW GROUP INC - C','Share','USD','Z','Z','','',1);
/*!40000 ALTER TABLE `equity` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-11-20 15:51:05
