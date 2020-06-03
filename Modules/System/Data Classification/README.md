This module provides functionality for handling data classification for objects that might contain sensitive information.

Use this module to do the following:
- create an entry in the Data Sensitivity table for every field in the database that might contain sensitive information 
- set the data sensitivity for a given field 
- synchronize the Data Sensitivity and Field tables by introducing new entries in the Data Sensitivity table for every new entry in the Field table 
- query on whether or not all the fields are classified 
- query on whether or not the Data Sensitivity table is empty for the current company 
- insert a new Data Sensitivity entry in the database for a given field 
- insert a new Data Privacy Entities entry in the database for a given table 
- get the date when the Field and Data Sensitivity tables have last been synchronized 
- raise an event to retrieve all the Data Privacy Entities 

# Public Objects
## Data Privacy Entities (Table 1180)

 Displays a list of data privacy entities.
 


## Data Classification Mgt. (Codeunit 1750)

 Exposes functionality to handle data classification tasks.
 

### PopulateDataSensitivityTable (Method) <a name="PopulateDataSensitivityTable"></a> 

 Creates an entry in the Data Sensitivity table for every field in the database that is classified as Customer Content,
 End User Identifiable Information (EUII), or End User Pseudonymous Identifiers (EUPI).
 

#### Syntax
```
procedure PopulateDataSensitivityTable()
```
### SetDefaultDataSensitivity (Method) <a name="SetDefaultDataSensitivity"></a> 

 Updates the Data Sensitivity table with the default data sensitivities for all the fields of all the tables
 in the DataPrivacyEntities record.
 

