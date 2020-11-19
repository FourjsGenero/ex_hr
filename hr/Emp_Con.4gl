import security
import util

import FGL UI_
import FGL Selection
import FGL Employee
import FGL wc_c3chart

schema hr

private constant k_screenList = "emp_list"
private define
  -- List of data entry screen fields or records
  ma_fields dynamic array of string =
    [
    "emp_hdr.*",
    "emp_pic.*",
    "emp_dtl.*",
    "pay_scr.*",
    "qualification_scr.*",
    "review_scr.*",
    "reviewdetail_scr.*",
    "leave_scr.*",
    "annual_scr.*",
    "sick_scr.*",
    "sickleave_scr.*",
    "travel_scr.*"
    ],
  r_view Employee.tView

# %Data Generated local demo data, not in database yet
private define
  mr_data record
    dash1 wc_c3chart.tChart,
    dash2 wc_c3chart.tChart,
    photo string,
    detail_edit string,
    map string
  end record



#############################################################################
#
#! Init
#+ Initialize the module
#+
#+ @code
#+ define r_view Employee.tView
#+ call Emp_View.Init(r_view)
#
#############################################################################
public function Init(r_view Employee.tView inout)
    
  defer interrupt
  defer quit
  options input wrap
  options field order form
  
  -- Set decorations
  -- call fgl_setTitle("Employees")
  call ui.interface.loadStyles("hr2") --% hr1 std, hr2: folder.accordion, collapse group, chrome toolbar
  call ui.interface.loadActionDefaults("hr1")
  call ui.interface.loadToolBar("opt1")  --%was "opt"
  
  -- Setup for Employee module
  call Employee.Init()

  -- Initialize the list and set the View Refresh callback
  locate r_view.doc.photo in file "photo.tmp"  #%MIRRORS
  call r_view.list.Init(function view_Refresh, "l_search")

  -- Initialize Dashboards --
  call mr_data.dash1.New("formonly.dash1")
  let mr_data.dash1.title = "Power Profile"
  let mr_data.dash1.narrative = "Results of Standing Starts"
  let mr_data.dash1.doc.data.type = "spline"
  let mr_data.dash1.doc.axis.x.label = "Effort"
  let mr_data.dash1.doc.axis.y.label = "Watts"
  call chart_Load(mr_data.dash1, "DASH1")
  call mr_data.dash2.New("formonly.dash2")
  let mr_data.dash2.title = "KPI"
  let mr_data.dash2.narrative = "Sales This Period"
  let mr_data.dash2.doc.data.type = "area-step"
  let mr_data.dash2.doc.axis.x.label = "Period"
  let mr_data.dash2.doc.axis.y.label = "Sales"
  call chart_Load(mr_data.dash2, "DASH2")
  end function



