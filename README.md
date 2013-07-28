Chromatism
==========

This is the beginning of a syntax highlighting `UITextView` for iOS. Currently it only knows about Obj-C. Previous Chromatism used a combination of `CoreText` and `UITableView` for performance, but luckily that is not needed anymore.

## Classes
- `JLTextView` is a textView with a syntaxTokenixer property to a `JLTokenizer`
- `JLTokenizer` is the class in which everything happens. It uses scopes and tokenPatterns to appropriately tokenize a textStorage or a string. It is a `NSTextStorage` and `UITextView`-delegate.
- `JLScope` has a `NSMutableIndexSet`-property that corresponds to ranges in the textStorage. Scopes can be arranged in a hierarchy. A scope's children is stored in the `subscopes` property, and a scopes parent is simply called its `scope`. A scope can be executed via the `-perform`-method. The method causes subscopes to perform cascadingly. 
- `JLTokenPattern` is a subclass of `JLScope`. It has a regex-pattern that in `-perform` searches through the ranges of its (super)scope.




