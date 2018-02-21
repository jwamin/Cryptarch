# Cryptarch - Bitcoin Investment Monitor

iOS App for tracking individual bitcoin/crypto investments.

Swift

# Features
* Add/Remove and track investments vs. the current bitcoin price
* Edit Screen using `commit editingStyle`, passing CD Object to new VC.
* Allows other cryptocurrency buys to be tracked. e.g LTC, ETH
* UITableView sections
* Pull to refresh
* Alert view on price fetch fail
* Persistent local storage with CoreData
* Managed Persistant datastore + tableview.
* `CoreGraphics` drawing arrows indicating changes in price

## TODO
* Landscape layout fixes.
* Dark mode color fixes for refresh and table headers
* `heightForRowAtIndexPath:`  or `isExpanded` - tap for detail instead of full view.
* Clear out all old code

## Nice to have
* Apple Watch
* Altcoins
* CG coloured triangles for main total label.
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