#############################################################################
#
#! Show
#+ Show View of Employee
#+
#+ @code
#+ call Emp_View.Show()
#
#############################################################################
public function Show()

  #%%% LIMITATION: For when we can pass params to sub dialogs
  # define
  #  r_view Employee.tView
  define
    l_status string


  -- Local setup with current view
  call Init(r_view)

  -- Initial refresh of the list
  call r_view.list.selection.Refresh()

  -- Open and display Employee form
  open form f_employee from "Employee"
  display form f_employee

  -- Initialize lookups
  call UI_.Combo_List("employee.title_id", "select title_id, description from title order by 1")
  call UI_.Combo_List("employee.country_id", "select country_id, name from country order by 2")
  call UI_.Combo_List("qualification.qual_id", "select qual_id, description from qual_type order by 1")
  call UI_.Node_Set(NULL, "Label", "text='*'", "color", "red")


  --% KLUDGE: we need to set current Selection.tQuery because we can't pass args in dialog
  call r_view.list.selection.Current()

  dialog attributes(unbuffered)

    -- Coalesce sub-dialogs
    subdialog list_Browse
    subdialog Selection.Search
    subdialog employee_Edit
    subdialog review_Edit
    subdialog reviewDetail_Edit
    subdialog qualification_Edit
    subdialog paySummary_Edit
    subdialog leave_Edit
    subdialog annualLeave_Edit
    subdialog sick_Edit
    subdialog sickLeave_Edit
    subdialog travel_Edit

    -- Initialize Dialog
    before dialog
      -- Set array length, status and Save button
      call dialog.setArrayLength(k_screenList, r_view.list.selection.count)
      call record_Status(dialog)
      call document_Touched(dialog, NULL)

      -- If no records in list, then can only be here to Add
      if r_view.list.selection.count < 1
      then
        call r_view.doc.New()
        next field emp_hdr.firstname
      end if 


    -- Setup brackground monitoring of touched fields
    {%OPT
    on idle 1
      call document_Touched(dialog, NULL)
    }
      
    #
    # Common actions to all sub-dialogs
    #

    -- Navigation
    on action first
      if dialog.getCurrentRow(k_screenList) > 1
      then
        call row_Set(dialog, 1)
      end if
      
    on action previous
      if dialog.getCurrentRow(k_screenList) > 1
      then
        call row_Set(dialog, dialog.getCurrentRow(k_screenList) - 1)
      end if
      
    on action next
      if dialog.getCurrentRow(k_screenList) < r_view.list.selection.count
      then
        call row_Set(dialog, dialog.getCurrentRow(k_screenList) + 1)
      end if
      
    on action last
      if dialog.getCurrentRow(k_screenList) < r_view.list.selection.count
      then
        {
        call row_Set(dialog, UI_.Page_Row("NEXT", dialog.getCurrentRow(k_screenList),
          fgl_dialog_getBufferLength(), Selection.rCurrent.count))
        }
        call row_Set(dialog, r_view.list.selection.count)
      end if
      
    -- Document actions
    on action query
      call Query(r_view, dialog)

    on action new --%attribute(image="new-active")
      call r_view.doc.New()

    on action trash
      call confirm_Delete(dialog)
      
    on action save
      message "Saving ..."
      let l_status = r_view.doc.Put()
     if l_status = "OK"
      then
        call document_Touched(dialog, false)
        message "Saved"
        call view_Refresh(dialog)
      else
        error l_status
      end if

    on action cancel
      message "Cancel"
      call confirm_Cancel(dialog)


    -- Get out of here
    on action close
      call confirm_Save(dialog)
      exit dialog
      
  end dialog
  
end function



#############################################################################
#
#! Query
#+ Query by Example in the Form, updates the Selection set
#+
#+ @code
#+ define r_view Employee.tView
#+ call Emp_View.Query(r_view, dialog)
#
#############################################################################
public function Query(r_view Employee.tView inout, po_dialog ui.Dialog)

  define
    l_sql string

  -- In case touched
  call confirm_Save(po_dialog)

  -- Query by Form
  construct l_sql on employee.* from emp_hdr.*, emp_dtl.*
    on action cancel attributes(defaultView=YES)
      return      
  end construct

  -- Apply selection filter
  let r_view.list.selection.where = l_sql
  call view_Refresh(po_dialog)
    
end function




#
# PRIVATE
#



#
# DIALOGS
#

#
#! list_Browse
#+ Browse through List of employees
#+
#+ @code
#+ subdialog list_Browse
#
private dialog list_Browse({r_view Employee.tView inout})

  define
    l_count integer

    
  display array r_view.list.lines to emp_list.* attributes(count=-1)

    before display
      call confirm_Save(dialog)
      
    before row
      call r_view.doc.Get(r_view.list.Key(arr_curr()))
      call data_Load(r_view.doc)
      call record_Status(dialog)

    on sort
      -- Refresh selection set query
      call r_view.list.selection.SortKey(dialog.getSortKey(k_screenList))
      let r_view.list.selection.desc = dialog.isSortReverse(k_screenList)
      call r_view.list.selection.Refresh()

    on fill buffer
      let l_count = r_view.list.Load(fgl_dialog_getBufferStart(), fgl_dialog_getBufferLength())

    on action accept
      -- First field of Document page
      next field emp_hdr.firstname

  end display
    
end dialog

    

#
#! employee_Edit
#+ Edit the current Employee
#+
#+ @code
#+ subdialog employee_Edit(TRUE)
#

private dialog employee_Edit()
  
  define
    ok boolean,
    l_error string,
    field_name string

  input r_view.doc.employee.*, mr_data.photo, mr_data.map
    from emp_hdr.*, emp_dtl.*, sick_balance, annual_balance, photo, map
    attributes(without defaults=true)

    on change firstname, middlenames, surname, preferredname, title_id,
      birthdate, gender, address1, address2, address3, address4,
      country_id, postcode, phone, mobile, email, startdate, position,
      taxnumber, base, basetype, sick_balance, annual_balance
      call document_Touched(dialog, TRUE)

    {%%% Not required for Web, but we could for desktop ----
    after field firstname, middlenames, surname, preferredname, title_id,
      birthdate, gender, address1, address2, address3, address4,
      country_id, postcode, phone, mobile, email, startdate, position,
      taxnumber, base, basetype, sick_balance, annual_balance
      
      -- Get current field and validate
      let l_field = dialog.getCurrentItem()
      call Employee.Valid_Field(l_field)
        returning ok, l_error
      if not ok
      then
        error l_error
        call dialog.nextField(l_field)
      end if
      %%%}
      
    after input
      -- as we Validate everything HERE:
      call r_view.doc.Valid_Record() returning ok, l_error, field_name
      if not ok
      then
        error l_error
        call dialog.nextField(field_name)
      end if

  end input
  
