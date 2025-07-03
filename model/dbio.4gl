#
# dbio  Data Input/Output
#

import FGL db

main

  -- Open database, default monitoring
  if db.Open(NVL(fgl_getenv("DB"),"hr")) != 0
  then
    error "Unable to open database"
    exit program 1
  end if

  -- Check args
  case arg_val(1)
    when "-i"
      call data_in()
    when "-o"
      call data_out()
    otherwise
      display "use: dbio -[i|o]"
      exit program 1
  end case

  exit program 0
end main

public function data_in()
    load from "country.unl" insert into country
    load from "title.unl" insert into title
    load from "qual_type.unl" insert into qual_type
    load from "employee.unl" insert into employee
    load from "qualification.unl" insert into qualification
    load from "activity.unl" insert into activity
    load from "annualleave.unl" insert into annualleave
    load from "paysummary.unl" insert into paysummary
    load from "sickleave.unl" insert into sickleave
    load from "timesheet_hdr.unl" insert into timesheet_hdr
    load from "timesheet_dtl.unl" insert into timesheet_dtl
    load from "review.unl" insert into review
    load from "leave.unl" insert into leave
    load from "travel.unl" insert into travel
    load from "sick.unl" insert into sick
    load from "document.unl" insert into document
end function

public function data_out()
    unload to "country.unl" select * from country
    unload to "title.unl" select * from title
    unload to "qual_type.unl" select * from qual_type
    unload to "employee.unl" select * from employee
    unload to "qualification.unl" select * from qualification
    unload to "activity.unl" select * from activity
    unload to "annualleave.unl" select * from annualleave
    unload to "paysummary.unl" select * from paysummary
    unload to "sickleave.unl" select * from sickleave
    unload to "timesheet_hdr.unl" select * from timesheet_hdr
    unload to "timesheet_dtl.unl" select * from timesheet_dtl
    unload to "review.unl" select * from review
    unload to "leave.unl" select * from leave
    unload to "travel.unl" select * from travel
    unload to "sick.unl" select * from sick
    unload to "document.unl" select * from document
end function

