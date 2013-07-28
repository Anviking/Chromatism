Chromatism
==========

This is the beginning of a syntax highlighting `UITextView` for iOS. Currently it only knows about Obj-C. Previously Chromatism used a combination of `CoreText` and `UITableView` for performance, but luckily that is not needed anymore.

## Classes
- `JLTextView` is a textView with a syntaxTokenixer property to a `JLTokenizer`
- `JLTokenizer` is the class in which everything happens. It uses scopes and tokenPatterns to appropriately tokenize a textStorage or a string. It is a `NSTextStorage` and `UITextView`-delegate.
- `JLScope` has a `NSMutableIndexSet`-property that corresponds to ranges in the textStorage. Scopes can be arranged in a hierarchy. A scope's children is stored in the `subscopes` property, and a scopes parent is simply called its `scope`. A scope can be executed via the `-perform`-method. The method causes subscopes to perform cascadingly. 
- `JLTokenPattern` is a subclass of `JLScope`. It has a regex-pattern that in `-perform` searches through the ranges of its parent scope.

## Scopes and Patterns
Scopes and patters can ensure that every regex pattern searches in the right places. To understand how they work, it is helpful to know what happens in the `-perform` method.

1. A scope may contain ranges before it's performed. When it's performed, the scope's set is intersected with the parent scope set. A scope can never contain more indexes that its parent scope.
2. The scope calls perform on its subscopes.
3. The scope ensures that its siblings don't search where the scope have found things.

For more detail, see the `-perform`-implementation on [`JLScope`](https://github.com/Anviking/Chromatism/blob/master/Chromatism/Chromatism/JLScope.m#65) and [`JLTokenPattern`](https://github.com/Anviking/Chromatism/blob/master/Chromatism/Chromatism/JLTokenPattern.m#56).

### Example
Modified snippet from `JLTokenizer`.

````objc
// The documentScope will be our root scope
JLScope *documentScope = [JLScope scopeWithTextStorage:storage];

// A subscope with a specific range. In this case, the range is the range of the edited line.
JLScope *rangeScope = [JLScope scopeWithRange:range inTextStorage:storage];

// "/* ... */" comments should search through the whole document, and no other patterns should search in its results
JLTokenPattern *comments1 = [JLTokenPattern tokenPatternWithPattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" andColor:colors[JLTokenTypeComment]];

// "//" comments should search in the range of the edited line, but only where there is no /* */ comment.
JLTokenPattern *comments2 = [JLTokenPattern tokenPatternWithPattern:@"//.*+$" andColor:colors[JLTokenTypeComment]];

JLTokenPattern *preprocessor = [JLTokenPattern tokenPatternWithPattern:@"#.*+$" andColor:colors[JLTokenTypePreprocessor]];

// This pattern should only search in the the results from the preprocessor pattern.
JLTokenPattern *importAngleBrackets = [JLTokenPattern tokenPatternWithPattern:@"<.*?>" andColor:colors[JLTokenTypeString]];
importAngleBrackets.scope = preprocessor;

JLTokenPattern *strings = [JLTokenPattern tokenPatternWithPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" andColor:colors[JLTokenTypeString]];
// This pattern should search where there is nothing else, *and* in the results of the preprocessor pattern. `-addScope` copies `strings` and adds the copy as a subscope of `preprocessor`.
[strings addScope:preprocessor];

JLTokenPattern *literals = [JLTokenPattern tokenPatternWithPattern:@"@[\\(|\\{|\\[][^\\(\\{\\[]+[\\)|\\}|\\]]" andColor:colors[JLTokenTypeNumber]];
literals.opaque = NO; // Scopes and patterns are opaque per default. Setting this to NO makes it that patterns that follow in the same scope can search and overwrite the results from this pattern.

// Setup the hiearchy
documentScope.subscopes = @[comments1, rangeScope];
rangeScope.subscopes = @[comments2, preprocessor, literals];

// Causes every subscope to perform as well
[documentScope perform];
````