end dialog



#
#! review_Edit
#+ Edit Reviews
#+
#+ @code
#+ subialog annualLeave_Edit
#
private dialog review_Edit()
    
  input array r_view.doc.review from review_scr.*
    attributes (without defaults)
      
    on change review_date, summary
      call document_Touched(dialog, TRUE) 
      
    after delete
      call document_Touched(dialog, TRUE)
  end input 
  
end dialog

private dialog reviewDetail_Edit()

  --%%% input m_editor from reviewdetail_scr.detail_edit
  input by name mr_data.detail_edit
    attributes (without defaults)
  end input

end dialog



#
#! paySummary_Edit
#+ Edit Pay Summary
#+
#+ @code
#+ subdialog paySummary_Edit
#
private dialog paySummary_Edit()

  input array r_view.doc.pay from pay_scr.*
    attributes (without defaults)

    before input
      call r_view.doc.Base_Set()
      
    on change pay_date, pay_amount
      call r_view.doc.Base_Set()
      call document_Touched(dialog, TRUE)

    after delete
      call r_view.doc.Base_Set()
      call document_Touched(dialog, TRUE)

  end input 
  
end dialog



#
#! qualification_Edit
#+ Edit Qualifications
#+
#+ @code
#+ subialog qualification_Edit
#
private dialog qualification_Edit()
    
  input array r_view.doc.qualification from qualification_scr.*
    attributes (without defaults)
      
    on change qual_date, narrative
      call document_Touched(dialog, TRUE) 
      
    after delete
      call document_Touched(dialog, TRUE)
  end input 
  
end dialog



#
#! sick_Edit
#+ Edit Sick Leave
#+
#+ @code
#+ subdialog sick_Edit
#
private dialog sick_Edit()

  input array r_view.doc.sick from sick_scr.*
    attributes (without defaults)
      
    on change start_date, end_date, days, reason, medical
      call document_Touched(dialog, TRUE)
      
    after delete
      call document_Touched(dialog, TRUE)
  end input
        
end dialog



#
#! sickLeave_Edit
#+ Edit Sick Leave
#+
#+ @code
#+ subdialog sickLeave_Edit
#
private dialog sickLeave_Edit()

  input array r_view.doc.sickleave from sickleave_scr.*
    attributes (without defaults)
    
    before input
      call r_view.doc.SickLeave_Balance()
      
    on change sick_date, sick_adjustment, sick_runningbalance 
      call r_view.doc.SickLeave_Balance()
      call document_Touched(dialog, TRUE)
      
    after delete
      call r_view.doc.SickLeave_Balance()
      call document_Touched(dialog, TRUE)
  end input
        
end dialog



#
#! leave_Edit
#+ Edit Annual Leave
#+
#+ @code
#+ subialog annualLeave_Edit
#
private dialog leave_Edit()
      
  input array r_view.doc.leave from leave_scr.*
    attributes (without defaults)
      
    on change start_date, end_date, days, reason, approved
      call document_Touched(dialog, TRUE) 
      
    after delete
      call document_Touched(dialog, TRUE)
  end input 

end dialog



#
#! annualLeave_Edit
#+ Edit Annual Leave
#+
#+ @code
#+ subialog annualLeave_Edit
#
private dialog annualLeave_Edit()
      
  input array r_view.doc.annual from annual_scr.*
    attributes (without defaults)

    before input
      call r_view.doc.AnnualLeave_Balance()
      
    on change annual_date, annual_adjustment, annual_runningbalance
      call r_view.doc.AnnualLeave_Balance()
      call document_Touched(dialog, TRUE) 
      
    after delete
      call r_view.doc.AnnualLeave_Balance()
      call document_Touched(dialog, TRUE)
  end input 

end dialog



