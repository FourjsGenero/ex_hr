{
close database ;
drop database hr ;
create database hr in dbspace1 with buffered log;

rollback work;
}


begin work;

create table employee
(
  employee_no integer not null,
  firstname char(30) not null,
  middlenames char(30),
  surname char(30) not null,
  preferredname char(30),
  title char(5),
  birthdate date not null,
  gender char(1) not null,
  address1 char(40) not null,
  address2 char(40),
  address3 char(40),
  address4 char(40),
  country char(20) not null,
  postcode char(10) not null,
  restrict_address char(1) not null,
  phone char(20) not null,
  restrict_phone char(1) not null,
  mobile char(20) not null,
  restrict_mobile char(1) not null,

  email char(40),

  startdate date,
  position char(20) not null,
  taxnumber char(20) not null,
  base decimal (10,2) not null,
  basetype char(3) not null,
  sick_balance decimal(5,1) not null,
  annual_balance decimal (5,1) not null,

  primary key (employee_no) constraint cx_empl000,
  check (gender in ('M','F')) constraint cx_empl001,
  check (restrict_address in ('Y','N')) constraint cx_empl002,
  check (restrict_phone in ('Y','N')) constraint cx_empl003,
  check (restrict_mobile in ('Y','N')) constraint cx_empl004
);
create index ix_empl001 on employee(surname);


create table paysummary
(
  employee_no integer not null,
  pay_date date not null,
  pay_amount decimal(10,2) not null,
  
  primary key(employee_no, pay_date) constraint cx_paysum000,
  foreign key(employee_no) references employee(employee_no) constraint cx_paysum001
);


create table sickleave
(
  employee_no integer not null,
  sick_date date not null,
  sick_adjustment decimal(11,2) not null,
  sick_runningbalance decimal(11,2) not null,

  primary key(employee_no, sick_date) constraint cx_sicklv000,
  foreign key(employee_no) references employee(employee_no) constraint cx_sicklv001
);

create table annualleave
(
  employee_no integer not null,
  annual_date date not null,
  annual_adjustment decimal(11,2) not null,
  annual_runningbalance decimal(11,2) not null,
  primary key(employee_no, annual_date) constraint cx_annlv000,
  foreign key(employee_no) references employee(employee_no) constraint cx_annlv001
);


create table activity
(
  activity_code char(8) not null,
  description char(30) not null,
  primary key(activity_code) constraint cx_activity000
);


create table timesheet_hdr
(
  tsheet_no integer not null,
  tsheet_date date not null,
  employee_no integer not null,
  comment char(40),
  primary key(tsheet_no) constraint cx_tshdr000,
  foreign key(employee_no) references employee(employee_no) constraint cx_tshdr001
);

create table timesheet_dtl
(
  tsheet_no integer not null,
  activity_code char(8) not null,
  narrative char(40),
  hours decimal(5,2) not null,
  primary key(tsheet_no, activity_code) constraint cx_tsdtl000,
  foreign key(tsheet_no) references timesheet_hdr(tsheet_no) constraint cx_tsdtl001,
  foreign key(activity_code) references activity(activity_code) constraint cx_tsdtl002
);

CREATE TABLE review (
        employee_no INTEGER NOT NULL,
        review_date DATE NOT NULL,
        summary CHAR(30) NOT NULL,
        detail VARCHAR(250),
        CONSTRAINT pk_review_1 PRIMARY KEY(employee_no, review_date),
        CONSTRAINT fk_review_employee_1 FOREIGN KEY(employee_no)
            REFERENCES employee(employee_no)
);
            
CREATE TABLE leave (
        employee_no INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        days DECIMAL(5,2) NOT NULL,
        reason CHAR(30) NOT NULL,
        approved CHAR(1) NOT NULL,
        CONSTRAINT pk_leave_1 PRIMARY KEY(employee_no, start_date),
        CONSTRAINT fk_leave_request_employee_1 FOREIGN KEY(employee_no)
            REFERENCES employee(employee_no)
);

CREATE TABLE travel (
        employee_no INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        days DECIMAL(5,2) NOT NULL,
        reason CHAR(30) NOT NULL,
        approved CHAR(1) NOT NULL,
        CONSTRAINT pk_travel_1 PRIMARY KEY(employee_no, start_date),
        CONSTRAINT fk_leave_request_employee_1_1 FOREIGN KEY(employee_no)
            REFERENCES employee(employee_no)
);

CREATE TABLE sick (
        employee_no INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        days DECIMAL(5,2) NOT NULL,
        reason CHAR(30) NOT NULL,
        medical CHAR(1) NOT NULL,
        CONSTRAINT pk_sick_1 PRIMARY KEY(employee_no, start_date),
        CONSTRAINT fk_leave_request_employee_1_1_1 FOREIGN KEY(employee_no)
            REFERENCES employee(employee_no)
);