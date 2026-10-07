-- ============================================================
-- NutriMatch
-- Hospital Diet Management System
-- MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS NutriMatch;

CREATE DATABASE NutriMatch
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE NutriMatch;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- ============================================================
-- 1. PEOPLE AND SECURITY
-- ============================================================

CREATE TABLE PERSON (
    person_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    national_id VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(30),
    email VARCHAR(150) NOT NULL UNIQUE,
    birth_date DATE,
    registration_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE ROLE (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE = InnoDB;


CREATE TABLE USER_ACCOUNT (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login DATETIME,

    CONSTRAINT fk_user_account_person
        FOREIGN KEY (person_id)
        REFERENCES PERSON(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE USER_ROLE (
    user_id INT NOT NULL,
    role_id INT NOT NULL,

    PRIMARY KEY (user_id, role_id),

    CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id)
        REFERENCES USER_ACCOUNT(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_user_role_role
        FOREIGN KEY (role_id)
        REFERENCES ROLE(role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 2. HOSPITAL STRUCTURE
-- ============================================================

CREATE TABLE HOSPITAL (
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(30),
    email VARCHAR(150),
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE FLOOR (
    floor_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,
    number INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),

    UNIQUE (hospital_id, number),

    CONSTRAINT fk_floor_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES HOSPITAL(hospital_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE ROOM (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    floor_id INT NOT NULL,
    number VARCHAR(20) NOT NULL,
    type VARCHAR(50),

    UNIQUE (floor_id, number),

    CONSTRAINT fk_room_floor
        FOREIGN KEY (floor_id)
        REFERENCES FLOOR(floor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE BED (
    bed_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    number VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'FREE',

    UNIQUE (room_id, number),

    CONSTRAINT fk_bed_room
        FOREIGN KEY (room_id)
        REFERENCES ROOM(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 3. PATIENTS AND ADMISSIONS
-- ============================================================

CREATE TABLE PATIENT (
    patient_id INT PRIMARY KEY,
    medical_record_number VARCHAR(50) NOT NULL UNIQUE,

    CONSTRAINT fk_patient_person
        FOREIGN KEY (patient_id)
        REFERENCES PERSON(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE ADMISSION (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    bed_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    reason VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    notes TEXT,

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES PATIENT(patient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_admission_bed
        FOREIGN KEY (bed_id)
        REFERENCES BED(bed_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE COMPANION (
    companion_id INT PRIMARY KEY,

    CONSTRAINT fk_companion_person
        FOREIGN KEY (companion_id)
        REFERENCES PERSON(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE COMPANIONSHIP (
    companionship_id INT AUTO_INCREMENT PRIMARY KEY,
    companion_id INT NOT NULL,
    admission_id INT NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    notes TEXT,

    CONSTRAINT fk_companionship_companion
        FOREIGN KEY (companion_id)
        REFERENCES COMPANION(companion_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_companionship_admission
        FOREIGN KEY (admission_id)
        REFERENCES ADMISSION(admission_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 4. RULE ENGINE
-- ============================================================

CREATE TABLE RULE (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    operator VARCHAR(30) NOT NULL,
    value VARCHAR(255) NOT NULL,
    unit VARCHAR(50),
    scope VARCHAR(50),
    severity VARCHAR(30),
    message VARCHAR(255),
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE COMPANION_RESTRICTION (
    restriction_id INT AUTO_INCREMENT PRIMARY KEY,
    companion_id INT NOT NULL,
    rule_id INT NOT NULL,
    type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,

    CONSTRAINT fk_companion_restriction_companion
        FOREIGN KEY (companion_id)
        REFERENCES COMPANION(companion_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_companion_restriction_rule
        FOREIGN KEY (rule_id)
        REFERENCES RULE(rule_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 5. CLINICAL INFORMATION
-- ============================================================

CREATE TABLE PATHOLOGY (
    pathology_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE PATIENT_PATHOLOGY (
    patient_id INT NOT NULL,
    pathology_id INT NOT NULL,
    diagnosis_date DATE,
    end_date DATE,
    notes TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (patient_id, pathology_id),

    CONSTRAINT fk_patient_pathology_patient
        FOREIGN KEY (patient_id)
        REFERENCES PATIENT(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_pathology_pathology
        FOREIGN KEY (pathology_id)
        REFERENCES PATHOLOGY(pathology_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 6. DIETS
-- ============================================================

CREATE TABLE DIET (
    diet_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE DIET_VERSION (
    diet_version_id INT AUTO_INCREMENT PRIMARY KEY,
    diet_id INT NOT NULL,
    version_number INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    UNIQUE (diet_id, version_number),

    CONSTRAINT fk_diet_version_diet
        FOREIGN KEY (diet_id)
        REFERENCES DIET(diet_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE PATHOLOGY_DIET (
    pathology_id INT NOT NULL,
    diet_id INT NOT NULL,
    notes TEXT,

    PRIMARY KEY (pathology_id, diet_id),

    CONSTRAINT fk_pathology_diet_pathology
        FOREIGN KEY (pathology_id)
        REFERENCES PATHOLOGY(pathology_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_pathology_diet_diet
        FOREIGN KEY (diet_id)
        REFERENCES DIET(diet_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE ADMISSION_DIET (
    admission_diet_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    diet_version_id INT NOT NULL,
    prescribing_user_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    notes TEXT,

    CONSTRAINT fk_admission_diet_admission
        FOREIGN KEY (admission_id)
        REFERENCES ADMISSION(admission_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_admission_diet_version
        FOREIGN KEY (diet_version_id)
        REFERENCES DIET_VERSION(diet_version_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_admission_diet_user
        FOREIGN KEY (prescribing_user_id)
        REFERENCES USER_ACCOUNT(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE DIET_VERSION_RULE (
    diet_version_id INT NOT NULL,
    rule_id INT NOT NULL,

    PRIMARY KEY (diet_version_id, rule_id),

    CONSTRAINT fk_diet_version_rule_version
        FOREIGN KEY (diet_version_id)
        REFERENCES DIET_VERSION(diet_version_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_diet_version_rule_rule
        FOREIGN KEY (rule_id)
        REFERENCES RULE(rule_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 7. NUTRITIONAL INFORMATION
-- ============================================================

CREATE TABLE INGREDIENT (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    measurement_unit VARCHAR(50),
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE NUTRIENT (
    nutrient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    base_unit VARCHAR(30) NOT NULL,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE INGREDIENT_NUTRIENT (
    ingredient_id INT NOT NULL,
    nutrient_id INT NOT NULL,
    quantity_per_100g DECIMAL(10,4) NOT NULL,

    PRIMARY KEY (ingredient_id, nutrient_id),

    CONSTRAINT fk_ingredient_nutrient_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ingredient_nutrient_nutrient
        FOREIGN KEY (nutrient_id)
        REFERENCES NUTRIENT(nutrient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE ALLERGEN (
    allergen_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE INGREDIENT_ALLERGEN (
    ingredient_id INT NOT NULL,
    allergen_id INT NOT NULL,

    PRIMARY KEY (ingredient_id, allergen_id),

    CONSTRAINT fk_ingredient_allergen_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ingredient_allergen_allergen
        FOREIGN KEY (allergen_id)
        REFERENCES ALLERGEN(allergen_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE DIETARY_CHARACTERISTIC (
    characteristic_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE INGREDIENT_CHARACTERISTIC (
    ingredient_id INT NOT NULL,
    characteristic_id INT NOT NULL,

    PRIMARY KEY (ingredient_id, characteristic_id),

    CONSTRAINT fk_ingredient_characteristic_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ingredient_characteristic_characteristic
        FOREIGN KEY (characteristic_id)
        REFERENCES DIETARY_CHARACTERISTIC(characteristic_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 8. NUTRITIONAL RULES
-- ============================================================

CREATE TABLE RULE_NUTRIENT (
    rule_id INT NOT NULL,
    nutrient_id INT NOT NULL,

    PRIMARY KEY (rule_id, nutrient_id),

    CONSTRAINT fk_rule_nutrient_rule
        FOREIGN KEY (rule_id)
        REFERENCES RULE(rule_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_rule_nutrient_nutrient
        FOREIGN KEY (nutrient_id)
        REFERENCES NUTRIENT(nutrient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE RULE_ALLERGEN (
    rule_id INT NOT NULL,
    allergen_id INT NOT NULL,

    PRIMARY KEY (rule_id, allergen_id),

    CONSTRAINT fk_rule_allergen_rule
        FOREIGN KEY (rule_id)
        REFERENCES RULE(rule_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_rule_allergen_allergen
        FOREIGN KEY (allergen_id)
        REFERENCES ALLERGEN(allergen_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE RULE_CHARACTERISTIC (
    rule_id INT NOT NULL,
    characteristic_id INT NOT NULL,

    PRIMARY KEY (rule_id, characteristic_id),

    CONSTRAINT fk_rule_characteristic_rule
        FOREIGN KEY (rule_id)
        REFERENCES RULE(rule_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_rule_characteristic_characteristic
        FOREIGN KEY (characteristic_id)
        REFERENCES DIETARY_CHARACTERISTIC(characteristic_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 9. DISHES AND RECIPES
-- ============================================================

CREATE TABLE DISH (
    dish_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    type VARCHAR(50),
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;


CREATE TABLE DISH_VERSION (
    dish_version_id INT AUTO_INCREMENT PRIMARY KEY,
    dish_id INT NOT NULL,
    version_number INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    validated BOOLEAN NOT NULL DEFAULT FALSE,
    validator_user_id INT,
    validation_date DATETIME,

    UNIQUE (dish_id, version_number),

    CONSTRAINT fk_dish_version_dish
        FOREIGN KEY (dish_id)
        REFERENCES DISH(dish_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_dish_version_user
        FOREIGN KEY (validator_user_id)
        REFERENCES USER_ACCOUNT(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE = InnoDB;


CREATE TABLE DISH_VERSION_INGREDIENT (
    dish_version_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity DECIMAL(10,3) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    sort_order INT NOT NULL,

    PRIMARY KEY (dish_version_id, ingredient_id),

    CONSTRAINT fk_dish_version_ingredient_version
        FOREIGN KEY (dish_version_id)
        REFERENCES DISH_VERSION(dish_version_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_dish_version_ingredient_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 10. MENUS AND MEAL SELECTIONS
-- ============================================================

CREATE TABLE MENU (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    meal_type VARCHAR(50) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',

    UNIQUE (date, meal_type, version)
) ENGINE = InnoDB;


CREATE TABLE MENU_DISH (
    menu_id INT NOT NULL,
    dish_version_id INT NOT NULL,
    sort_order INT NOT NULL,
    available BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (menu_id, dish_version_id),

    CONSTRAINT fk_menu_dish_menu
        FOREIGN KEY (menu_id)
        REFERENCES MENU(menu_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_menu_dish_dish_version
        FOREIGN KEY (dish_version_id)
        REFERENCES DISH_VERSION(dish_version_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE MEAL_SELECTION (
    meal_selection_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    menu_id INT NOT NULL,
    deadline DATETIME,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    confirmation_date DATETIME,

    UNIQUE (admission_id, menu_id),

    CONSTRAINT fk_meal_selection_admission
        FOREIGN KEY (admission_id)
        REFERENCES ADMISSION(admission_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_meal_selection_menu
        FOREIGN KEY (menu_id)
        REFERENCES MENU(menu_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE MEAL_SELECTION_DISH (
    meal_selection_id INT NOT NULL,
    dish_version_id INT NOT NULL,
    selection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (meal_selection_id, dish_version_id),

    CONSTRAINT fk_meal_selection_dish_selection
        FOREIGN KEY (meal_selection_id)
        REFERENCES MEAL_SELECTION(meal_selection_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_meal_selection_dish_dish_version
        FOREIGN KEY (dish_version_id)
        REFERENCES DISH_VERSION(dish_version_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 11. KITCHEN PRODUCTION
-- ============================================================

CREATE TABLE PRODUCTION_ORDER (
    production_order_id INT AUTO_INCREMENT PRIMARY KEY,
    dish_version_id INT NOT NULL,
    date DATE NOT NULL,
    meal_type VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',

    CONSTRAINT fk_production_order_dish_version
        FOREIGN KEY (dish_version_id)
        REFERENCES DISH_VERSION(dish_version_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE MEAL_ORDER (
    meal_order_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    meal_selection_id INT,
    date DATE NOT NULL,
    meal_type VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    preparation_date DATETIME,
    delivery_date DATETIME,

    CONSTRAINT fk_meal_order_admission
        FOREIGN KEY (admission_id)
        REFERENCES ADMISSION(admission_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_meal_order_selection
        FOREIGN KEY (meal_selection_id)
        REFERENCES MEAL_SELECTION(meal_selection_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE = InnoDB;


CREATE TABLE TRAY (
    tray_id INT AUTO_INCREMENT PRIMARY KEY,
    meal_order_id INT NOT NULL UNIQUE,
    tray_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    preparation_date DATETIME,
    delivery_date DATETIME,

    CONSTRAINT fk_tray_meal_order
        FOREIGN KEY (meal_order_id)
        REFERENCES MEAL_ORDER(meal_order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- 12. CONTROL AND INCIDENTS
-- ============================================================

CREATE TABLE INCIDENT (
    incident_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT,
    meal_order_id INT,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    resolution TEXT,

    CONSTRAINT fk_incident_admission
        FOREIGN KEY (admission_id)
        REFERENCES ADMISSION(admission_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_incident_meal_order
        FOREIGN KEY (meal_order_id)
        REFERENCES MEAL_ORDER(meal_order_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_incident_user
        FOREIGN KEY (user_id)
        REFERENCES USER_ACCOUNT(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ============================================================
-- ADDITIONAL INDEXES
-- ============================================================

CREATE INDEX idx_admission_patient
    ON ADMISSION(patient_id);

CREATE INDEX idx_admission_bed
    ON ADMISSION(bed_id);

CREATE INDEX idx_companionship_admission
    ON COMPANIONSHIP(admission_id);

CREATE INDEX idx_companionship_companion
    ON COMPANIONSHIP(companion_id);

CREATE INDEX idx_admission_diet_admission
    ON ADMISSION_DIET(admission_id);

CREATE INDEX idx_admission_diet_version
    ON ADMISSION_DIET(diet_version_id);

CREATE INDEX idx_dish_version_dish
    ON DISH_VERSION(dish_id);

CREATE INDEX idx_menu_date
    ON MENU(date);

CREATE INDEX idx_meal_selection_admission
    ON MEAL_SELECTION(admission_id);

CREATE INDEX idx_meal_order_admission
    ON MEAL_ORDER(admission_id);

CREATE INDEX idx_meal_order_selection
    ON MEAL_ORDER(meal_selection_id);

CREATE INDEX idx_incident_admission
    ON INCIDENT(admission_id);

CREATE INDEX idx_incident_meal_order
    ON INCIDENT(meal_order_id);


-- ============================================================
-- END
-- ============================================================

SET FOREIGN_KEY_CHECKS = 1;