This module provides the tools needed to manage web services.

Use this module to do the following:
- Create and modify web services.
- Access web service URLs.
- Get and set web service filters and clauses.


# Public Objects
## Tenant Web Service Columns (Table 6711)

 Contains tenant web service column entities.
 


## Tenant Web Service Filter (Table 6712)

 Contains tenant web service filter entities.
 


## Tenant Web Service OData (Table 6710)

 Contains tenant web service OData clause entities.
 


## Web Service Aggregate (Table 9900)

 Contains web services aggregated from Web Services and Tenant Web Services.
 


## Web Service Management (Codeunit 9750)

 Provides methods for creating and modifying web services, accessing web service URLs, and getting and setting web service filters and clauses.
 

### CreateWebService (Method) <a name="CreateWebService"></a> 

 Creates a web service for a given object. If the web service already exists, it modifies the web service accordingly.
 This method should be used for On-Prem scenarios only. Calling this method in SaaS will throw a runtime error.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
```
#### Parameters
*ObjectType ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The type of the object.

*ObjectId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the object.

*ObjectName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the object.

*Published ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the web service is published or not.

### CreateTenantWebService (Method) <a name="CreateTenantWebService"></a> 

 Creates a tenant web service for a given object. If the tenant web service already exists, it modifies the tenant web service accordingly.
 

#### Syntax
```
procedure CreateTenantWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
```
#### Parameters
*ObjectType ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The type of the object.

*ObjectId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the object.

*ObjectName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the object.

*Published ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the web service is published or not.

### GetWebServiceUrl (Method) <a name="GetWebServiceUrl"></a> 

 Gets the web service URL for a given Web Service Aggregate record and client type.
 

#### Syntax
```
procedure GetWebServiceUrl(WebServiceAggregate: Record "Web Service Aggregate"; ClientType: Enum "Client Type"): Text
```
#### Parameters
*WebServiceAggregate ([Record "Web Service Aggregate"]())* 

The record for getting web service URL.

*ClientType ([Enum "Client Type"]())* 

The client type of the URL. Clients are SOAP, ODataV3 and ODataV4.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Web service URL for the given record.
### CreateTenantWebServiceColumnsFromTemp (Method) <a name="CreateTenantWebServiceColumnsFromTemp"></a> 

 Creates tenant web service columns from temporary records.
 

#### Syntax
```
procedure CreateTenantWebServiceColumnsFromTemp(var TenantWebServiceColumns: Record "Tenant Web Service Columns"; var TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary; TenantWebServiceRecordId: RecordID)
```
#### Parameters
*TenantWebServiceColumns ([Record "Tenant Web Service Columns"]())* 

Record that the columns from temporary records are inserted to.

*TempTenantWebServiceColumns ([Record "Tenant Web Service Columns" temporary]())* 

Temporary record that the columns are inserted from.

*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the Tenant Web Service corresponding to columns.

### CreateTenantWebServiceFilterFromRecordRef (Method) <a name="CreateTenantWebServiceFilterFromRecordRef"></a> 

 Creates a tenant web service filter from a record reference.
 

#### Syntax
```
procedure CreateTenantWebServiceFilterFromRecordRef(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; var RecRef: RecordRef; TenantWebServiceRecordId: RecordID)
```
#### Parameters
*TenantWebServiceFilter ([Record "Tenant Web Service Filter"]())* 

Record that the filter from record reference is inserted to.

*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

Record reference that the filter is inserted from.

*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the Tenant Web Service corresponding to the filter.

### GetTenantWebServiceFilter (Method) <a name="GetTenantWebServiceFilter"></a> 

 Returns the tenant web service filter for a given record.
 

#### Syntax
```
procedure GetTenantWebServiceFilter(TenantWebServiceFilter: Record "Tenant Web Service Filter"): Text
```
#### Parameters
*TenantWebServiceFilter ([Record "Tenant Web Service Filter"]())* 

The record for getting filter.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Tenant web service filter for the given record.
### SetTenantWebServiceFilter (Method) <a name="SetTenantWebServiceFilter"></a> 

 Sets the tenant web service filter for a given record.
 

#### Syntax
```
procedure SetTenantWebServiceFilter(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; FilterText: Text)
```
#### Parameters
*TenantWebServiceFilter ([Record "Tenant Web Service Filter"]())* 

The record for setting tenant web service filter.

*FilterText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The tenant web service filter that is set.

### GetODataSelectClause (Method) <a name="GetODataSelectClause"></a> 

 Returns the OData select clause for a given record.
 

#### Syntax
```
procedure GetODataSelectClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for getting OData select clause.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

OData select clause for the given record.
### SetODataSelectClause (Method) <a name="SetODataSelectClause"></a> 

 Sets the OData select clause for a given record.
 

#### Syntax
```
procedure SetODataSelectClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for setting OData select clause.

*ODataText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OData select clause that is set.

### GetODataFilterClause (Method) <a name="GetODataFilterClause"></a> 

 Returns the OData filter clause for a given record.
 

#### Syntax
```
procedure GetODataFilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for getting OData filter clause.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

