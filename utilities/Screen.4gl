main

  open form f_screen from "Screen"
  display form f_screen
  call show_Viewport()
  
  menu
    on action windowresized
      call show_Viewport()
    on action quit
      exit menu
    on action close
      exit menu
  end menu
  
end main

function show_Viewport()
  var p_size string
  call ui.Interface.frontCall("standard","feInfo",["windowSize"],[p_size])
  display p_size, p_size, p_size to f1, f2, f3
end function