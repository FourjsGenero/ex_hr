#############################################################################
#
# UI_. Index
#
# PUBLIC
#! ButtonEdit_ButtonActive: Activate button and set Image on ButtonEdit
#! Combo_List: set INCLUDE values in a Combo widget
#! Element_Hide: Hide/unhide a form element
#! Field_Get: Get an attribute from a Field node in the current window
#! Field_Hide: Hide/unhide a form field
#! Field_Node: Return node for a Form Field identified by name
#! Field_Set: Set an attribute of a Field node in the current window
#! Fields_Touched: Get or Set the touched status of a list of fields
#! Item_Get: Get an attribute from a Form Item in the current window
#! Item_Node: Return Node for a Form Item in the current window
#! Item_Set: Set an attribute of a Form Item in the current window
#! Node_Get: Get an attribute from a Node in the current window
#! Node_Find: Finds first Node matching Class and Name
#! Node_Set: Set an attribute of a Node in the current window
#! NodeList_Find: Finds a List of Nodes matching Class and Name
#! Menu_Attach: Create and attach a Menu object
#! Page_Row: Calculates the next or previous row for a page offset
#! Style_Get: Get style attribute
#! Style_Set: Set style attribute
#! Table_PageRow: Calculates the next or previous row for a page offset
#! Table_Size: Sets maximum number of rows in table
#! Widget_Get: Get an attribute from a Field Widget in the current window
#! Widget_Node: Get Node for a Field Widget in the current window
#! Widget_Set: Set an attribute of a Field Widget in the current window
#! Window_Title: Set the title bar text of the current window
#
# TBD
#> Dialog_ActionSet(dialog, "active|hidden|enable", state)
#
# PRIVATE
#! xpath_Expr: returns an XPath expression for a class and name
#
#############################################################################

--% package Common
import FGL str
import FGL OM_




#
# class: Field, Widget, Node
#
# TableColumn, FormField: colName
# p_class could be simply "Field", "Column" or tag type or
#   FormField/Edit
# p_name could be name or expression eg. tag='abc"
#


# Actions
#   /UserInterface/LocalAction
#   /UserInterface/ActionDefaultList/ActionDefault
#   //Window/Menu/MenuAction
#   //Window/Dialog/LocalAction
#   //Window/Dialog/Action
#




#
# ButtonEdit:
#

#
#! UI_.ButtonEdit_ButtonActive
#+ Activate button and set Image on ButtonEdit
#+
#+ @param p_name    Name of ButtonEdit field
#+ @param p_image   Image resource
#+ @param p_active  Active: TRUE or FALSE
#+
#+ @code
#+ on change l_search
#+   call UI_.ButtonEdit_ButtonActive("l_search", "search", TRUE)
#

public function ButtonEdit_ButtonActive(p_name string, p_image string, p_active boolean)
  returns ()

  define
    l_action string


  call Widget_Set(NULL, p_name, "image", p_image)
  call Widget_Set(NULL, p_name, "actionActive", p_active)
  let l_action = Widget_Get(NULL, p_name, "action")
  call Item_Set("Action", l_action, "active", p_active)

end function




#
# Combo:
#

############################################################################
#
#! UI_.Combo_List:
#+ Sets the INCLUDE values in a Combo widget
#+
#+ @param p_colName   Field or column name of combo widget
#+ @param p_query     SQL statement or a pipe (|) separated list of tuples
#+                    where each tuple may be value,description pair sep by (^)
#+
#+ @code
#+ call UI_.Combo_List("honorific", "Mr|Mrs|Miss|Ms")
#+ call UI_.Combo_List("state", "SELECT stateId, name FROM states")
#
############################################################################

