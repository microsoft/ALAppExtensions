Administrators can define retention policies to specify how frequently they want Business Central to delete outdated data in tables that contain log entries and archived records. For example, cleaning up log entries can make it easier to work with the data that's actually relevant. Policies can include all data in the tables that is past the expiration date, or you can add filter criteria that will include only certain expired data in the policy.

# Public Objects
## Reten. Pol. Deleting Param (Table 3907)

 The table is used as a parameter table for the DeleteRecords method on the Reten. Pol Deleting interface.

 if "Indirect Permission Required" is true and the implementation does not have the required indirect permissions,
 then "Skip Event Indirect Perm. Req." should be set to false. This will allow a subscriber to handle the deletion.

 if there are more records to be deleted than as indicated by "Max. Number of Rec. to Delete",
 then only a number of records equal to "Max. Number of Rec. to Delete" should be deleted.
 In the case where not all records were deleted, "Skip Event Rec. Limit Exceeded" should be set to false. This
 will allow either a subscriber or the user to schedule another run to delete the remaining records.

 "Total Max. Nr. of Rec. to Del." is provided for information only. This is the maximum number of records recommended to delete
 in a single run of Apply Retention Policies.

 "User Invoked Run" is provided for information only.
 


## Reten. Pol. Filtering Param (Table 3906)

 The table is used as a parameter table for the ApplyRetentionPolicyAllRecordFilters and ApplyRetentionPolicySubSetFilters methods on the Reten. Pol Filtering interface.
 


## Retention Period (Table 3900)

 The Retention Periods table is used to define retention periods.
 You define a retention period by selecting one of the default values in the Retention Period field, or by selecting the Custom value and providing a date formula.
 The date formula must result in a date that is at least two days before the current date.
 


## Retention Policy Setup (Table 3901)

 This table stores the retention policy setup records.
 


## Retention Policy Setup Line (Table 3902)

 This table stores the filter used to apply retention policies to subsets of records in a table.
 

### SetTableFilter (Method) <a name="SetTableFilter"></a> 

 Use this procedure to open a Filter Page Builder page and store the resulting filter in view format on the current record.
 

#### Syntax
```
procedure SetTableFilter()
```
### GetTableFilterView (Method) <a name="GetTableFilterView"></a> 

 Use this procedure to get the filter in view format stored in the current record.
 