#
#! travel_Edit
#+ Edit Travel Requests
#+
#+ @code
#+ subialog travel_Edit
#
private dialog travel_Edit()
      
  input array r_view.doc.travel from travel_scr.*
    attributes (without defaults)
      
    on change start_date, end_date, days, reason, approved
      call document_Touched(dialog, TRUE) 
      
    after delete
      call document_Touched(dialog, TRUE)
  end input 

end dialog



#
#! row_Set
#+ Set the current row in list view
#+
#+ @param po_control  Controller dialog
#+ @param p_row       Row to set as current
#+
#+ @code
#+ define ra_line dynamic array of t_ZoneLine
#+ ...
#+ call row_Set(dialog) 
#
private function row_Set(po_dialog ui.Dialog, p_row INTEGER)

  define
    l_row integer
    
  call confirm_Save(po_dialog)
  --% let l_row = po_dialog.visualToArrayIndex(k_screenList, p_row)
  --% let l_row = po_dialog.arrayToVisualIndex(k_screenList, p_row)
  --% let l_row = Employee.ListItem_Key(p_row)
  call po_dialog.setCurrentRow(k_screenList, p_row)
  call r_view.doc.Get(r_view.list.Key(p_row))
  call data_Load(r_view.doc)
  call record_Status(po_dialog)
        
end function



#
#! view_Refresh
#+ Refresh the View due to new search criteria
#+
#+ @param po_dialog     Controller dialog object
#+
#+ @code
#+ define ra_companies dynamic array of t_CompanyLine,
#+   l_search string
#+ ...
#+ on change l_search
#+   call view_Refresh(dialog)
#
#%KLUDGE: should be passed: r_view Employee.tView,

private function view_Refresh(po_dialog ui.Dialog)

  define
    l_row integer,
    l_count integer

    
  call confirm_Save(po_dialog)
  call r_view.list.selection.Filter(po_dialog.getFieldValue(r_view.list.selection.field))
  call r_view.list.selection.Refresh()
  call po_dialog.setArrayLength(k_screenList, r_view.list.selection.count)
  let l_count = r_view.list.Load(fgl_dialog_getBufferStart(), fgl_dialog_getBufferLength())
  call record_Status(po_dialog)

  -- Refresh data for current row
  let l_row = po_dialog.getCurrentRow(k_screenList)
  call r_view.doc.Get(iif(l_row, r_view.list.Key(l_row), 0))
  call data_Load(r_view.doc)
        
end function


#
#! record_Status
#+ Display status of the current selection set, ie. record n of m
#+
#+ @param po_control    Contoller dialog
#+
#+ @code
#+ call record_Status(dialog)
#

private function record_Status(po_control ui.Dialog)

  message sfmt("Record %1 of %2", po_control.getCurrentRow(k_screenList),
    po_control.getArrayLength(k_screenList))

end function



#
#! confirm_Cancel
#+ Check if modified and Prompt user to confirm to discard changes
#+
#+ @param po_dialog  Controller dialog object
#+
#+ @code
#+ call confirm_Cancel(dialog)
#

private function confirm_Cancel(po_dialog ui.Dialog)

  if UI_.Fields_Touched(po_dialog, ma_fields, NULL)
  then
    if fgl_WinQuestion("Discard Changes?",
      "The current document has been modified.\nDo you wish to discard these changes?",
      "yes",
      "no|yes",
      "question",
      FALSE) =  "yes"
    then
      message "Discarding ..."
      call r_view.doc.Get(r_view.doc.employee.employee_no)
      call data_Load(r_view.doc)
      call document_Touched(po_dialog, FALSE)
      message "Changes discarded"
    end if
  end if

end function



#
#! confirm_Delete
#+ Dialog to confirm if record is to be deleted
#+
#+ @param po_dialog   Controller dialog object
#+
#+ @returnType        Boolean
#+ @return            TRUE if record was deleted
#+
#+ @code
#+ call confirm_Delete(dialog)
#

private function confirm_Delete(po_dialog ui.Dialog)

  define
    l_row integer
    --% ,l_deleted boolean


  --% let l_deleted = FALSE
  if fgl_WinQuestion("Delete Employee?",
    "Do you wish to Delete this employee and all related data?",
    "yes",
    "no|yes",
    "question",
    FALSE) =  "yes"
  then
    message "Deleting ..."
    if r_view.doc.Delete() = "OK"
    then
      # remove line and repositon to next or previous record
      let l_row = po_dialog.getCurrentRow(k_screenList)
      call document_Touched(po_dialog, FALSE)
      --% call Selection.Refresh()
      --% call po_dialog.deleteRow(k_screenList, l_row)
      call view_Refresh(po_dialog)
      call po_dialog.setCurrentRow(k_screenList, l_row)
      --% let l_deleted = TRUE
    end if
    message ""
  end if

  --% call document_Touched(po_dialog, FALSE)

  --% return l_deleted