public function Combo_List(p_colName string, p_query string)
  returns ()

  define
    p_key     string,
    p_value   string,
    p_end     integer,
    d_combo   ui.ComboBox,
    o_list    base.StringTokenizer


  ### Trim in case CHAR was passed ###
  let p_colName = p_colName.trim()
  let p_query = p_query.trim()

  ### Get node for ComboBox ###
  let d_combo = ui.ComboBox.forName(p_colName)
  if d_combo is NULL
  then
    return
  end if

  ### Clear previous items ###
  call d_combo.clear()

  ### Process according to what's in query ###
  if p_query.toUpperCase() matches "SELECT*FROM*"
  then
    ### Prepare query ###
    prepare q_comboList from p_query
    declare c_comboList cursor for q_comboList

    ### Get list of values ###
    foreach c_comboList into p_key, p_value
      if p_value is NULL
      then
        let p_value = p_key clipped
      end if
      call d_combo.addItem(p_key clipped, p_value clipped)
      let p_value = NULL
    end foreach
  else
    ### Query is simple list of values ###
    let o_list = base.StringTokenizer.create(p_query, "|")
    while o_list.hasMoreTokens()
      let p_value = o_list.nextToken()
      if p_value matches "*^*"
      then
        let p_end = p_value.getIndexOf("^", 1)
        let p_key = p_value.subString(1, p_end-1)
        let p_value = p_value.subString(p_end+1, length(p_value))
      else
        let p_key = p_value clipped
      end if
      call d_combo.addItem(p_key clipped, p_value clipped)
    end while
  end if

end function





#
# Elements: Screen elements
#

#############################################################################
#
#! UI_.Element_Hide
#+ Hide an element on the current form, in the current window
#+
#+ @param p_name    Name of element
#+ @param p_hide    0=unhide, 1=hidden, 2=hidden but user can unhide
#+
#+ @code
#+ call UI_.Element_Hide("name", 1)
#
#############################################################################

public function Element_Hide(p_name string, p_hide boolean)
  returns ()

  define
    w_current ui.Window,
    f_current ui.Form

  let w_current = ui.Window.getCurrent()
  let f_current = w_current.getForm()

  call f_current.setElementHidden(p_name, p_hide)
  
end function




#
# Fields: Form Field ops
#

#############################################################################
#
#! UI_.Field_Get
#+ Get an attribute from a Field node in the current window
#+
#+ @param p_name    Name of field (either name=table.column or colName=column)
#+ @param p_attrib  Attribute of field
#+
#+ @returnType      String
#+ @return          Value of attribute
#+
#+ @code
#+ define p_value string
#+ let p_value = UI_.Field_Get("customer.name", "varType")
#
#############################################################################

public function Field_Get(p_name string, p_attrib string)
  returns (string)

  define
    d_field   om.DomNode,
    p_value   string


  ### If Field node found, get attribute ###
  let d_field = Field_Node(p_name)
  if d_field is not NULL
  then
    let p_value = d_field.getAttribute(p_attrib)
  end if

  return p_value

end function



#############################################################################
#
#! UI_.Field_Hide
#+ Hide a field on the current form, in the current window
#+
#+ @param p_name    Name of field (either name=table.column or colName=column)
#+ @param p_hide    0=unhide, 1=hidden, 2=hidden but user can unhide
#+
#+ @code
#+ call UI_.Field_Hide("name", 1)
#
#############################################################################

public function Field_Hide(p_name string, p_hide boolean)
  returns ()

  define
    w_current ui.Window,
    f_current ui.Form

  let w_current = ui.Window.getCurrent()
  let f_current = w_current.getForm()

  call f_current.setFieldHidden(p_name, p_hide)
  
end function



#############################################################################
#
#! UI_.Field_Node
#+ Return node for a Form Field identified by name
#+
#+ @param p_name  Name of field (either name=table.column or colName=column)
#+
#+ @returnType    om.DomNode
#+ @return        DomNode of FormField
#+
#+ @code
#+ define d_custid om.DomNode
#+ let d_custid = UI_.Field_Node("custid")
#
#############################################################################

