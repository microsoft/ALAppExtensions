Contains the page that enables a user to pick which new features to use.
# Public Objects
## Feature Data Update Status (Table 2610)

 Table stores feature data update status per company.
 


## Feature Data Update (Interface)

 Interface defines methods for feature data update task management.
 

### IsDataUpdateRequired (Method) <a name="IsDataUpdateRequired"></a> 

 Searches the database for data that must be updated before the feature can be enabled.
 

#### Syntax
```
procedure IsDataUpdateRequired(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

true if there is data to update
### ReviewData (Method) <a name="ReviewData"></a> 

 Opens the page showing the list of tables with counted records that require update.
 

#### Syntax
```
procedure ReviewData()
```
### UpdateData (Method) <a name="UpdateData"></a> 

 Runs the process that updates data for the feature.
 

#### Syntax
```
procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 

the feature update status record

### AfterUpdate (Method) <a name="AfterUpdate"></a> 

 Method is called after the update is complete, e.g. to complete the setup for the feature.
 

#### Syntax
```
procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 

the feature update status record

### GetTaskDescription (Method) <a name="GetTaskDescription"></a> 

 Retruns the detailed description of the data update required for the feature.
 It is shown of the "Schedule Feature Data Update" page to explain the user what is going to happen.
 

#### Syntax
```
procedure GetTaskDescription()TaskDescription: Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The process description

## Feature Data Error Handler (Codeunit 2613)

 Error handler codeunit used by the task scheduler during feature data update.
 

### OnLogError (Event) <a name="OnLogError"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
local procedure OnLogError(FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 




## Feature Management Facade (Codeunit 2611)

 This codeunit provides public functions for feature management.
 

### IsEnabled (Method) <a name="IsEnabled"></a> 

 Returns true if the feature is enabled and data update, if required, is complete.
 

#### Syntax
```
procedure IsEnabled(FeatureId: Text[50]): Boolean
```
#### Parameters
*FeatureId ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

the feature id in the system table "Feature Key"

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

if the feature is fully enabled
### AfterValidateEnabled (Method) <a name="AfterValidateEnabled"></a> 

 Updates the status in "Feature Data Update Status" records related to all companies.
 Also sends the notification reminding user to sign in again after feature is enabled/disabled.
 

#### Syntax
```
procedure AfterValidateEnabled(FeatureKey: Record "Feature Key")
```
#### Parameters
*FeatureKey ([Record "Feature Key"]())* 

the current "Feature Key" record

### GetFeatureKeyUrlForWeb (Method) <a name="GetFeatureKeyUrlForWeb"></a> 

 Gets the URL to let users try out a feature.
 The feature key for the feature to try.

#### Syntax
```
procedure GetFeatureKeyUrlForWeb(FeatureKey: Text[50]): Text
```
#### Parameters
*FeatureKey ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The feature key for the feature to try.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### GetImplementation (Method) <a name="GetImplementation"></a> 

 Returns true if the feature has an interface implementation.
 

#### Syntax
```
procedure GetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status")Implemented: Boolean
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### GetTaskDescription (Method) <a name="GetTaskDescription"></a> 

 Retrurns the result of the interface's GetTaskDescription method.
 

#### Syntax
```
procedure GetTaskDescription(FeatureDataUpdateStatus: Record "Feature Data Update Status")TaskDescription: Text
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### ReviewData (Method) <a name="ReviewData"></a> 

 Runs the interface's review data method.
 

#### Syntax
```
procedure ReviewData(FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### Update (Method) <a name="Update"></a> 

 Schedules or starts update depending on the options picked on the wizard page.
 

#### Syntax
```
procedure Update(var FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 

The current status record

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

true if user picked Update or Schedule and the task is scheduled or executed.
### CancelTask (Method) <a name="CancelTask"></a> 

 Cancels the scheduled task before it is started.
 

#### Syntax
```
procedure CancelTask(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; ClearStartDateTime: Boolean)
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



*ClearStartDateTime ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



### UpdateData (Method) <a name="UpdateData"></a> 

 Runs the interface's data updata method and updates the feature status.
 

#### Syntax
```
procedure UpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



### OnAfterUpdateData (Event) <a name="OnAfterUpdateData"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



### OnBeforeUpdateData (Event) <a name="OnBeforeUpdateData"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



### OnBeforeScheduleTask (Event) <a name="OnBeforeScheduleTask"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeScheduleTask(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var DoNotScheduleTask: Boolean; var TaskId: Guid)
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



*DoNotScheduleTask ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



*TaskId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 



### OnGetImplementation (Event) <a name="OnGetImplementation"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var FeatureDataUpdate: interface "Feature Data Update"; var ImplementedId: Text[50])
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 



*FeatureDataUpdate ([interface "Feature Data Update"]())* 



*ImplementedId ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### OnShowTaskLog (Event) <a name="OnShowTaskLog"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnShowTaskLog(FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 




## Update Feature Data (Codeunit 2612)

 Codeunit that is executed by the task scheduler during the feature data update.
 


## Feature Management (Page 2610)

 Page that enables a user to pick which new features to use
 

### OnOpenFeatureMgtPage (Event) <a name="OnOpenFeatureMgtPage"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
local procedure OnOpenFeatureMgtPage(var FeatureIDFilter: Text; var IgnoreFilter: Boolean)
```
#### Parameters
*FeatureIDFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*IgnoreFilter ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 




## Schedule Feature Data Update (Page 2612)

 Page provide the dialog where user can run or schedule the feature datat update.
 

### Set (Method) <a name="Set"></a> 

 Inserts the copy of "Feature Data Update Status" record as a temporary source of the page.
 

#### Syntax
```
procedure Set(FeatureDataUpdateStatus: Record "Feature Data Update Status")
```
#### Parameters
*FeatureDataUpdateStatus ([Record "Feature Data Update Status"]())* 

the instance of the actual record


## Upcoming Changes Factbox (Page 2611)

 Factbox part page that enables a user to learn more about upcoming changes
 


## Feature Status (Enum 2610)

 Enum defines the feature statuses.
 

### Disabled (value: 0)

### Enabled (value: 1)

### Pending (value: 2)

### Scheduled (value: 3)

### Updating (value: 4)

### Incomplete (value: 5)

### Complete (value: 6)


## Feature To Update (Enum 2611)

 The enum lists the features that require some data update.
 Text value must match the key value in the "Feature Key" table, Int value is the implementation codeunit id.
 

