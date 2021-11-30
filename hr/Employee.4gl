#
# Employee    Business rules and model logic for Employee
#

import FGL db
import FGL str
import FGL Selection

schema hr


#
# Module Types
#
public type

  tEmployee record like employee.*,
  tPaySummary record like paysummary.*,
  tAnnualLeave record like annualleave.*,
  tSickLeave record like sickleave.*,

  tLeave record like leave.*,
  tSick record like sick.*,
  tTravel record like travel.*,
  tReview record like review.*,
  tQualification record like qualification.*,

  tDoc
    record
      employee tEmployee,
      pay dynamic array of tPaySummary,
      qualification dynamic array of tQualification,
      review dynamic array of tReview,
      leave dynamic array of tLeave,
      annual dynamic array of tAnnualLeave,
      sick dynamic array of tSick,
      sickleave dynamic array of tSickLeave,
      travel dynamic array of tTravel,
      photo byte
    end record,

  tLine
    record
      employee_no like employee.employee_no,
      employee_surname like employee.surname,
      employee_firstname like employee.firstname,
      employee_position like employee.position
    end record,
    
  tList
    record
      selection Selection.tQuery,
      lines dynamic array of tLine
    end record,

  tView
    record
      doc tDoc,
      list tList
    end record,

  tValidationFunction
    function(this tDoc inout) returns (boolean, string)


#
# Module: Class variables
# These have to be module level because we can't
# a) Pass record by Reference (Solved 3.20 INOUT)
# b) Pass parameters to sub-dialogs (SUPNA-2747)
# c) Pass method reference to another module
#

private define
  ma_valid dictionary of tValidationFunction,
  m_initialized boolean




#
# MAIN - Standalone or Unit Test
#
main

end main



#
# PUBLIC (Class methods)
#


#############################################################################
#
#! Init
#+ Initialize the module
#+
#+ @code
#+ call Employee.Init()
#
#############################################################################
public function Init()

  if m_initialized
  then
    return
  end if
  let m_initialized = TRUE

  -- Declare static cursors
  declare c_employee cursor for
    select * from employee where employee_no = ?
    order by employee_no

  declare c_paySummary cursor for
    select *
    from paysummary
    where employee_no = ?
    order by pay_date desc

  declare c_sick cursor for
    select *
    from sick
    where employee_no = ?
    order by start_date desc

  declare c_sickLeave cursor for
    select *
    from sickleave
    where employee_no = ?
    order by sick_date desc

  declare c_leave cursor for
    select *
    from leave
    where employee_no = ?
    order by start_date desc
    
  declare c_annualLeave cursor for
    select *
    from annualleave
    where employee_no = ?
    order by annual_date desc

  declare c_travel cursor for
    select *
    from travel
    where employee_no = ?
    order by start_date desc

  declare c_review cursor for
    select *
    from review
    where employee_no = ?
    order by review_date desc

  declare c_qualification cursor for
    select *
    from qualification
    where employee_no = ?
    order by qual_date desc
    
  declare c_country cursor for
    select *
    from country
    where country_id = ?
    order by country_id

  -- %%% OUTSIDE Init List
  #%%% call this.list.init()

  -- Dictionary of Validation functions
  let ma_valid["firstname"] = function Valid_FirstName
  let ma_valid["surname"] = function Valid_Surname
  let ma_valid["title_id"] = function Valid_Title_ID
  let ma_valid["birthdate"] = function Valid_Birthdate
  let ma_valid["gender"] = function Valid_Gender
  let ma_valid["address1"] = function Valid_Address1
  let ma_valid["postcode"] = function Valid_PostCode
  let ma_valid["country_id"] = function Valid_Country_ID
  let ma_valid["phone"] = function Valid_Phone
  let ma_valid["mobile"] = function Valid_Mobile
  let ma_valid["email"] = function Valid_Email
  
end function



#
# METHODS (Object methods)
#