#### Syntax
```
procedure GetTableFilterView(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The filter in the view format. 
### GetTableFilterText (Method) <a name="GetTableFilterText"></a> 

 Use this procedure to get the filter in text format stored in the current record.
 

#### Syntax
```
procedure GetTableFilterText(): Text[2048]
```
#### Return Value
*[Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The Filter in text format.
### IsLocked (Method) <a name="IsLocked"></a> 

 Use this procedure to verify whether the retention policy setup line is locked.
 

#### Syntax
```
procedure IsLocked(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the line is locked.

## Reten. Pol. Deleting (Interface)

 The Reten. Pol. Deleting interface is used to set filters on the table for which a retention policy is applied.
 

### DeleteRecords (Method) <a name="DeleteRecords"></a> 

 This function deletes the expired records for the retention policy according to the settings in the parameter table.
 

#### Syntax
```
procedure DeleteRecords(var RecRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The record reference with expired records for the retention policy.

*RetenPolDeletingParam ([Record "Reten. Pol. Deleting Param" temporary]())* 

The parameter table for this run of apply retention policy.


## Reten. Pol. Filtering (Interface)

 The Reten. Pol. Filtering interface is used to set filters on the table for which a retention policy is applied.
 

### ApplyRetentionPolicyAllRecordFilters (Method) <a name="ApplyRetentionPolicyAllRecordFilters"></a> 

 This method is called when the retention policy applies to all records of the table. The FilterRecordRef must contain filters whe returned.
 

#### Syntax
```
procedure ApplyRetentionPolicyAllRecordFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
```
#### Parameters
*RetentionPolicySetup ([Record "Retention Policy Setup"]())* 

The retention policy for which filters are applied.

*FilterRecordRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A RecordRef of the table on which the filters are applied.

*RetenPolFilteringParam ([Record "Reten. Pol. Filtering Param" temporary]())* 

The parameter table for this run of apply retention policy.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true when there are expired records in the filters
### ApplyRetentionPolicySubSetFilters (Method) <a name="ApplyRetentionPolicySubSetFilters"></a> 

 This method is called when the retention policy defines subsets of records. The records in FilterRecordRef must be marked to indicate they are part of the union of all subsets.
 

#### Syntax
```
procedure ApplyRetentionPolicySubSetFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
```
#### Parameters
*RetentionPolicySetup ([Record "Retention Policy Setup"]())* 

The retention policy for which filters are applied.

*FilterRecordRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A RecordRef of the table on which the filters are applied.

*RetenPolFilteringParam ([Record "Reten. Pol. Filtering Param" temporary]())* 

The parameter table for this run of apply retention policy.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true when there are expired records in the filters
### HasReadPermission (Method) <a name="HasReadPermission"></a> 

    procedure HasReadPermission(TableId: Integer): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(RecRef.ReadPermission())
    end;
 


 This method is used to determine whether the implementation has read permission to the table specified in TableId.
 The permissions depend on both the user and the implementation codeunit.
 If the combination of user and implementation codeunit do not have read permission to the table, the retention policy will not be applied.
 A notification will be shown on the Retention Policy Setup card.
 

#### Syntax
```
procedure HasReadPermission(TableId: Integer): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table for a retention policy is defined

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the records in the table can be read.
### Count (Method) <a name="Count"></a> 

    procedure Count(RecRef:RecordRef): Integer
    begin
        exit(RecRef.Count())
    end;
 


 This method is to count the records in the table specified in the RecRef.
 The method is only called when the base code does not have read permission to the table.
 

#### Syntax
```
procedure Count(RecRef: RecordRef): Integer
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A record reference.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of records.

## Retention Period (Interface)

 The retention period interface provides functions to retrieve the date formula and calculate the expiration date based on a retention period record.
 

### RetentionPeriodDateFormula (Method) <a name="RetentionPeriodDateFormula"></a> 
Returns the date formula for a given retention period.

#### Syntax
```
procedure RetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"): Text
```
#### Parameters
*RetentionPeriod ([Record "Retention Period"]())* 

The record that has the retention period for which you want the date formula.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The date formula as a string in a language-independent format.
### RetentionPeriodDateFormula (Method) <a name="RetentionPeriodDateFormula"></a> 
Returns the date formula for a given retention period.

#### Syntax
```
procedure RetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"; Translated: Boolean): Text
```
#### Parameters
*RetentionPeriod ([Record "Retention Period"]())* 

The record that has the retention period for which you want the date formula.

*Translated ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether to return the date formula in a language-independent format or in the current language format.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The date formula as a string.
### CalculateExpirationDate (Method) <a name="CalculateExpirationDate"></a> 
Returns the expiration date for a given retention period.

#### Syntax
```
procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"): Date
```
#### Parameters
*RetentionPeriod ([Record "Retention Period"]())* 

The record that has the retention period for which you want the expiration date. By default, the current date is used.

#### Return Value
*[Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type)*

The expiration date.
### CalculateExpirationDate (Method) <a name="CalculateExpirationDate"></a> 
Returns the expiration date for a given retention period.

#### Syntax
```
procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"; UseDate: Date): Date
```
#### Parameters
*RetentionPeriod ([Record "Retention Period"]())* 

The record that has the retention period for which you want the expiration date.

*UseDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The expiration date is calculated based on this date.

#### Return Value
*[Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type)*

The expiration date.
### CalculateExpirationDate (Method) <a name="CalculateExpirationDate"></a> 
Returns the expiration date and time for a given retention period.

#### Syntax
```
procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"; UseDateTime: DateTime): DateTime
```
#### Parameters
*RetentionPeriod ([Record "Retention Period"]())* 

The record that has the retention period for which you want the expiration date and time.

*UseDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The expiration date and time are calculated based on this date and time.

#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The expiration date and time.

## Apply Retention Policy (Codeunit 3910)

 This codeunit provides functions to apply a retention policy.
 

### ApplyRetentionPolicy (Method) <a name="ApplyRetentionPolicy"></a> 

 Applies all enabled, non-manual retention polices. This will delete records according to the settings defined in the Retention Policy Setup table.
 

#### Syntax
```
procedure ApplyRetentionPolicy(UserInvokedRun: Boolean)
```
#### Parameters
*UserInvokedRun ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Use this value to indicate whether the user initiated the function call or an automated process did. This value is later passed in the event OnApplyRetentionPolicyRecordLimitExceeded.

### ApplyRetentionPolicy (Method) <a name="ApplyRetentionPolicy"></a> 

 Applies the given Retention Policy. This will delete records according to the settings defined in the Retention Policy Setup table.
 

#### Syntax
```
procedure ApplyRetentionPolicy(RetentionPolicySetup: Record "Retention Policy Setup"; UserInvokedRun: Boolean)
```
#### Parameters
*RetentionPolicySetup ([Record "Retention Policy Setup"]())* 

This is the setup record which defines the retention policy to apply.

*UserInvokedRun ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Use this value to indicate whether the user initiated the functioncall or an automated process did. This value is later passed in the event OnApplyRetentionPolicyRecordLimitExceeded.

### GetExpiredRecordCount (Method) <a name="GetExpiredRecordCount"></a> 

 Returns the number of expired records for the given Retention Policy Setup record. These records would be deleted if the Retention Policy was applied.
 

#### Syntax
```
procedure GetExpiredRecordCount(RetentionPolicySetup: Record "Retention Policy Setup"): Integer
```
#### Parameters
*RetentionPolicySetup ([Record "Retention Policy Setup"]())* 

This is the setup record which defines the retention policy for which the expired records will be counted.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of records which are expired.
### SetWhereOlderExpirationDateFilter (Method) <a name="SetWhereOlderExpirationDateFilter"></a> 

 This method places a filter on the record reference where records are older than the ExpirationDate. The filter excludes any record where the date field specified in DateFieldNo has no value.
 

#### Syntax
```
procedure SetWhereOlderExpirationDateFilter(DateFieldNo: Integer; ExpirationDate: Date; var RecRef: RecordRef; FilterGroup: Integer; NullDateReplacementValue: Date)
```
#### Parameters
*DateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The date or datetime field the filter will be placed on.

*ExpirationDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The expiration date used in the filter.

*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The record reference on which the filter will be placed.

*FilterGroup ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The filtergroup in which the filter will be placed.

*NullDateReplacementValue ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The date to be used to determine whether a record has expired when the date or datetime value of the record is 0D.

### SetWhereNewerExpirationDateFilter (Method) <a name="SetWhereNewerExpirationDateFilter"></a> 

 This method places a filter on the record reference where records are newer than the ExpirationDate. The filter excludes any record where the date field specified in DateFieldNo has no value.
 

#### Syntax
```
procedure SetWhereNewerExpirationDateFilter(DateFieldNo: Integer; ExpirationDate: Date; var RecRef: RecordRef; FilterGroup: Integer; NullDateReplacementValue: Date)
```
#### Parameters
*DateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The date or datetime field the filter will be placed on.

*ExpirationDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The expiration date used in the filter.

*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The record reference on whic the filter will be placed.

*FilterGroup ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The filtergroup in which the filter will be placed.

*NullDateReplacementValue ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The date to be used to determine whether a record has expired when the date or datetime value of the record is 0D.

### OnApplyRetentionPolicyRecordLimitExceeded (Event) <a name="OnApplyRetentionPolicyRecordLimitExceeded"></a> 

 This event is raised once the maximum number of records which can be deleted in a single run is reached. The limit is defined internally and cannot be changed. The event can be used to schedule a new run to delete the remaining records.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnApplyRetentionPolicyRecordLimitExceeded(CurrTableId: Integer; NumberOfRecordsRemainingToBeDeleted: Integer; ApplyAllRetentionPolicies: Boolean; UserInvokedRun: Boolean; var Handled: Boolean)
```
#### Parameters
*CurrTableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Specifies the Id of the table on which the limit was reached.

*NumberOfRecordsRemainingToBeDeleted ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Show the number of records remaining to be deleted for the table specified in CurrTableId.

*ApplyAllRetentionPolicies ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies where the interupted run was for all retention policies or only one retention policy.

*UserInvokedRun ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether the run was initiated by a user or not.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



### OnApplyRetentionPolicyIndirectPermissionRequired (Event) <a name="OnApplyRetentionPolicyIndirectPermissionRequired"></a> 

 This event is raised when the user applying the retention policy has indirect permissions to delete records in the table.
 A subscriber to this event with indirect permissions can delete the records on behalf of the user.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnApplyRetentionPolicyIndirectPermissionRequired(var RecRef: RecordRef; var Handled: Boolean)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The record reference which contains the expired records to be deleted.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the event has been handled.


## Reten. Pol. Allowed Tables (Codeunit 3905)

 This codeunit is used to manage the list of allowed tables for which retention policies can be set up.
 Extensions can only approve the tables they create. Extensions cannot approve tables from other extensions.
 

### AddAllowedTable (Method) <a name="AddAllowedTable"></a> 

 Adds a table to the list of allowed tables.
 

#### Syntax
```
procedure AddAllowedTable(TableId: Integer): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### AddAllowedTable (Method) <a name="AddAllowedTable"></a> 

 Adds a table to the list of allowed tables.
 

#### Syntax
```
procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

*DefaultDateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of the date or datetime field used as default to determine the age of records in the table.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### AddAllowedTable (Method) <a name="AddAllowedTable"></a> 

 Adds a table to the list of allowed tables.
 

#### Syntax
```
procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer; MandatoryMinRetenDays: Integer): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

*DefaultDateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of the date or datetime field used as default to determine the age of records in the table.

*MandatoryMinRetenDays ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The minimum number of days records must be kept in the table. 

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### AddAllowedTable (Method) <a name="AddAllowedTable"></a> 

 Adds a table to the list of allowed tables.
 

#### Syntax
```
procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer; TableFilters: JsonArray): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

*DefaultDateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of the date or datetime field used as default to determine the age of records in the table.

*TableFilters ([JsonArray]())* 

A JsonArray which contains the default table filters for the retention policy

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### AddAllowedTable (Method) <a name="AddAllowedTable"></a> 

 Adds a table to the list of allowed tables.
 

#### Syntax
```
procedure AddAllowedTable(TableId: Integer; TableFilters: JsonArray): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

*TableFilters ([JsonArray]())* 

A JsonArray which contains the default table filters for the retention policy

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### AddAllowedTable (Method) <a name="AddAllowedTable"></a> 

 Adds a table to the list of allowed tables.
 

#### Syntax
```
procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer; MandatoryMinRetenDays: Integer; RetenPolFiltering: Enum "Reten. Pol. Filtering"; RetenPolDeleting: Enum "Reten. Pol. Deleting"; TableFilters: JsonArray): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

*DefaultDateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of the date or datetime field used as default to determine the age of records in the table.

*MandatoryMinRetenDays ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The minimum number of days records must be kept in the table.

*RetenPolFiltering ([Enum "Reten. Pol. Filtering"]())* 

Determines the implementation used to filter records when applying retention polices.

*RetenPolDeleting ([Enum "Reten. Pol. Deleting"]())* 

Determines the implementation used to delete records when applying retention polices.

