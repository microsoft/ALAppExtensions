This module exposes functionality to encode barcodes.

Use this module to:
    - Define a barcode font provider.
    - Use the IDAutomation 1D barcode provider to generate barcodes. This barcode provider uses fonts from IDAutomation. For more information about IDAutomation and the fonts, visit the [IDAutomation website](https://www.idautomation.com/).
  
# Public Objects
## Barcode Encode Settings (Table 9203)

 Common setting used when encoding barcodes.
 


## Barcode Font Encoder (Interface)

 Exposes common interface for barcode font encoder.
 

### EncodeFont (Method) <a name="EncodeFont"></a> 

 Encodes a input text to a barcode font.
 

#### Syntax
```
procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
```
#### Parameters
*InputText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to encode.

*BarcodeEncodeSettings ([Record "Barcode Encode Settings"]())* 

Settings to use when encoding the input text.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The encoded barcode.
### IsValidInput (Method) <a name="IsValidInput"></a> 

 Validates whether a text can be encoded.
 The validation is based on a regular expression according to
 https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
 

#### Syntax
```
procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean
```
#### Parameters
*InputText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to validate.

*BarcodeEncodeSettings ([Record "Barcode Encode Settings"]())* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the validation succeeds; otherwise - false.

## Barcode Font Provider (Interface)

 Interface for barcode font providers.
 

### GetSupportedBarcodeSymbologies (Method) <a name="GetSupportedBarcodeSymbologies"></a> 

 Gets a list of the barcode symbologies that the provider supports.
 

#### Syntax
```
procedure GetSupportedBarcodeSymbologies(var Result: List of [Enum "Barcode Symbology"])
```
#### Parameters
*Result ([List of [Enum "Barcode Symbology"]]())* 

A list of barcode symbologies.

### EncodeFont (Method) <a name="EncodeFont"></a> 

 Encodes an input text into a barcode.
 

#### Syntax
```
procedure EncodeFont(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"): Text
```
#### Parameters
*InputText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to encode.

*BarcodeSymbology ([Enum "Barcode Symbology"]())* 

The symbology to use for the encoding.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The encoded barcode.
### EncodeFont (Method) <a name="EncodeFont"></a> 

 Encodes an input text into a barcode.
 

#### Syntax
```
procedure EncodeFont(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
```
#### Parameters
*InputText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to encode.

*BarcodeSymbology ([Enum "Barcode Symbology"]())* 

The symbology to use for the encoding.

*BarcodeEncodeSettings ([Record "Barcode Encode Settings"]())* 

The settings to use when encoding the text.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The encoded barcode.
### ValidateInput (Method) <a name="ValidateInput"></a> 

 Validates if the input text is in a valid format to be encoded using the provided barcode symbology.
 

The function should throw an error if the input text is in invalid format or if the symbology is not supported by the provider.

#### Syntax
```
procedure ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology")
```
#### Parameters
*InputText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to validate

*BarcodeSymbology ([Enum "Barcode Symbology"]())* 

The barcode symbology for which to check.

### ValidateInput (Method) <a name="ValidateInput"></a> 

 Validates if the input text is in a valid format to be encoded using the provided barcode symbology.
 

The function should throw an error if the input text is in invalid format or if the symbology is not supported by the provider.

#### Syntax
```
procedure ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings")
```
#### Parameters
*InputText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to validate

*BarcodeSymbology ([Enum "Barcode Symbology"]())* 

The barcode symbology for which to check.

*BarcodeEncodeSettings ([Record "Barcode Encode Settings"]())* 

The settings to use for the validation.


## Barcode Symbology (Enum 9204)

 The available barcode symbologies.
 

### Code39 (value: 100)


 Code 39 - An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
 

### Codabar (value: 105)


 Codabar - A numeric barcode encoding numbers with a slightly higher density than Code 39.
 

### Code128 (value: 110)


 Code 128 - Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
 

### Code93 (value: 115)


 Code 93 - Similar to Code 39, but requires two checksum characters.
 

### Interleaved2of5 (value: 120)


 Interleaved 2 of 5 - The Interleaved 2 of 5 barcode symbology encodes numbers in pairs, similar to Code 128 set C.
 

### Postnet (value: 125)


 Postenet - The Intelligent Mail customer barcode combines the information of both the POSTNET and PLANET symbologies, and additional information, into a single barcode that is about the same size as the traditional POSTNET symbol.
 

### MSI (value: 130)


 MIS - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications.
 

### EAN-8 (value: 200)


 EAN-8 - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications.
 

### EAN-13 (value: 201)


 EAN-13 - The EAN-13 was developed as a superset of UPC-A, adding an extra digit to the beginning of every UPC-A number.
 

### UPC-A (value: 202)


 UPC-A - The Universal Product Code (UPC; redundantly: UPC code) is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores.
 

### UPC-E (value: 203)


 UPC-E -  To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E.
 


## Barcode Font Provider (Enum 9203)

 The available barcode font providers.
 

### IDAutomation1D (value: 0)


 IDAutomation 1D-barcode provider.
 

