Provides helper functions to encode data

Use this module to convert encoded text to another encoding.

# Public Objects
## Encoding (Codeunit 1485)

 Provides helper functions to encode data

### Convert (Method)

 Converts a text from one encoding to another.
 
#### Syntax
```
procedure Convert(SrcCodepage: Integer; DstCodepage: Integer; Text: Text)
```
#### Parameters
* SourceCodepage
Encoding code page identifier of the source text.
* DestinationCodepage
Encoding code page identifier for the result text.
* Text
The text to convert.

 The text in the destination encoding.