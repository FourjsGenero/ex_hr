#+ Database creation script for PostgreSQL 8.4 and higher
#+
#+ Note: This script is a helper script to create an empty database schema
#+       Adapt it to fit your needs

IMPORT FGL db
IMPORT FGL dbio

MAIN
    DISPLAY sfmt("FGLPROFILE=%1", fgl_getenv("FGLPROFILE"))

    -- Open database, default monitoring
    if db.Open(NVL(fgl_getenv("DB"),"hr")) != 0
    then
        error "Unable to open database"
        exit program(1)
    end if

    BEGIN WORK
    IF arg_val(1) == "-init"
    THEN
        CALL db_drop_constraints()
        CALL db_drop_tables()
    END IF

    CALL db_create_tables()
    CALL db_add_indexes()
    CALL db_add_constraints()

    CALL dbio.data_in()

    COMMIT WORK
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
        title_id CHAR(8) NOT NULL,
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
    EXECUTE IMMEDIATE "CREATE TABLE qualification (
        employee_no INTEGER NOT NULL,
        qual_date DATE NOT NULL,
        qual_id CHAR(8) NOT NULL,
        narrative VARCHAR(80))"
    EXECUTE IMMEDIATE "CREATE TABLE qual_type (
        qual_id CHAR(8) NOT NULL,
        level INTEGER NOT NULL,
        description CHAR(50) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE review (
        employee_no INTEGER NOT NULL,
        review_date DATE NOT NULL,
        summary CHAR(50) NOT NULL,
        detail VARCHAR(1000))"
    EXECUTE IMMEDIATE "CREATE TABLE leave (
        employee_no INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        days DECIMAL(5,2) NOT NULL,
        reason CHAR(50) NOT NULL,
        approved CHAR(1) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE travel (
        employee_no INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        days DECIMAL(5,2) NOT NULL,
        reason CHAR(50) NOT NULL,
        approved CHAR(1) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE sick (
        employee_no INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        days DECIMAL(5,2) NOT NULL,
        reason CHAR(50) NOT NULL,
        medical CHAR(1) NOT NULL)"
    EXECUTE IMMEDIATE "CREATE TABLE document (
        employee_no INTEGER NOT NULL,
        doc_id CHAR(40) NOT NULL,
        content BYTE)"

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
    EXECUTE IMMEDIATE "DROP TABLE qualification"
    EXECUTE IMMEDIATE "DROP TABLE qual_type"
    EXECUTE IMMEDIATE "DROP TABLE review"
    EXECUTE IMMEDIATE "DROP TABLE leave"
    EXECUTE IMMEDIATE "DROP TABLE travel"
    EXECUTE IMMEDIATE "DROP TABLE sick"
    EXECUTE IMMEDIATE "DROP TABLE document"

END FUNCTION