#############################################################################
#
#! tList::Init
#+ Setup the List Selection Control parameters
#+
#+ @code
#+ define r_list tList
#+ call r_list.Initialize()
#
#############################################################################
public function (this tList) Init(p_refresh function(po_dialog ui.Dialog), p_field string)

  define
    i integer,
    --% just using a_cols declaration to set values concisely
    a_cols dynamic array of Selection.tColumn =
    [
    (name: "employee_no",   label:"Employee No"),
    (name: "surname",       label:"Surname"),
    (name: "firstname",     label:"First Name"),
    (name: "middlenames",   label:"Middle Names"),
    (name: "preferredname", label:"Preferred Name"),
    (name: "title_id",      label:"Title ID"),
    (name: "birthdate",     label:"Birth Date"),
    (name: "address1",      label:"Address 1"),
    (name: "address2",      label:"Address 2"),
    (name: "address3",      label:"Address 3"),
    (name: "address4",      label:"Address 4"),
    (name: "country_id",    label:"Country ID"),
    (name: "postcode",      label:"Post Code"),
    (name: "phone",         label:"Phone"),
    (name: "mobile",        label:"Mobile"),
    (name: "email",         label:"Email"),
    (name: "position",      label:"Position"),
    (name: "taxnumber",     label:"Tax Number"),
    (name: "base",          label:"Base"),
    (name: "basetype",      label:"Base Type")
    ]

  -- Setup search columns
  for i = 1 to a_cols.getLength()
    -- all selected by default
    let a_cols[i].selected = true
    -- index to search columns by name
    let this.selection.index[a_cols[i].name] = i
  end for
  call a_cols.copyTo(this.selection.columns)
  
  -- Base query
  let this.selection.select = "employee_no, surname, firstname, position"
  let this.selection.from = " employee"
  let this.selection.default.orderBy = "1"

  let this.selection.options.matchCase = FALSE
  let this.selection.options.matchWord = false

  -- Set the View Refresh callback function
  let this.selection.View_Refresh = p_refresh
  let this.selection.field = p_field

  -- Initial refresh
  call this.selection.Filter("")
  call this.selection.Refresh()
  
end function



#############################################################################
#
#! tList::Load
#+ Load the current page in list view
#+
#+ @param p_start    Starting absolute record
#+ @param p_len      Number of records
#+
#+ @code
#+ define r_list tList
#+ ...
#+ call r_list.Load(fgl_dialog_getBufferStart(), fgl_dialog_getBufferLength())
#
#############################################################################
public function (this tList) Load(p_start int, p_len int) returns integer
  define
    l_row, i integer

  call this.lines.clear()

  let l_row = p_start
  for i = 1 to p_len
    #% fetch absolute l_row c_empLine into this.lines[i].*
    call this.selection.cursor.fetchAbsolute(l_row)

    -- Exit if no more rows
    if sqlca.sqlcode
    then
      return l_row-1
    end if
    let l_row = l_row + 1

    -- % Set data into line
    let this.lines[i].employee_no = this.selection.cursor.getResultValue(1)
    let this.lines[i].employee_surname = this.selection.cursor.getResultValue(2)
    let this.lines[i].employee_firstname = this.selection.cursor.getResultValue(3)
    let this.lines[i].employee_position = this.selection.cursor.getResultValue(4)
  end for

  -- default row if no data
  return l_row
  
end function



#############################################################################
#
#was ListItem_Key
#+ tList::Key
#+ Return the key for an absolute list item in the list
#+
#+ @param p_row      Item number in list
#+
#+ @returnType      like employee.employee_no
#+ @return          Primary key - Employee number
#+
#+ @code
#+ define p_employeeNo like employee.employee_no
#+ ...
#+ let p_employeeNo = Employee.ListItem_Key(arr_curr()) 
#
#############################################################################

public function (this tList) Key(p_row integer) returns like employee.employee_no
    
  #% fetch absolute p_row c_empLine into r_line.*
  call this.selection.cursor.fetchAbsolute(p_row)
  if sqlca.sqlcode
  then
    return NULL
  end if

  -- % unique key field
  return this.selection.cursor.getResultValue(1)

end function







