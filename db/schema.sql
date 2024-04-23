-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema gbc_superstore
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `gbc_superstore` ;

-- -----------------------------------------------------
-- Schema gbc_superstore
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `gbc_superstore` DEFAULT CHARACTER SET utf8 ;
USE `gbc_superstore` ;

-- -----------------------------------------------------
-- Table `gbc_superstore`.`RegionalManager`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`RegionalManager` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`RegionalManager` (
  `Manager_ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Manager_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`Region`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`Region` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`Region` (
  `Region_ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(45) NOT NULL,
  `Manager_ID` INT NOT NULL,
  PRIMARY KEY (`Region_ID`),
  INDEX `fk_Region_Regional_Managers1_idx` (`Manager_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Region_Regional_Managers1`
    FOREIGN KEY (`Manager_ID`)
    REFERENCES `gbc_superstore`.`RegionalManager` (`Manager_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`Category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`Category` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`Category` (
  `Category_ID` INT NOT NULL AUTO_INCREMENT,
  `Category_Name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Category_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`SubCategory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`SubCategory` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`SubCategory` (
  `SubCategory_ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(45) NOT NULL,
  `Category_ID` INT NOT NULL,
  PRIMARY KEY (`SubCategory_ID`),
  INDEX `fk_SubCategories_Categories1_idx` (`Category_ID` ASC) VISIBLE,
  CONSTRAINT `fk_SubCategories_Categories1`
    FOREIGN KEY (`Category_ID`)
    REFERENCES `gbc_superstore`.`Category` (`Category_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`Products`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`Products` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`Products` (
  `Product_ID` VARCHAR(25) NOT NULL,
  `Product_Name` VARCHAR(200) NOT NULL,
  `SubCategory_ID` INT NOT NULL,
  PRIMARY KEY (`Product_ID`),
  INDEX `fk_Products_SubCategories1_idx` (`SubCategory_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Products_SubCategories1`
    FOREIGN KEY (`SubCategory_ID`)
    REFERENCES `gbc_superstore`.`SubCategory` (`SubCategory_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`Customers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`Customers` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`Customers` (
  `Customer_ID` VARCHAR(25) NOT NULL,
  `FullName` VARCHAR(60) NOT NULL,
  `Segment` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Customer_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`ShippingInfo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`ShippingInfo` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`ShippingInfo` (
  `Shipping_ID` INT NOT NULL AUTO_INCREMENT,
  `ShipMode` VARCHAR(60) NOT NULL,
  `City` VARCHAR(60) NULL,
  `State` VARCHAR(60) NULL,
  `Country` VARCHAR(60) NULL,
  `PostalCode` INT NULL,
  PRIMARY KEY (`Shipping_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`Orders`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`Orders` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`Orders` (
  `Order_ID` VARCHAR(25) NOT NULL,
  `OrderDate` DATETIME NOT NULL,
  `ShipDate` DATETIME NOT NULL,
  `Customer_ID` VARCHAR(25) NOT NULL,
  `Shipping_ID` INT NOT NULL,
  `Region_ID` INT NOT NULL,
  PRIMARY KEY (`Order_ID`),
  INDEX `fk_Orders_Customer1_idx` (`Customer_ID` ASC) VISIBLE,
  INDEX `fk_Orders_ShippingInfo1_idx` (`Shipping_ID` ASC) VISIBLE,
  INDEX `fk_Orders_Region1_idx` (`Region_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Orders_Customer1`
    FOREIGN KEY (`Customer_ID`)
    REFERENCES `gbc_superstore`.`Customers` (`Customer_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_ShippingInfo1`
    FOREIGN KEY (`Shipping_ID`)
    REFERENCES `gbc_superstore`.`ShippingInfo` (`Shipping_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Region1`
    FOREIGN KEY (`Region_ID`)
    REFERENCES `gbc_superstore`.`Region` (`Region_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`Returned`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`Returned` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`Returned` (
  `Returned_ID` INT NOT NULL AUTO_INCREMENT,
  `Returned` TINYINT(1) NOT NULL,
  `Order_ID` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`Returned_ID`),
  INDEX `fk_Returns_Orders1_idx` (`Order_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Returns_Orders1`
    FOREIGN KEY (`Order_ID`)
    REFERENCES `gbc_superstore`.`Orders` (`Order_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `gbc_superstore`.`OrderDetails`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gbc_superstore`.`OrderDetails` ;

CREATE TABLE IF NOT EXISTS `gbc_superstore`.`OrderDetails` (
  `OrderDetails_ID` INT NOT NULL AUTO_INCREMENT,
  `Order_ID` VARCHAR(25) NOT NULL,
  `Product_ID` VARCHAR(25) NOT NULL,
  `Sales` DOUBLE NOT NULL,
  `Quantity` INT NOT NULL,
  `Discount` FLOAT NOT NULL,
  `Profit` DOUBLE NOT NULL,
  PRIMARY KEY (`OrderDetails_ID`),
  INDEX `fk_Orders_has_Product_Product1_idx` (`Product_ID` ASC) VISIBLE,
  INDEX `fk_Orders_has_Product_Orders1_idx` (`Order_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Orders_has_Product_Orders1`
    FOREIGN KEY (`Order_ID`)
    REFERENCES `gbc_superstore`.`Orders` (`Order_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_has_Product_Product1`
    FOREIGN KEY (`Product_ID`)
    REFERENCES `gbc_superstore`.`Products` (`Product_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
