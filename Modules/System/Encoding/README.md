Provides helper functions to encode data

Use this module to convert encoded text to another encoding.

# Public Objects
## Encoding (Codeunit 1486)

 Codeunig that exposes encoding functionality.
 

### Convert (Method) <a name="Convert"></a> 

 Converts a text from one encoding to another.
 

#### Syntax
```
procedure Convert(SourceCodepage: Integer; DestinationCodepage: Integer; Text: Text): Text
```
#### Parameters
*SourceCodepage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Encoding code page identifier of the source text. Valid values are between 0 and 65535.

*DestinationCodepage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Encoding code page identifier for the result text. Valid values are between 0 and 65535.

*Text ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The text in the destination encoding.
