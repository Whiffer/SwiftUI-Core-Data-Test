# SwiftUI-Core-Data-Data-Test

Extended sample program to demonstrate how CoreData can be used with SwiftUI.
This sample has been sort of a play ground to try to duplicate or reinvent some familiar 
UIKit patterns using SwiftUI that are common with some Core Data based Apps.

This project currently compiles and runs on Xcode 11.0 Beta 7 
Current development testing has mostly been on iPhone devices.
It does run on iPad and macOS with a few size class issues.

The key component of this sample is the class CoreDataDataSource which encapsulates
much of the functionality of an NSFetchedResultsController for use with SwiftUI.
This version of CoreDataDataSource has several custom initializers for extended capabilities.

=======================

The App uses a Tab View that displays and edits the same CoreData database several ways.

Tab 1: Typical "drill-down" view with Lists and Detail view editing

Tab 2: Two side-by-side instances of the same view as in Tab 1. This is helpful to see that
the Core-data changes are observed by all views properly.

Tab 3: Has a Data Source set up to support a nested SwiftUI Grouped List 
with correct implementations of move and delete within a group.

Tab 4: Demonstrates Selecting rows within a List
It uses a generic ListSelectionManager to allow specific actions (e.g. updating database) 
at the time on the selection or deselection, in addition to inserting and deleting from the selection Set.
It also demonstrates how to create a custom ToggleStyle to use instead of the Default Switch ToggleStyle.
Selecting Items is only allowed in Edit mode, which also exposes several commands when active.

=======================

CREDITS:
1.  Thanks to @kontiki for insight on how to correctly use the editMode environment var.
https://stackoverflow.com/questions/57496453/swiftui-how-do-i-make-edit-rows-in-a-list

=======================

KNOWN ISSUES:

1.  (No longer an issue in Beta 7).  Start the App and then Select the Side by Side tab, tap Edit in either of the two views. 
Selecting any other tab view causes a crash somewhere in the SwiftUI framework. 

This project is still a work in progress.  Several more changes will be made in the near future.