#############################################################################
#
#! tDoc::New()
#+ Setup defaults for a New employee
#+
#+ @code
#+ define r_doc Employee.tDoc
#+ call r_doc.New()
#
#############################################################################
public function (this tDoc) New()

  define
    p_maxEmpNo like employee.employee_no


  -- % call Init() here, as this has to be called before anything else

  -- get last employee number
  select max(employee_no)
  into p_maxEmpNo
  from employee


  -- Clear
  call this.Clear()
  
  -- Setup defaults
  locate this.photo in file "photo.tmp"   #%Constructor - session file
  let this.employee.employee_no = nvl(p_maxEmpNo, 0) + 1
  let this.employee.country_id = "AU"
  let this.employee.birthdate = TODAY
  let this.employee.title_id = "Mr"
  let this.employee.gender = "M"
  let this.employee.phone = "+61 "
  let this.employee.mobile = "+61 "

  let this.employee.employee_no = this.employee.employee_no
  let this.employee.annual_balance = 0
  let this.employee.base = 0
  let this.employee.basetype = "SAL"
  let this.employee.sick_balance = 0
  let this.employee.startdate = TODAY
    
end function



#############################################################################
#
#! Get()
#+ Get related data for an employee number
#+
#+ @code
#+ define p_employeeNo like employee.employee_no
#+ call Employee.Get(p_employeeNo)
#
#############################################################################
public function (this tDoc) Get(p_employeeNo like employee.employee_no)

  define
    r_pay tPaySummary,
    r_qualification tQualification,
    r_review tReview,
    r_sick tSick,
    r_sickLeave tSickLeave,
    r_leave tLeave,
    r_annual tAnnualLeave,
    r_travel tTravel,
    i integer


  call this.Clear()
  
  -- Employee
  foreach c_employee using p_employeeNo into this.employee.*
    exit foreach
  end foreach

  -- Pay Summary
  let i = 0
  foreach c_paySummary using p_employeeNo into r_pay.*
    let this.pay[i:=i+1].* = r_pay.*
  end foreach
  
  -- Qualification
  let i = 0
  foreach c_qualification using p_employeeNo into r_qualification.*
    let this.qualification[i:=i+1].* = r_qualification.*
  end foreach
  
  -- Review
  let i = 0
  foreach c_review using p_employeeNo into r_review.*
    let this.review[i:=i+1].* = r_review.*
  end foreach
  
  -- Sick
  let i = 0
  foreach c_sick using p_employeeNo into r_sick.*
    let this.sick[i:=i+1].* = r_sick.*
  end foreach
  
  -- Sick Leave
  let i = 0
  foreach c_sickLeave using p_employeeNo into r_sickLeave.*
    let this.sickleave[i:=i+1].* = r_sickLeave.*
  end foreach
  
  -- Leave
  let i = 0
  foreach c_leave using p_employeeNo into r_leave.*
    let this.leave[i:=i+1].* = r_leave.*
  end foreach
  
  -- Annual Leave
  let i = 0
  foreach c_annualLeave using p_employeeNo into r_annual.*
    let this.annual[i:=i+1].* = r_annual.*
  end foreach

  -- Travel
  let i = 0
  foreach c_travel using p_employeeNo into r_travel.*
    let this.travel[i:=i+1].* = r_travel.*
  end foreach
  
end function



#############################################################################
#
#! tDoc.Put()
#+ Put related data for current Document
#+
#+ @code
#+ define r_doc tDoc
#+ ...
#+ call r_doc.Put()
#
#############################################################################
public function (this tDoc) Put() returns string

  define
    l_mode string

    
  select employee_no
  from employee
  where employee_no = this.employee.employee_no
  let l_mode = iif(status = NOTFOUND, "ADD", "UPDATE")

  -- Update balances
  call this.SickLeave_Balance()
  call this.AnnualLeave_Balance()
  
  -- Upsert
  if l_mode = "ADD"
  then
    return (this.Insert())
  else
    return (this.Update())
  end if
  
end function




