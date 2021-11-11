Provides functionality for emitting telemetry about feature usage and uptake.
Various common custom dimensions are added to each message (e. g. caller app name and version, client type, environment type etc). This telemetry can then be processed to gain insights into how features are performing and how to improve them.
# Public Objects
## Feature Telemetry (Codeunit 8703)

 Provides functionality for emitting telemetry in a universal format.
 

Only system metadata and end user pseudonymous identifiers are to be emitted through this codeunit.

### LogUsage (Method) <a name="LogUsage"></a> 
FeatureTelemetry.LogUsage('0000XYZ', 'Emailing', 'Email sent');


 Sends telemetry about feature usage.
 

#### Syntax
```
procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text)
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*EventName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the event.

### LogUsage (Method) <a name="LogUsage"></a> 

 TranslationHelper.SetGlobalLanguageToDefault();
 CustomDimensions.Add('JobQueueObjectType', Format(JobQueueEntry."Object Type to Run"));
 CustomDimensions.Add('JobQueueObjectId', Format(JobQueueEntry."Object ID to Run"));
 FeatureTelemetry.LogUsage('0000XYZ', 'Job Queue', 'Job executed', CustomDimensions);
 TranslationHelper.RestoreGlobalLanguage();
 


 Sends telemetry about feature usage.
 

Custom dimensions often contain infromation translated in different languages. It is a common practice to send telemetry in the default language (see example).

#### Syntax
```
procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text; CustomDimensions: Dictionary of [Text, Text])
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*EventName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the event.

*CustomDimensions ([Dictionary of [Text, Text]]())* 

A dictionary containing additional information about the event.

### LogError (Method) <a name="LogError"></a> 

 if not Success then
     FeatureTelemetry.LogError('0000XYZ', 'Retention policies', 'Applying a policy', GetLastErrorText(true));
 


 Sends telemetry about errors happening during feature usage.
 

#### Syntax
```
procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text)
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the error.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*EventName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the event.

*ErrorText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text of the error.

### LogError (Method) <a name="LogError"></a> 

 if not Success then
     FeatureTelemetry.LogError('0000XYZ', 'Configuration packages', 'Importing a package', GetLastErrorText(true), GetLastErrorCallStack());
 


 Sends telemetry about errors happening during feature usage.
 

#### Syntax
```
procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text; ErrorCallStack: Text)
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the error.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*EventName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the event.

*ErrorText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text of the error.

*ErrorCallStack ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The error call stack.

### LogError (Method) <a name="LogError"></a> 

 if not Success then begin
     TranslationHelper.SetGlobalLanguageToDefault();
     CustomDimensions.Add('UpdateEntity', Format(AzureADUserUpdateBuffer."Update Entity"));
     FeatureTelemetry.LogError('0000XYZ', 'User management', 'Syncing users with M365', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
     TranslationHelper.RestoreGlobalLanguage();
 end;
 


 Sends telemetry about errors happening during feature usage.
 

Custom dimensions often contain infromation translated in different languages. It is a common practice to send telemetry in the default language (see example).

#### Syntax
```
procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text; ErrorCallStack: Text; CustomDimensions: Dictionary of [Text, Text])
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the error.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*EventName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the event.

*ErrorText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text of the error.

*ErrorCallStack ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The error call stack.

*CustomDimensions ([Dictionary of [Text, Text]]())* 

A dictionary containing additional information about the error.

### LogUptake (Method) <a name="LogUptake"></a> 

 Sends telemetry about feature uptake.
 


 This method may perform database write transactions, therefore it should not be used from within try functions.
 Expected feature uptake transitions:
 "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
 *Any state* -> "Undiscovered" (to reset the feature uptake status)
 

#### Syntax
```
procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status")
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*FeatureUptakeStatus ([Enum "Feature Uptake Status"]())* 

The new status of the feature uptake.

### LogUptake (Method) <a name="LogUptake"></a> 

 Sends telemetry about feature uptake.
 


 This method may perform database write transactions, therefore it should not be used from within try functions.
 Expected feature uptake transitions:
 "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
 *Any state* -> "Undiscovered" (to reset the feature uptake status)
 

#### Syntax
```
procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean)
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*FeatureUptakeStatus ([Enum "Feature Uptake Status"]())* 

The new status of the feature uptake.

*IsPerUser ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.

### LogUptake (Method) <a name="LogUptake"></a> 

 Sends telemetry about feature uptake.
 


 This method may perform database write transactions, therefore it should not be used from within try functions.
 Expected feature uptake transitions:
 "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
 *Any state* -> "Undiscovered" (to reset the feature uptake status)
 

#### Syntax
```
procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; CustomDimensions: Dictionary of [Text, Text])
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*FeatureUptakeStatus ([Enum "Feature Uptake Status"]())* 

