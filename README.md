Chromatism
==========

This is an experimation of a Syntax Highlighting textView using a tableView and CoreText. It consists of a UITextView with a UITableVIew overlay. The UITextView has its textColor set to `[UIColor clearColor]` and ints only purpose is to provide a textinput. Ontop of the textView there is a `UITableView`, which render the lines currently visible.


##This is what happens when the text editor is created:

1. The text is broken up into lines by a CTTypesetter on initialization and stored in an array.
2. The tableview asks for the lines that should be visible.
3. The tableView creates UITableViewCells which draw the lines.

##What happens upon scrolling:
1. The tableView takes the cells that go offscreen and reuse them by telling them to draw new lines. Cells still onscreen are not redrawn.

##What happens upon text change:
1. What type of text change is it?
2. If it can be handled by slightly modifying the lines, do so. No typesetter is required to look through the entire text.
3. If not there is no option but to recalculate everything with the typesetter.



The tokenizing itself uses regex to modify an attributed string. The tokenizer tries to tokenizer as little as possible. If the user types a letter most regex patterns are going to be applied to the current line.




