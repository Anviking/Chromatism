Chromatism
==========

iOS Syntax highlightning using Swift. This is no Clang, but hopefully a little more than an array of regex-expressions.

Experimental-Swift branch features:
- JLNestedToken  `/* Comment /* Another Comment */ */`. Could possible do great stuff with {}-scope-aware-auto-completion.
- Tests – sort of.
- The `JLTokenizer` is no longer handles everything. `JLLanguage`-subclasses handles the language syntax, and `JLTextView` will handle textView-related-stuff, like indentation, with the help of `JLLanguage`