#############################################################################
#
#! Delete()
#+ Delete related data for current employee
#+
#+ @code
#+ define p_employeeNo like employee.employee_no
#+ call Employee.Get(p_employeeNo)
#
#############################################################################
public function (this tDoc) Delete() returns string

  define
    l_status string,
    l_void integer


  -- Start
  if not db.Begin()
  then
    return "ERROR: Unable to start database transaction"
  end if
  let l_status = "OK"

  if (l_status := this.detail_Upsert("DELETE")) = "OK"
  then
    try
      delete from employee
      where employee_no = this.employee.employee_no
    catch
      let l_status = "ERROR: " || sqlca.sqlerrm
    end try
  end if

  if l_status matches "ERROR*"
  then
    let l_void = db.Rollback()
    return l_status
  end if

  if not db.Commit()
  then
    return "ERROR: Unable to commit transaction"
  end if
        
  return "OK"
  
end function



#############################################################################
#
#! Insert()
#+ Insert related data for current employee
#+
#+ @code
#+ call Employee.Insert()
#
#############################################################################
public function (this tDoc) Insert() returns string

  define
    l_status string,
    l_void integer
    

  -- Start
  if not db.Begin()
  then
    return "ERROR: Unable to start database transaction"
  end if
  let l_status = "OK"

  -- Employee
  try
    insert into employee values (this.employee.*)
  catch
    let l_status = "ERROR: " || sqlca.sqlerrm
  end try

  if l_status = "OK"
  then
    let l_status = this.detail_Upsert("INSERT")
  end if

  if l_status matches "ERROR*"
  then
    let l_void = db.Rollback()
    return l_status
  end if

  if not db.Commit()
  then
    return "ERROR: Unable to commit transaction"
  end if
        
  return "OK"
  
end function



#############################################################################
#
#! Update()
#+ Update related data for current employee
#+
#+ @code 
#+ call Employee.Update()
#
#############################################################################
public function (this tDoc) Update() returns string

  define
    l_status string,
    l_void integer
    

  -- Start
  if not db.Begin()
  then
    return "ERROR: Unable to start database transaction"
  end if
  let l_status = "OK"

  -- Employee
  try
    update employee
    set
      employee.* = this.employee.*
    where employee_no = this.employee.employee_no
  catch
    let l_status = "ERROR: " || sqlca.sqlerrm
  end try

  if l_status = "OK"
  then
    let l_status = this.detail_Upsert("INSERT")
  end if

  if l_status matches "ERROR*"
  then
    let l_void = db.Rollback()
    return l_status
  end if

  if not db.Commit()
  then
    return "ERROR: Unable to commit transaction"
  end if
        
  return "OK"
  
end function



#############################################################################
#
#! Base_Set()
#+ Set base salary or wage
#+
#+ @code
#+ call Employee.Base_Set()
#
#############################################################################
public function (this tDoc) Base_Set()
  define
    i integer,
    l_date date,
    l_base like employee.base
    

  let l_date = "01/01/1900"
  let l_base = 0

  for i = 1 to this.pay.getLength()
    if this.pay[i].pay_date > l_date
    then
      let l_base = this.pay[i].pay_amount
      let l_date = this.pay[i].pay_date
    end if
  end for

  let this.employee.base = l_base
end function



#############################################################################
#
#! AnnualLeave_Balance()
#+ Update Annual Leave Balance
#+
#+ @code
#+ call Employee.AnnualLeave_Balance()
#
#############################################################################
public function (this tDoc) AnnualLeave_Balance()
  define
    i integer,
    l_date date,
    l_balance like employee.annual_balance
    

  let l_date = "01/01/1900"
  let l_balance = 0

  for i = 1 to this.annual.getLength()
    if this.annual[i].annual_date > l_date
    then
      let l_balance = this.annual[i].annual_runningbalance
      let l_date = this.annual[i].annual_date
    end if
  end for

  let this.employee.annual_balance = l_balance
end function




#############################################################################
#
#! SickLeave_Balance()
#+ Update Sick Leave Balance
#+
#+ @code
#+ call Employee.SickLeave_Balance()
#
#############################################################################
public function (this tDoc) SickLeave_Balance()
  define
    i integer,
    l_date date,
    l_balance like employee.sick_balance
    

  let l_date = "01/01/1900"
  let l_balance = 0

  for i = 1 to this.sick.getLength()
    if this.sickleave[i].sick_date > l_date
    then
      let l_balance = this.sickleave[i].sick_runningbalance
      let l_date = this.sickleave[i].sick_date
    end if
  end for

  let this.employee.sick_balance = l_balance
end function


