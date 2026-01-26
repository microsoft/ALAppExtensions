namespace Microsoft.CRM.EmailLoggin;

interface "Email Logging API Client"
{
    Access = Internal;

    procedure GetMessages(AccessToken: SecretText; UserEmail: Text; MaxCount: Integer; var MessagesJsonObject: JsonObject);
    procedure DeleteMessage(AccessToken: SecretText; UserEmail: Text; MessageId: Text);
    procedure ArchiveMessage(AccessToken: SecretText; UserEmail: Text; SourceMessageId: Text; var TargetMessageJsonObject: JsonObject);
}