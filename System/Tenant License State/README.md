This module provides methods for retrieving the current state of the tenant license, and the start and end dates of the license.

Use this module to do the following:
- Get the start date or the end date of the current license.
- Check whether the license state is evaluation, trial, or suspended.
- Check whether the trial period has been extended.
- Check whether the current license is paid, suspended, or warning.

For on-premises versions, you can also use this module to extend the period for a trial license.

# Public Objects
## Tenant License State (Codeunit 2300)

 Exposes functionality to retrieve the current state of the tenant license.
 

### GetPeriod (Method) <a name="GetPeriod"></a> 

 Returns the default number of days that the tenant license can be in the current state, passed as a parameter.
 

#### Syntax
```
procedure GetPeriod(TenantLicenseState: Enum "Tenant License State"): Integer
```
#### Parameters
*TenantLicenseState ([Enum "Tenant License State"]())* 

The tenant license state.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The default number of days that the tenant license can be in the current state, passed as a parameter or -1 if a default period is not defined for the state.
### GetStartDate (Method) <a name="GetStartDate"></a> 

 Gets the start date for the current license state.
 

#### Syntax
```
procedure GetStartDate(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The start date for the current license state or a blank date if no license state is found.
### GetEndDate (Method) <a name="GetEndDate"></a> 

 Gets the end date for the current license state.
 

#### Syntax
```
procedure GetEndDate(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The end date for the current license state or a blank date if no license state is found.
### IsEvaluationMode (Method) <a name="IsEvaluationMode"></a> 

 Checks whether the current license state is evaluation.
 

#### Syntax
```
procedure IsEvaluationMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is evaluation, otherwise false.
### IsTrialMode (Method) <a name="IsTrialMode"></a> 

 Checks whether the current license state is trial.
 

#### Syntax
```
procedure IsTrialMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is trial, otherwise false.
### IsTrialSuspendedMode (Method) <a name="IsTrialSuspendedMode"></a> 

 Checks whether the trial license is suspended.
 

#### Syntax
```
procedure IsTrialSuspendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is suspended and the previous license state is trial, otherwise false.
### IsTrialExtendedMode (Method) <a name="IsTrialExtendedMode"></a> 

 Checks whether the trial license has been extended.
 

#### Syntax
```
procedure IsTrialExtendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is trial and the tenant has had at least one trial license state before, otherwise false.
### IsTrialExtendedSuspendedMode (Method) <a name="IsTrialExtendedSuspendedMode"></a> 

 Checks whether the trial license has been extended and is currently suspended.
 

#### Syntax
```
procedure IsTrialExtendedSuspendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is suspended and the tenant has had at least two trial license states before, otherwise false.
### IsPaidMode (Method) <a name="IsPaidMode"></a> 

 Checks whether the current license state is paid.
 

#### Syntax
```
procedure IsPaidMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is paid, otherwise false.
### IsPaidWarningMode (Method) <a name="IsPaidWarningMode"></a> 

 Checks whether the paid license is in warning mode.
 

#### Syntax
```
procedure IsPaidWarningMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is warning and the previous license state is paid, otherwise false.
### IsPaidSuspendedMode (Method) <a name="IsPaidSuspendedMode"></a> 

 Checks whether the paid license is suspended.
 

#### Syntax
```
procedure IsPaidSuspendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is suspended and the previous license state is paid, otherwise false.
### GetLicenseState (Method) <a name="GetLicenseState"></a> 

 Gets the the current license state.
 

#### Syntax
```
procedure GetLicenseState(): Enum "Tenant License State"
```
#### Return Value
*[Enum "Tenant License State"]()*

The the current license state.
### ExtendTrialLicense (Method) <a name="ExtendTrialLicense"></a> 

 Extends the trial license.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ExtendTrialLicense()
```

## Tenant License State (Enum 2301)

 This enum has the tenant license state types.
 

### Evaluation (value: 0)


 Specifies that the tenant license is in the evaluation state.
 

### Trial (value: 1)


 Specifies that the tenant license is in the trial state.
 

### Paid (value: 2)


 Specifies that the tenant license is in the paid state.
 

### Warning (value: 3)


 Specifies that the tenant license is in the warning state.
 This period starts after the trial period or when the tenant's subscription expires.
 

### Suspended (value: 4)


 Specifies that the tenant license is in the suspended state.
 

### Deleted (value: 5)


 Specifies that the tenant license is in the deleted state.
 

### LockedOut (value: 6)


 Specifies that the tenant license is in the locked state.
 The tenant is locked, and no one can access it.
 

