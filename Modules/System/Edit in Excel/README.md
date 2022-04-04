This module provides an API for the Edit in Excel funcitonality in Business Central.

This module can be used to:
- Enable Edit in Excel functionality on new pages
- Modify the behaviour of the Edit in Excel functionality

### How to download an Edit in Excel file
```
procedure Example()
var
    EditinExcel: Codeunit "Edit in Excel";
    Filter: Text;
    FileName: Text;
begin
    Filter := StrSubstNo('Journal_Batch_Name eq ''%1'' and Journal_Template_Name eq ''%2''', JournalBatchName, JournalTemplateName);
    FileName := StrSubstNo('%1 (%2, %3)', CurrPage.Caption, JournalBatchName, JournalTemplateName);
    EditinExcel.EditPageInExcel(CurrPage.Caption, CurrPage.ObjectId(false), Filter, FileName);
end;
```

### How to override Edit in Excel functionality
```
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcel', '', false, false)]
local procedure OnEditInExcel(ServiceName: Text[240]; ODataFilter: Text; SearchFilter: Text; var Handled: Boolean)
begin
    if HandleOnEditInExcel(ServiceName, ODataFilter, SearchFilter) then
        Handled := True;
end;
```

# Public Objects
## Edit in Excel Settings (Table 1480)

 Contains settings for Edit in Excel.
 


## Edit in Excel (Codeunit 1481)

 This codeunit provides an interface to running Edit in Excel for a specific page.
 

### EditPageInExcel (Method) <a name="EditPageInExcel"></a> 

 Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
 

#### Syntax
```
procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text)
```
#### Parameters
*PageCaption ([Text[240]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the page. This will be used for the name of the downloaded excel file, additionally the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.

*PageId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The ID of the page, for example, "21".

*Filter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Business Central filter to be applied in Edit in Excel.

### EditPageInExcel (Method) <a name="EditPageInExcel"></a> 

 Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
 

#### Syntax
```
procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text; FileName: Text)
```
#### Parameters
*PageCaption ([Text[240]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the page. This will be used for the name of the downloaded excel file, if the FileName parameter is not set. Additionally, the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.

*PageId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The ID of the page, for example, "21".

*Filter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Business Central filter to be applied in Edit in Excel.

*FileName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the downloaded excel file.

### GenerateExcelWorkBook (Method) <a name="GenerateExcelWorkBook"></a> 

 Prepares an Excel file for the Edit in Excel functionality by using the specified web service, and downloads the file.
 

#### Syntax
```
procedure GenerateExcelWorkBook(TenantWebService: Record "Tenant Web Service"; SearchFilter: Text)
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The web service referenced through Edit in Excel.

*SearchFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The search filter of the user.

### OnEditInExcel (Event) <a name="OnEditInExcel"></a> 

 This event is called when Edit in Excel is invoked and allows overriding the Edit in Excel functionality.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnEditInExcel(ServiceName: Text[240]; ODataFilter: Text; SearchFilter: Text; var Handled: Boolean)
```
#### Parameters
*ServiceName ([Text[240]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the web service already created for use with Edit in Excel.

*ODataFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*SearchFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The search filter of the user.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 




## Excel Centralized Depl. Wizard (Page 1480)

 This is a wizard which guides the user through setting up their tenant for using Edit in Excel with Excel add-in installed through centralized deployments.
 