*TableFilters ([JsonArray]())* 

A JsonArray which contains the default table filters for the retention policy

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### AddTableFilterToJsonArray (Method) <a name="AddTableFilterToJsonArray"></a> 

 This helper method is used to build an array of table filters which will be inserted automatically when creating a retention policy for the allowed table.
 You must first build up the array by calling this helper function and adding all relevant table filter information before passing the JsonArray to the AddAllowedTable method.
 

#### Syntax
```
procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetentionPeriodEnum: Enum "Retention Period Enum"; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecRef: RecordRef)
```
#### Parameters
*TableFilters ([JsonArray]())* 

The JsonArray to which the table filter information will be added.

*RetentionPeriodEnum ([Enum "Retention Period Enum"]())* 

Identifies the retention period for the retention policy table filter.

*DateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of the date or datetime field used as to determine the age of records in the table.

*Enabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the retention policy line will be enabled.

*Locked ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the retention policy line will be locked. If this parameter is true, the line will also be enabled.

*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A record reference containing the filters to be added to the retention policy setup line.

### AddTableFilterToJsonArray (Method) <a name="AddTableFilterToJsonArray"></a> 

 This helper method is used to build an array of table filters which will be inserted automatically when creating a retention policy for the allowed table.
 You must first build up the array by calling this helper function and adding all relevant table filter information before passing the JsonArray to the AddAllowedTable method.
 

