# Cryptarch - Bitcoin Investment Monitor

iOS App for tracking individual bitcoin/crypto investments.

Swift

# Features
* Add/Remove and track investments vs. the current bitcoin price
* Allows other cryptocurrency buys to be tracked. e.g LTC
* UITableView sections
* Pull to refresh
* Alert view on price fetch fail
* Persistent local storage with CoreData
* Managed Persistant datastore + tableview.
* `CoreGraphics` drawing arrows indicating changes in price

## TODO
* Edit Screen
* `heightForRowAtIndexPath:`  or `isExpanded` - tap for detail

## Nice to have

* more `UITableView` methods. Reorder
* Comparitive rates
* Cumulative view

### Techniques Used
* Parsing JSON with Swift
* NSURLSession to get current prices
* Async fetching of crypto prices using `DispatchGroup` with callback on complete
* Persistent storange with `NSFetchedResultsController` integration adapted from Apple boilerplate code.
* UITableView + UITableVIewCell Subclasses

#### Frameworks Used
`UIKit`
`CoreData`
`NSURLSession`
`CoreGraphics`
