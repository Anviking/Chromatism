Chromatism
==========

This is the beginning of a syntax highlighting `UITextView` for iOS. Currently it only knows about Obj-C. Previously Chromatism used a combination of `CoreText` and `UITableView` for performance, but luckily that is not needed anymore.

**Chromatism is currently unstable, changing quickly and without test-coverage.**

![](http://anviking.com/img/chromatism_black.png)

## License
MIT, see [LICENSE.txt](https://github.com/Anviking/Chromatism/blob/master/LICENSE.txt). If you develop Chromatism further, sharing your improvements are encouraged.

## How to add Chromatism to your application:

1. Drag and drop `Chromatism.xcodeproj` to your project.
2. Add `Chromatism` as a target dependency and link to `libChromatism.a`
3. Make sure you have the `-ObjC` flag on the `Other Linker Flags` build setting.
4. Add `"$(BUILT_PRODUCTS_DIR)/../../Headers"` to the `Header Search Paths` build setting.

## Classes
- `JLTextView` is a textView with a syntaxTokenixer property to a `JLTokenizer`
- `JLTokenizer` is the work horse of Chromatism. It uses scopes and tokenPatterns to appropriately tokenize a textStorage or a string. It is a delegate of `NSTextStorage` and `UITextView`.
- `JLScope` has a `NSMutableIndexSet`-property that corresponds to ranges in the textStorage. Scopes can be arranged in a hierarchy. A scope's children is stored in the `subscopes` property, and a scopes parent is simply called its `scope`. A scope can be executed via the `-perform`-method. The method causes subscopes to perform cascadingly. 
- `JLTokenPattern` is a subclass of `JLScope`. It has a regex-pattern that in `-perform` searches through the ranges of its parent scope.


## Scopes and Patterns
Scopes and patters can ensure that regex patterns search in the right place. To understand how they work, it is helpful to know what happens in the `-perform` method.

1. A scope may contain ranges before it's performed. When it's performed, the scope's set is intersected with the parent scope set. A scope can never contain more indexes that its parent scope.
2. The scope calls perform on its subscopes.
3. The scope ensures that its siblings don't search where the scope have found things.

For more detail, see the `-perform`-implementation on [`JLScope`](https://github.com/Anviking/Chromatism/blob/master/Chromatism/Chromatism/JLScope.m#65) and [`JLTokenPattern`](https://github.com/Anviking/Chromatism/blob/master/Chromatism/Chromatism/JLTokenPattern.m#56).