#### Syntax
```
procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetPeriodCalc: DateFormula; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecRef: RecordRef)
```
#### Parameters
*TableFilters ([JsonArray]())* 

The JsonArray to which the table filter information will be added.

*RetPeriodCalc ([DateFormula]())* 

Identifies the retention period dateformula for the retention policy table filter.

*DateFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of the date or datetime field used as to determine the age of records in the table.

*Enabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the retention policy line will be enabled.

*Locked ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the retention policy line will be locked. If this parameter is true, the line will also be enabled.

*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A record reference containing the filters to be added to the retention policy setup line.

### RemoveAllowedTable (Method) <a name="RemoveAllowedTable"></a> 

 Removes a table from the list of allowed tables.
 

#### Syntax
```
procedure RemoveAllowedTable(TableId: Integer): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to remove.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the table is not in the list of allowed tables. False if the table is in the list of allowed tables.
### IsAllowedTable (Method) <a name="IsAllowedTable"></a> 

 Checks whether a table exists in the list of allowed tables.
 

#### Syntax
```
procedure IsAllowedTable(TableId: Integer): boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID to check.

#### Return Value
*[boolean]()*

True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.
### GetAllowedTables (Method) <a name="GetAllowedTables"></a> 

 Returns the allowed tables as a list.
 

#### Syntax
```
procedure GetAllowedTables(var AllowedTables: List of [Integer])
```
#### Parameters
*AllowedTables ([List of [Integer]]())* 

The allowed tables as a List.

### GetAllowedTables (Method) <a name="GetAllowedTables"></a> 

 Returns the allowed tables as a filter string.
 

#### Syntax
```
procedure GetAllowedTables(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The allowed tables as a filter string.
### GetRetenPolFiltering (Method) <a name="GetRetenPolFiltering"></a> 

 Returns the enum value set for retention policy filtering. This determines which code will handle the filtering of records when the retention policy for the allowed table is applied.
 

#### Syntax
```
procedure GetRetenPolFiltering(TableId: Integer): enum "Reten. Pol. Filtering"
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the allowed table.

#### Return Value
*[enum "Reten. Pol. Filtering"]()*

The retention policy filtering enum value.
### GetRetenPolDeleting (Method) <a name="GetRetenPolDeleting"></a> 

 Returns the enum value set for retention policy deleting. This determines which code will handle the deleting of records when the retention policy for the allowed table is applied.
 

#### Syntax
```
procedure GetRetenPolDeleting(TableId: Integer): enum "Reten. Pol. Deleting"
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the allowed table.

#### Return Value
*[enum "Reten. Pol. Deleting"]()*

The retention policy deleting enum value.
### GetDefaultDateFieldNo (Method) <a name="GetDefaultDateFieldNo"></a> 

 Returns the number of the date or datetime field in the list of allowed tables for the given table.
 

#### Syntax
```
procedure GetDefaultDateFieldNo(TableId: Integer): Integer
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the allowed table.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The field number of the date or datetime field in the allowed table.
### GetMandatoryMinimumRetentionDays (Method) <a name="GetMandatoryMinimumRetentionDays"></a> 

 Returns the mandatory minimum number of retention days for the given table.
 

#### Syntax
```
procedure GetMandatoryMinimumRetentionDays(TableId: Integer): Integer
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the allowed table.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The mandatory minimum number of retention days for the allowed table.
### CalcMinimumExpirationDate (Method) <a name="CalcMinimumExpirationDate"></a> 

 Calculates the minimum expiration date for a given allowed table based on the minimum number of retention days and today's date.
 

#### Syntax
```
procedure CalcMinimumExpirationDate(TableId: Integer): Date
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the allowed table.