public function Field_Node(p_name string)
  returns (om.DomNode)

  define
    d_win     om.DomNode,
    d_field   om.DomNode


  ### Look into current window ###
  let d_win = Window_Node(NULL)

  ### Try FormField first ###
  let d_field = Node_Find(d_win, "FormField", p_name)
  if d_field is NULL
  then
    ### Otherwise try TableColumn ###
    return Node_Find(d_win, "TableColumn", p_name)
  else
    return d_field
  end if

end function




#############################################################################
#
#! UI_.Field_Set
#+ Set an attribute of a Field node in the current window
#+
#+ @param p_name    Name of field (either name=table.column or colName=column)
#+ @param p_attrib  Attribute of field
#+ @param p_value   Value to set attribute to
#+
#+ @code
#+ call UI_.Field_Set(p_name, p_attrib, p_value)
#
#############################################################################

public function Field_Set(p_name string, p_attrib string, p_value string)
  returns ()

  define
    d_field   om.DomNode


  ### If Field node found, set attribute ###
  let d_field = Field_Node(p_name)
  if d_field is not NULL
  then
    call d_field.setAttribute(p_attrib, p_value)
  end if

end function



#############################################################################
#
#! UI_.Fields_Touched
#+ Get or Set the touched status of a list of fields
#+
#+ @param po_dialog    Dialog
#+ @param pa_fields    List of fields, including wildcards for screen records
#+ @param p_state      State to set to, or NULL to get current status
#+
#+ @code
#+ define pa_fields dynamic array of string
#+ let pa_fields[1] = "customer.*'
#+ let pa_fields[2] = "stock_no"
#+ ...
#+ if UI_.Fields_Touched(dialog, pa_fields, NULL) then ...
#+ let void = UI_.Fields_Touched(dialog, pa_fields, FALSE)
#
#############################################################################

public function Fields_Touched(po_dialog ui.Dialog, pa_fields dynamic array of string, p_state boolean)
  returns (boolean)

  define
    idx integer

    
    for idx = 1 to pa_fields.getLength()
        if p_state is NULL
        then
          if po_dialog.getFieldTouched(pa_fields[idx])
          then
            return TRUE
          end if
        else
          call po_dialog.setFieldTouched(pa_fields[idx], p_state)
        end if
    end for

  return FALSE
  
end function




#
# Item: Form Item ops
#

#############################################################################
#
#! UI_.Item_Get
#+ Get an attribute from a Form Item in the current window
#+
#+ @param p_class   Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name    Name attribute, MUST have NAME defined for Item in form spec
#+ @param p_attrib  Attribute of item
#+
#+ @returnType      String
#+ @return          Value of attribute
#+
#+ @code
#+ define p_value string
#+ let p_value = UI_.Item_Get("Table", "t_list", "tabName")
#
#############################################################################

public function Item_Get(p_class string, p_name string, p_attrib string)
  returns (string)

  return Node_Get(OM_.Window_Node(NULL), p_class, p_name, p_attrib)

end function




#############################################################################
#
#! UI_.Item_Node
#+ Return Node for a Form Item in the current window
#+
#+ @param p_class Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name  Name attribute - MUST have NAME defined for Item in form spec
#+
#+ @returnType    om.DomNode
#+ @return        DomNode for the named Form Item
#+
#+ @code
#+ define d_table om.DomNode
#+ let d_table = UI_.Item_Node("Table", "t_list")
#
#############################################################################

public function Item_Node(p_class string, p_name string)
  returns (om.DomNode)

  return Node_Find(OM_.Window_Node(NULL), p_class, p_name)

end function




#############################################################################
#
#! UI_.Item_Set
#+ Set an attribute of a Form Item in the current window
#+
#+ @param p_class   Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name    Name attribute, MUST have NAME defined for Item in form spec
#+ @param p_attrib  Attribute of item
#+ @param p_value   Value to set attribute to
#+
#+ @code
#+ call UI_.Item_Set("Table", "t_list", "width", "38")
#
#############################################################################

