#+ Database creation script for IBM Informix
#+
#+ Note: This script is a helper script to create an empty database schema
#+       Adapt it to fit your needs

MAIN
    DATABASE hr

    CALL db_drop_constraints()
    CALL db_drop_tables()
    CALL db_create_tables()
    CALL db_add_indexes()
    CALL db_add_constraints()
END MAIN

#+ Create all tables in database.
FUNCTION db_create_tables()
    WHENEVER ERROR STOP

    EXECUTE IMMEDIATE "CREATE TABLE activity (
        activity_code CHAR(8) NOT NULL,
        description CHAR(30) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE annualleave (
        employee_no INTEGER NOT NULL,
        annual_date DATE NOT NULL,
        annual_adjustment DECIMAL(11,2) NOT NULL,
        annual_runningbalance DECIMAL(11,2) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE employee (
        employee_no INTEGER NOT NULL,
        firstname CHAR(30) NOT NULL,
        middlenames CHAR(30),
        surname CHAR(30) NOT NULL,
        preferredname CHAR(30),
        title_id CHAR(5) NOT NULL,
        birthdate DATE NOT NULL,
        gender CHAR(1) NOT NULL,
        address1 CHAR(40) NOT NULL,
        address2 CHAR(40),
        address3 CHAR(40),
        address4 CHAR(40),
        country_id CHAR(3) NOT NULL,
        postcode CHAR(10) NOT NULL,
        phone CHAR(20) NOT NULL,
        mobile CHAR(20) NOT NULL,
        email CHAR(40),
        startdate DATE,
        position CHAR(20) NOT NULL,
        taxnumber CHAR(20) NOT NULL,
        base DECIMAL(10,2) NOT NULL,
        basetype CHAR(3) NOT NULL,
        sick_balance DECIMAL(5,1) NOT NULL,
        annual_balance DECIMAL(5,1) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE paysummary (
        employee_no INTEGER NOT NULL,
        pay_date DATE NOT NULL,
        pay_amount DECIMAL(10,2) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE sickleave (
        employee_no INTEGER NOT NULL,
        sick_date DATE NOT NULL,
        sick_adjustment DECIMAL(11,2) NOT NULL,
        sick_runningbalance DECIMAL(11,2) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE timesheet_dtl (
        tsheet_no INTEGER NOT NULL,
        activity_code CHAR(8) NOT NULL,
        narrative CHAR(40),
        hours DECIMAL(5,2) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE timesheet_hdr (
        tsheet_no INTEGER NOT NULL,
        tsheet_date DATE NOT NULL,
        employee_no INTEGER NOT NULL,
        comment CHAR(40))"
    EXECUTE IMMEDIATE "CREATE TABLE country (
        country_id CHAR(3) NOT NULL,
        name CHAR(20) NOT NULL,
        phone_code CHAR(4) NOT NULL,
        postcode_length INTEGER NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE title (
        title_id CHAR(8) NOT NULL,
        description CHAR(20) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE qualfication (
        employee_no INTEGER NOT NULL,
        qual_date DATE NOT NULL,
        qual_id CHAR(8) NOT NULL,
        narrative CHAR(30))"
    EXECUTE IMMEDIATE "CREATE TABLE qual_type (
        qual_id CHAR(8) NOT NULL,
        level INTEGER NOT NULL,
        description CHAR(30) NOT NULL)"

END FUNCTION

#+ Drop all tables from database.
FUNCTION db_drop_tables()
    WHENEVER ERROR CONTINUE

    EXECUTE IMMEDIATE "DROP TABLE activity"
    EXECUTE IMMEDIATE "DROP TABLE annualleave"
    EXECUTE IMMEDIATE "DROP TABLE employee"
    EXECUTE IMMEDIATE "DROP TABLE paysummary"
    EXECUTE IMMEDIATE "DROP TABLE sickleave"
    EXECUTE IMMEDIATE "DROP TABLE timesheet_dtl"
    EXECUTE IMMEDIATE "DROP TABLE timesheet_hdr"
    EXECUTE IMMEDIATE "DROP TABLE country"
    EXECUTE IMMEDIATE "DROP TABLE title"
    EXECUTE IMMEDIATE "DROP TABLE qualfication"
    EXECUTE IMMEDIATE "DROP TABLE qual_type"

END FUNCTION

#+ Add constraints for all tables.
FUNCTION db_add_constraints()
    WHENEVER ERROR STOP

    EXECUTE IMMEDIATE "ALTER TABLE activity ADD CONSTRAINT
        PRIMARY KEY (activity_code)
        CONSTRAINT cx_activity000"
    EXECUTE IMMEDIATE "ALTER TABLE annualleave ADD CONSTRAINT
        PRIMARY KEY (employee_no, annual_date)
        CONSTRAINT cx_annlv000"
    EXECUTE IMMEDIATE "ALTER TABLE employee ADD CONSTRAINT
        PRIMARY KEY (employee_no)
        CONSTRAINT cx_empl000"
    EXECUTE IMMEDIATE "ALTER TABLE paysummary ADD CONSTRAINT
        PRIMARY KEY (employee_no, pay_date)
        CONSTRAINT cx_paysum000"
    EXECUTE IMMEDIATE "ALTER TABLE sickleave ADD CONSTRAINT
        PRIMARY KEY (employee_no, sick_date)
        CONSTRAINT cx_sicklv000"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl ADD CONSTRAINT
        PRIMARY KEY (tsheet_no, activity_code)
        CONSTRAINT cx_tsdtl000"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_hdr ADD CONSTRAINT
        PRIMARY KEY (tsheet_no)
        CONSTRAINT cx_tshdr000"
    EXECUTE IMMEDIATE "ALTER TABLE country ADD CONSTRAINT
        PRIMARY KEY (country_id)
        CONSTRAINT pk_country_1"
    EXECUTE IMMEDIATE "ALTER TABLE title ADD CONSTRAINT
        PRIMARY KEY (title_id)
        CONSTRAINT pk_honorific_1"
    EXECUTE IMMEDIATE "ALTER TABLE qualfication ADD CONSTRAINT
        PRIMARY KEY (employee_no, qual_date)
        CONSTRAINT pk_qualfication_1"
    EXECUTE IMMEDIATE "ALTER TABLE qual_type ADD CONSTRAINT
        PRIMARY KEY (qual_id)
        CONSTRAINT pk_qual_type_1"
    EXECUTE IMMEDIATE "ALTER TABLE annualleave ADD CONSTRAINT 
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)
        CONSTRAINT cx_annlv001"
    EXECUTE IMMEDIATE "ALTER TABLE paysummary ADD CONSTRAINT 
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)
        CONSTRAINT cx_paysum001"
    EXECUTE IMMEDIATE "ALTER TABLE sickleave ADD CONSTRAINT 
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)
        CONSTRAINT cx_sicklv001"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl ADD CONSTRAINT 
        FOREIGN KEY (tsheet_no)
        REFERENCES timesheet_hdr (tsheet_no)
        CONSTRAINT cx_tsdtl001"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl ADD CONSTRAINT 
        FOREIGN KEY (activity_code)
        REFERENCES activity (activity_code)
        CONSTRAINT cx_tsdtl002"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_hdr ADD CONSTRAINT 
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)
        CONSTRAINT cx_tshdr001"
    EXECUTE IMMEDIATE "ALTER TABLE qualfication ADD CONSTRAINT 
        FOREIGN KEY (qual_id)
        REFERENCES qual_type (qual_id)
        CONSTRAINT fk_qualfication_qual_type_1"
    EXECUTE IMMEDIATE "ALTER TABLE employee ADD CONSTRAINT 
        FOREIGN KEY (country_id)
        REFERENCES country (country_id)
        CONSTRAINT fk_employee_country_1"
    EXECUTE IMMEDIATE "ALTER TABLE employee ADD CONSTRAINT 
        FOREIGN KEY (title_id)
        REFERENCES title (title_id)
        CONSTRAINT fk_employee_title_1"
    EXECUTE IMMEDIATE "ALTER TABLE qualfication ADD CONSTRAINT 
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)
        CONSTRAINT fk_qualfication_employee_1"