end function



#
#! confirm_Save
#+ Check if record needs to be saved and prompt user to confirm
#+
#+ @param po_dialog  Controller dialog object
#+
#+ @code
#+ call confirm_Save(dialog)
#

private function confirm_Save(po_dialog ui.Dialog)

  if UI_.Fields_Touched(po_dialog, ma_fields, NULL)
  then
    if fgl_WinQuestion("Unsaved Document",
      "The current document has been modified.\nDo you wish to Save this document?",
      "yes",
      "no|yes",
      "question",
      FALSE) =  "yes"
    then
      message "Saving ..."
      if r_view.doc.Put() = "OK"
      then
        message "Employee saved"
      end if
    else
      call r_view.doc.Get(r_view.doc.employee.employee_no)
      call data_Load(r_view.doc)
      message "Changes discarded"
    end if
    call document_Touched(po_dialog, FALSE)
  end if

end function


#
#! document_Touched
#+ Update the status of whether the doc has been modified
#+ and activating or de-activating the Save/Cancel buttons
#+
#+ @param po_dialog   Controller dialog object
#+ @param p_state     State to set (TRUE or FALSE) or NULL if status quo
#+ ...
#+ call document_Touched(dialog, FALSE)
#
private function document_Touched(po_dialog ui.Dialog, p_state boolean)

  define
    l_state boolean,
    l_void string


  -- Reset touched state if state defined
  if p_state is not NULL
  then
    let l_void = UI_.Fields_Touched(po_dialog, ma_fields, p_state)
  end if
  
  -- Set Save/Cancel button active according to state of document
  let l_state = UI_.Fields_Touched(po_dialog, ma_fields, NULL)
  call po_dialog.setActionActive("save", l_state)
  call po_dialog.setActionActive("cancel", l_state)
  
end function


#
# Pseudo data %%%%%%%%%%%%%%SMOKE
#


#
#! Load   Load data into chart
#