#### Return Value
*[Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type)*

The minimum expiration date.

## Retention Policy Log (Codeunit 3908)

 This codeunit provides functions for logging error, warning, and informational messages to the Retention Policy Log Entry table.
 

### LogError (Method) <a name="LogError"></a> 

 LogError will create an entry in the Retention Policy Log Entry table with Message Type set to Error.
 An error message will be displayed to the user and any changes in the current transaction will be reverted.
 

#### Syntax
```
procedure LogError(Category: Enum "Retention Policy Log Category"; Message: Text[2048])
```
#### Parameters
*Category ([Enum "Retention Policy Log Category"]())* 

The category for which to log the message.

*Message ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The message to log.

### LogError (Method) <a name="LogError"></a> 

 LogError will create an entry in the Retention Policy Log Entry table with Message Type set to Error.
 If DisplayError is true, an error message will be displayed to the user and any changes in the current transaction will be rolled back.
 If DisplayError is false, no error is displayed, the code continues to run, and no changes are reverted.
 

#### Syntax
```
procedure LogError(Category: Enum "Retention Policy Log Category"; Message: Text[2048]; DisplayError: Boolean)
```
#### Parameters
*Category ([Enum "Retention Policy Log Category"]())* 

The category for which to log the message.

*Message ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The message to log.

*DisplayError ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether the error is displayed.

### LogWarning (Method) <a name="LogWarning"></a> 

 LogWarning will create an entry in the Retention Policy Log Entry table with Message Type set to Warning. No message is displayed to the user.
 

#### Syntax
```
procedure LogWarning(Category: Enum "Retention Policy Log Category"; Message: Text[2048])
```
#### Parameters
*Category ([Enum "Retention Policy Log Category"]())* 

The category for which to log the message.

*Message ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The message to log.

### LogInfo (Method) <a name="LogInfo"></a> 

 LogInfo will create an entry in the Retention Policy Log Entry table with Message Type set to Info. No message is displayed to the user.
 

#### Syntax
```
procedure LogInfo(Category: Enum "Retention Policy Log Category"; Message: Text[2048])
```
#### Parameters
*Category ([Enum "Retention Policy Log Category"]())* 

The category for which to log the message.

*Message ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The message to log.


## Retention Policy Setup (Codeunit 3902)

 This codeunit contains helper methods for retention policy setups.
 

### SetTableFilterView (Method) <a name="SetTableFilterView"></a> 

 Use this procedure to open a Filter Page Builder page and store the resulting filter in view format on the retention policy setup line.
 

#### Syntax
```
procedure SetTableFilterView(var RetentionPolicySetupLine: record "Retention Policy Setup Line"): Text[2048]
```
#### Parameters
*RetentionPolicySetupLine ([record "Retention Policy Setup Line"]())* 

The record where the filter is stored.

