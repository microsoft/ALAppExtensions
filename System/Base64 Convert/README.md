The module provides functionality to convert the text to and from base 64. It may be used for dealing with large XML files, pictures etc.

# Public Objects
## Base64 Convert (Codeunit 4110)

 Converts text to and from its base-64 representation.
 

### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text; TextEncoding: TextEncoding): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*TextEncoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The TextEncoding for the input string.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text; TextEncoding: TextEncoding; Codepage: Integer): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*TextEncoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The TextEncoding for the input string.

*Codepage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Codepage if TextEncoding is MsDos or Windows.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text; InsertLineBreaks: Boolean): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*InsertLineBreaks ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether line breaks are inserted in the output.
 If true, inserts line breaks after every 76 characters.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text; InsertLineBreaks: Boolean; TextEncoding: TextEncoding; Codepage: Integer): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*InsertLineBreaks ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether line breaks are inserted in the output.
 If true, inserts line breaks after every 76 characters.

*TextEncoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The TextEncoding for the input string.

*Codepage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Codepage if TextEncoding is MsDos or Windows.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input stream to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(InStream: InStream): Text
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream to read the input from.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input stream to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(InStream: InStream; InsertLineBreaks: Boolean): Text
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream to read the input from.

*InsertLineBreaks ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether line breaks are inserted in the output.
 If true, inserts line breaks after every 76 characters.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### FromBase64 (Method) <a name="FromBase64"></a> 
The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.


 Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
 

#### Syntax
```
procedure FromBase64(Base64String: Text): Text
```
#### Parameters
*Base64String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Regular string that is equivalent to the input base-64 string.
### FromBase64 (Method) <a name="FromBase64"></a> 
The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.


 Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
 

#### Syntax
```
procedure FromBase64(Base64String: Text; TextEncoding: TextEncoding): Text
```
#### Parameters
*Base64String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*TextEncoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The TextEncoding for the input string.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Regular string that is equivalent to the input base-64 string.
### FromBase64 (Method) <a name="FromBase64"></a> 
The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.


 Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
 

#### Syntax
```
procedure FromBase64(Base64String: Text; TextEncoding: TextEncoding; Codepage: Integer): Text
```
#### Parameters
*Base64String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*TextEncoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The TextEncoding for the inout string.

*Codepage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Codepage if TextEncoding is MsDos or Windows.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Regular string that is equivalent to the input base-64 string.
### FromBase64 (Method) <a name="FromBase64"></a> 
The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.


 Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
 

#### Syntax
```
procedure FromBase64(Base64String: Text; OutStream: OutStream)
```
#### Parameters
*Base64String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*OutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the output to.