public function Item_Set(p_class string, p_name string, p_attrib string, p_value string)
  returns ()

  call Node_Set(OM_.Window_Node(NULL), p_class, p_name, p_attrib, p_value)

end function


#############################################################################
#
#! Page_Row
#+ Calculates the next or previous row for a page offset
#+
#+ @param p_direction   Direction "NEXT" or "PREVIOUS"
#+ @param p_current     Current row number
#+ @param p_pageSize    Page size (number of rows)
#+ @param p_maxRow      Maximum row number
#+
#+ @returnType          Integer
#+ @return              Row number
#+
#+ @code
#+ define p_newRow integer
#+ call Page_Row("NEXT", 42, 15, 100)
#
#############################################################################

public function Page_Row(p_direction string, p_current integer, p_pageSize integer, p_maxRow integer)
  returns (integer)

  define
    l_row integer

  if p_direction.toUpperCase() = "PREVIOUS"
  then
    let l_row = p_current - p_pageSize
    if l_row  > 0
    then
      return l_row
    else
      return 1
    end if
  else
    let l_row = p_current + p_pageSize
    if l_row < p_maxRow
    then
      return l_row
    else
      return p_maxRow
    end if
  end if
  
end function




#
# Node: UI node
#

#############################################################################
#
#! UI_.Node_Get
#+ Get an Attribute from a Node
#+
#+ @param d_root    Root node (NULL defaults to UI node) to search from
#+ @param p_class   Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name    Name attribute, MUST have NAME defined for Item in form spec
#+ @param p_attrib  Attribute of item
#+
#+ @returnType      String
#+ @return          Value of attribute
#+
#+ @code
#+ define d_win om.DomNode, p_value string
#+ let d_win = OM.Window_Node(NULL)
#+ let p_value = UI_.Node_Get(d_win, "Group", "gPage", "text")
#
#############################################################################

public function Node_Get(d_root om.DomNode, p_class string, p_name string, p_attrib string)
  returns (string)

  ### Determine attribute field for name ###
  return OM_.Node_AttribGet(d_root,
    xpath_Expr("//", p_class, p_name), p_attrib)

end function




#############################################################################
#
#! UI_.Node_Find
#+ Finds first Node matching Class (tag) and Name
#+
#+ @param d_root    Root node (defaults to UI node)
#+ @param p_class   Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name    Name attribute, MUST have NAME defined for Item in form spec
#+
#+ @returnType      om.DomNode
#+ @return          First Node that matches
#+
#+ @code
#+ define d_win, d_group om.DomNode
#+ let d_win = OM.Window_Node(NULL)
#+ let d_group = UI_.Node_Find(d_win, "Group", "gPage")
#
#############################################################################

public function Node_Find(d_root om.DomNode, p_class string, p_name string)
  returns (om.DomNode)

  ### get list of matching nodes ###
  return OM_.Node_Select(d_root, xpath_Expr("//", p_class, p_name))

end function




#############################################################################
#
#! UI_.Node_Set
#+ Set an attribute of a Node in the current window
#+
#+ @param d_root    Root node (defaults to UI node)
#+ @param p_class   Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name    Name attribute, MUST have NAME defined for Item in form spec
#+ @param p_attrib  Attribute of item
#+ @param p_value   Value to set attribute to
#+
#+ @code
#+ define d_win om.DomNode
#+ let d_win = OM.Window_Node(NULL)
#+ call UI_.Node_Set(d_win, "Group", "gPage", "text", "Instances")
#
#############################################################################

public function Node_Set(d_root om.DomNode, p_class string, p_name string, p_attrib string, p_value string)
  returns ()

  call OM_.Node_AttribSet(d_root, xpath_Expr("//", p_class, p_name),
    p_attrib, p_value)

end function




