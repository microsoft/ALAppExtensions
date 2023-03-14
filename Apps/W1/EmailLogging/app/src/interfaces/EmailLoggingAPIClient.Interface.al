interface "Email Logging API Client"
{
    Access = Internal;

    procedure GetMessages(AccessToken: Text; UserEmail: Text; MaxCount: Integer; var MessagesJsonObject: JsonObject);
    procedure DeleteMessage(AccessToken: Text; UserEmail: Text; MessageId: Text);
    procedure ArchiveMessage(AccessToken: Text; UserEmail: Text; SourceMessageId: Text; var TargetMessageJsonObject: JsonObject);
}