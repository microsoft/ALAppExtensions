Provides an API that lets you connect email accounts to Business Central so that people can send messages without having to open their email application. The email module consists of the following main entities:

### Email Account
An email account holds the information needed to send emails from Business Central.

### Email Address Lookup
Email address lookup suggests email addresses to the user for the To, Cc and Bcc fields, and the suggestions are based on the related records of the email.

### Email Connector
An email connector is an interface for creating and managing email accounts, and sending emails. Every email account belongs to an email connector.

### Email Scenario
Email scenarios are specific business processes that involve documents or notifications. Use scenarios to seamlessly integrate email accounts with business processes.

### Email Message
Payload for every email that is being composed or already has been sent.

### Email Outbox
Holds draft emails, and emails that were not successfully sent.

### Sent Email
Holds emails that have been sent.

# Public Objects
## Email Account (Table 8902)

 A common representation of an email account.
 


## Email Outbox (Table 8888)
Holds information about draft emails and email that are about to be sent.


## Sent Email (Table 8889)
Holds information about the sent emails.

### GetMessageId (Method) <a name="GetMessageId"></a> 

 Get the message id of the sent email.
 

#### Syntax
```
procedure GetMessageId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

Message id.

## Email Related Attachment (Table 8910)

 Temporary table that holds information about attachments related to an email.
 


## Email Connector (Interface)

 An e-mail connector interface used to creating e-mail accounts and sending an e-mail.
 

### Send (Method) <a name="Send"></a> 

 Sends an e-mail using the provided account.
 

#### Syntax
```
procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message that is to be sent out.

*AccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The email account ID which is used to send out the email.

### GetAccounts (Method) <a name="GetAccounts"></a> 

 Gets the e-mail accounts registered for the connector.
 

#### Syntax
```
procedure GetAccounts(var Accounts: Record "Email Account")
```
#### Parameters
*Accounts ([Record "Email Account"]())* 

Out variable that holds the registered e-mail accounts for the connector.

### ShowAccountInformation (Method) <a name="ShowAccountInformation"></a> 

 Shows the information for an e-mail account.
 

#### Syntax
```
procedure ShowAccountInformation(AccountId: Guid)
```
#### Parameters
*AccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the e-mail account

### RegisterAccount (Method) <a name="RegisterAccount"></a> 

 Registers an e-mail account for the connector.
 

The out parameter must hold the account ID of the added account.

#### Syntax
```
procedure RegisterAccount(var Account: Record "Email Account"): Boolean
```
#### Parameters
*Account ([Record "Email Account"]())* 

Out parameter with the details of the registered Account.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an account was registered.
### DeleteAccount (Method) <a name="DeleteAccount"></a> 

 Deletes an e-mail account for the connector.
 

#### Syntax
```
procedure DeleteAccount(AccountId: Guid): Boolean
```
#### Parameters
*AccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the e-mail account

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an account was deleted.
### GetLogoAsBase64 (Method) <a name="GetLogoAsBase64"></a> 

 Provides a custom logo for the connector that shows in the Setup Email Account Guide.
 

The recomended image size is 128x128.