#############################################################################
#
#! UI_.NodeList_Find
#+ Finds a List of Nodes matching Class and Name
#+
#+ @param d_root    Root node (defaults to UI node)
#+ @param p_class   Class of Form Item (node tag: Eg. Table, Group, Grid, ...)
#+ @param p_name    Name attribute, MUST have NAME defined for Item in form spec
#+
#+ @returnType      om.NodeList
#+ @return          NodeList of matched nodes
#+
#+ @code
#+ define d_win om.DomNode, d_list om.NodeList
#+ let d_win = OM.Window_Node(NULL)
#+ let d_list = UI_.NodeList_Find(d_win, "LocalAction", "interrupt")
#
#############################################################################

public function NodeList_Find(d_root om.DomNode, p_class string, p_name string)
  returns (om.NodeList)

  ### get list of matching nodes ###
  return OM_.NodeList_Select(d_root, xpath_Expr("//", p_class, p_name))

end function




#############################################################################
#
#! UI_.Menu_Attach
#+ Create and attach a Menu object
#+
#+ @param d_parent  DomNode of parent to attach menu object
#+ @param p_class   TopMenuGroup|TopMenuCommand|StartMenuGroup|StartMenuCommand
#+ @param p_text    Text for group
#+ @param p_image   Optional image
#+ @param p_cmd     Command (shell) to execute
#+
#+ @returnType      om.DomNode
#+ @return          DomNode of menu object
#+
#+ @code
#+ define d_menu, d_grp, d_cmd om.DomNode
#+ let d_menu = UI_.Item_Node("TopMenu", "top")
#+ let d_grp = UI_.Menu_Attach(d_menu, "TopMenuGroup", "Config", "folder", "")
#+ let d_menu = UI_.Menu_Attach(d_grp, "TopMenuCommand", "Setup", "leaf", "teams")
#
#############################################################################

public function Menu_Attach(d_parent om.DomNode, p_class string, p_text string, p_image string, p_cmd string)
  returns (om.DomNode)

  define
    p_attrib  string,
    d_child   om.DomNode


  ### Type of menu ###
  case p_class
  when "TopMenuGroup"
  when "TopMenuCommand"
    let p_attrib = "name"
  when "StartMenuGroup"
  when "StartMenuCommand"
    let p_attrib = "exec"
  otherwise
    return NULL
  end case

  let d_child = d_parent.createChild(p_class)
  call d_child.setAttribute("text", str._(p_text))
  call d_child.setAttribute("image", p_image)
  if p_attrib.getLength()
  then
    call d_child.setAttribute(p_attrib, p_cmd)
  end if

  return d_child

end function





#
# Style
#
# % Dynamically create Style & Attribute if it doesn't exist?
#

#############################################################################
#
#! UI_.Style_Get
#+ Get Style Attribute
#+
#+ @param p_style   Style name
#+ @param p_attrib  Style attribute
#+
#+ @returnType      String
#+ @return          Style Attribute value
#+
#+ @code
#+ define p_value string
#+ let p_value = UI_.Style_Get("Label.Heading", "fontFamily")
#
#############################################################################

public function Style_Get(p_style string, p_attrib string)
  returns (string)

  define
    d_aui       om.DomNode,
    p_path      string


  ### Look into AUI ###
  let d_aui = OM_.UI_Node()

  ### Hunt for matching style ###
  let p_path = xpath_Expr("//", "Style", p_style),
    xpath_Expr("/", "StyleAttribute", p_attrib)

  return OM_.Node_AttribGet(d_aui, p_path, "value")

end function




#############################################################################
#
#! UI_.Style_Set
#+ Set Style Attribute
#+
#+ @param p_style   Style name
#+ @param p_attrib  Style attribute
#+ @param p_value   Value to set attribute to
#+
#+ @code
#+ call UI_.Style_Set("Label.Heading", "fontFamily", "Helvetica")
#
#############################################################################

