#
# Dom_Test.4gl  Unit tests for Dom module
#

import FGL OM_




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