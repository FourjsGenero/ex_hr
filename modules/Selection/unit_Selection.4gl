#
# Selection_Test.4gl: Unit Test Module for managing Query Selection sets
#

##########################################################################
#
# UNIT TESTS
#
##########################################################################

#
# 1. Options Settings
# 2. Single Table
# 3. Multiple tables with a join
# 4. Mutliple tables with inner & outer joins
# 5. Apply Options
# 6. Apply Sort


import FGL Selection




#
# Main: Unit Test
#

main

  call Run("MENU")
  
end main



#
#! Run
#
public function Run(p_request string)

  case p_request
    when "MENU"
  end case

end function


#
#! Setup
#
private function Setup()

end function


#
#! Teardown
#
private function Teardown()

end function