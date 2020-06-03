Contains functionality that enables a user to manage printers.
# Public Objects
## Printer Setup (Codeunit 2616)

 Exposes functionality to manage printer settings.
 

### OnOpenPrinterSettings (Event) <a name="OnOpenPrinterSettings"></a> 

 Integration event that is called to view and edit the settings of a printer. 
 Subscribe to this event if you want to introduce user configurable settings for a printer.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnOpenPrinterSettings(PrinterID: Text; var IsHandled: Boolean)
```
#### Parameters
*PrinterID ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A value that determines the printer being drilled down.

*IsHandled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



### OnSetAsDefaultPrinter (Event) <a name="OnSetAsDefaultPrinter"></a> 

 Integration event that is called to set the default printer for all reports. 
  Subscribe to this event to specify a value in the Printer Name field and leave the User ID and Report ID fields blank in Printers Selection.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnSetAsDefaultPrinter(PrinterID: Text; UserID: Text; var IsHandled: Boolean)
```
#### Parameters
*PrinterID ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A value that determines the printer being set as default.

*UserID ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A value that determines the user for whom the printer is being set as default. Empty value implies all users.

*IsHandled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



### GetPrinterSelectionsPage (Event) <a name="GetPrinterSelectionsPage"></a> 

 Integration event that is called to get the page ID of the Printer Selection page.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure GetPrinterSelectionsPage(var PageID: Integer; var IsHandled: Boolean)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

An out value that determines the id of the Printer Selection page.

*IsHandled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 




## Printer Management (Page 2616)

 Exposes the list of available printers.
 


## Printer Paper Kind (Enum 2616)

 Specifies the standard paper sizes
 

### A2 (value: 66)

### A3 (value: 8)

### A4 (value: 9)

### A5 (value: 11)

### A6 (value: 70)

### B4 (value: 12)

### B4Envelope (value: 33)

### B5 (value: 13)

### B5Envelope (value: 34)

### B6Envelope (value: 35)

### B6Jis (value: 88)

### C3Envelope (value: 29)

### C4Envelope (value: 30)

### C5Envelope (value: 28)

### C65Envelope (value: 32)

### C6Envelope (value: 31)

### CSheet (value: 24)

### DLEnvelope (value: 27)

### DSheet (value: 25)

### ESheet (value: 26)

### Executive (value: 7)

### Folio (value: 14)

### GermanLegalFanfold (value: 41)

### GermanStandardFanfold (value: 40)

### InviteEnvelope (value: 47)

### IsoB4 (value: 42)

### ItalyEnvelope (value: 36)

### JapaneseDoublePostcard (value: 69)

### JapaneseEnvelopeChouNumber3 (value: 73)

### JapaneseEnvelopeChouNumber4 (value: 74)

### JapaneseEnvelopeKakuNumber2 (value: 71)

### JapaneseEnvelopeKakuNumber3 (value: 72)

### JapaneseEnvelopeYouNumber4 (value: 91)

### JapanesePostcard (value: 43)

### Ledger (value: 4)

### Legal (value: 5)

### Letter (value: 1)

### MonarchEnvelope (value: 37)

### Note (value: 18)

### Number10Envelope (value: 20)

### Number11Envelope (value: 21)

### Number12Envelope (value: 22)

### Number14Envelope (value: 23)

### Number9Envelope (value: 19)

### PersonalEnvelope (value: 38)

### Prc16K (value: 93)

### Prc32K (value: 94)

### PrcEnvelopeNumber1 (value: 96)

### PrcEnvelopeNumber10 (value: 105)

### PrcEnvelopeNumber2 (value: 97)

### PrcEnvelopeNumber3 (value: 98)

### PrcEnvelopeNumber4 (value: 99)

### PrcEnvelopeNumber5 (value: 100)

### PrcEnvelopeNumber6 (value: 101)

### PrcEnvelopeNumber7 (value: 102)

### PrcEnvelopeNumber8 (value: 103)

### PrcEnvelopeNumber9 (value: 104)

### Quarto (value: 15)

### Standard10x11 (value: 45)

### Standard10x14 (value: 16)

### Standard11x17 (value: 17)

### Standard12x11 (value: 90)

### Standard15x11 (value: 46)

### Standard9x11 (value: 44)

### Statement (value: 6)

### Tabloid (value: 3)

### USStandardFanfold (value: 39)

### Custom (value: 0)


## Printer Paper Source Kind (Enum 2617)

 Standard paper sources.
 

### AutomaticFeed (value: 7)

### Cassette (value: 14)

### Custom (value: 257)

### Envelope (value: 5)

### FormSource (value: 15)

### LargeCapacity (value: 11)

### LargeFormat (value: 10)

### Lower (value: 2)

### Manual (value: 4)

### ManualFeed (value: 6)

### Middle (value: 3)

### SmallFormat (value: 9)

### TractorFeed (value: 8)

### Upper (value: 1)


## Printer Type (Enum 2619)

 Specifies the type of a printer.
 

### Local Printer (value: 0)

### Network Printer (value: 1)


## Printer Unit (Enum 2618)

 Specifies several of the units of measure used for printing.
 

### Display (value: 0)

### HundredthsOfAMillimeter (value: 2)

### TenthsOfAMillimeter (value: 3)

### ThousandthsOfAnInch (value: 1)

