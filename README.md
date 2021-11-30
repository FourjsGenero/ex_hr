# ex_hr
UPDATED for 4.00

Example program demonstrating the refactoring of a simple HR application
using various features of Genero 4.00. No, it's not a complete application
from a data perspective as some of the data is generated,
it's purpose was primarily to demonstrate various UX and DX enhancements
using Genero features.

The example runs from a sqlite database in
$(ProjectDir)/data/hr.db

Summary of Features in this Demo ...

UX enhancements include:
* Responsive
* Multiple Dialogs
* Universal Search module
* Contextual Save
* Infinite Arrays
* Mandatory Field indicators
* Ready to Edit
* Placeholders
* Aggregate Fields
* Images
* Chrome Bar
* Accordion Folders
* Web Components
  * Rich Text Editor
  * Charts
  * Google Maps

UX enhancements removed (since 3.20):
* Collapsible Groups (to better demonstrate Responsive)

DX enhancements include:
* FGL Modules
* Multiple Dialogs
* SubForms
* SubDialogs
* On Change
* On Fill Buffer
* On Sort
* TopMenus
* Toolbars
* Function References
* Auto Generate Documentation
* Try / Catch
* Dictionaries
* Pass By Reference (inout)
* Methods (for Record Types)
* Literal Initialization
* Genero (no link)
* GAR package

Other
* Localisation Strings (partial, no strings file yet)
* "Record n of m" indicator is now an inactive button on the dialog bar instead of a message


RESPONSIVE Variations
Configs:
* hr: the original before any responsive features added
* hr-R1: Rev 1 - Initial responsive layouts
* hr-R2: Rev 2 - After some fine-tuning

NOTE: If it doesn't Build All successfully the first time, just Build All again.
