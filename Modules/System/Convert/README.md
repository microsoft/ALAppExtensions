Provides helper functions to convert data

Use this module to do the following:
- Convert encoded text to another encoding

# Public Objects
## Convert (Codeunit 1485)

 Provides helper functions to convert data

### ConvertTextEncoding (Method)

 Converts a text from one encoding to another.
 
#### Syntax
```
procedure ConvertTextEncoding(SrcCodepage: Integer; DstCodepage: Integer; Text: Text)
```
#### Parameters
* SrcCodepage
Code page identifier of the source.
* DstCodepage
Code page identifier of the output.
* Text
The text containing the characters to encode.