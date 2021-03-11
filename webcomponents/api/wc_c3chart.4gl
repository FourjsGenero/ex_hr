import FGL str
import util

#
# c3chart Type Def
#
public type
  tColumn dynamic array of string,
  tColumns dynamic array of tColumn,
  tTypes dictionary of string,
  tGroup dynamic array of string,
  tGroups dynamic array of tGroup,

  tData record
    x string,
    xFormat string,
    y string,
    yFormat string,
    columns tColumns,
    type string,
    types tTypes,
    groups tGroups,
    onclick string
  end record,

  tAxisType record
      type string,
      label string,
      categories dynamic array of string
    end record,
  tAxis record
    rotated boolean,
    x tAxisType,
    y tAxisType
  end record,

  tGridLines record
    show boolean,
    lines dynamic array of string
  end record,
  tGrid record
    x tGridLines,
    y tGridLines
  end record,

  tLegend record
    position string,
    show boolean
  end record,

  tTooltip record
    show boolean,
    grouped boolean,
    format string
  end record,

  tPadding record
    top string,
    right string,
    bottom string,
    left string
  end record,

  tColor record
    pattern dynamic array of string
  end record,
  
  tDoc record
    data tData,
    axis tAxis,
    grid tGrid,
    legend tLegend,
    tooltip tTooltip,
    padding tPadding,
    color tColor
  end record,

  tChart record
    field string,
    title string,
    narrative string,
    showfocus boolean,
    doc tDoc
  end record,

  tElement record
    x string,
    value string,
    id string,
    index string,
    name string
  end record

public define
  m_trace boolean = FALSE



#
# Class Methods
#

  
#
#! Init
#+ Initialize
#+
#+ @code
#+ call wc_c3chart.Init()
#
public function Init()
  #% no longer needed, but for any other initializations
  #let m_trace = FALSE
end function


#
#! Domain
#+ Returns list of possible values in a domain
#+
#+ @param p_domain    Domain to return possible values of
#+
#+ @code
#+ define a_list dynamic array of string
#+ call wc_c3chart.Domain("chart_type") returning a_list
#

public function Domain(p_domain string) returns dynamic array of string

  define
    a_list dynamic array of string

  case p_domain.toUpperCase()
    when "CHART_TYPE"
      call str.ArraySet(a_list, '["","line","spline","step","area","area-spline","area-step","bar","scatter","pie","donut","gauge"]')
    when "AXIS_TYPE"
      call str.ArraySet(a_list, '["","indexed","category","timeseries"]')
    when "POSITION"
      call str.ArraySet(a_list, '["","bottom","right","inset"]')
  end case
  
  return a_list

end function



#
# tChart::Methods
#

#
#! tChart.New
#+ Define a new instance of Chart
#+
#+ @param p_field     Form name of the field
#+
#+ @code
#+ define r_chart wc_c3chart.tChart
#+ call r_chart.New("formonly.p_chart")
#
public function (this tChart) New(p_field string)

  -- Field name of widget
  let this.field = p_field

  -- Set defaults
  let this.doc.axis.rotated = FALSE
  let this.doc.legend.show = TRUE
  let this.doc.tooltip.show = TRUE
  
end function



#
#! tChart.Serialize
#+ Serialize a chart
#+
#+ @returnType string
#+ @return JSON string of tChart.doc structure
#+
#+ @code
#+ define r_chart wc_c3chart.tChart,
#+   p_json string
#+ let p_json = r_chart.Serialize()
#
public function (this tChart) Serialize() returns string

  call trace(util.JSON.stringify(this))
  return util.JSON.stringify(this)
  
end function



#
#! tChart.Set
#+ Set initial contents of widget
#+
#+ @code
#+ define r_chart tChart
#+ let r_chart.data.x = "x"
#+ ...
#+ call r_chart.Set()
#
public function (this tChart) Set()

  call ui.Interface.frontCall("webcomponent", "call", [this.field, "Set", this.Serialize()], [])
  
end function



#
# tData::Methods
#

#
#! tData.Set
#+ Set column of data from JSONArray string
#+
#+ @param p_json    JSON array of strings
#+
#+ @code
#+ define r_data tData
#+ call r_data.Set(1, '["alpha","100","180","240"]')
#
public function (this tData) Set(p_idx integer, p_json string)

  call str.ArraySet(this.columns[p_idx], p_json)

end function





#
# tElement::Methods
#

#
#! tElement.Get
#+ DeSerialize a selected chart element from JSON string
#+
#+ @param p_json    JSON encoded element
#+ @returnType      tElement
#+ @return          Element record
#+
#+ @code
#+ define r_element tElement, p_json string
#+ call tElement.Get(p_json)
#
public function (this tElement) Get(p_json string)

  call trace(p_json)
  if (p_json.getLength())
  then
    call util.JSON.parse(p_json, this)
  end if
  
end function




#
# PRIVATE
#

#
#! trace
#+ Dump argument string as trace to output if trace enabled
#+
#+ @param     Data string to dump to output
#+
#+ @code
#+ call trace('here i am')
#
private function trace(p_data string)

  if m_trace
  then
    display p_data
  end if

end function