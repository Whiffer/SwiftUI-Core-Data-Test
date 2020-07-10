# SwiftUI-Core-Data-Test

Update: July 10, 2020 for Xcode 12

I know I said that I wouldn't enhance this project any further, but after hearing no real new news along these lines from Apple at WWDC 2020, I felt I had to tidy up a few loose ends and make a few additional enhancements for myself.  After spending more than a year learning the philosophy of SwiftUI and rewriting my own App several times to get it to work the way I wanted, I restructured and reorganized the CoreDataDataSource to make it easier to modify the execution of the fetch requests based on selected @State vars changing.  

First, all of the various init() methods were combined into a single all encompasing init() method that is used to construct an initial CoreDataDataSource object.  Second, the actual Data methods and properties were reorganized to be more consistent with the various usage scenarios, supporting a single array, multiple arrays when using a sectionNameKeyPath, and without a Fetched Results Controller. Third, taking a page from SwiftUI View's and View Modifiers, Fetch Request Modifier methods were added to allow for easier modifying of the Fetch Requests with current @State vars just prior to performing the actual fetch.

1)  The general pattern is to declare a CoreDataDataSource var @StateObject and supply it's init with any known constant query parameters.
2)  When supplying Data to a ForEach statement in a List, you supply it with the appropriate CoreDataDataSource object and optionally follow it with one or more Query Modifiers that may use your other @State vars to customize the Fetch Request just before the fetch is made.
3)  To supply a single array of objects to a List, the 'objects' property performs the fetch and supplies the results to the ForEach statement.
4)  When using a Fetched Results Controller with a sectionNameKeyPath, you use the 'sections' property for the outer ForEach statement and and the 'objects(inSection:)' method for the inner ForEach statement.

There is also a 'count' Property and 'fetch()' Method that work without a Fetched Results Controller. They will use the same Fetch Request as would be used by the List methods and properties.

I have now included stripped down examples of the most common usage patterns is the CodeExamples.swift file.

=======================

This sample program demonstrates how CoreData can be used with SwiftUI.  The goal of this program is to try to duplicate or reinvent some familiar UIKit patterns using SwiftUI that are common with some Core Data based iOS Apps.

This project currently compiles and runs on Xcode Version 12.0 beta 2 (12A6163b)

Most of the current development testing targets have been actual iPhone devices.  It does run on iPad and macOS with a few size class issues (currently not a high priority for me).

The key component of this sample program is the class CoreDataDataSource which encapsulates much of the functionality of an NSFetchedResultsController in a manner to be useful with SwiftUI.  This version of CoreDataDataSource has several custom initializers for different usage scenarios.

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
There is a weird issue when reordering rows in a list. This only happens when dragging a row up, and only when dragged one position up.  I have seen this occur in other apps, so it must be a bug or working as designed.  This issue seems to be fixed in Xcode Version 12.0 beta 1 (12A6159).
