This module provides an API for the Edit in Excel functionality in Business Central.

This module can be used to:
- Enable Edit in Excel functionality on new pages
- Modify the behaviour of the Edit in Excel functionality

### How to download an Edit in Excel file
```
procedure Example()
var
    EditinExcel: Codeunit "Edit in Excel";
    EditinExcelFilters: Codeunit "Edit in Excel Filters";
    FileName: Text;
begin
    EditinExcelFilters.AddField('Journal_Batch_Name', Enum::"Edit in Excel Filter Type"::Equal, JournalBatchName, Enum::"Edit in Excel Edm Type"::"Edm.String");
    EditinExcelFilters.AddField('Journal_Template_Name', Enum::"Edit in Excel Filter Type"::Equal, JournalTemplateName, Enum::"Edit in Excel Edm Type"::"Edm.String");
    FileName := StrSubstNo('%1 (%2, %3)', CurrPage.Caption, JournalBatchName, JournalTemplateName);
    EditinExcel.EditPageInExcel(CopyStr(CurrPage.Caption, 1, 240), Page::"Example page", EditinExcelFilters, FileName);
end;
```

### How to override Edit in Excel functionality
```
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcelWithFilters', '', false, false)]
local procedure OnEditInExcelWithFilters(ServiceName: Text[240]; var EditinExcelFilters: Codeunit "Edit in Excel Filters"; SearchFilter: Text; var Handled: Boolean)
begin
    // Note: Since EditinExcelFilters is sent by var, you can simply modify the filters and not handle the entire flow by not setting Handled := True
    if HandleOnEditInExcel(ServiceName, EditinExcelFilters, SearchFilter) then
        Handled := True;
end;
```

### How to generate your own Excel file
```
procedure CreateExcelFile(ServiceName: Text[250]; EditinExcelFilters: Codeunit "Edit in Excel Filters"; SearchFilter: Text)
var
    EditinExcelWorkbook: Codeunit "Edit in Excel Workbook";
    FileName: Text;
begin
    // Initialize the workbook
    EditinExcelWorkbook.Initialize(ServiceName);

    // Add columns that should be shown to the user
    EditinExcelWorkbook.AddColumn(Rec.FieldCaption(Code), 'Code');
    EditinExcelWorkbook.AddColumn(Rec.FieldCaption(Name), 'Name');

    // Add any filters from the page (see below for how to create filters). Note: It's allowed to filter on columns not added to the excel file
    EditinExcelWorkbook.SetFilters(EditinExcelFilters);

    // Download the excel file
    FileName := 'ExcelFileName.xlsx';
    DownloadFromStream(EditinExcelWorkbook.ExportToStream(), DialogTitleTxt, '', '*.*', FileName);
end;
```

### How to create filters
```
procedure CreateExcelFilters()
var
    EditinExcelFilters: Codeunit "Edit in Excel Filters";
begin
    // Let's add a simple filter "Blocked = False"
    EditinExcelFilters.AddField('Blocked', Enum::"Edit in Excel Filter Type"::Equal, 'false', Enum::"Edit in Excel Edm Type"::"Edm.Boolean");

    // Now the filter "No. = 10000|20000"
    EditinExcelFilters.AddField('No_', Enum::"Edit in Excel Filter Collection Type"::"or", Enum::"Edit in Excel Edm Type"::"Edm.String")
                        .AddFilterValue(Enum::"Edit in Excel Filter Type"::Equal, '10000')
                        .AddFilterValue(Enum::"Edit in Excel Filter Type"::Equal, '20000');

    // Finally let's add a range, "Amount = 1000..2000"
    EditinExcelFilters.AddField('Amount', Enum::"Edit in Excel Filter Collection Type"::"and", Enum::"Edit in Excel Edm Type"::"Edm.Decimal")
                        .AddFilterValue(Enum::"Edit in Excel Filter Type"::"Greater or Equal", '1000')
                        .AddFilterValue(Enum::"Edit in Excel Filter Type"::"Less or Equal", '2000');

    // Since we did not clear EditinExcelFilters in between, the current filter is "(Blocked = false) and (No_ = 10000|20000) and (Amount = 1000..2000)"
    // In other words, all the filters are added together.
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


### OnEditInExcelWithStructuredFilter (Event) <a name="OnEditInExcelWithStructuredFilter"></a> 
 This event is called when Edit in Excel is invoked, handling JSON structured filters. It also allows overriding the Edit in Excel functionality.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnEditInExcelWithStructuredFilter(ServiceName: Text[240]; Filter: JsonObject; Payload: JsonObject; SearchFilter: Text; var Handled: Boolean)
```
#### Parameters
*ServiceName ([Text[240]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the web service already created for use with Edit in Excel.

*Filter ([JsonObject](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/jsonobject/jsonobject-data-type))* 

Business Central Filter to be applied in Edit in Excel

*Payload ([JsonObject](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/jsonobject/jsonobject-data-type)*

Object binding the name of the filtered field with  its EdmType

*SearchFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The search filter of the user.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 


## Excel Centralized Depl. Wizard (Page 1480)

 This is a wizard which guides the user through setting up their tenant for using Edit in Excel with Excel add-in installed through centralized deployments.
 

