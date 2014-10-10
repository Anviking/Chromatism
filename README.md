Chromatism
==========

iOS Syntax highlightning using Swift built for performance, but still at a very experimental non-reliable state.

![image](http://i.imgur.com/P1ENCfv.png)

## New since Swift rewrite:
- JLNestedToken  `/* Comment /* Another Comment */ */`. Could possible do great stuff with {}-scope-aware-auto-completion. Needs some more work though.
- Tests – sort of.
- `JLKeywordScope` Optimizes regex patterns for keywords. `(?:He(?:j(?:san|)|llo))`

## Todo
- `JLTokenizingScope` should keep track of additions/deletions of tokens, and JLNestedScope should be able to use that information. Better performance, JLNestedScope don't have to keep track of both hollow and non-hollow indexes anymore, and enables proper "parantesis-flash-blink-thing-handling" in JLTextView.
- Make the code and classes more logical
  - How much should `JLLanguage` and `JLDocumentScope` be responsable for?
- Add a symbol-recognicion-scope
- Add more languages

