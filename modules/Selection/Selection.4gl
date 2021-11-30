#
# Selection.4gl: Module for managing Query Selection sets
#
# Methods
#| tQuery::
#!  .Current          Set current tQuery in class
#!  .Refresh          Selection refresh
#!  .Options_Dialog   Set search options to match case, word and choose which columns to include
#!  .Filter           Set selection where clause from search filter criteria
#!  .SQL              Return SQL query for a selection set
#!  .SortKey          Set the sort key
#
# Dialogs
#! Search                   Search dialog box
#

##########################################################################
#
# TYPES
#
##########################################################################

-- Data column
public type tColumn
  record
    selected boolean,
    name string,
    label string,
    type string
  end record

-- Search Options
private type tSearchOptions
  record
    matchCase boolean,
    matchWord boolean
  end record

private type tSelectDefault
  record
    orderBy string,
    join string
  end record

--%REDUNDANT private type tf_listRefresh function(po_dialog ui.Dialog)
  
-- List: defines query and data set
public type tQuery
  record
    select string,
    from string,
    where string,
    orderBy string,
    desc boolean,
    count integer,
    default tSelectDefault,
    options tSearchOptions,
    columns dynamic array of tColumn,
    index dictionary of integer,
    cursor base.SqlHandle,
    View_Refresh function(po_dialog ui.Dialog),
    field string
  end record

public constant
  k_AutoSearchLimit = 100


-- Local Data
--%LIMITATION - as we can't pass params to sub-dialogs
private define  mr_current tQuery

-- a table description %%% Replace with 
{
DEFINE fields DYNAMIC ARRAY OF RECORD
    name STRING, -- a column name
    type STRING  -- a column type
END RECORD
}






##########################################################################
#
# OBJECT METHODS
#
##########################################################################

#
#%LIMITATION
#
#! tQuery::Current
#+ Set current tQuery in class, as sub-dialogs can't be passed any data as parameters
#+
#+ @code
#+ define r_sel Selection.tQuery
#+ ...
#+ call r_sel.Current()
#

public function (this tQuery) Current()

  let mr_current = this

end function


#
#! tQuery::Refresh
#+ Selection refresh 
#+
#+ @param pr_selection  Selection set
#+
#+ @code
#+ define p_query string, r_sel Selection.tQuery
#+ ...
#+ call r_sel.Refresh()
#

public function (this tQuery) Refresh()

  {%%
  define l_debug string
  let l_debug = rList.selection.SQL("DATA")
  }

  -- Create new handle if NULL
  if this.cursor is NULL
  then
    let this.cursor = base.SqlHandle.create()
  end if

  -- Close if cursor already open?
  try
    call this.cursor.close()
  catch
  end try

  -- Cursor for list
  call this.cursor.prepare(this.SQL("DATA"))
  call this.cursor.openScrollCursor()

  -- Save count
  declare c_listCount cursor from this.SQL("COUNT")
  foreach c_listCount into this.count
  end foreach
  
end function



#
#! tQuery::Options_Dialog
#+ Set search options to match case, word and choose which columns to include
#+
#+ @code
#+ define r_sel Selection.tQuery
#+ ...
#+ call r_sel.Options_Dialog()
#
public function (this tQuery) Options_Dialog()

  define
    r_opts tSearchOptions,
    a_cols dynamic array of tColumn


  -- Save options & columns before in case of Cancel
  let r_opts.* = this.options.*
  call this.columns.copyTo(a_cols)
  
  open window w_searchOptions with form "Selection_SearchOptions"
    attributes(STYLE="dialog")

  dialog attributes(unbuffered)

    input array a_cols from sca_columns.*
    end input

    input by name r_opts.matchCase, r_opts.matchWord
      attributes(without defaults)
    end input

    on action close
      exit dialog
      
    on action cancel
      exit dialog
      
    on action accept
      -- Save options to this
      let this.options.* = r_opts.*
      call a_cols.copyTo(this.columns)
      exit dialog
  end dialog
  
  close window w_searchOptions
    
end function



#
#! tQuery::Filter
#+ Set selection where clause from search filter criteria 
#+
#+ @param p_match   Match wildcard pattern
#+
#+ @code
#+ define r_sel Selection.tQuery
#+ call r_sel.Filter("A*")
#
# Options for Advanced?
#   match first or any
#   choose specific fields or all
#   ignore case
#
public function (this tQuery) Filter(p_match string)

  define
    l_cond, l_or, l_any, l_where string,
    l_col integer

  let l_where = ""

  #
  # to match any case
  #  upper(column) matches upper(p_match)
  # if match specific string, remove the "*"
  #
  if p_match.getLength()
  then
    -- match specific word?
    let l_any = iif(this.options.matchWord, "", "%")
    
    -- for each filterable column, add to Where clause
    let l_or = " "
    for l_col = 1 to this.columns.getLength()
      if this.columns[l_col].selected
      then
        if this.options.matchCase
        then
          let l_cond = l_or, this.columns[l_col].name, "||'' like '", l_any, p_match, l_any, "'"
        else
          let l_cond = l_or, "upper(", this.columns[l_col].name, "||'') like upper('", l_any, p_match, l_any, "')"
        end if
        let l_where = l_where.append(l_cond)
        let l_or = " or "
      end if
    end for
  end if

  LET this.where = l_where

end function



#
#! tQuery::SQL
#+ Return SQL query for a selection set
#+
#+ @param pr_selection  Selection set
#+ @param p_select      "data", "count"
#+
#+ @code
#+ define p_query string, r_sel Selection.tQuery
#+ ...
#+ let p_query =  r_sel.SQL("data")
#

