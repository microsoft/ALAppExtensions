The module provides functionality to convert a text to a QR Code.

# Public Objects
## QR Code (Codeunit 2890)

 Converts text to its qr code representation.
 

### GenerateQRCodeImage (Method) <a name="GenerateQRCodeImage"></a> 

 Converts the value of the input string to its equivalent QR Code representation.

#### Syntax
```
GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"): Boolean
```
#### Parameters
*SourceText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Parameters
*QRCodeImageTempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob where the QR code is written to.


#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Returns the success of the QR code creation.
### GenerateQRCodeImage (Method) <a name="GenerateQRCodeImage"></a> 

 Converts the value of the input string to its equivalent QR Code representation.

#### Syntax
```
GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer): Boolean
```
#### Parameters
*SourceText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Parameters
*QRCodeImageTempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob where the QR code is written to.

#### Parameters
*ErrorCorrectionLevel ([Enum "QR Code Error Correction Level"]())* 

ErrorCorrectionLevel">The Error Correction Level.

#### Parameters
*ModuleSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Module Size of the QR Code.


#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Returns the success of the QR code creation.
### GenerateQRCodeImage (Method) <a name="GenerateQRCodeImage"></a> 

 Converts the value of the input string to its equivalent QR Code representation.

#### Syntax
```
GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer; QuiteZoneWidth: Integer): Boolean
```
#### Parameters
*SourceText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Parameters
*QRCodeImageTempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob where the QR code is written to.

#### Parameters
*ErrorCorrectionLevel ([Enum "QR Code Error Correction Level"]())* 

ErrorCorrectionLevel">The Error Correction Level.

#### Parameters
*ModuleSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Module Size of the QR Code.

#### Parameters
*QuiteZoneWidth ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Quite Zone Width of the QR Code.


#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Returns the success of the QR code creation.
### GenerateQRCodeImage (Method) <a name="GenerateQRCodeImage"></a> 

 Converts the value of the input string to its equivalent QR Code representation.

#### Syntax
```
GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer; QuiteZoneWidth: Integer; CodePage: Integer): Boolean
```
#### Parameters
*SourceText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Parameters
*QRCodeImageTempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob where the QR code is written to.

#### Parameters
*ErrorCorrectionLevel ([Enum "QR Code Error Correction Level"]())* 

ErrorCorrectionLevel">The Error Correction Level.

#### Parameters
*ModuleSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Module Size of the QR Code.

#### Parameters
*QuiteZoneWidth ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Quite Zone Width of the QR Code.

#### Parameters
*CodePage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The codepage to use.


#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Returns the success of the QR code creation.