#### Return Value
*[Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The filter in Text format.
### GetTableFilterView (Method) <a name="GetTableFilterView"></a> 

 Use this procedure to get the filter that is stored in a view format on the retention policy setup line.
 

#### Syntax
```
procedure GetTableFilterView(RetentionPolicySetupLine: record "Retention Policy Setup Line"): Text
```
#### Parameters
*RetentionPolicySetupLine ([record "Retention Policy Setup Line"]())* 

The record where the filter is stored.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The filter in View format.
### GetTableFilterText (Method) <a name="GetTableFilterText"></a> 

 Use this procedure to get the filter that is stored in a text format on the retention policy setup line.
 

#### Syntax
```
procedure GetTableFilterText(RetentionPolicySetupLine: Record "Retention Policy Setup Line"): Text[2048]
```
#### Parameters
*RetentionPolicySetupLine ([Record "Retention Policy Setup Line"]())* 

The record where the filter is stored.

#### Return Value
*[Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The Filter in text format.
### TableIdLookup (Method) <a name="TableIdLookup"></a> 

 Use this procedure to open a lookup page to select one of the allowed Table Id's.
 

#### Syntax
```
procedure TableIdLookup(TableId: Integer): Integer
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The currently stored Table ID. This value will be selected when you open the lookup.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The new selected table id.
### DateFieldNoLookup (Method) <a name="DateFieldNoLookup"></a> 

 Use this procedure to open a lookup page to select one of the date or datetime fields for the given table.
 

#### Syntax
```
procedure DateFieldNoLookup(TableId: Integer; FieldNo: Integer): Integer
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID for which you want to select a field number.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The currently selected field number.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The new selected field number.
### IsRetentionPolicyEnabled (Method) <a name="IsRetentionPolicyEnabled"></a> 

 This procedure checks whether any retention policies are enabled.
 

#### Syntax
```
procedure IsRetentionPolicyEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if a retention policy is enabled. False if no retention policies are enabled.
### IsRetentionPolicyEnabled (Method) <a name="IsRetentionPolicyEnabled"></a> 

 This procedure checks whether a retention policy is enabled for the given table ID.
 

#### Syntax
```
procedure IsRetentionPolicyEnabled(TableId: Integer): Boolean
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table that will be checked for an enabled retention policy.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if a retention policy is enabled for the table ID. False if no retention policy is enabled for the table ID.

## Retention Periods (Page 3900)

 List page that contains all of the retention periods that have been defined.
 


## Retention Policy Log Entries (Page 3904)

 Lists the entries in the Retention Policy Log.
 


## Reten. Policy Setup ListPart (Page 3905)

 This page lists all of the retention policies that have been defined.
 


## Retention Policy Setup Card (Page 3901)

 This page shows the retention policy setup.
 


## Retention Policy Setup Lines (Page 3902)

 This page shows the retention policy setup lines. Each line defines a subset of records in a table for which you can set a separate retention period.
 


## Retention Policy Setup List (Page 3903)

 This page lists all of the retention policies that have been defined.
 


## Reten. Pol. Deleting (Enum 3904)

 This enum is used to determine the implementation codeunit called to delete expired records when applying a retention policy.
 

### Default (value: 0)


 The default implementation.
 


## Reten. Pol. Filtering (Enum 3903)

 This enum is used to determine the implementation codeunit called when filtering a table for expired records when applying a retention policy.
 

### Default (value: 0)


 The default implementation.
 


## Retention Period Enum (Enum 3900)

 Enum that defines standard retention periods.
 

### Never Delete (value: 0)


 The "Never Delete" value results in a retention period where records are never removed.
 

### Custom (value: 1)


 The Custom value can be used to create user defined retention periods.
 

### 1 Week (value: 2)


 The "1 Week" value results in a retention period where records that are older than seven days are deleted.
 

### 1 Month (value: 3)


 The "1 Month" value results in a retention period where records that are older than one month are deleted.
 

### 3 Months (value: 4)


 The "3 Months" value results in a retention period where records that are older than three months are deleted.
 

### 6 Months (value: 5)


 The "6 Months" value results in a retention period where records that are older than six months are deleted.
 

### 1 Year (value: 6)


 The "1 Year" value results in a retention period where records that are older than one year are deleted.
 

### 5 Years (value: 7)


 The "5 Years" value results in a retention period where records that are older than five years are deleted.
 

### 28 Days (value: 8)


 The "28 Days" value results in a retention period where records that are older than twenty-eight days are deleted.
 


## Retention Policy Log Category (Enum 3901)

 The Retention Policy Log Category is used to categorize log entries by area.
 

### Retention Policy - Allowed Tables (value: 0)

Category used for creating log entries concerning allowed tables.

### Retention Policy - Period (value: 1)

Category used for creating log entries concerning retention period.

### Retention Policy - Setup (value: 2)

Category used for creating log entries concerning retention policy setup.

### Retention Policy - Apply (value: 3)

Category used for creating log entries concerning applying retention policies.


## Retention Policy Log Message Type (Enum 3902)

 Specifies the type of log message.
 

### Error (value: 0)

Message type used for creating log entries of type Error

### Warning (value: 1)

Message type used for creating log entries of type Warning

### Info (value: 2)

Message type used for creating log entries of type Info