public function Style_Set(p_style string, p_attrib string, p_value string)
  returns ()

  define
    d_aui       om.DomNode,
    p_path      string


  ### Look into AUI ###
  let d_aui = OM_.UI_Node()

  ### Hunt for matching style ###
  let p_path = xpath_Expr("//", "Style", p_style),
    xpath_Expr("/", "StyleAttribute", p_attrib)

  call OM_.Node_AttribSet(d_aui, p_path, "value", p_value)

end function



#
# Table
#

############################################################################
#
#! UI_.Table_PageRow
#+ Calculates the next or previous row for a page offset
#+
#+ @param p_direction   Direction "NEXT" or "PREVIOUS"
#+ @param p_current     Current row number
#+ @param p_pageSize    Page size (number of rows)
#+ @param p_maxRow      Maximum row number
#+
#+ @returnType          Integer
#+ @return              Row number
#+
#+ @code
#+ define p_newRow integer
#+ let p_newRow = Page_Row("NEXT", 42, 15, 100)
#
############################################################################

public function Table_PageRow(p_direction string, p_current integer, p_pageSize integer, p_maxRow integer)
  returns (integer)

  define
    l_row integer

  if p_direction.toUpperCase() = "PREVIOUS"
  then
    let l_row = p_current - p_pageSize
    if l_row  > 0
    then
      return l_row
    else
      return 1
    end if
  else
    let l_row = p_current + p_pageSize
    if l_row < p_maxRow
    then
      return l_row
    else
      return p_maxRow
    end if
  end if
  
end function




############################################################################
#
#! UI_.Table_Size
#+ Sets maximum number of rows in table
#+
#+ @param p_table   Name of table in current form
#+ @param p_rows    Number of rows
#+
#+ @code
#+ call UI_.Table_Size("t_list", 100)
#
############################################################################

public function Table_Size(p_table string, p_rows integer)
  returns ()

  define
    d_win     om.DomNode


  ### Look into current window ###
  let d_win = OM_.Window_Node(NULL)

  call Node_Set(d_win, "Table", p_table, "size", p_rows)

end function



#
# Widget
#

#############################################################################
#
#! UI_.Widget_Get
#+ Get an attribute from a Field Widget in the current window
#+ Widget is typically a child of a FormField or TableColumn
#+
#+ @param p_class   Class - defaults to FormField/* or TableColumn/*
#+                  but can specify specific eg. TableColumn/Edit
#+ @param p_name    Name of field in primary node
#+ @param p_attrib  Attribute of field
#+
#+ @returnType      String
#+ @return          Value of attribute
#+
#+ define p_value string
#+ let p_value = UI_.Widget_Get(NULL, "custid", "color")
#+ let p_value = UI_.Widget_Get("TableColumn/Edit", "account", "format")
#
#############################################################################

public function Widget_Get(p_class string, p_name string, p_attrib string)
  returns (string)

  define
    d_widget    om.DomNode


  ### Find widget node, and return attribute if found ###
  let d_widget = Widget_Node(p_class, p_name)
  if d_widget is not NULL
  then
    return d_widget.getAttribute(p_attrib)
  else
    return ""
  end if

end function




#############################################################################
#
#! UI_.Widget_Node
#+ Get Node for a Field Widget in the current window
#+ Widget is typically a child of a FormField or TableColumn
#+
#+ @param p_class   Class - defaults to FormField/* or TableColumn/*
#                   but can specify specific eg. TableColumn/Edit
#+ @param p_name    Name of field in primary node
#+
#+ @returnType      om.DomNode
#+ @return          Node for a Class of widget identified by Name
#+
#+ @code
#+ define d_cust om.DomNode 
#+ let d_cust = UI_.Widget_Node("", "formonly.custid")
#+ let d_cust = UI_.Widget_Node("FormField/ButtonEdit", "custid")
#
#############################################################################

