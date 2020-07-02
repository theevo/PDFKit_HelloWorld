# PDFKit_HelloWorld
Experimental app. I want to be able to load a sample PDF file and add one annotation to it that says "hello world"

## Abridged Explainer on Apple's PDFKit

### PDF coordinate space

Adobe made it, so they set the rules for how it works.

In iOS, the origin point (0,0) for a UIView starts at the top left corner. All space to the right of origin increment the X coordinate positively; space below origin increments Y coordinate positively.

With PDFs, the origin point starts in the bottom left corner. Therefore, all space above origin increments Y positively.

### Translating coordinates

Apple has given us `convert` methods to translate a coordinate from UIView to PDFView and vice versa.

### Annotations

We achieve the ability to write text on a PDF through annotations. My goal is to build an app that allows the user to fill out a PDF form, scoping it solely to text. Not interested in drawing or signing right now.

Annotations are initialized with a `CGRect`, which is basically a box with an position and size. A PDF coordinate is expected for the position, not the UIKit coordinate.


### Annotation Size

The fact that you must know the size of your CGRect before you add it to the page presented a challenge. If your box is too small, the text inside it will not be seen.

I don't see any issue at this time with making the size too big, but making it too big just seems wasteful.

I chose to make the width of this box flexible according to the length of the string. Courier, a monospaced font, definitely helped make this length slightly more predictable.

I came up with a formula like (length * X) and tested random words from the dictionary until a satisfactory X seemed to handle most words.

What I didn't expect later was running into really short strings. For example, the user might enter a single digit like 8. Well, my formula didn't quite work in that case, so I had to bump X up.

I think a logarithmic formula would be better. The first few characters need some space - especially the first one. A linear formula like mine is just too extreme for strings that exceed 6 characters. I'll keep thinking about that.

For the purposes of an MVP, the linear formula works just fine.