#### Syntax
```
procedure GetLogoAsBase64(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 encoded image.
### GetDescription (Method) <a name="GetDescription"></a> 

 Provides a more detailed description of the connector.
 

#### Syntax
```
procedure GetDescription(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A more detailed desctiption of the connector.

## Email Account (Codeunit 8894)

 Provides functionality to work with email accounts.
 

### GetAllAccounts (Method) <a name="GetAllAccounts"></a> 

 Gets all of the email accounts registered in Business Central.
 

#### Syntax
```
procedure GetAllAccounts(LoadLogos: Boolean; var Accounts: Record "Email Account" temporary)
```
#### Parameters
*LoadLogos ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Flag, used to determine whether to load the logos for the accounts.

*Accounts ([Record "Email Account" temporary]())* 

Out parameter holding the email accounts.

### GetAllAccounts (Method) <a name="GetAllAccounts"></a> 

 Gets all of the email accounts registered in Business Central.
 

#### Syntax
```
procedure GetAllAccounts(var Accounts: Record "Email Account" temporary)
```
#### Parameters
*Accounts ([Record "Email Account" temporary]())* 

Out parameter holding the email accounts.

### IsAnyAccountRegistered (Method) <a name="IsAnyAccountRegistered"></a> 

 Checks if there is at least one email account registered in Business Central.
 

#### Syntax
```
procedure IsAnyAccountRegistered(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there is any account registered in the system, otherwise - false.
### ValidateEmailAddress (Method) <a name="ValidateEmailAddress"></a> 
The email address "%1" is not valid.


 Validates an email address and throws an error if it is invalid.
 

If the provided email address is an empty string, the function will do nothing.

#### Syntax
```
[TryFunction]
procedure ValidateEmailAddress(EmailAddress: Text)
```
#### Parameters
*EmailAddress ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The email address to validate.

### ValidateEmailAddress (Method) <a name="ValidateEmailAddress"></a> 
The email address "%1" is not valid.


 Validates an email address and throws an error if it is invalid.
 

#### Syntax
```
[TryFunction]
procedure ValidateEmailAddress(EmailAddress: Text; AllowEmptyValue: Boolean)
```
#### Parameters
*EmailAddress ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The email address to validate.

*AllowEmptyValue ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether to skip the validation if the provided email address is empty.

### ValidateEmailAddresses (Method) <a name="ValidateEmailAddresses"></a> 
The email address "%1" is not valid.


 Validates email addresses and displays an error if any are invalid.
 

If the provided email address is an empty string, the function will do nothing.

#### Syntax
```
[TryFunction]
procedure ValidateEmailAddresses(EmailAddresses: Text)
```
#### Parameters
*EmailAddresses ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The email addresses to validate, separated by semicolons.

### ValidateEmailAddresses (Method) <a name="ValidateEmailAddresses"></a> 
The email address "%1" is not valid.


 Validates email addresses and displays an error if any are invalid.
 

#### Syntax
```
[TryFunction]
procedure ValidateEmailAddresses(EmailAddresses: Text; AllowEmptyValue: Boolean)
```
#### Parameters
*EmailAddresses ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The email addresses to validate, separated by semicolons.

*AllowEmptyValue ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether to skip the validation if no email address is provided.

### OnAfterValidateEmailAddress (Event) <a name="OnAfterValidateEmailAddress"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterValidateEmailAddress(EmailAddress: Text; AllowEmptyValue: Boolean)
```
#### Parameters
*EmailAddress ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*AllowEmptyValue ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 




## Email (Codeunit 8901)

 Provides functionality to create and send emails.
 

### SaveAsDraft (Method) <a name="SaveAsDraft"></a> 

 Saves a draft email in the Outbox.
 

#### Syntax
```
procedure SaveAsDraft(EmailMessage: Codeunit "Email Message")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to save.

### SaveAsDraft (Method) <a name="SaveAsDraft"></a> 

 Saves a draft email in the Outbox.
 

#### Syntax
```
procedure SaveAsDraft(EmailMessage: Codeunit "Email Message"; var EmailOutbox: Record "Email Outbox")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to save.

*EmailOutbox ([Record "Email Outbox"]())* 

The created outbox entry.

### Enqueue (Method) <a name="Enqueue"></a> 

 Enqueues an email to be sent in the background.
 

The default account will be used for sending the email.

#### Syntax
```
procedure Enqueue(EmailMessage: Codeunit "Email Message")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

### Enqueue (Method) <a name="Enqueue"></a> 

 Enqueues an email to be sent in the background.
 

#### Syntax
```
procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailScenario ([Enum "Email Scenario"]())* 

The scenario to use in order to determine the email account to use for sending the email.

### Enqueue (Method) <a name="Enqueue"></a> 

 Enqueues an email to be sent in the background.
 

Both "Account Id" and Connector fields need to be set on the  parameter.

#### Syntax
```
procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary)
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccount ([Record "Email Account" temporary]())* 

The email account to use for sending the email.

### Enqueue (Method) <a name="Enqueue"></a> 

 Enqueues an email to be sent in the background.
 

#### Syntax
```
procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email account to use for sending the email.

*EmailConnector ([Enum "Email Connector"]())* 

The email connector to use for sending the email.

### Send (Method) <a name="Send"></a> 
The email message has already been queued.


 Sends the email in the current session.
 

The default account will be used for sending the email.

#### Syntax
```
procedure Send(EmailMessage: Codeunit "Email Message"): Boolean
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the email was successfully sent; otherwise - false.
### Send (Method) <a name="Send"></a> 
The email message has already been queued.


 Sends the email in the current session.
 

#### Syntax
```
procedure Send(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"): Boolean
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailScenario ([Enum "Email Scenario"]())* 

The scenario to use in order to determine the email account to use for sending the email.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the email was successfully sent; otherwise - false.
### Send (Method) <a name="Send"></a> 
The email message has already been queued.


 Sends the email in the current session.
 

Both "Account Id" and Connector fields need to be set on the  parameter.

#### Syntax
```
procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary): Boolean
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccount ([Record "Email Account" temporary]())* 

The email account to use for sending the email.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the email was successfully sent; otherwise - false
### Send (Method) <a name="Send"></a> 
The email message has already been queued.


 Sends the email in the current session.
 

#### Syntax
```
procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"): Boolean
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email account to use for sending the email.

*EmailConnector ([Enum "Email Connector"]())* 

The email connector to use for sending the email.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the email was successfully sent; otherwise - false
### OpenInEditor (Method) <a name="OpenInEditor"></a> 

 Opens an email message in "Email Editor" page.
 

#### Syntax
```
procedure OpenInEditor(EmailMessage: Codeunit "Email Message")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

### OpenInEditor (Method) <a name="OpenInEditor"></a> 

 Opens an email message in "Email Editor" page.
 

#### Syntax
```
procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailScenario ([Enum "Email Scenario"]())* 

The scenario to use in order to determine the email account to use  on the page.

### OpenInEditor (Method) <a name="OpenInEditor"></a> 

 Opens an email message in "Email Editor" page.
 

Both "Account Id" and Connector fields need to be set on the  parameter.

#### Syntax
```
procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary)
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccount ([Record "Email Account" temporary]())* 

The email account to fill in.

### OpenInEditor (Method) <a name="OpenInEditor"></a> 

 Opens an email message in "Email Editor" page.
 

#### Syntax
```
procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email account to use on the page.

*EmailConnector ([Enum "Email Connector"]())* 

The email connector to use on the page.

### OpenInEditorModally (Method) <a name="OpenInEditorModally"></a> 

 Opens an email message in "Email Editor" page modally.
 

#### Syntax
```
procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"): Enum "Email Action"
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

#### Return Value
*[Enum "Email Action"]()*

The action that the user performed with the email message.
### OpenInEditorModally (Method) <a name="OpenInEditorModally"></a> 

 Opens an email message in "Email Editor" page modally.
 

#### Syntax
```
procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"): Enum "Email Action"
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailScenario ([Enum "Email Scenario"]())* 

The scenario to use in order to determine the email account to use  on the page.

#### Return Value
*[Enum "Email Action"]()*

The action that the user performed with the email message.
### OpenInEditorModally (Method) <a name="OpenInEditorModally"></a> 

 Opens an email message in "Email Editor" page modally.
 

Both "Account Id" and Connector fields need to be set on the  parameter.

#### Syntax
```
procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary): Enum "Email Action"
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccount ([Record "Email Account" temporary]())* 

The email account to fill in.

#### Return Value
*[Enum "Email Action"]()*

The action that the user performed with the email message.
### OpenInEditorModally (Method) <a name="OpenInEditorModally"></a> 

 Opens an email message in "Email Editor" page modally.
 

#### Syntax
```
procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"): Enum "Email Action"
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message to use as payload.

*EmailAccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email account to use on the page.

*EmailConnector ([Enum "Email Connector"]())* 

The email connector to use on the page.

#### Return Value
*[Enum "Email Action"]()*

The action that the user performed with the email message.
### GetSentEmailsForRecord (Method) <a name="GetSentEmailsForRecord"></a> 

 Gets the sent emails related to a record.


#### Syntax
```
[Obsolete('Use GetSentEmailsForRecord(TableId: Integer; SystemId: Guid; var ResultEmailOutbox: Record "Email Outbox" temporary) instead.','19.0')]
procedure GetSentEmailsForRecord(TableId: Integer; SystemId: Guid)ResultSentEmails: Record "Sent Email" temporary
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the record.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the record.

#### Return Value
*[Record "Sent Email" temporary]()*

The sent email related to a record.
### GetSentEmailsForRecord (Method) <a name="GetSentEmailsForRecord"></a> 

 Gets the sent emails related to a record.


#### Syntax
```
procedure GetSentEmailsForRecord(TableId: Integer; SystemId: Guid; var ResultSentEmails: Record "Sent Email" temporary)
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the record.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the record.

*ResultSentEmails ([Record "Sent Email" temporary]())* 



### GetSentEmailsForRecord (Method) <a name="GetSentEmailsForRecord"></a> 

 Gets the sent emails related to a record.


#### Syntax
```
procedure GetSentEmailsForRecord(RecordVariant: Variant; var ResultSentEmails: Record "Sent Email" temporary)
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

Source Record.

*ResultSentEmails ([Record "Sent Email" temporary]())* 

The sent email related to a record.

### GetEmailOutboxForRecord (Method) <a name="GetEmailOutboxForRecord"></a> 

 Gets the outbox emails related to a record.


#### Syntax
```
procedure GetEmailOutboxForRecord(RecordVariant: Variant; var ResultEmailOutbox: Record "Email Outbox" temporary)
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

Source Record.

*ResultEmailOutbox ([Record "Email Outbox" temporary]())* 

The outbox emails related to a record.

### OpenSentEmails (Method) <a name="OpenSentEmails"></a> 

 Open the sent emails page for a source record given by its table ID and system ID.


#### Syntax
```
procedure OpenSentEmails(TableId: Integer; SystemId: Guid)
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the record.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the record.

### GetOutboxEmailRecordStatus (Method) <a name="GetOutboxEmailRecordStatus"></a> 

 Gets the outbox email status.


#### Syntax
```
procedure GetOutboxEmailRecordStatus(MessageId: Guid)ResultStatus: Enum "Email Status"
```
#### Parameters
*MessageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The MessageId of the record.

#### Return Value
*[Enum "Email Status"]()*

Email Status of the record.
### AddRelation (Method) <a name="AddRelation"></a> 

 Adds a relation between an email message and a record.


#### Syntax
```
procedure AddRelation(EmailMessage: Codeunit "Email Message"; TableId: Integer; SystemId: Guid; RelationType: Enum "Email Relation Type")
```
#### Parameters
*EmailMessage ([Codeunit "Email Message"]())* 

The email message for which to create the relation.

*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID of the record.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the record.

*RelationType ([Enum "Email Relation Type"]())* 

The relation type to set.

### OnGetTestEmailBody (Event) <a name="OnGetTestEmailBody"></a> 

 Integration event to override the default email body for test messages.
 

#### Syntax
```
[Obsolete('The event will be removed. Subscribe to OnGetBodyForTestEmail instead', '17.3')]
[IntegrationEvent(false, false)]
procedure OnGetTestEmailBody(Connector: Enum "Email Connector"; var Body: Text)
```
#### Parameters
*Connector ([Enum "Email Connector"]())* 

The connector used to send the email message.

*Body ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out param to set the email body to a new value.

### OnShowSource (Event) <a name="OnShowSource"></a> 

 Integration event to show an email source record.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnShowSource(SourceTableId: Integer; SourceSystemId: Guid; var IsHandled: Boolean)
```
#### Parameters
*SourceTableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



*SourceSystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the source record.

*IsHandled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Out parameter to set if the event was handled.

### OnGetBodyForTestEmail (Event) <a name="OnGetBodyForTestEmail"></a> 

 Integration event to override the default email body for test messages.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetBodyForTestEmail(Connector: Enum "Email Connector"; AccountId: Guid; var Body: Text)
```
#### Parameters
*Connector ([Enum "Email Connector"]())* 

The connector used to send the email message.

*AccountId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The account ID of the email account used to send the email message.

*Body ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out param to set the email body to a new value.

### OnAfterSendEmail (Event) <a name="OnAfterSendEmail"></a> 

 Integration event that notifies senders about whether their email was successfully sent in the background.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterSendEmail(MessageId: Guid; Status: Boolean)
```
#### Parameters
*MessageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email in the queue.

*Status ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the message was successfully sent.

### OnFindRelatedAttachments (Event) <a name="OnFindRelatedAttachments"></a> 

 Integration event to get the names and IDs of attachments related to a source record.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnFindRelatedAttachments(SourceTableId: Integer; SourceSystemID: Guid; var EmailRelatedAttachments: Record "Email Related Attachment")
```
#### Parameters
*SourceTableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table number of the source record.

*SourceSystemID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the source record.

*EmailRelatedAttachments ([Record "Email Related Attachment"]())* 

Out parameter to return attachments related to the source record.

### OnGetAttachment (Event) <a name="OnGetAttachment"></a> 

 Integration event that requests an attachment to be added to an email.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetAttachment(AttachmentTableID: Integer; AttachmentSystemID: Guid; MessageID: Guid)
```
#### Parameters
*AttachmentTableID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table number of the attachment.

*AttachmentSystemID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The system ID of the attachment.

*MessageID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email to add an attachment to.

### OnEnqueuedInOutbox (Event) <a name="OnEnqueuedInOutbox"></a> 

 Integration event to implement additional validation after the email message has been enqueued in the email outbox.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnEnqueuedInOutbox(MessageId: Guid)
```
#### Parameters
*MessageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email that has been queued


## Email Message (Codeunit 8904)

 Codeunit to create and manage email messages.
 

### Create (Method) <a name="Create"></a> 

 Creates the email with recipients, subject, and body.
 

#### Syntax
```
procedure Create(ToRecipients: Text; Subject: Text; Body: Text)
```
#### Parameters
*ToRecipients ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The recipient(s) of the email. A string containing the email addresses of the recipients separated by semicolon.

*Subject ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The subject of the email.

*Body ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Raw text that will be used as body of the email.

### Create (Method) <a name="Create"></a> 

 Creates the email with recipients, subject, and body.
 

#### Syntax
```
procedure Create(ToRecipients: Text; Subject: Text; Body: Text; HtmlFormatted: Boolean)
```
#### Parameters
*ToRecipients ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The recipient(s) of the email. A string containing the email addresses of the recipients separated by semicolon.

*Subject ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The subject of the email.

*Body ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The body of the email.

*HtmlFormatted ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether the body is HTML formatted.

### Create (Method) <a name="Create"></a> 

 Creates the email with recipients, subject, and body.
 

#### Syntax
```
procedure Create(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean)
```
#### Parameters
*ToRecipients ([List of [Text]]())* 

The recipient(s) of the email. A list of email addresses the email will be send directly to.

*Subject ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The subject of the email.

*Body ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The body of the email

*HtmlFormatted ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether the body is HTML formatted

### Create (Method) <a name="Create"></a> 

 Creates the email with recipients, subject, and body.
 

#### Syntax
```
procedure Create(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
```
#### Parameters
*ToRecipients ([List of [Text]]())* 

The recipient(s) of the email. A list of email addresses the email will be send directly to.

*Subject ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The subject of the email.

*Body ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The body of the email.

*HtmlFormatted ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether the body is HTML formatted.

*CCRecipients ([List of [Text]]())* 

The CC recipient(s) of the email. A list of email addresses that will be listed as CC.

*BCCRecipients ([List of [Text]]())* 

TThe BCC recipient(s) of the email. A list of email addresses that will be listed as BCC.

### Get (Method) <a name="Get"></a> 

 Gets the email message with the given ID.
 

#### Syntax
```
procedure Get(MessageId: Guid): Boolean
```
#### Parameters
*MessageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the email message to get.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the email was found; otherwise - false.
### GetBody (Method) <a name="GetBody"></a> 

 Gets the body of the email message.
 

#### Syntax
```
procedure GetBody(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The body of the email.
### GetSubject (Method) <a name="GetSubject"></a> 

 Gets the subject of the email message.
 

#### Syntax
```
procedure GetSubject(): Text[2048]
```
#### Return Value
*[Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The subject of the email.
### IsBodyHTMLFormatted (Method) <a name="IsBodyHTMLFormatted"></a> 

 Checks if the email body is formatted in HTML.
 

#### Syntax
```
procedure IsBodyHTMLFormatted(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the email body is formatted in HTML; otherwise - false.
### GetId (Method) <a name="GetId"></a> 

 Gets the ID of the email message.
 

#### Syntax
```
procedure GetId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID of the email.
### GetRecipients (Method) <a name="GetRecipients"></a> 

 Gets the recipents of a certain type of the email message.
 

#### Syntax
```
procedure GetRecipients(RecipientType: Enum "Email Recipient Type"; var Recipients: list of [Text])
```
#### Parameters
*RecipientType ([Enum "Email Recipient Type"]())* 

Specifies the type of the recipients.

*Recipients ([list of [Text]]())* 

Out parameter filled with the recipients' email addresses.

### AddAttachment (Method) <a name="AddAttachment"></a> 

 Adds a file attachment to the email message.
 

#### Syntax
```
procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentBase64: Text)
```
#### Parameters
*AttachmentName ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the file attachment.

*ContentType ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Content Type of the file attachment.

*AttachmentBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64 text representation of the attachment.

### AddAttachment (Method) <a name="AddAttachment"></a> 

 Adds a file attachment to the email message.
 

#### Syntax
```
procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentStream: InStream)
```
#### Parameters
*AttachmentName ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the file attachment.

*ContentType ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Content Type of the file attachment.

*AttachmentStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The instream of the attachment.

### Attachments_DeleteContent (Method) <a name="Attachments_DeleteContent"></a> 

 Deletes the contents of the currently selected attachment.
 

#### Syntax
```
procedure Attachments_DeleteContent(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if contents was successfully deleted, otherwise false.
### Attachments_First (Method) <a name="Attachments_First"></a> 

 Finds the first attachment of the email message.
 

#### Syntax
```
procedure Attachments_First(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there is any attachment; otherwise - false.
### Attachments_Next (Method) <a name="Attachments_Next"></a> 

 Finds the next attachment of the email message.
 

#### Syntax
```
procedure Attachments_Next(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID of the next attachment if it was found; otherwise - 0.
### Attachments_GetName (Method) <a name="Attachments_GetName"></a> 

 Gets the name of the current attachment.
 

#### Syntax
```
procedure Attachments_GetName(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the current attachment.
### Attachments_GetContent (Method) <a name="Attachments_GetContent"></a> 

 Gets the content of the current attachment.
 

#### Syntax
```
procedure Attachments_GetContent(var AttachmentStream: InStream)
```
#### Parameters
*AttachmentStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Out parameter with the content of the current attachment.

### Attachments_GetContentBase64 (Method) <a name="Attachments_GetContentBase64"></a> 

 Gets the content of the current attachment in Base64 encoding.
 

#### Syntax
```
procedure Attachments_GetContentBase64(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The content of the current attachment in Base64 encoding.
### Attachments_GetContentType (Method) <a name="Attachments_GetContentType"></a> 

 Gets the content type of the current attachment.
 

#### Syntax
```
procedure Attachments_GetContentType(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The content type of the current attachment.
### Attachments_GetContentId (Method) <a name="Attachments_GetContentId"></a> 

 Gets the content ID of the current attachment.
 

This value is filled only if the attachment is inline the email body.

#### Syntax
```
procedure Attachments_GetContentId(): Text[40]
```
#### Return Value
*[Text[40]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The content ID of the current attachment.
### Attachments_GetLength (Method) <a name="Attachments_GetLength"></a> 

 Gets the content length of the current attachment.
 

#### Syntax
```
procedure Attachments_GetLength(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The content length of the current attachment.
### Attachments_IsInline (Method) <a name="Attachments_IsInline"></a> 

 Checks if the attachment is inline the message body.
 

#### Syntax
```
procedure Attachments_IsInline(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the attachment is inline the message body; otherwise - false.
### OnGetAttachmentContent (Event) <a name="OnGetAttachmentContent"></a> 

 Integration event to provide the stream of data for a given MediaID. If attachment content has been deleted, this event makes it possible to provide
 the data from elsewhere.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetAttachmentContent(MediaID: Guid; var InStream: Instream; var Handled: Boolean)
```
#### Parameters
*MediaID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

Id of the underlying media field that contains the attachment data.

*InStream ([Instream]())* 

Stream to that should pointed to the attachment data.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Was the attachment content added to the stream.


## Email Scenario (Codeunit 8893)

 Provides functionality to work with email scenarios.
 

### GetDefaultEmailAccount (Method) <a name="GetDefaultEmailAccount"></a> 

 Gets the default email account.
 

#### Syntax
```
procedure GetDefaultEmailAccount(var EmailAccount: Record "Email Account"): Boolean
```
#### Parameters
*EmailAccount ([Record "Email Account"]())* 

Out parameter holding information about the default email account.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an account for the the default scenario was found; otherwise - false.
### GetEmailAccount (Method) <a name="GetEmailAccount"></a> 

 Gets the email account used by the given email scenario.
 If the no account is defined for the provided scenario, the default account (if defined) will be returned.
 

#### Syntax
```
procedure GetEmailAccount(Scenario: Enum "Email Scenario"; var EmailAccount: Record "Email Account"): Boolean
```
#### Parameters
*Scenario ([Enum "Email Scenario"]())* 

The scenario to look for.

*EmailAccount ([Record "Email Account"]())* 

Out parameter holding information about the email account.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an account for the specified scenario was found; otherwise - false.
### SetDefaultEmailAccount (Method) <a name="SetDefaultEmailAccount"></a> 

 Sets a default email account.
 

#### Syntax
```
procedure SetDefaultEmailAccount(EmailAccount: Record "Email Account")
```
#### Parameters
*EmailAccount ([Record "Email Account"]())* 

The email account to use.

### SetEmailAccount (Method) <a name="SetEmailAccount"></a> 

 Sets an email account to be used by the given email scenario.
 

#### Syntax
```
procedure SetEmailAccount(Scenario: Enum "Email Scenario"; EmailAccount: Record "Email Account")
```
#### Parameters
*Scenario ([Enum "Email Scenario"]())* 

The scenario for which to set an email account.

*EmailAccount ([Record "Email Account"]())* 

The email account to use.

### UnassignScenario (Method) <a name="UnassignScenario"></a> 

 Unassign an email scenario. The scenario will then use the default email account.
 

#### Syntax
```
procedure UnassignScenario(Scenario: Enum "Email Scenario")
```
#### Parameters
*Scenario ([Enum "Email Scenario"]())* 

The scenario to unassign.


## Email Test Mail (Codeunit 8887)

 Sends a test email to a specified account.
 


## Email Accounts (Page 8887)

 Lists all of the registered email accounts
 

### GetAccount (Method) <a name="GetAccount"></a> 

 Gets the selected email account.
 

#### Syntax
```
procedure GetAccount(var Account: Record "Email Account")
```
#### Parameters
*Account ([Record "Email Account"]())* 

The selected email account

### SetAccount (Method) <a name="SetAccount"></a> 

 Sets an email account to be selected.
 

#### Syntax
```
procedure SetAccount(var Account: Record "Email Account")
```
#### Parameters
*Account ([Record "Email Account"]())* 

The email account to be initially selected on the page

### EnableLookupMode (Method) <a name="EnableLookupMode"></a> 

 Enables the lookup mode on the page.
 

#### Syntax
```
procedure EnableLookupMode()
```

## Email Account Wizard (Page 8886)

 Step by step guide for adding a new email account in Business Central
 


## Email Activities (Page 8885)

 Provides information about the status of the emails.
 


## Email Relation Picker (Page 8910)

## Email Editor (Page 13)

 A page to create, edit and send e-mails.
 


## Email Outbox (Page 8882)

 Displays information about email that are queued for sending.
 


## Email Viewer (Page 12)

 A page to view sent emails.
 


## Sent Emails (Page 8883)

 Provides an overview of all e-mail that were sent out.
 


## Email Attachments (Page 8889)

## Email Related Attachments (Page 8890)

 Displays a list of related attachments to an email.
 


## Email Scenario Setup (Page 8893)

 Page is used to display email scenarios usage by email accounts.
 


## Email Scenarios FactBox (Page 8895)

 Lists of all scenarios assigned to an account.
 


## Email Scenarios for Account (Page 8894)

 Displays the scenarios that could be linked to a provided e-mail account.
 


## Email User-Specified Address (Page 8884)

 A page to enter an email address.
 

### GetEmailAddress (Method) <a name="GetEmailAddress"></a> 

 Gets the email address(es) that has been entered.
 

#### Syntax
```
procedure GetEmailAddress(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Email address(es)
### SetEmailAddress (Method) <a name="SetEmailAddress"></a> 

 Sets the inital value to be displayed.
 

#### Syntax
```
procedure SetEmailAddress(Address: Text)
```
#### Parameters
*Address ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to be prefilled


## Email Connector (Enum 8889)

 Enum that holds all of the available email connectors.
 


## Email Relation Type (Enum 8908)

 Represent the type of relation between an email and a source record.
 

### Primary Source (value: 0)


 Primary source of an email. There should only be one primary source for an email.
 

### Related Entity (value: 1)


 Related entity of an email. An email can have many record relations of this type.
 


## Email Action (Enum 8891)

 Defines the action that the user can take when open an email message in the editor modally.
 

### Saved As Draft (value: 0)


 The email was saved as draft.
 

### Discarded (value: 1)


 The email was discarded.
 

### Sent (value: 2)


 The email was sent.
 


## Email Status (Enum 8888)

 Specifies the status of an email when it is in the outbox.
 

###   (value: 0)


 An uninitialized email.
 

### Draft (value: 1)


 An email waiting to be queued up for sending.
 

### Queued (value: 2)


 An email queued up and waiting to be processed.
 

### Processing (value: 3)


 An email that is currently being processed and sent.
 

### Failed (value: 4)


 An email that had an error occur during processing.
 


## Email Recipient Type (Enum 8901)

 Specifies the type of an email recipient.
 

### To (value: 0)


 Recipient type 'To'.
 

### Cc (value: 1)


 Recipient type 'Cc'.
 

### Bcc (value: 3)


 Recipient type 'Bcc'.
 


## Email Scenario (Enum 8890)

 Email scenarios.
 Used to decouple email accounts from sending emails.
 

### Default (value: 0)


 The default email scenario.
 Used in the cases where no other scenario is defined.
 

