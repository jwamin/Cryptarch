# Bitcoin Investment Monitor

iOS App for tracking individual bitcoin investments.

Swift

# Features
* Add/Remove and track investments vs. the current bitcoin price
* Pull to refresh
* Alert view on price fetch fail
* Persistent local storage with CoreData

## TODO
* Edit Screen
* Better UI
* `heightForRowAtIndexPath:` - tap for detail

## Nice to have
* `CoreGraphics` drawing arrows
* more `UITableView` methods. Reorder
* Comparitive rates

### Techniques Used
* Parsing JSON with Swift
* NSURLSession to get current price
* UITableView + UITableVIewCell Subclasses

#### Frameworks Used
`UIKit`
`CoreData`
`NSURLSession`
