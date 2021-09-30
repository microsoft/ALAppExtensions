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

Stores whether the operation was successful.

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

Stores whether the operation was successful.

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

Stores whether the operation was successful.


## Printer Management (Page 2616)

 Exposes the list of available printers.
 


## Printer Paper Kind (Enum 2616)

 Specifies the standard paper sizes
 

### A2 (value: 66)


 A2 paper (420 mm by 594 mm).
 

### A3 (value: 8)


 A3 paper (297 mm by 420 mm).
 

### A4 (value: 9)


 A4 paper (210 mm by 297 mm).
 

### A5 (value: 11)


 A5 paper (148 mm by 210 mm).
 

### A6 (value: 70)


 A6 paper (105 mm by 148 mm).
 

### B4 (value: 12)


 B4 paper (250 mm by 353 mm).
 

### B4Envelope (value: 33)


 B4 envelope (250 mm by 353 mm).
 

### B5 (value: 13)


 B5 paper (176 mm by 250 mm).
 

### B5Envelope (value: 34)


 B5 envelope (176 mm by 250 mm).
 

### B6Envelope (value: 35)


 B6 envelope (176 mm by 125 mm).
 

### B6Jis (value: 88)


 JIS B6 paper (128 mm by 182 mm).
 

### C3Envelope (value: 29)


 C3 envelope (324 mm by 458 mm).
 

### C4Envelope (value: 30)


 C4 envelope (229 mm by 324 mm).
 

### C5Envelope (value: 28)


 C5 envelope (162 mm by 229 mm).
 

### C65Envelope (value: 32)


 C65 envelope (114 mm by 229 mm).
 

### C6Envelope (value: 31)


 C6 envelope (114 mm by 162 mm).
 

### CSheet (value: 24)


 C paper (17 in. by 22 in.).
 

### DLEnvelope (value: 27)


 DL envelope (110 mm by 220 mm).
 

### DSheet (value: 25)


 D paper (22 in. by 34 in.).
 

### ESheet (value: 26)


 E paper (34 in. by 44 in.).
 

### Executive (value: 7)


 Executive paper (7.25 in. by 10.5 in.).
 

### Folio (value: 14)


 Folio paper (8.5 in. by 13 in.).
 

### GermanLegalFanfold (value: 41)


 German legal fanfold (8.5 in. by 13 in.).
 

### GermanStandardFanfold (value: 40)


 German standard fanfold (8.5 in. by 12 in.).
 

### InviteEnvelope (value: 47)


 Invitation envelope (220 mm by 220 mm).
 

### IsoB4 (value: 42)


 ISO B4 (250 mm by 353 mm).
 

### ItalyEnvelope (value: 36)


 Italy envelope (110 mm by 230 mm).
 

### JapaneseDoublePostcard (value: 69)


 Japanese double postcard (200 mm by 148 mm).
 

### JapaneseEnvelopeChouNumber3 (value: 73)


 Japanese Chou #3 envelope.
 

### JapaneseEnvelopeChouNumber4 (value: 74)


 Japanese Chou #4 envelope.
 

### JapaneseEnvelopeKakuNumber2 (value: 71)


 Japanese Kaku #2 envelope.
 

### JapaneseEnvelopeKakuNumber3 (value: 72)


 Japanese Kaku #3 envelope.
 

### JapaneseEnvelopeYouNumber4 (value: 91)


 Japanese You #4 envelope.
 

### JapanesePostcard (value: 43)


 Japanese postcard (100 mm by 148 mm).
 

### Ledger (value: 4)


 Ledger paper (17 in. by 11 in.).
 

### Legal (value: 5)


 Legal paper (8.5 in. by 14 in.).
 

### Letter (value: 1)


 Letter paper (8.5 in. by 11 in.).
 

### MonarchEnvelope (value: 37)


 Monarch envelope (3.875 in. by 7.5 in.).
 

### Note (value: 18)


 Note paper (8.5 in. by 11 in.).
 

### Number10Envelope (value: 20)


 #10 envelope (4.125 in. by 9.5 in.).
 

### Number11Envelope (value: 21)


 #11 envelope (4.5 in. by 10.375 in.).
 

### Number12Envelope (value: 22)


 #12 envelope (4.75 in. by 11 in.).
 

