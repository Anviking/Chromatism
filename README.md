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
- `JLScope` has a `NSMutableIndexSet`-property that corresponds to ranges in the textStorage. Scopes can be arranged in a complex hierarchy, especially since it is a subclass of `NSOperation`.
- `JLTokenPattern` is a subclass of `JLScope`. It has a regex-pattern that in `-perform` searches through the ranges of its parent scope.


## Implementing your own syntax highlighting for another language
1. Subclass `JLTokenizer.
2. Checkout `JLObjectiveCTokenizer` to see what to do next.
3. (Optional) Be awesome and submit a PR.