END FUNCTION

#+ Drop all constraints from all tables.
FUNCTION db_drop_constraints()
    WHENEVER ERROR CONTINUE

    EXECUTE IMMEDIATE "ALTER TABLE annualleave DROP CONSTRAINT cx_annlv001"
    EXECUTE IMMEDIATE "ALTER TABLE paysummary DROP CONSTRAINT cx_paysum001"
    EXECUTE IMMEDIATE "ALTER TABLE sickleave DROP CONSTRAINT cx_sicklv001"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl DROP CONSTRAINT cx_tsdtl001"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl DROP CONSTRAINT cx_tsdtl002"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_hdr DROP CONSTRAINT cx_tshdr001"
    EXECUTE IMMEDIATE "ALTER TABLE qualfication DROP CONSTRAINT fk_qualfication_qual_type_1"
    EXECUTE IMMEDIATE "ALTER TABLE employee DROP CONSTRAINT fk_employee_country_1"
    EXECUTE IMMEDIATE "ALTER TABLE employee DROP CONSTRAINT fk_employee_title_1"
    EXECUTE IMMEDIATE "ALTER TABLE qualfication DROP CONSTRAINT fk_qualfication_employee_1"

END FUNCTION

#+ Add indexes for all tables.
FUNCTION db_add_indexes()
    WHENEVER ERROR STOP

    EXECUTE IMMEDIATE "CREATE INDEX ix_empl001 ON employee(surname)"

END FUNCTION