OData filter clause for the given record.
### SetODataFilterClause (Method) <a name="SetODataFilterClause"></a> 

 Sets the OData filter clause for a given record.
 

#### Syntax
```
procedure SetODataFilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for setting OData filter clause.

*ODataText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OData filter clause that is set.

### GetODataV4FilterClause (Method) <a name="GetODataV4FilterClause"></a> 

 Returns the OData V4 filter clause for a given record.
 

#### Syntax
```
procedure GetODataV4FilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for getting OData V4 filter clause.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

OData V4 filter clause for the given record.
### SetODataV4FilterClause (Method) <a name="SetODataV4FilterClause"></a> 

 Sets the OData V4 filter clause for a given record.
 

#### Syntax
```
procedure SetODataV4FilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for setting OData V4 filter clause.

*ODataText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OData V4 filter clause that is set.

### GetObjectCaption (Method) <a name="GetObjectCaption"></a> 

 Gets the name of the object that will be exposed to the web service for a given record.
 

#### Syntax
```
procedure GetObjectCaption(WebServiceAggregate: Record "Web Service Aggregate"): Text[80]
```
#### Parameters
*WebServiceAggregate ([Record "Web Service Aggregate"]())* 

The record for getting the name of the object.

#### Return Value
*[Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Name of the object.
### LoadRecords (Method) <a name="LoadRecords"></a> 

 Loads records from Web Service and Tenant Web Service table into given Web Service Aggregate record.
 

#### Syntax
```
procedure LoadRecords(var WebServiceAggregate: Record "Web Service Aggregate")
```
#### Parameters
*WebServiceAggregate ([Record "Web Service Aggregate"]())* 

The variable that the records are loaded into.

### LoadRecordsFromTenantWebServiceColumns (Method) <a name="LoadRecordsFromTenantWebServiceColumns"></a> 

 Loads records from Tenant Web Service table if there is a corresponding Tenant Web Service Column.
 

#### Syntax
```
procedure LoadRecordsFromTenantWebServiceColumns(var TenantWebService: Record "Tenant Web Service")
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The variable that the records are loaded into.

### CreateTenantWebServiceColumnForPage (Method) <a name="CreateTenantWebServiceColumnForPage"></a> 

 Creates a tenant web service for a given page.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateTenantWebServiceColumnForPage(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer)
```
#### Parameters
*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the given page.

*FieldNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the tenant web service column.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

### CreateTenantWebServiceColumnForQuery (Method) <a name="CreateTenantWebServiceColumnForQuery"></a> 

 Creates a tenant web service for a given query.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateTenantWebServiceColumnForQuery(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer; MetaData: DotNet QueryMetadataReader)
```
#### Parameters
*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the given query.

*FieldNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the tenant web service column.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

*MetaData ([DotNet QueryMetadataReader]())* 

Metadata used to convert field name.

### InsertSelectedColumns (Method) <a name="InsertSelectedColumns"></a> 

 Inserts selected columns in a given dictionary to the tenant web service columns table.
 

#### Syntax
```
procedure InsertSelectedColumns(var TenantWebService: Record "Tenant Web Service"; var ColumnDictionary: DotNet GenericDictionary2; var TargetTenantWebServiceColumns: Record "Tenant Web Service Columns"; DataItem: Integer)
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The tenant web service corresponding to columns.

*ColumnDictionary ([DotNet GenericDictionary2]())* 

Dictionary that contains selected columns to be inserted to the tenant web service columns table.

*TargetTenantWebServiceColumns ([Record "Tenant Web Service Columns"]())* 

Tenant web service columns table record that selected columns are inserted to.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

### RemoveUnselectedColumnsFromFilter (Method) <a name="RemoveUnselectedColumnsFromFilter"></a> 

 Removes filters that are not in the selected columns for the given service.
 

#### Syntax
```
procedure RemoveUnselectedColumnsFromFilter(var TenantWebService: Record "Tenant Web Service"; DataItem: Integer; DataItemView: Text): Text
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The tenant web service corresponding to columns.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

*DataItemView ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The field name of the data item.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Filter text for unselected columns.
### IsServiceNameValid (Method) <a name="IsServiceNameValid"></a> 

 Checks if given service name is valid.
 

#### Syntax
```
procedure IsServiceNameValid(Value: Text): Boolean
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The service name to be checked.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

If given service name valid or not.

## Client Type (Enum 9751)

 This enum has the web service client types.
 

### SOAP (value: 0)


 Specifies that the client type is SOAP.
 

### ODataV3 (value: 1)


 Specifies that the client type is OData V3.
 

### ODataV4 (value: 2)


 Specifies that the client type is OData V4.
 


## OData Protocol Version (Enum 9750)

 This enum has the OData protocol versions.
 

### V3 (value: 0)


 Specifies that the OData protocol version is V3.
 

### V4 (value: 1)


 Specifies that the OData protocol version is V4.
 

