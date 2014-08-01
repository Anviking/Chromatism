Chromatism
==========

iOS Syntax highlightning using Swift. This is no Clang, but hopefully a little more than an array of regex-expressions.

##Experimental-Swift branch features:
- JLNestedToken  `/* Comment /* Another Comment */ */`. Could possible do great stuff with {}-scope-aware-auto-completion.
- Tests – sort of.

##Todo
- `JLTokenizingScope` should keep track of additions/deletions of tokens, and JLNestedScope should be able to use that information. Better performance, JLNestedScope don't have to keep track of both hollow and non-hollow indexes anymore, and enables proper "parantesis-flash-blink-thing-handling" in JLTextView.
- Make the code and classes more logical
  - Should `JLToken` be renamed to `JLRegexScope` or something to avoid confusion with `JLTokenizingScope.Token`?
  - How much should `JLLanguage` and `JLDocumentScope` be responsable for?
- Add a symbol-recognicion-scope
- Add more languages