public function (this tQuery) SQL(p_select STRING)
    returns string

  define  
    l_orderBy, l_where, l_and, l_query string


  let l_orderBy = NVL(this.orderBy, this.default.orderBy)

  let l_where = iif(this.default.join.getLength(), SFMT("(%1)", this.default.join), "")
  let l_and = iif(l_where.getLength(), " and ", " ")
  let l_where = l_where.append(iif(this.where.getLength(), l_and || "(" || this.where || ")", ""))


  let l_query =
    "select ", this.select,
    " from ", this.from,
    iif(l_where.getLength(), " where ", ""), l_where
    
  case p_select.toUpperCase()
  when "COUNT"
    let l_query = "select count(*) from (", l_query, ")"
  otherwise
    let l_query =  l_query,
      " ", iif(l_orderBy.getLength(), "order by " || l_orderBy, ""),
      " ", iif(this.desc, " desc", "")
  end case

  return l_query
  
end function



#
#! tQuery::SortKey
#+ Set the sort key
#+ (and fix if it has an underscore prefix, used if column already exists)
#+
#+ @param p_key   Raw sort key
#+
#+ @code
#+ define r_sel Selection.tQuery
#+ call r_sel.SortKey(dialog.getSortKey(k_screenList))
#
public function (this tQuery) SortKey(p_key string)

  while p_key matches "_*"
    let p_key = p_key.subString(2,p_key.getLength())
  end while

  let this.orderBy = p_key
  
end function




##########################################################################
#
# DIALOGS
#
##########################################################################

#
#%%% MUST Set mr_current
#
#! Search
#+ Search dialog box
#+
#+ @code
#+ subdialog Selection.Search
#
public dialog Search()

  define
    l_search string

    
    #
    # Search
    #
    input by name l_search

      before input
        --%%% just for call confirm_Save
        -- do we really need a callback for context change?
        call mr_current.View_Refresh(dialog)
        
      on change l_search
        -- Only do this when row count > limit?
        -- this is not practical unless data set is moderate
        if mr_current.count < k_AutoSearchLimit
        then
          call mr_current.View_Refresh(dialog)
        end if

      after input
        call mr_current.View_Refresh(dialog)

      on action b_search
        call mr_current.Options_Dialog()
    end input
    
end dialog

{
public dialog Find()

  define
    l_find string

    
    #
    # Search
    #
    input by name l_find

      after input
        ### Find NEXT
        --% let mr_current.where = iFilter(l_find)
        call mF_listFind(dialog)
        --% call List_Refresh(ra_users, dialog)

      on action b_prev
        ### Find PREV
        
      on action b_search
        call Options_Dialog()
    end input
    
end dialog
}



#------------------------------------------------------------------

#----------- NOTE IMPLEMENTED YET ----------------------

#
# Adapted from $FGLDIR/demo/dbbrowser/dbbrowser.4gl
#
public function (this tQuery) ListForm_Create(tabName string)

  define i int
  define colName, colType string
  define f ui.Form
  define w ui.Window

  define window, form, grid, table, formfield, edit  om.DomNode

  let w = ui.Window.getCurrent()
  let f = w.createForm("test")
  let form = f.getNode()

  --
  let window = form.getParent()
  call window.setAttribute("text", tabName)
  --
  let grid = form.createChild("Grid")
  call grid.setAttribute("width", 1)
  call grid.setAttribute("height", 1)
  let table = grid.createChild("Table")
  call table.setAttribute("doubleClick", "update")
  call table.setAttribute("tabName", tabName)
  call table.setAttribute("pageSize", 10)
  call table.setAttribute("gridWidth", 1)
  call table.setAttribute("gridHeight", 1)

  for i = 1 to this.columns.getLength()
    let formfield = table.createChild("TableColumn")
    let colName = this.columns[i].name
    let colType = this.columns[i].type
    call formfield.setAttribute("text", colName)
    call formfield.setAttribute("colName", colName)
    call formfield.setAttribute("name", tabName || "." || colName)
    call formfield.setAttribute("sqlType", colType)
    --CALL formfield.setAttribute("fieldId", i)
    call formfield.setAttribute("tabIndex", i + 1)
    let edit = formfield.createChild("Edit")
    call edit.setAttribute("width", bestWidth(colType))
  end for
  --CALL form.writeXml("test.42f")
end function


private function bestWidth(t)
  define t string
  define i, j, len int

  if (i := t.getIndexOf('(', 1)) > 0
  then
    if (j := t.getIndexOf(',', i + 1)) == 0
    then
      let j = t.getIndexOf(')', i + 1)
    end if
    let len = t.subString(i + 1, j - 1)
    let t = t.subString(1, i - 1)
  end if

  case t
  when "BOOLEAN"  return 1
  when "TINYINT"  return 4
  when "SMALLINT" return 6
  when "INTEGER"  return 11
  when "BIGINT"   return 20
  when "SMALLFLOAT" return 14
  when "FLOAT"   return 14
  when "STRING"  return 20
  when "DECIMAL" return iif(len is null, 16, len + 2)
  when "MONEY"   return iif(len is null, 16, len + 2)
  when "CHAR"    return iif(len is null, 1, iif (len > 20, 20, len))
  when "VARCHAR" return iif(len is null, 1, iif (len > 20, 20, len))
  when "DATE"    return 10
  otherwise
    return 20
  end case
end function


private function (this tQuery) describeTable(tabName string)

    define h base.SqlHandle
    define i int

    let h = base.SqlHandle.create()
    call h.prepare("select * from " || tabName)
    call h.open()
    call this.columns.clear()
    for i = 1 to h.getResultCount()
        let this.columns[i].name = h.getResultName(i)
        let this.columns[i].label = this.columns[i].name
        let this.columns[i].type = h.getResultType(i)
    end for
    call h.close()
end function












