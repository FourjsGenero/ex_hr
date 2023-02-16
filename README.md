# ex_hr
UPDATED for 4.00

Example program demonstrating the refactoring of a simple HR application
using various features of Genero 4.00. No, it's not a complete application
from a data perspective as some of the data is generated,
it's purpose was primarily to demonstrate various UX and DX enhancements
using Genero features.

The example runs from a sqlite database in
$(ProjectDir)/data/hr.db

## Summary of Features in this Demo

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


## RESPONSIVE Variations

Configs:
* hr: the original before any responsive features added
* hr-R1: Rev 1 - Initial responsive layouts
* hr-R2: Rev 2 - After some fine-tuning

NOTE: If it doesn't Build All successfully the first time, just Build All again.


## NOT USING STUDIO?
While this example is best experienced using Genero Studio, you can still build and using the command line on Unix/Linux using make:

## Environment
The environment can be set from ~/set.env or ~/hr/Makefile.
Note that you should set LANG to your UTF-8 based locale, eg. en_US.UTF-8.

To build all from the project root:

  make

To run:

  make run
  make run-r1
  make run-r2

To clean

  make clean


## Screen Shots

This is the application running in a Browser

![Browser Client](https://user-images.githubusercontent.com/20328875/219250407-b4f709a5-6531-45e4-be29-fb1991ff50b8.png "Browser Client")

Here are shots of the various pages of the application running in the Desktop Client, which shares the same Universal Rendering as the Browser Client

![Desktop Client 1](https://user-images.githubusercontent.com/20328875/219250430-4d2b5eac-3c15-4d5c-aeb5-2097624b6c02.png "Desktop Client 1")

![Desktop Client 2](https://user-images.githubusercontent.com/20328875/219250435-28bf6e5e-e7c2-4203-bfae-2ce7dbf9bf97.png "Desktop Client 2")

and changing the form factor of the Desktop Client

![Desktop Client 3](https://user-images.githubusercontent.com/20328875/219250448-e520707b-ff65-4451-be9d-9c76d09a64a8.png "Desktop Client 3")

![Desktop Client 4](https://user-images.githubusercontent.com/20328875/219250452-7870448d-aa8a-467b-a482-2d4e7ec5912b.png "Desktop Client 4")

![Desktop Client 5](https://user-images.githubusercontent.com/20328875/219250460-3dd417f0-308d-4f44-84ed-e5c432076066.png "Desktop Client 5")

The same application while running on a tablet using Responsive Layout to cater for the smaller form factor

![iPad 1](https://user-images.githubusercontent.com/20328875/219250469-57899f43-0f35-47c7-9239-bbde5cdcb029.png "iPad 1")

![iPad 2](https://user-images.githubusercontent.com/20328875/219250474-bab84f62-7ff8-4cb4-a1f0-7572eaadfd2b.png "iPad 2")

![iPad 3](https://user-images.githubusercontent.com/20328875/219250478-e6f60d65-97de-4de5-bfb6-cc94a54096a6.png "iPad 3")

and the same application now running on a mobile phone adapting to the smalleest form factor

![iPhone 1](https://user-images.githubusercontent.com/20328875/219250482-e767ce8f-4c5e-4b05-bd41-03837ddd007b.png "iPhone 1")

![iPhone 2](https://user-images.githubusercontent.com/20328875/219250485-f2cc3469-6bf2-45d8-b589-47837a4415b8.png "iPhone 2")

![iPhone 3](https://user-images.githubusercontent.com/20328875/219250487-cf0b1d5b-e0d6-4541-b0c1-b02f8dcae057.png "iPhone 3")

![iPhone 4](https://user-images.githubusercontent.com/20328875/219250491-0f1b18b9-6f7e-473c-86de-f66dbee7bd22.png "iPhone 4")

![iPhone 5](https://user-images.githubusercontent.com/20328875/219250492-5cc2ce4a-584a-4d17-a21a-7f4a6a825f8b.png "iPhone 5")


## Additional Resources

### Adding Responsiveness to your Application

Presentation from WWDC21 which takes you step by step through the process of making this example application responsive:
https://4js.com/files/documents/wwdc21/genero_4.00/B1-Responsive-01B.pdf

or you can watch the presentation here:
https://vimeo.com/651046082

