# SwiftUI-Core-Data-Test

This sample program demonstrates how CoreData can be used with SwiftUI.  The goal of this program is to try to duplicate or reinvent some familiar UIKit patterns using SwiftUI that are common with some Core Data based iOS Apps.

This project currently compiles and runs on Xcode Version 11.3.1 (11C504)

Most of the current development testing targets have been actual iPhone devices.  It does run on iPad and macOS with a few size class issues (currently not a high priority for me).

The key component of this sample program is the class CoreDataDataSource which encapsulates much of the functionality of an NSFetchedResultsController in a manner to be useful with SwiftUI.  This version of CoreDataDataSource has several custom initializers for different usage scenarios.

This project is essentially complete as-is and will not be enhanced further.  If there is a need to demonstrate additional UI scenarios, a new project will be created.

=======================

The App uses a Tab View that displays and edits the same CoreData database several ways.

Tab 1: 
- Typical "drill-down" view with Lists and Detail view editing

Tab 2: 
- Two side-by-side instances of the same view as in Tab 1. This is helpful to see that the Core-data changes are observed by all views properly.

Tab 3: 
- Has a Data Source set up to support a nested SwiftUI Grouped List with correct implementations of move and delete within a group.

Tab 4: 
- Demonstrates Selecting rows within a List
It uses a generic ListSelectionManager to allow specific actions (e.g. updating database) at the time of the selection or deselection, in addition to inserting and deleting from the Set of selections.  It also demonstrates how to create a custom ToggleStyle that can be used instead of the Default Switch ToggleStyle.  Selecting Items is only allowed in Edit mode, which also exposes several commands when active.

Tab 5: 
- Demonstrates how to use a SearchBar with the CoreDataDataSource
Added a new method to load the data source using an NSPredicate to supply data to a ForEach List.  Created a UIViewRepresentable SearchBar that accepts the search text and returns a new NSPredicate back to the SwiftUI view after each keystroke.

=======================

CREDITS:
1.  Thanks to @kontiki for insight on how to correctly use the editMode environment var.
https://stackoverflow.com/questions/57496453/swiftui-how-do-i-make-edit-rows-in-a-list

=======================

KNOWN ISSUE:

1. https://github.com/Whiffer/SwiftUI-Core-Data-Test/issues/1
There is a weird issue when reordering rows in a list. This only happens when dragging a row up, and only when dragged one position up.  I have seen this occur in other apps, so it must be a bug or working as designed.