private function data_Load(r_doc Employee.tDoc inout)

  -- Load up chart data
  --%%% call chart_Load(mr_data.dash1, "DASH1")
  call chart_Load(mr_data.dash1, "RANDOM")
  call mr_data.dash1.Set()
  --%%% call chart_Load(mr_data.dash2, "DASH2")
  call chart_Load(mr_data.dash2, "RANDOM")
  call mr_data.dash2.Set()

  -- photo --
  let mr_data.photo = downshift(r_doc.employee.gender) || ((r_doc.employee.employee_no mod 10) using "&&")

  -- %%% Change this every 3
  case r_doc.employee.employee_no mod 3
  when 1
    let mr_data.detail_edit = '<h2><span style="color:#0066cc">Experience</span></h2><h4><span style="color:#008a00">Position: Lead Singer</span></h4><h5>Dates: 11nov14-Present</h5><p>Summarize your key responsibilities, leadership, and most stellar accomplishments. Don?t list everything; keep it relevant and include data that shows the impact you made.</p><h4><span style="color:#008a00">Position: Drummer</span></h4><h5>Dates 02jul13-10nov14</h5><p>Think about the size of the team you led, the number of projects you balanced, or the number of articles you wrote.</p><h2><span style="color:#0066cc">Education</span></h2><h4><span style="color:#008a00">Doctorate Degree &#x2F; 12jan11</span></h4><h5><span style="color:#008a00">School of Rock</span></h5><p>You might want to include your GPA and a summary of relevant coursework, awards, and honors.</p><h2><span style="color:#0066cc">Volunteer Experience or Leadership</span></h2><p>Did you manage a team for your club, lead a project for your favorite charity, or edit your school newspaper? Go ahead and describe experiences that illustrate your leadership abilities.<br/>  </p>'
  when 2
    let mr_data.detail_edit = '<h2><span style="color:#0066cc">Experience</span></h2><h4><span style="color:#008a00">Position: Band Leader</span></h4><h5>Dates: 29sep13-Present</h5><p>Theres a lady whos sure, all thet glitters is gold and shes buying a stairway to heaven</p><h4><span style="color:#008a00">Position: Lead Guitarist</span></h4><h5>Dates 10jan14-22dec16</h5><p>I dont mind you coming here, and wasting all my time, when your standing oh so near, I kind of lose my mind, yeah, you always knew to wear it well, you look so facny I can tell, I dont mind you coming here and wasting all my time.</p><h2><span style="color:#0066cc">Education</span></h2><h4><span style="color:#008a00">Masters Degree &#x2F; 23nov10</span></h4><h5><span style="color:#008a00">Rock n Roll High School</span></h5><p>Nine to five its five to nine, aint gonna take it its our time, we want the world and we want it now, were gonna take it any how, we want the airwaves.</p><h2><span style="color:#0066cc">Volunteer Experience or Leadership</span></h2><p>In Penny Lane there is a barber showing photographs, of every head hes had the pleasure to know, and all the peopld that come and go, stop and say hello.<br/>  </p>'
  otherwise
    let mr_data.detail_edit = '<h2><span style="color:#0066cc">Experience</span></h2><h4><span style="color:#008a00">Position: Backup Vocals</span></h4><h5>Dates: 12jun12-Present</h5><p>Thunderbolt and lightning, very, very frightening, oh mama mia, mama mia, can anybody, find me, somebody to love</p><h4><span style="color:#008a00">Position: Bass Guitar</span></h4><h5>Dates 03apr12-18aug15</h5><p>Hello darkness my old friend, Ive come to talk to you again, because a vision softly creeping, left its seed while I was sleeping, and the visions that was planted in my brain, still remains, within the sounds of silence.</p><h2><span style="color:#0066cc">Education</span></h2><h4><span style="color:#008a00">Diploma in Grunge &#x2F; 24mar13</span></h4><h5><span style="color:#008a00">Music Conservatory</span></h5><p>There must be some kind of way out of here, said the joker to the theif, theres too much confusion, I cant get no relief.</p><h2><span style="color:#0066cc">Volunteer Experience or Leadership</span></h2><p>I see a red door and I want to paint it black, no colours anymore I want them to turn black. I see the girls go by dressed in their summer clothes, I have to turn my head until my darkness goes.<br/>  </p>'
  end case
      -- Need to *embed* for some websites like Google maps
      --% display "https://maps.google.com/maps?q=Paris&output=embed" to map
      #% display "https://maps.google.com/maps?q=Paris" to map
      --% display "https://www.openstreetmap.org/export/embed.html?bbox=7.7011263370513925%2C48.609369784200005%2C7.715288400650024%2C48.61584599949853&amp;layer=mapnik" to map

  -- %get location from employee and set map location
  let mr_data.map = "https://maps.google.com/maps?q=Paris"

end function


#
#! chart_Load
#
public function chart_Load(r_chart wc_c3chart.tChart inout, p_set string)

  define
    p_max, i,j integer

  case
    when p_set = "DASH1"
      let i = 0
      -- Set data using JSONarray strings, just to show that we can
      call r_chart.doc.data.Set(i:=i+1, '["Alpha"]')
      call r_chart.doc.data.Set(i:=i+1, '["Beta"]')
      call r_chart.doc.data.Set(i:=i+1, '["Gamma"]')
      call r_chart.doc.data.Set(i:=i+1, '["Delta"]')
      call r_chart.doc.data.Set(i:=i+1, '["Epsilon"]')
    when p_set = "DASH2"
      let i = 0
      -- Set data using JSONarray strings, just to show that we can
      call r_chart.doc.data.Set(i:=i+1, '["Zeta"]')
      call r_chart.doc.data.Set(i:=i+1, '["Eta"]')
      call r_chart.doc.data.Set(i:=i+1, '["Theta"]')
      call r_chart.doc.data.Set(i:=i+1, '["Iota"]')
      call r_chart.doc.data.Set(i:=i+1, '["Kappa"]')
    otherwise
      -- Simulate fetching data for selected element, load some random data
      let p_max = 300
      for j = 1 to 5
        for i = 2 to 7
          let r_chart.doc.data.columns[j,i] = data_Random(p_max)
        end for
      end for
  end case
  
end function


#
#! data_Random    Generate some random data
#
private function data_Random(p_max integer)

  return util.integer.abs(security.RandomGenerator.CreateRandomNumber() mod p_max)
  
end function





#
# %%%TEST
#

#
# UpShift_Labels
#

function UpShift_Labels()

  define nl om.NodeList 
  define r, n om.DomNode 
  define i integer

  let r = ui.Interface.getRootNode()
  let nl = r.selectByTagName("Label")

  for i=1 to nl.getLength()
    let n = nl.item(i)
    call n.setAttribute("text", n.getAttribute("text").toUpperCase())
  end for
  
end function