#
# Valid_*: Field Validation functions
#
function Valid_FirstName(this tDoc inout) returns (boolean, string)
  if this.employee.firstname is null then
      return FALSE, "Firstname must be entered"
  end if
  return TRUE, ""
end function

function Valid_Surname(this tDoc inout) returns (boolean, string)
  if this.employee.surname is null then
      return FALSE, "Surname must be entered"
  end if
  return TRUE, ""
end function

function Valid_Title_ID(this tDoc inout) returns (boolean, string)
  select  title_id
  from    title
  where   title_id = this.employee.title_id
  if status = NOTFOUND
  then
    return FALSE, "Title is invalid"
  end if
  return TRUE, ""
end function

function Valid_Gender(this tDoc inout) returns (boolean, string)
  if this.employee.gender not matches "[MF]" then
      return FALSE, "Gender must either be (M)ale or (F)emale"
  end if
  return TRUE, ""
end function

function Valid_Birthdate(this tDoc inout) returns (boolean, string)
  if this.employee.birthdate is null then
      return FALSE, "Birthdate must be entered"
  end if
  if this.employee.birthdate > today then
      return FALSE, "Birthdate must be before today"
  end if
  if this.employee.birthdate < "01/01/1900" then
      return FALSE, "Birthdate must be on or after 1/1/1900"
  end if
  return TRUE, ""
end function

function Valid_Address1(this tDoc inout) returns (boolean, string)
  if this.employee.address1 is null then
      return FALSE, "Address must be entered"
  end if
  return TRUE, ""
end function

function Valid_PostCode(this tDoc inout) returns (boolean, string)
  if length(this.employee.postcode) < 3
  then
    return false, "Postcode is too short"
  else
    return TRUE, ""
  end if
end function

function Valid_Country_ID(this tDoc inout) returns (boolean, string)
  select  country_id
  from    country
  where   country_id = this.employee.country_id
  if status = NOTFOUND
  then
    return FALSE, "Country is invalid"
  end if
  return TRUE, ""
end function

function Valid_Phone(this tDoc inout) returns (boolean, string)
  if PhoneNumber_Valid(this.employee.phone)
  then
    return TRUE, ""
  else
    return FALSE, "Invalid phone number - must contain + and numbers"
  end if
end function

function Valid_Mobile(this tDoc inout) returns (boolean, string)
  if PhoneNumber_Valid(this.employee.mobile)
  then
    return TRUE, ""
  else
    return FALSE, "Invalid mobile number - must contain numbers with spaces, optional +"
  end if
end function

function PhoneNumber_Valid(p_phone string)
  if p_phone matches "+*"
  then
    let p_phone = p_phone.subString(2,p_phone.getLength())
  end IF

  return str.HasOnly("[0-9 ]", p_phone)
end function

function Valid_Email(this tDoc inout) returns (boolean, string)
  define
    l_email string,
    l_user string,
    l_domain string


  -- Split address into user and domain
  let l_email = this.employee.email
  call str.Split(l_email.toLowerCase(), "@")
    returning l_user, l_domain

  -- User and domain must be non-null
  if l_user.getLength() = 0 or l_domain.getLength() = 0
  then
    return FALSE, "Email address invalid: user or domain is null"
  end if

  -- Must contain alphanumeric, dash, underscore and dots only
  -- but not overly concerned as we need to validate it anyway
  if str.HasOnly("[a-z0-9._-]", l_user) and str.HasOnly("[a-z0-9._-]", l_domain)
  then
    return FALSE, "Email address contains invalid characters"
  end if

  return TRUE, ""
end function


#
# Valid_Field: Validate a field
#
function (this tDoc) Valid_Field(p_field string) returns (boolean, string)
  define
    l_validFunc tValidationFunction,
    l_error string,
    ok boolean

  if ma_valid.contains(p_field)
  then
    let l_validFunc = ma_valid[p_field]
  else
    return TRUE, ""
  end if

  call l_validFunc(this)
    returning ok, l_error

  return ok, l_error
  
end function

