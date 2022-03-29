interface "Email Logging Message"
{
    Access = Internal;

    procedure GetId(): Text;
    procedure GetInternetMessageId(): Text;
    procedure GetSender(): Text;
    procedure GetToAndCcRecipients(): List of [Text];
    procedure GetToRecipients(): List of [Text];
    procedure GetCcRecipients(): List of [Text];
    procedure GetSubject(): Text;
    procedure GetWebLink(): Text;
    procedure GetSentDateTime(): DateTime;
    procedure GetReceivedDateTime(): DateTime;
    procedure GetIsDraft(): Boolean;
    procedure IsInitialized(): Boolean;
    procedure Initialize(JsonObject: JsonObject);
}