The new status of the feature uptake.

*IsPerUser ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.

*CustomDimensions ([Dictionary of [Text, Text]]())* 

A dictionary containing additional information about the event.

### LogUptake (Method) <a name="LogUptake"></a> 

 Sends telemetry about feature uptake.
 


 This method may perform database write transactions, therefore it should not be used from within try functions, unless PerformWriteTransactionsInASeparateSession is true.
 Expected feature uptake transitions:
 "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
 *Any state* -> "Undiscovered" (to reset the feature uptake status)
 

#### Syntax
```
procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; PerformWriteTransactionsInASeparateSession: Boolean)
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*FeatureUptakeStatus ([Enum "Feature Uptake Status"]())* 

The new status of the feature uptake.

*IsPerUser ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.

*PerformWriteTransactionsInASeparateSession ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if database write transactions should be performed in a separate background session.

### LogUptake (Method) <a name="LogUptake"></a> 

 Sends telemetry about feature uptake.
 


 This method may perform database write transactions, therefore it should not be used from within try functions, unless PerformWriteTransactionsInASeparateSession is true.
 Expected feature uptake transitions:
 "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
 *Any state* -> "Undiscovered" (to reset the feature uptake status)
 

#### Syntax
```
procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; PerformWriteTransactionsInASeparateSession: Boolean; CustomDimensions: Dictionary of [Text, Text])
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*FeatureName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the feature.

*FeatureUptakeStatus ([Enum "Feature Uptake Status"]())* 

The new status of the feature uptake.

*IsPerUser ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.

*PerformWriteTransactionsInASeparateSession ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if database write transactions should be performed in a separate background session.

*CustomDimensions ([Dictionary of [Text, Text]]())* 

A dictionary containing additional information about the event.

### OnLogMessage (Event) <a name="OnLogMessage"></a> 

 Allows 3d party extensions to send feature telemetry.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnLogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; CustomDimensions: Dictionary of [Text, Text])
```
#### Parameters
*EventId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A unique ID of the event.

*Message ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Feature telemetry message.

*Verbosity ([Verbosity]())* 

Verbosity of the feature telemetry message.

*CustomDimensions ([Dictionary of [Text, Text]]())* 

A dictionary containing additional information about the event.


## Feature Telemetry Custom Dims (Codeunit 8706)

 Provides functionality for adding common custom dimensions for feature telemetry.
 

This codeunit is only intended to be used from subscribers of [OnAddCommonCustomDimensions](#OnAddCommonCustomDimensions) event.

### AddCommonCustomDimension (Method) <a name="AddCommonCustomDimension"></a> 

 Add a custom dimension for every feature telemetry message. Is used in conjunction with [OnAddCommonCustomDimensions](#OnAddCommonCustomDimensions)

#### Syntax
```
procedure AddCommonCustomDimension(CustomDimensionName: Text; CustomDimensionValue: Text)
```
#### Parameters
*CustomDimensionName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the custom dimension.

*CustomDimensionValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value of the custom dimension.

### OnAddCommonCustomDimensions (Event) <a name="OnAddCommonCustomDimensions"></a> 

 [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Telemetry Custom Dims", 'OnAddCommonCustomDimensions', '', true, true)]
 local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Feature Telemetry Custom Dims")
 begin
     Sender.AddCommonCustomDimension('CommonCustomDimension', 'Some info');
 end;
 


 Allows to provide additional custom dimensions for every feature telemetry message. Is used in conjunction with [AddCommonCustomDimensions](#AddCommonCustomDimensions).
 

Global language is set to default for the subscribers of this event.

#### Syntax
```
[IntegrationEvent(true, false)]
internal procedure OnAddCommonCustomDimensions()
```

## Feature Uptake Status (Enum 8703)

 Specifies the uptake status of an application feature.
 

### Undiscovered (value: 0)


 The feature has not been discovered.
 

### Discovered (value: 1)


 The feature has been discovered.
 

### Set up (value: 2)


 The feature has been set up.
 

### Used (value: 3)


 The feature has been used.
 

