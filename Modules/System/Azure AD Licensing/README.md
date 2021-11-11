Provides a way to access information about the subscribed SKUs and the corresponding service plans. It uses two collections: one that stores the subscribed SKUs and the other that stores the corresponding service plans of the SKU that we currently point to in the collection. ResetSubscribedSKU and ResetServicePlans will set the enumerators to the initial position. Use NextSubscribedSKU to advance the enumerator to the next subscribed SKU in the collection and NextServicePlan to advance to the next service plan of the SKU that the enumerator currently points to. 
You can specify whether to include unknown plans by using the SetIncludeUnknownPlans function.

Usage examples:
```
procedure GetSKUs()
var
    SKU: Record "YOUR SKU TABLE";
    AzureADLic: codeunit "Azure AD Licensing";
begin
    while AzureADLic.NextSubscribedSKU() do begin
        SKU.id := AzureADLic.SubscribedSKUId();
        SKU.PartNumber := AzureADLic.SubscribedSKUPartNumber();
        SKU.PrepaidUnitsInEnabledState := AzureADLic.SubscribedSKUPrepaidUnitsInEnabledState();
        SKU.ConsumedUnits := AzureADLic.SubscribedSKUConsumedUnits();
        SKU.insert();
    end;
end;
procedure GetPlansBySKUs()
var
    Plan: Record "YOUR PLAN TABLE";
    AzureADLic: codeunit "Azure AD Licensing";
begin
    while AzureADLic.NextSubscribedSKU() do begin
        AzureADLic.ResetServicePlans();
        while AzureADLic.NextServicePlan() do begin
            Plan.ServicePlanId := AzureADLic.ServicePlanId();
            Plan.ServicePlanName := AzureADLic.ServicePlanName();
            Plan.SKUId := AzureADLic.SubscribedSKUId();
            Plan.insert();
        end;
    end;
end;
```

# Public Objects
## Azure AD Licensing (Codeunit 458)

 Access information about the subscribed SKUs and the corresponding service plans.
 You can retrieve information such as the SKU Object ID, SKU ID, number of licenses assigned, the license state (enabled, suspended, or warning), and the SKU part number.
 For the corresponding service plans, you can retrieve the ID, the capability status, or the name.
 

### ResetSubscribedSKU (Method) <a name="ResetSubscribedSKU"></a> 

 Sets the enumerator for the subscribed SKUs to its initial position, which is before the first subscribed SKU in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure ResetSubscribedSKU(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the enumerator was successfully reset and otherwise false.
### NextSubscribedSKU (Method) <a name="NextSubscribedSKU"></a> 

 Advances the enumerator to the next subscribed SKU in the collection. If only known service plans should be included, it advances to the next SKU known in Business Central.
 

#### Syntax
```
[NonDebuggable]
procedure NextSubscribedSKU(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the enumerator was successfully advanced to the next SKU; false if the enumerator has passed the end of the collection.
### SubscribedSKUCapabilityStatus (Method) <a name="SubscribedSKUCapabilityStatus"></a> 

 Gets the capability status of the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUCapabilityStatus(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The capability status of the subscribed SKU, or an empty string if the subscribed SKUs enumerator was not initialized.
### SubscribedSKUConsumedUnits (Method) <a name="SubscribedSKUConsumedUnits"></a> 

 Gets the number of licenses assigned to the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUConsumedUnits(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

 The number of licenses that are assigned to the subscribed SKU, or 0 if the subscribed SKUs enumerator was not initialized.
### SubscribedSKUObjectId (Method) <a name="SubscribedSKUObjectId"></a> 

 Gets the object ID of the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUObjectId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The object ID of the current SKU. If the subscribed SKUs enumerator was not initialized, it will return an empty string.
### SubscribedSKUPrepaidUnitsInEnabledState (Method) <a name="SubscribedSKUPrepaidUnitsInEnabledState"></a> 

 Gets the number of prepaid licenses that are enabled for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUPrepaidUnitsInEnabledState(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

 The number of prepaid licenses that are enabled for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.
### SubscribedSKUPrepaidUnitsInSuspendedState (Method) <a name="SubscribedSKUPrepaidUnitsInSuspendedState"></a> 

 Gets the number of prepaid licenses that are suspended for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUPrepaidUnitsInSuspendedState(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of prepaid licenses that are suspended for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.
### SubscribedSKUPrepaidUnitsInWarningState (Method) <a name="SubscribedSKUPrepaidUnitsInWarningState"></a> 

 Gets the number of prepaid licenses that are in warning status for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUPrepaidUnitsInWarningState(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

 The number of prepaid licenses that are in warning status for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.
### SubscribedSKUId (Method) <a name="SubscribedSKUId"></a> 

 Gets the unique identifier (GUID) for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The unique identifier (GUID) of the subscribed SKU; empty string if the subscribed SKUs enumerator was not initialized.
### SubscribedSKUPartNumber (Method) <a name="SubscribedSKUPartNumber"></a> 

 Gets the part number of the subscribed SKU that the enumerator is currently pointing to in the collection. For example, "AAD_PREMIUM" OR "RMSBASIC."
 

#### Syntax
```
[NonDebuggable]
procedure SubscribedSKUPartNumber(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The part number of the subscribed SKU or an empty string if the subscribed SKUs enumerator was not initialized.
### ResetServicePlans (Method) <a name="ResetServicePlans"></a> 

 Sets the enumerator for service plans to its initial position, which is before the first service plan in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure ResetServicePlans()
```
### NextServicePlan (Method) <a name="NextServicePlan"></a> 

 Advances the enumerator to the next service plan in the collection.
 

#### Syntax
```
[NonDebuggable]
procedure NextServicePlan(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the enumerator was successfully advanced to the next service plan; false if the enumerator has passed the end of the collection or it was not initialized.
### ServicePlanCapabilityStatus (Method) <a name="ServicePlanCapabilityStatus"></a> 

 Gets the service plan capability status.
 

#### Syntax
```
[NonDebuggable]
procedure ServicePlanCapabilityStatus(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The capability status of the service plan, or an empty string if the service plan enumerator was not initialized.
### ServicePlanId (Method) <a name="ServicePlanId"></a> 

 Gets the service plan ID.
 

#### Syntax
```
[NonDebuggable]
procedure ServicePlanId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The ID of the service plan, or an empty string if the service plan enumerator was not initialized.
### ServicePlanName (Method) <a name="ServicePlanName"></a> 

 Gets the service plan name.
 

#### Syntax
```
[NonDebuggable]
procedure ServicePlanName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The name of the service plan, or an empty string if the service plan enumerator was not initialized.
### IncludeUnknownPlans (Method) <a name="IncludeUnknownPlans"></a> 

 Checks whether to include unknown plans when moving to the next subscribed SKU in the subscribed SKUs collection.
 

#### Syntax
```
[NonDebuggable]
procedure IncludeUnknownPlans(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the unknown service plans should be included. Otherwise, false.
### SetIncludeUnknownPlans (Method) <a name="SetIncludeUnknownPlans"></a> 

 Sets whether to include unknown plans when moving to the next subscribed SKU in subscribed SKUs collection.
 

#### Syntax
```
[NonDebuggable]
procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
```
#### Parameters
*IncludeUnknownPlans ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.

### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets a flag that is used to determine whether a test is in progress or not.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure SetTestInProgress(TestInProgress: Boolean)
```
#### Parameters
*TestInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.

