This module provides methods for retrieving server configuration settings.

Use this module to do the following:

- Check whether the Excel add-in is installed.

For on-premises versions, you can also use this module to do the following:

- Check whether online extensions can be installed.
- Check whether the API services are enabled.
- Check whether the API subscriptions are enabled.
- Get the timeout for notifications sent by API subscriptions.
- Get the maximum number of notifications that API subscriptions can send.
- Gets the delay when starting to process API subscriptions.


# Public Objects
## Server Setting (Codeunit 6723)

 Exposes functionality to fetch some application server settings for the server which hosts the current tenant.
 

### GetEnableSaaSExtensionInstallSetting (Method) <a name="GetEnableSaaSExtensionInstallSetting"></a> 
Checks whether online extensions can be installed on the server.

Gets the value of the server setting EnableSaasExtensionInstallConfigSetting.

#### Syntax
```
[Scope('OnPrem')]
procedure GetEnableSaaSExtensionInstallSetting(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True, if they can be installed; otherwise, false.
### GetIsSaasExcelAddinEnabled (Method) <a name="GetIsSaasExcelAddinEnabled"></a> 
Checks whether Excel add-in is enabled on the server.

Gets the value of the server setting IsSaasExcelAddinEnabled.

#### Syntax
```
procedure GetIsSaasExcelAddinEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetApiServicesEnabled (Method) <a name="GetApiServicesEnabled"></a> 
Checks whether the API Services are enabled.

Gets the value of the server setting ApiServicesEnabled.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiServicesEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetApiSubscriptionsEnabled (Method) <a name="GetApiSubscriptionsEnabled"></a> 
Checks whether the API subscriptions are enabled.

Gets the value of the server setting ApiSubscriptionsEnabled.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionsEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetApiSubscriptionSendingNotificationTimeout (Method) <a name="GetApiSubscriptionSendingNotificationTimeout"></a> 
Gets the timeout for the notifications sent by API subscriptions.

Gets the value of the server setting ApiSubscriptionSendingNotificationTimeout.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionSendingNotificationTimeout(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The timeout value in milliseconds.
### GetApiSubscriptionMaxNumberOfNotifications (Method) <a name="GetApiSubscriptionMaxNumberOfNotifications"></a> 
Gets the maximum number of notifications that API subscriptions can send.

Gets the value of the server setting ApiSubscriptionMaxNumberOfNotifications.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionMaxNumberOfNotifications(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The maximum number of notifications that can be sent.
### GetApiSubscriptionDelayTime (Method) <a name="GetApiSubscriptionDelayTime"></a> 
Gets the delay when starting to process API subscriptions.

Gets the value of the server setting ApiSubscriptionDelayTime.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionDelayTime(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The time value in milliseconds.
### GetTestAutomationEnabled (Method) <a name="GetTestAutomationEnabled"></a> 
Checks whether the Test Automation is enabled.

Gets the value of the server setting TestAutomationEnabled.

#### Syntax
```
[Scope('OnPrem')]
procedure GetTestAutomationEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetUsePermissionSetsFromExtensions (Method) <a name="GetUsePermissionSetsFromExtensions"></a> 
Checks whether permissions are read from the permission table in SQL or from metadata (.al code)

Gets the value of the server setting UsePermissionSetsFromExtensions.

#### Syntax
```
procedure GetUsePermissionSetsFromExtensions(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetEnableMembershipEntitlement (Method) <a name="GetEnableMembershipEntitlement"></a> 
Checks whether Entitlements are enabled

Gets the value of the server setting EnableMembershipEntitlement.

#### Syntax
```
procedure GetEnableMembershipEntitlement(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise false.