### Number14Envelope (value: 23)


 #14 envelope (5 in. by 11.5 in.).
 

### Number9Envelope (value: 19)


 #9 envelope (3.875 in. by 8.875 in.).
 

### PersonalEnvelope (value: 38)


 6 3/4 envelope (3.625 in. by 6.5 in.).
 

### Prc16K (value: 93)


 16K paper (146 mm by 215 mm).
 

### Prc32K (value: 94)


 32K paper (97 mm by 151 mm).
 

### PrcEnvelopeNumber1 (value: 96)


 #1 envelope (102 mm by 165 mm).
 

### PrcEnvelopeNumber10 (value: 105)


 #10 envelope (324 mm by 458 mm).
 

### PrcEnvelopeNumber2 (value: 97)


 #2 envelope (102 mm by 176 mm).
 

### PrcEnvelopeNumber3 (value: 98)


 #3 envelope (125 mm by 176 mm).
 

### PrcEnvelopeNumber4 (value: 99)


 #4 envelope (110 mm by 208 mm).
 

### PrcEnvelopeNumber5 (value: 100)


 #5 envelope (110 mm by 220 mm).
 

### PrcEnvelopeNumber6 (value: 101)


 #6 envelope (120 mm by 230 mm).
 

### PrcEnvelopeNumber7 (value: 102)


 #7 envelope (160 mm by 230 mm).
 

### PrcEnvelopeNumber8 (value: 103)


 #8 envelope (120 mm by 309 mm).
 

### PrcEnvelopeNumber9 (value: 104)


 #9 envelope (229 mm by 324 mm).
 

### Quarto (value: 15)


 Quarto paper (215 mm by 275 mm).
 

### Standard10x11 (value: 45)


 Standard paper (10 in. by 11 in.).
 

### Standard10x14 (value: 16)


 Standard paper (10 in. by 14 in.).
 

### Standard11x17 (value: 17)


 Standard paper (11 in. by 17 in.).
 

### Standard12x11 (value: 90)


 Standard paper (12 in. by 11 in.).
 

### Standard15x11 (value: 46)


 Standard paper (15 in. by 11 in.).
 

### Standard9x11 (value: 44)


 Standard paper (9 in. by 11 in.).
 

### Statement (value: 6)


 Statement paper (5.5 in. by 8.5 in.).
 

### Tabloid (value: 3)


 Tabloid paper (11 in. by 17 in.).
 

### USStandardFanfold (value: 39)


 US standard fanfold (14.875 in. by 11 in.).
 

### Custom (value: 0)


 Custom. The paper size is defined by the user.
 


## Printer Paper Source Kind (Enum 2617)

 Standard paper sources.
 

### AutomaticFeed (value: 7)


 Automatically fed paper.
 

### Cassette (value: 14)


 A paper cassette.
 

### Custom (value: 257)


 A printer-specific paper source.
 

### Envelope (value: 5)


 An envelope.
 

### FormSource (value: 15)


 The default input bin of printer.
 

### LargeCapacity (value: 11)


 The large-capacity bin of printer.
 

### LargeFormat (value: 10)


 Large-format paper.
 

### Lower (value: 2)


 The lower bin of a printer.
 

### Manual (value: 4)


 Manually fed paper.
 

### ManualFeed (value: 6)


 Manually fed envelope.
 

### Middle (value: 3)


 The middle bin of a printer.
 

### SmallFormat (value: 9)


 Small-format paper.
 

### TractorFeed (value: 8)


 A tractor feed.
 

### Upper (value: 1)


 The upper bin of a printer.
 


## Printer Type (Enum 2619)

 Specifies the type of a printer.
 

### Local Printer (value: 0)


 Specifies a local printer.
 

### Network Printer (value: 1)


 Specifies a cloud printer.
 


## Printer Unit (Enum 2618)

 Specifies several of the units of measure used for printing.
 

### Display (value: 0)


 The default unit (0.01 in.)
 

### HundredthsOfAMillimeter (value: 2)


 One-hundredth of a millimeter (0.01 mm).
 

### TenthsOfAMillimeter (value: 3)


 One-tenth of a millimeter (0.1 mm).
 

### ThousandthsOfAnInch (value: 1)


 One-thousandth of an inch (0.001 in.).
 