#
# Valid_Record - Validate all fields plus some
#
function (this tDoc) Valid_Record() returns (boolean, string, string)
  define
    a_fields dynamic array of string,
    l_validFunc tValidationFunction,
    l_error string,
    ok boolean,
    i integer

  -- get field list
  let a_fields = ma_valid.getKeys()
  
  -- Validate each field
  for i = 1 to a_fields.getLength()
    let l_validFunc = ma_valid[a_fields[i]]
    call l_validFunc(this) returning ok, l_error
    if not ok
    then
      return FALSE, l_error, a_fields[i]
    end if
  end for

  -- Other rules
  if not PostCode_In_Country_Valid(this.employee.postcode, this.employee.country_id)
  then
      return FALSE, "Postcode must be valid for country", "postcode"
  end if
  
  return TRUE, "", ""
  
end function

function PostCode_In_Country_Valid(p_postcode string, p_countryid string) returns boolean
  define
    r_country record like country.*,
    l_postcode string

  let l_postcode = nvl(p_postcode,"")
  let l_postcode = l_postcode.trim()

  -- get country record
  call country_Get(p_countryid)
    returning r_country

  -- Verify postcode is correct length for country
  if l_postcode.getLength() != r_country.postcode_length
  then
    return FALSE
  end if

  return TRUE
end function





#--------------------PRIVATE---------------------------------#

#############################################################################
#
#! detail_Upsert()
#+ Upsert related data for current employee
#+
#+ @code
#+ define p_employeeNo like employee.employee_no
#+ ...
#+ call Employee.Get(p_employeeNo)
#
#############################################################################
private function (this tDoc) detail_Upsert(p_mode string)
  returns string

  define
    i integer

    
  let p_mode = p_mode.toUpperCase()

  try
    delete from paysummary where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.pay.getLength()
        let this.pay[i].employee_no = this.employee.employee_no
        insert into paysummary values(this.pay[i].*)
      end for
    end if 

    delete from qualification where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.qualification.getLength()
        let this.qualification[i].employee_no = this.employee.employee_no
        insert into qualification values(this.qualification[i].*)
      end for
    end if 
   
    delete from review where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.review.getLength()
        let this.review[i].employee_no = this.employee.employee_no
        insert into review values(this.review[i].*)
      end for
    end if 

    delete from sick where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.sick.getLength()
        let this.sick[i].employee_no = this.employee.employee_no
        insert into sick values(this.sick[i].*)
      end for
    end if 
    
    delete from sickleave where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.sickleave.getLength()
        let this.sickleave[i].employee_no = this.employee.employee_no
        insert into sickleave values(this.sickleave[i].*)
      end for
    end if 

    delete from leave where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.leave.getLength()
        let this.leave[i].employee_no = this.employee.employee_no
        insert into leave values(this.leave[i].*)
      end for
    end if
    
    delete from annualleave where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.annual.getLength()
        let this.annual[i].employee_no = this.employee.employee_no
        insert into annualleave values(this.annual[i].*)
      end for
    end if

    delete from travel where employee_no = this.employee.employee_no
    if p_mode != "DELETE"
    then
      let i = 0
      for i = 1 to this.travel.getLength()
        let this.travel[i].employee_no = this.employee.employee_no
        insert into travel values(this.travel[i].*)
      end for
    end if
    
  catch
    return "ERROR: " || sqlca.sqlerrm
  end try

  return "OK"

end function





#############################################################################
#
#! tDoc::Clear()
#+ Clear employee data set view
#+
#+ @code
#+ define r_view tDoc
#+ call r_view.Clear()
#
#############################################################################
private function (this tDoc) Clear()

  initialize this.employee to NULL
  --%%% TBD initialize this.photo to NULL

  call this.pay.clear()
  call this.qualification.clear()
  call this.review.clear()
  call this.leave.clear()
  call this.annual.clear()
  call this.sick.clear()
  call this.sickleave.clear()
  call this.travel.clear()
  
end function



#############################################################################
#
#! country_Get
#+ Get record for a country by country_id
#+
#+ @code
#+ call country_Get("AU")
#
#############################################################################
private function country_Get(p_countryid like country.country_id) returns record like country.*
  define
    r_country record like country.*

  foreach c_country using p_countryid into r_country.*
  end foreach

  return r_country
  
end function    
