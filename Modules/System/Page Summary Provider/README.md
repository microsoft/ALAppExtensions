This contains functionality for providing summary data for a given page. Depending on the given page, the returned summary data can be of different types (Caption, Brick fields, Dropdown fields, First N fields, etc.)
# Public Objects
## Page Summary Provider (Codeunit 2718)

 Exposes functionality that gets page summary for a selected page.
 This codeunit is exposed as a webservice and hence all functions are available through OData calls.
 

### GetPageSummary (Method) <a name="GetPageSummary"></a> 

 {
   "version":"1.1",
   "pageCaption":"Customer Card",
   "pageType":"Card",
   "summaryType":"Brick",
   "fields":[
      {"caption":"No.","fieldValue":"01445544","type":"Code"},
      {"caption":"Name","fieldValue":"Progressive Home Furnishings","type":"Text"},
      {"caption":"Contact","fieldValue":"Mr. Scott Mitchell","type":"Text"},
      {"caption":"Balance Due (LCY)","fieldValue":"1.499,03","type":"Decimal"}]
   }
 }

 In case of an error:
 {
   "version":"1.1",
   "pageCaption":"Customer Card",
   "pageType":"Card",
   "summaryType":"Caption",
   "error":[
     "code":"InvalidBookmark"
     "message":"The bookmark is invalid."
   ]
 }
 


 Gets page summary for a given Page ID and bookmark.
 

#### Syntax
```
procedure GetPageSummary(PageId: Integer; Bookmark: Text): Text
```
#### Parameters
*PageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



*Bookmark ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Text value for the page summary in JSON format.
### GetPageSummaryBySystemID (Method) <a name="GetPageSummaryBySystemID"></a> 

 {
   "version":"1.1",
   "pageCaption":"Customer Card",
   "pageType":"Card",
   "summaryType":"Brick",
   "url":"https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&page=22&bookmark=27%3bEgAAAAJ7CDAAMQA5ADAANQA4ADkAMw%3d%3",
   "fields":[
      {"caption":"No.","fieldValue":"01445544","type":"Code"},
      {"caption":"Name","fieldValue":"Progressive Home Furnishings","type":"Text"},
      {"caption":"Contact","fieldValue":"Mr. Scott Mitchell","type":"Text"},
      {"caption":"Balance Due (LCY)","fieldValue":"1.499,03","type":"Decimal"}]
   }
 }

 In case of an error:
 {
   "version":"1.1",
   "pageCaption":"Customer Card",
   "pageType":"Card",
   "summaryType":"Caption",
   "error":[
     "code":"InvalidSystemId"
     "message":"The system id is invalid."
   ]
 }
 


 Gets page summary for a given Page ID and System ID.
 

#### Syntax
```
procedure GetPageSummaryBySystemID(PageId: Integer; SystemId: Guid): Text
```
#### Parameters
*PageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Text value for the page summary in JSON format.
### GetPageSummary (Method) <a name="GetPageSummary"></a> 

 {
   "version":"1.1",
   "pageCaption":"Customer Card",
   "pageType":"Card",
   "summaryType":"Caption",
 }

 In case of error:
 {
   "version":"1.1",
   "pageCaption":"Customer Card",
   "pageType":"Card",
   "summaryType":"Caption",
   "error":[
     "code":"error code"
     "message":"error message"
   ]
 }
 


 Gets page information such as page caption and and page type.
 

#### Syntax
```
procedure GetPageSummary(PageId: Integer): Text
```
#### Parameters
*PageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Text value for the page summary in JSON format.
### GetVersion (Method) <a name="GetVersion"></a> 

 Gets the current version of the Page Summary Provider.
 

#### Syntax
```
procedure GetVersion(): Text[30]
```
#### Return Value
*[Text[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Text value for the current version of Page Summary Provider.
### OnBeforeGetPageSummary (Event) <a name="OnBeforeGetPageSummary"></a> 

 Allows changing which fields and values are returned when fetching page summary.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeGetPageSummary(PageId: Integer; RecId: RecordId; var FieldsJsonArray: JsonArray; var Handled: Boolean)
```
#### Parameters
*PageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



*RecId ([RecordId](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 



*FieldsJsonArray ([JsonArray]())* 



*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



### OnAfterGetSummaryFields (Event) <a name="OnAfterGetSummaryFields"></a> 

 Allows changing which fields are shown when fetching page summary, including their order.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterGetSummaryFields(PageId: Integer; RecId: RecordId; var FieldList: List of [Integer])
```
#### Parameters
*PageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



*RecId ([RecordId](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 



*FieldList ([List of [Integer]]())* 



### OnAfterGetPageSummary (Event) <a name="OnAfterGetPageSummary"></a> 

 Allows changing which fields and values are returned just before sending the response.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterGetPageSummary(PageId: Integer; RecId: RecordId; var FieldsJsonArray: JsonArray)
```
#### Parameters
*PageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



*RecId ([RecordId](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 



*FieldsJsonArray ([JsonArray]())* 




## Summary Type (Enum 2716)

 Specifies the type of a summary.
 

### Caption (value: 0)


 Specifies the default type that represents caption of a object
 

### Brick (value: 1)


 Specifies the type that represents fields defined in a brick fieldgroup
 