#### Syntax
```
procedure SetDefaultDataSensitivity(var DataPrivacyEntities: Record "Data Privacy Entities")
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 

The variable that is used to update the Data Sensitivity table.

### SetSensitivities (Method) <a name="SetSensitivities"></a> 

 For each Data Sensitivity entry, it sets the value of the "Data Sensitivity" field to the Sensitivity option.
 

#### Syntax
```
procedure SetSensitivities(var DataSensitivity: Record "Data Sensitivity"; Sensitivity: Option)
```
#### Parameters
*DataSensitivity ([Record "Data Sensitivity"]())* 

The record that gets updated

*Sensitivity ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The option that the "Data Sensitivity" field gets updated to.

### SyncAllFields (Method) <a name="SyncAllFields"></a> 

 Synchronizes the Data Sensitivity table with the Field table. It inserts new values in the Data Sensitivity table for the
 fields that the Field table contains and the Data Sensitivity table does not and it deletes the unclassified fields from
 the Data Sensitivity table that the Field table does not contain.
 

#### Syntax
```
procedure SyncAllFields()
```
### GetDataSensitivityOptionString (Method) <a name="GetDataSensitivityOptionString"></a> 

 Gets the values that the "Data Sensitivity" field of the Data Sensitivity table can contain.
 

#### Syntax
```
procedure GetDataSensitivityOptionString(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


 A Text value representing the values that the "Data Sensitivity" field of the Data Sensitivity table can contain.
 
### SetTableFieldsToNormal (Method) <a name="SetTableFieldsToNormal"></a> 

 Sets the data sensitivity to normal for all fields in the table with the ID TableNumber.
 

#### Syntax
```
procedure SetTableFieldsToNormal(TableNumber: Integer)
```
#### Parameters
*TableNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table in which the field sensitivities will be set to normal.

### SetFieldToPersonal (Method) <a name="SetFieldToPersonal"></a> 

 Sets the data sensitivity to personal for the field with the ID FieldNo from the table with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToPersonal(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### SetFieldToSensitive (Method) <a name="SetFieldToSensitive"></a> 

 Sets the data sensitivity to sensitive for the field with the ID FieldNo from the table with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToSensitive(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### SetFieldToCompanyConfidential (Method) <a name="SetFieldToCompanyConfidential"></a> 

 Sets the data sensitivity to company confidential for the field with the ID FieldNo from the table
 with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToCompanyConfidential(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### SetFieldToNormal (Method) <a name="SetFieldToNormal"></a> 

 Sets the data sensitivity to normal for the field with the ID FieldNo from the table with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToNormal(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### DataPrivacyEntitiesExist (Method) <a name="DataPrivacyEntitiesExist"></a> 

 Checks whether any of the data privacy entity tables (Customer, Vendor, Employee, and so on) contain entries.
 

#### Syntax
```
procedure DataPrivacyEntitiesExist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there are any entries and false otherwise.
### AreAllFieldsClassified (Method) <a name="AreAllFieldsClassified"></a> 

 Checks whether the Data Sensitivity table contains any unclassified entries.
 

#### Syntax
```
procedure AreAllFieldsClassified(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there are any unclassified entries and false otherwise.
### IsDataSensitivityEmptyForCurrentCompany (Method) <a name="IsDataSensitivityEmptyForCurrentCompany"></a> 

 Checks whether the Data Sensitivity table contains any entries for the current company.
 

#### Syntax
```
procedure IsDataSensitivityEmptyForCurrentCompany(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there are any entries and false otherwise.
### InsertDataSensitivityForField (Method) <a name="InsertDataSensitivityForField"></a> 

 Inserts a new entry in the Data Sensitivity table for the specified table ID, field ID and with the given
 data sensitivity option (some of the values that the option can have are normal, sensitive and personal).
 

#### Syntax
```
procedure InsertDataSensitivityForField(TableNo: Integer; FieldNo: Integer; DataSensitivityOption: Option)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

*DataSensitivityOption ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The data sensitivity option

### InsertDataPrivacyEntity (Method) <a name="InsertDataPrivacyEntity"></a> 

 Inserts a new Data Privacy Entity entry in a record.
 

#### Syntax
```
procedure InsertDataPrivacyEntity(var DataPrivacyEntities: Record "Data Privacy Entities"; TableNo: Integer; PageNo: Integer; KeyFieldNo: Integer; EntityFilter: Text; PrivacyBlockedFieldNo: Integer)
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 

The record that the entry gets inserted into.

*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The entity's table ID.

*PageNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The entity's page ID.

*KeyFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The entity's primary key ID.

*EntityFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The entity's ID.

*PrivacyBlockedFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

If the entity has a Privacy Blocked field, then the field's ID; otherwise 0.

### GetLastSyncStatusDate (Method) <a name="GetLastSyncStatusDate"></a> 

 Gets the last date when the Data Sensitivity and Field tables where synchronized.
 

#### Syntax
```
procedure GetLastSyncStatusDate(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The last date when the Data Sensitivity and Field tables where synchronized.
### RaiseOnGetDataPrivacyEntities (Method) <a name="RaiseOnGetDataPrivacyEntities"></a> 

 Raises an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
 Throws an error when it is not called with a temporary record.
 

#### Syntax
```
procedure RaiseOnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 


 The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
 

### OnGetDataPrivacyEntities (Event) <a name="OnGetDataPrivacyEntities"></a> 

 Publishes an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 


 The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
 

### OnCreateEvaluationData (Event) <a name="OnCreateEvaluationData"></a> 

 Publishes an event that allows subscribers to create evaluation data.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnCreateEvaluationData()
```
### OnShowSyncFieldsNotification (Event) <a name="OnShowSyncFieldsNotification"></a> 

 Publishes an event that allows subscribers to show a notification that calls for users to synchronize their
 Data Sensitivity and Field tables.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnShowSyncFieldsNotification()
```

## Data Classification Wizard (Page 1752)

 Exposes functionality that allows users to classify their data.
 

### ResetControls (Method) <a name="ResetControls"></a> 

 Resets the buttons on the page, enabling and disabling them according to the current step.
 

#### Syntax
```
procedure ResetControls()
```
### ShouldEnableNext (Method) <a name="ShouldEnableNext"></a> 

 Queries on whether or not the Next button should be enabled.
 

#### Syntax
```
procedure ShouldEnableNext(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Next button should be enabled and false otherwise.
### SetExportModeSelected (Method) <a name="SetExportModeSelected"></a> 

 Setter for the IsExportModeSelectedValue.
 

#### Syntax
```
procedure SetExportModeSelected(Value: Boolean)
```
#### Parameters
*Value ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The Value to set.

### SetExpertModeSelected (Method) <a name="SetExpertModeSelected"></a> 

 Setter for the IsExpertModeSelectedValue.
 

#### Syntax
```
procedure SetExpertModeSelected(Value: Boolean)
```
#### Parameters
*Value ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The Value to set.

### SetImportModeSelected (Method) <a name="SetImportModeSelected"></a> 

 Setter for the SetImportModeSelected.
 

#### Syntax
```
procedure SetImportModeSelected(Value: Boolean)
```
#### Parameters
*Value ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The Value to set.

### NextStep (Method) <a name="NextStep"></a> 

 Selects the next step.
 

#### Syntax
```
procedure NextStep(Backward: Boolean)
```
#### Parameters
*Backward ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A boolean value that specifies if the next step should be to go back.

### CheckMandatoryActions (Method) <a name="CheckMandatoryActions"></a> 

 Displays errors if the preconditions for an action are not met.
 

#### Syntax
```
procedure CheckMandatoryActions()
```
### IsNextEnabled (Method) <a name="IsNextEnabled"></a> 

 Queries on whether the Next button is enabled.
 

#### Syntax
```
procedure IsNextEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Next button is enabled and false otherwise.
### GetStep (Method) <a name="GetStep"></a> 

 Gets the current step.
 

#### Syntax
```
procedure GetStep(): Option

```
#### Return Value
*[Option
]()*

The current step.
### SetStep (Method) <a name="SetStep"></a> 

 Sets the current step.
 

#### Syntax
```
procedure SetStep(StepValue: Option)
```
#### Parameters
*StepValue ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The new value of the current step.

### IsImportModeSelected (Method) <a name="IsImportModeSelected"></a> 

 Queries on whether import mode is selected.
 

#### Syntax
```
procedure IsImportModeSelected(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if import mode is selected and false otherwise.
### IsExportModeSelected (Method) <a name="IsExportModeSelected"></a> 

 Queries on whether export mode is selected.
 

#### Syntax
```
procedure IsExportModeSelected(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if export mode is selected and false otherwise.
### IsExpertModeSelected (Method) <a name="IsExpertModeSelected"></a> 

 Queries on whether expert mode is selected.
 

#### Syntax
```
procedure IsExpertModeSelected(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if expert mode is selected and false otherwise.
### GetLedgerEntriesDefaultClassification (Method) <a name="GetLedgerEntriesDefaultClassification"></a> 

 Gets the default classification for ledger entries.
 

#### Syntax
```
procedure GetLedgerEntriesDefaultClassification(): Option

```
#### Return Value
*[Option
]()*

The default classification for ledger entries.
### GetTemplatesDefaultClassification (Method) <a name="GetTemplatesDefaultClassification"></a> 

 Gets the default classification for templates.
 

#### Syntax
```
procedure GetTemplatesDefaultClassification(): Option

```
#### Return Value
*[Option
]()*

The default classification for templates.
### GetSetupTablesDefaultClassification (Method) <a name="GetSetupTablesDefaultClassification"></a> 

 Gets the default classification for setup tables.
 

#### Syntax
```
procedure GetSetupTablesDefaultClassification(): Option

```
#### Return Value
*[Option
]()*

The default classification for setup tables.

## Data Classification Worksheet (Page 1751)

 Exposes functionality that allows users to classify their data.
 


## Field Content Buffer (Page 1753)

 Displays a list of field content buffers.
 


## Field Data Classification (Page 1750)

 Displays a list of fields and their corresponding data classifications.
 