#+ Add constraints for all tables.
FUNCTION db_add_constraints()
    WHENEVER ERROR STOP

    EXECUTE IMMEDIATE "ALTER TABLE activity ADD CONSTRAINT cx_activity000
        PRIMARY KEY (activity_code)"
    EXECUTE IMMEDIATE "ALTER TABLE annualleave ADD CONSTRAINT cx_annlv000
        PRIMARY KEY (employee_no, annual_date)"
    EXECUTE IMMEDIATE "ALTER TABLE employee ADD CONSTRAINT cx_empl000
        PRIMARY KEY (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE paysummary ADD CONSTRAINT cx_paysum000
        PRIMARY KEY (employee_no, pay_date)"
    EXECUTE IMMEDIATE "ALTER TABLE sickleave ADD CONSTRAINT cx_sicklv000
        PRIMARY KEY (employee_no, sick_date)"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl ADD CONSTRAINT cx_tsdtl000
        PRIMARY KEY (tsheet_no, activity_code)"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_hdr ADD CONSTRAINT cx_tshdr000
        PRIMARY KEY (tsheet_no)"
    EXECUTE IMMEDIATE "ALTER TABLE country ADD CONSTRAINT pk_country_1
        PRIMARY KEY (country_id)"
    EXECUTE IMMEDIATE "ALTER TABLE title ADD CONSTRAINT pk_honorific_1
        PRIMARY KEY (title_id)"
    EXECUTE IMMEDIATE "ALTER TABLE qualification ADD CONSTRAINT pk_qualification_1
        PRIMARY KEY (employee_no, qual_date)"
    EXECUTE IMMEDIATE "ALTER TABLE qual_type ADD CONSTRAINT pk_qual_type_1
        PRIMARY KEY (qual_id)"
    EXECUTE IMMEDIATE "ALTER TABLE review ADD CONSTRAINT pk_review_1
        PRIMARY KEY (employee_no, review_date)"
    EXECUTE IMMEDIATE "ALTER TABLE leave ADD CONSTRAINT pk_leave_1
        PRIMARY KEY (employee_no, start_date)"
    EXECUTE IMMEDIATE "ALTER TABLE travel ADD CONSTRAINT pk_travel_1
        PRIMARY KEY (employee_no, start_date)"
    EXECUTE IMMEDIATE "ALTER TABLE sick ADD CONSTRAINT pk_sick_1
        PRIMARY KEY (employee_no, start_date)"
    EXECUTE IMMEDIATE "ALTER TABLE document ADD CONSTRAINT pk_document_1
        PRIMARY KEY (employee_no, doc_id)"
    EXECUTE IMMEDIATE "ALTER TABLE annualleave ADD CONSTRAINT cx_annlv001
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE paysummary ADD CONSTRAINT cx_paysum001
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE sickleave ADD CONSTRAINT cx_sicklv001
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl ADD CONSTRAINT cx_tsdtl001
        FOREIGN KEY (tsheet_no)
        REFERENCES timesheet_hdr (tsheet_no)"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_dtl ADD CONSTRAINT cx_tsdtl002
        FOREIGN KEY (activity_code)
        REFERENCES activity (activity_code)"
    EXECUTE IMMEDIATE "ALTER TABLE timesheet_hdr ADD CONSTRAINT cx_tshdr001
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE qualification ADD CONSTRAINT fk_qualification_qual_type_1
        FOREIGN KEY (qual_id)
        REFERENCES qual_type (qual_id)"
    EXECUTE IMMEDIATE "ALTER TABLE employee ADD CONSTRAINT fk_employee_country_1
        FOREIGN KEY (country_id)
        REFERENCES country (country_id)"
    EXECUTE IMMEDIATE "ALTER TABLE employee ADD CONSTRAINT fk_employee_title_1
        FOREIGN KEY (title_id)
        REFERENCES title (title_id)"
    EXECUTE IMMEDIATE "ALTER TABLE qualification ADD CONSTRAINT fk_qualification_employee_1
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE review ADD CONSTRAINT fk_review_employee_1
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)
        ON DELETE CASCADE"
    EXECUTE IMMEDIATE "ALTER TABLE leave ADD CONSTRAINT fk_leave_request_employee_1
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE travel ADD CONSTRAINT fk_leave_request_employee_1_1
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE sick ADD CONSTRAINT fk_leave_request_employee_1_1_1
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"
    EXECUTE IMMEDIATE "ALTER TABLE document ADD CONSTRAINT fk_document_employee_1
        FOREIGN KEY (employee_no)
        REFERENCES employee (employee_no)"

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
    EXECUTE IMMEDIATE "ALTER TABLE qualification DROP CONSTRAINT fk_qualification_qual_type_1"
    EXECUTE IMMEDIATE "ALTER TABLE employee DROP CONSTRAINT fk_employee_country_1"
    EXECUTE IMMEDIATE "ALTER TABLE employee DROP CONSTRAINT fk_employee_title_1"
    EXECUTE IMMEDIATE "ALTER TABLE qualification DROP CONSTRAINT fk_qualification_employee_1"
    EXECUTE IMMEDIATE "ALTER TABLE review DROP CONSTRAINT fk_review_employee_1"
    EXECUTE IMMEDIATE "ALTER TABLE leave DROP CONSTRAINT fk_leave_request_employee_1"
    EXECUTE IMMEDIATE "ALTER TABLE travel DROP CONSTRAINT fk_leave_request_employee_1_1"
    EXECUTE IMMEDIATE "ALTER TABLE sick DROP CONSTRAINT fk_leave_request_employee_1_1_1"
    EXECUTE IMMEDIATE "ALTER TABLE document DROP CONSTRAINT fk_document_employee_1"

END FUNCTION

#+ Add indexes for all tables.
FUNCTION db_add_indexes()
    WHENEVER ERROR STOP

    EXECUTE IMMEDIATE "CREATE INDEX ix_empl001 ON employee(surname)"

END FUNCTION


