Collection of the default subscribers to system events and corresponding overridable integration events for the SmartList Designer.
# Public Objects
## [Obsolete] Query Navigation Validation (Table 2889)

 Contains details about the results of validating Query Navigation data.
 


## [Obsolete] SmartList Designer Handler (Table 2888)

 A single-record table that can be used to handle contention between multiple subscribers of the events for the SmartList Designer.
 Consumers of the events should check this record to see if another extension is registered as the handler and then decide if they
 should execute code within their own subscriptions to these events. Likewise, consumers could set this record to register themselves
 as the handler of events.
 


## [Obsolete] Query Navigation Validation (Codeunit 2890)

 Contains helper methods for performing SmartList Designer related tasks
 

### ValidateNavigation (Method) <a name="ValidateNavigation"></a> 

 Checks that the contents of the Query Navigation record is still valid.
 

#### Syntax
```
procedure ValidateNavigation(NavigationRec: Record "Query Navigation"; var ValidationResult: Record "Query Navigation Validation"): Boolean
```
#### Parameters
*NavigationRec ([Record "Query Navigation"]())* 

The Query Navigation record to validate.

*ValidationResult ([Record "Query Navigation Validation"]())* 

A record containing the details about the results of the validation.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the record is valid; Otherwise false.
### ValidateNavigation (Method) <a name="ValidateNavigation"></a> 

 Checks if the provided Query Navigation data would result in a valid Query Navigation record.
 

#### Syntax
```
procedure ValidateNavigation(SourceQueryObjectId: Integer; TargetPageId: Integer; LinkingDataItemName: Text; var ValidationResult: Record "Query Navigation Validation"): Boolean
```
#### Parameters
*SourceQueryObjectId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the query that is the source of data for the query navigation.

*TargetPageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page that the query navigation opens.

*LinkingDataItemName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 


 The optional name of the data item within the source query that is used to generate linking filters.
 This restricts the records on the target page based on the data within the selected query row when the
 navigation item is selected.
 

*ValidationResult ([Record "Query Navigation Validation"]())* 

A record containing the details about the results of the validation.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the data represents a valid record; Otherwise false.

## [Obsolete] SmartList Designer Subscribers (Codeunit 2888)

 Collection of the default subscribers to system events and corresponding overridable integration events for the SmartList Designer.
 

### OnBeforeDefaultGetEnabled (Event) <a name="OnBeforeDefaultGetEnabled"></a> 

 Notifies that the Default Get Enabled procedure has been invoked.
 Invoked once per session, this is used to indicate if the SmartList Designer and
 associated events are supported by the consumer.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultGetEnabled(var Handled: Boolean; var Enabled: Boolean)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

*Enabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A value set by subscribers to indicate if the designer supported/enabled.

### OnBeforeDefaultOnCreateForTable (Event) <a name="OnBeforeDefaultOnCreateForTable"></a> 

 Notifies that the Default On Create For Table procedure has been invoked.
 This should open up the designer and initialize it for creating a new SmartList
 using the provided TableId to identify the intended root SmartList data item.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Obsolete('Use OnBeforeDefaultCreateNewForTableAndView instead', '17.0')]
internal procedure OnBeforeDefaultOnCreateForTable(var Handled: Boolean; TableId: Integer)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to be used for the root data item.

### OnBeforeDefaultCreateNewForTableAndView (Event) <a name="OnBeforeDefaultCreateNewForTableAndView"></a> 

 Notifies that the Default On Create For Table And View procedure has been invoked.
 This should open up the designer and initialize it for creating a new SmartList
 using the provided TableId to identify the intended root SmartList data item.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultCreateNewForTableAndView(var Handled: Boolean; TableId: Integer; ViewId: Text)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to use as the root data item.

*ViewId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

An optional view ID token that contains information about the page or view that the user was using before they opened SmartList Designer.

### OnBeforeDefaultOnEditQuery (Event) <a name="OnBeforeDefaultOnEditQuery"></a> 

 Notifies that the Default On Edit Query procedure has been invoked.
 This should open up the designer and initialize it for editing an existing
 SmartList. The provide QueryId specifies which SmartList to edit.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultOnEditQuery(var Handled: Boolean; QueryId: Text)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

*QueryId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The ID of the SmartList query that is being edited.

### OnBeforeDefaultOnInvalidQueryNavigation (Event) <a name="OnBeforeDefaultOnInvalidQueryNavigation"></a> 

 Notiifes that the Default On Invalid Query Navigation procedure has been invoked.
 This occurs when a Query Navigation action has been invoked but its definition is
 found to be invalid. Most commonly this would be a result of an extension that the
 action depended upon being uninstalled.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultOnInvalidQueryNavigation(var Handled: Boolean; Id: BigInteger)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

*Id ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The unique ID of the Query Navigation record that has become invalid.

