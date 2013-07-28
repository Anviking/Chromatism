Chromatism
==========

This is the beginning of a syntax highlighting `UITextView` for iOS. Currently it only knows about Obj-C. Previous Chromatism used a combination of `CoreText` and `UITableView` for performance, but luckily that is not needed anymore.

## Classes
- `JLTextView` is a textView with a syntaxTokenixer property to a `JLTokenizer`
- `JLTokenizer` is the class in which everything happens. It uses scopes and tokenPatterns to appropriately tokenize a textStorage or a string. It is a `NSTextStorage` and `UITextView`-delegate.
- `JLScope` has a `NSMutableIndexSet`-property that corresponds to ranges in the textStorage. Scopes can be arranged in a hierarchy. A scope's children is stored in the `subscopes` property, and a scopes parent is simply called its `scope`. A scope can be executed via the `-perform`-method. The method causes subscopes to perform cascadingly. 
- `JLTokenPattern` is a subclass of `JLScope`. It has a regex-pattern that in `-perform` searches through the ranges of its (super)scope.

## Scopes and Patterns

### Example
This is slightly modified snippet from the `JLTokenizer`-class.

````objc
// The documentScope will be our root scope
JLScope *documentScope = [JLScope scopeWithTextStorage:storage];

// A subscope with a specific range. In this case, it is a scope with the range of the edited line.
JLScope *rangeScope = [JLScope scopeWithRange:range inTextStorage:storage];

// We begin with the patterns that will find the most amout of text.

// "/* ... */" comments should search through the whole document, and no other patterns should search in its results
JLTokenPattern *comments1 = [JLTokenPattern tokenPatternWithPattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" andColor:colors[JLTokenTypeComment]];

// "//" comments should search in the range of the edited line, but only where there is no /* */ comment.
JLTokenPattern *comments2 = [JLTokenPattern tokenPatternWithPattern:@"//.*+$" andColor:colors[JLTokenTypeComment]];

JLTokenPattern *preprocessor = [JLTokenPattern tokenPatternWithPattern:@"#.*+$" andColor:colors[JLTokenTypePreprocessor]];

// This pattern should only search in the the results from the preprocessor pattern. If we want a pattern to have multiple scopes we could use addScope which creates a copy of the pattern, and adds it as a subscope in the other scope.
JLTokenPattern *importAngleBrackets = [JLTokenPattern tokenPatternWithPattern:@"<.*?>" andColor:colors[JLTokenTypeString]];
preprocessor.scope = preprocessor;


JLTokenPattern *literals = [JLTokenPattern tokenPatternWithPattern:@"@[\\(|\\{|\\[][^\\(\\{\\[]+[\\)|\\}|\\]]" andColor:colors[JLTokenTypeNumber]];
literals.opaque = NO; // Scopes and patterns are opaque per default. Setting this to NO makes it that patterns that follow in the same scope can search and overwrite the results from this pattern.

// Setup the hiearchy
documentScope.subscopes = @[comments1, rangeScope];
rangeScope.subscopes = @[comments2, preprocessor, literals];

// Causes every subscope to perform as well
[documentScope perform];
````