public function Widget_Node(p_class string, p_name string)
  returns (om.DomNode)

  define
    d_win       om.DomNode,
    d_node      om.DomNode,
    p_fieldPath string,
    p_tablePath string


  ### default to a Field widget ###
  if p_class.getLength()
  then
    let p_fieldPath = p_class
    let p_tablePath = ""
  else
    let p_fieldPath = "FormField/*"
    let p_tablePath = "TableColumn/*"
  end if

  ### Look into current window ###
  let d_win = OM_.Window_Node(NULL)
  let d_node = NULL

  ### Try FormField first ###
  let d_node = Node_Find(d_win, p_fieldPath, p_name)

  ### Otherwise try TableColumn ###
  if d_node is NULL and p_tablePath.getLength()
  then
    let d_node = Node_Find(d_win, p_tablePath, p_name)
  end if

  return d_node

end function




#############################################################################
#
#! UI_.Widget_Set
#+ Set an attribute of a Field Widget in the current window
#+
#+ @param p_class   Class - defaults to FormField/* or TableColumn/*
#                   but can specify specific eg. TableColumn/Edit
#+ @param p_name    Name of field in primary node
#+ @param p_attrib  Attribute of field
#+ @param p_value   Value to set attribute to
#+
#+ @code
#+ call UI_.Widget_Set("", "password", "isPassword", TRUE)
#+ call UI_.Widget_Set("FormField/*", "password", "isPassword", TRUE)
#
#############################################################################

public function Widget_Set(p_class string, p_name string, p_attrib string, p_value string)
  returns ()

  define
    d_widget  om.DomNode


  ### Find widget node, and return attribute if found ###
  let d_widget = Widget_Node(p_class, p_name)
  if d_widget is not NULL
  then
    call d_widget.setAttribute(p_attrib, p_value)
  end if

end function






############################################################################
#
#! UI_.Window_Title
#+ Set the Title bar text of the current window
#+
#+ @param p_text  Window Text
#+
#+ @code
#+ call UI_.Window_Title("My Window")
#
############################################################################

public function Window_Title(p_text string)
  returns ()

  define
    d_win     ui.Window


  let d_win = ui.Window.getCurrent()

  if d_win is not NULL
  then
    call d_win.setText(str._(p_text.trim()))
  end if

end function  






##########################################################################
#
# LOCAL (PRIVATE)
#
##########################################################################





############################################################################
#
#! xpath_Expr
#+ PRIVATE: returns an XPath expression for a class and name
#+
#+ @param p_prefix  Prefix to this expression, typically "//" or "/"
#                   but could be a partial expression like "//Style/"
#+ @param p_class   Class (tag type) of node
#+ @param p_name    name, colName or attrib='value' expression
#+
#+ @param p_xpath   XPath expression
#+
#+ @returnType      string
#+ @return          XPath expression
#+
#+ @code
#+ define p_xpath string
#+ let p_xpath =  xpath_Expr("", "Edit", "custid")
#+ let p_xpath =  xpath_Expr("/", "Window", "w_main")
#+ let p_xpath =  xpath_Expr("//Style", "StyleAttribute", "menuPosition")
#
############################################################################

private function xpath_Expr(p_prefix string, p_class string, p_name string)
  returns (string)


  define
    p_subClass  string,
    p_expr      string,
    p_xpath     string


  ### Is there a sub class? ###
  let p_subClass = ""
  if p_class matches "*/*"
  then
    call str.Split(p_class, "/")
      returning p_class, p_subClass
    if p_subClass.getLength()
    then
      let p_subClass = "/", p_subClass
    end if
  end if

  ### Determine attribute field for name ###
  case
  when p_name matches "*=*"
    ### attrib='value' override ###
    let p_expr = "@", p_name.trim()
  when (p_class matches "FormField*" or p_class matches "TableColumn*")
    and p_name not matches "*.*"
    ### columnName only ###
    let p_expr = "@colName='", p_name.trim(), "'"
  otherwise
    ### table.columnName ###
    let p_expr = "@name='", p_name.trim(), "'"
  end case

  let p_xpath = p_prefix, p_class.trim(), "[", p_expr, "]", p_subClass

  return p_xpath

end function
